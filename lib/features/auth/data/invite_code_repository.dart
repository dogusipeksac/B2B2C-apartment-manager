import 'dart:io';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/auth/domain/code_preview.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Normalizes invite codes (matches Edge Function rules).
String normalizeInviteCode(String raw) {
  return raw.trim().toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
}

/// Result of Edge `redeem_code` with `probe: true` (read-only for resume UI).
class InviteProbeResult {
  const InviteProbeResult({
    required this.wouldResume,
    this.buildingName,
    this.unitLabel,
  });

  final bool wouldResume;
  final String? buildingName;
  final String? unitLabel;
}

typedef AdminInviteProbeResult = InviteProbeResult;
typedef ResidentInviteProbeResult = InviteProbeResult;

/// Validates invite codes via anon Supabase reads and redeems via Edge
/// Function.
class InviteCodeRepository {
  InviteCodeRepository({
    required SupabaseClient client,
    required Dio dio,
  })  : _client = client,
        _dio = dio,
        _disabled = false;

  InviteCodeRepository.disabled({Dio? dio})
      : _client = null,
        _dio = dio ?? Dio(),
        _disabled = true;

  final SupabaseClient? _client;
  final Dio _dio;
  final bool _disabled;

  Future<CodePreview?> validateCode(String code) async {
    if (_disabled) {
      return null;
    }
    final normalized = normalizeInviteCode(code);
    if (normalized.length < 4) {
      return null;
    }
    try {
      final data = await _client!
          .from('invite_codes')
          .select(
            'code_type, building_id, unit_id, '
            'buildings(name, address, city, district), '
            'units(block, door_number, floor)',
          )
          .eq('code', normalized)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      final type =
          InviteCodeType.fromWire(data['code_type'] as String? ?? 'unit');
      final buildings = data['buildings'];
      final units = data['units'];

      String? buildingName;
      String? address;
      if (buildings is Map<String, dynamic>) {
        buildingName = buildings['name'] as String?;
        final parts = <String>[
          if ((buildings['address'] as String?)?.trim().isNotEmpty ?? false)
            buildings['address']! as String,
          if ((buildings['district'] as String?)?.trim().isNotEmpty ?? false)
            buildings['district']! as String,
          if ((buildings['city'] as String?)?.trim().isNotEmpty ?? false)
            buildings['city']! as String,
        ];
        address = parts.isEmpty ? null : parts.join(', ');
      }

      String? unitLabel;
      if (units is Map<String, dynamic>) {
        final block = (units['block'] as String?)?.trim();
        final door = (units['door_number'] as String?)?.trim();
        final floor = units['floor'];
        final floorPart = floor == null ? '' : '$floor. kat · ';
        if (block != null && block.isNotEmpty) {
          unitLabel =
              '$floorPart$block · ${door ?? '-'}';
        } else if (door != null && door.isNotEmpty) {
          unitLabel = '$floorPart$door';
        }
      }

      return CodePreview(
        codeType: type,
        buildingName: buildingName,
        unitLabel: unitLabel,
        address: address,
      );
    } on SocketException {
      throw const AppException.network();
    } on PostgrestException {
      throw const AppException.server();
    } on AppException {
      rethrow;
    } on Object {
      throw const AppException.unknown();
    }
  }

  /// Whether an existing registration exists for this invite (manager).
  Future<InviteProbeResult> probeAdminInvite(
    String code,
    String deviceId,
  ) =>
      _probeInvite(code, deviceId);

  /// Whether an existing registration exists for this unit invite (resident).
  Future<InviteProbeResult> probeResidentInvite(
    String code,
    String deviceId,
  ) =>
      _probeInvite(code, deviceId);

  Future<InviteProbeResult> _probeInvite(
    String code,
    String deviceId,
  ) async {
    if (_disabled) {
      return const InviteProbeResult(wouldResume: false);
    }

    final normalized = normalizeInviteCode(code);
    final url = '${Env.supabaseUrl}/functions/v1/redeem_code';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: <String, dynamic>{
          'code': normalized,
          'device_id': deviceId,
          'probe': true,
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer ${Env.supabaseAnonKey}',
            'apikey': Env.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );

      final status = response.statusCode ?? 0;
      final body = response.data ?? <String, dynamic>{};

      if (status >= 500 ||
          status == 404 ||
          status == 409 ||
          status == 422) {
        return const InviteProbeResult(wouldResume: false);
      }

      if (status == 200 &&
          body['success'] == true &&
          body['probe'] == true) {
        final resume = body['would_resume'] == true;
        final bnRaw = body['building_name'];
        final bn = bnRaw is String ? bnRaw.trim() : '';
        final ulRaw = body['unit_label'];
        final ul = ulRaw is String ? ulRaw.trim() : '';
        return InviteProbeResult(
          wouldResume: resume,
          buildingName: bn.isEmpty ? null : bn,
          unitLabel: ul.isEmpty ? null : ul,
        );
      }

      return const InviteProbeResult(wouldResume: false);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AppException.network();
      }
      return const InviteProbeResult(wouldResume: false);
    } on SocketException {
      throw const AppException.network();
    } on Object {
      return const InviteProbeResult(wouldResume: false);
    }
  }

  Future<LocalSession> redeemCode(
    String code,
    String deviceId, {
    String? fullName,
  }) async {
    if (_disabled) {
      throw const AppException.validation(code: 'demo_mode');
    }

    final normalized = normalizeInviteCode(code);
    final url = '${Env.supabaseUrl}/functions/v1/redeem_code';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: <String, dynamic>{
          'code': normalized,
          'device_id': deviceId,
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer ${Env.supabaseAnonKey}',
            'apikey': Env.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );

      final status = response.statusCode ?? 0;
      final body = response.data ?? <String, dynamic>{};

      if (status >= 500) {
        throw AppException.server(
          code: body['error'] as String?,
        );
      }

      if (status == 404 || status == 409) {
        throw AppException.validation(
          code: body['error'] as String?,
        );
      }

      if (status == 422 || status == 400) {
        throw AppException.validation(
          code: body['error'] as String?,
        );
      }

      if (status == 200 &&
          body['success'] == true &&
          body['role'] is String) {
        final bnRaw = body['building_name'];
        final bn = bnRaw is String ? bnRaw.trim() : '';
        final fnRaw = body['full_name'];
        final fnFromServer = fnRaw is String ? fnRaw.trim() : '';
        final resolvedName = fnFromServer.isNotEmpty
            ? fnFromServer
            : (fullName?.trim().isNotEmpty ?? false)
            ? fullName!.trim()
            : null;
        return LocalSession(
          deviceId: deviceId,
          role: UserRole.fromWire(body['role'] as String),
          savedAt: DateTime.now(),
          buildingId: body['building_id'] as String?,
          unitId: body['unit_id'] as String?,
          profileId: body['profile_id'] as String?,
          fullName: resolvedName,
          sessionToken: body['session_token'] as String?,
          buildingName: bn.isEmpty ? null : bn,
        );
      }

      throw const AppException.unknown();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AppException.network();
      }
      throw const AppException.unknown();
    } on SocketException {
      throw const AppException.network();
    } on Object {
      throw const AppException.unknown();
    }
  }
}

final dioProvider = Provider<Dio>((ref) => Dio());

final inviteCodeRepositoryProvider = Provider<InviteCodeRepository>(
  (ref) {
    if (Env.demoMode) {
      return InviteCodeRepository.disabled();
    }
    return InviteCodeRepository(
      client: supabase,
      dio: ref.watch(dioProvider),
    );
  },
);
