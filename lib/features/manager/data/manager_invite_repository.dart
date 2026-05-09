import 'dart:math';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads units and creates resident invite codes via Edge Function (service role).
class ManagerInviteRepository {
  ManagerInviteRepository({required Dio dio}) : _dio = dio, _disabled = false;

  ManagerInviteRepository.disabled() : _dio = Dio(), _disabled = true;

  final Dio _dio;
  final bool _disabled;

  static String formatUnitLabel({
    required int? floor,
    required String doorNumber,
    required String block,
  }) {
    final floorPart = floor == null ? '' : '$floor. kat · ';
    final b = block.trim();
    if (b.isNotEmpty) {
      return '$floorPart$b · ${doorNumber.trim()}';
    }
    return '$floorPart${doorNumber.trim()}';
  }

  Future<ManagerInviteListResult> listUnits(LocalSession session) async {
    if (_disabled) {
      return ManagerInviteListResult(
        units: _demoUnits(),
        buildingName: 'Demo Apartman',
      );
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/manager_invite';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': 'list_units',
        'device_id': session.deviceId,
        'session_token': token,
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
    final rawData = response.data;
    if (status == 404 &&
        (rawData is String || (rawData is Map && rawData.isEmpty))) {
      throw const AppException.validation(
        code: 'manager_invite_not_deployed',
      );
    }
    final body = _bodyMap(rawData);
    if (status == 404 && body.isEmpty) {
      throw const AppException.validation(
        code: 'manager_invite_not_deployed',
      );
    }

    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(
        code: _errorCode(body),
      );
    }

    if (status == 200 &&
        body['success'] == true &&
        body['units'] is List<dynamic>) {
      final list = body['units'] as List<dynamic>;
      final bnRaw = body['building_name'];
      final bn = bnRaw is String ? bnRaw.trim() : '';
      final units = list.map((raw) {
        final m = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
        final floor = m['floor'] as int?;
        final door = m['door_number'] as String? ?? '';
        final block = m['block'] as String? ?? '';
        final id = m['id'] as String? ?? '';
        final label = formatUnitLabel(
          floor: floor,
          doorNumber: door,
          block: block,
        );
        final invRaw = m['invite_code'];
        final inviteCode = invRaw is String && invRaw.trim().isNotEmpty
            ? invRaw.trim()
            : null;
        DateTime? inviteExpires;
        final expRaw = m['invite_expires_at'];
        if (expRaw is String && expRaw.trim().isNotEmpty) {
          inviteExpires = DateTime.tryParse(expRaw.trim());
        }
        return ManagerUnitOption(
          id: id,
          floor: floor,
          doorNumber: door,
          block: block,
          label: label,
          inviteCode: inviteCode,
          inviteExpiresAt: inviteExpires,
        );
      }).toList();
      return ManagerInviteListResult(
        units: units,
        buildingName: bn.isEmpty ? null : bn,
      );
    }

    throw const AppException.unknown();
  }

  Future<CreatedUnitInvite> createInvite(
    LocalSession session, {
    String? unitId,
  }) async {
    if (_disabled) {
      const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final rnd = Random();
      final buf = StringBuffer();
      for (var i = 0; i < 5; i++) {
        buf.write(alphabet[rnd.nextInt(alphabet.length)]);
      }
      return CreatedUnitInvite(
        code: buf.toString(),
        unitId: unitId ?? 'demo-u1',
        expiresAt: DateTime.now().add(const Duration(days: 90)),
      );
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/manager_invite';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': 'create_invite',
        'device_id': session.deviceId,
        'session_token': token,
        if (unitId != null && unitId.isNotEmpty) 'unit_id': unitId,
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
    final rawData = response.data;
    if (status == 404 &&
        (rawData is String || (rawData is Map && rawData.isEmpty))) {
      throw const AppException.validation(
        code: 'manager_invite_not_deployed',
      );
    }
    final body = _bodyMap(rawData);
    if (status == 404 && body.isEmpty) {
      throw const AppException.validation(
        code: 'manager_invite_not_deployed',
      );
    }

    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(
        code: _errorCode(body),
      );
    }

    if (status == 200 &&
        body['success'] == true &&
        body['code'] is String &&
        body['unit_id'] is String) {
      DateTime? exp;
      final expRaw = body['expires_at'];
      if (expRaw is String && expRaw.trim().isNotEmpty) {
        exp = DateTime.tryParse(expRaw.trim());
      }
      return CreatedUnitInvite(
        code: body['code']! as String,
        unitId: body['unit_id']! as String,
        expiresAt: exp,
      );
    }

    throw const AppException.unknown();
  }

  Map<String, dynamic> _bodyMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  void _throwIfHttpError(int status, Map<String, dynamic> body) {
    if (status >= 500) {
      throw AppException.server(code: body['error'] as String?);
    }
    if (status == 401 || status == 403) {
      throw AppException.auth(code: body['error'] as String?);
    }
    if (status == 404 || status == 409) {
      throw AppException.validation(code: _errorCode(body));
    }
    if (status == 422 || status == 400) {
      throw AppException.validation(code: _errorCode(body));
    }
  }

  static List<ManagerUnitOption> _demoUnits() {
    ManagerUnitOption u(
      String id,
      int floor,
      String door,
      String block,
      String? code,
    ) {
      return ManagerUnitOption(
        id: id,
        floor: floor,
        doorNumber: door,
        block: block,
        label: formatUnitLabel(
          floor: floor,
          doorNumber: door,
          block: block,
        ),
        inviteCode: code,
        inviteExpiresAt: code != null
            ? DateTime.now().add(const Duration(days: 7))
            : null,
      );
    }

    return [
      u('demo-u1', 6, 'A', '', 'K7P29'),
      u('demo-u2', 6, 'B', '', null),
      u('demo-u3', 6, 'C', '', null),
      u('demo-u4', 5, 'A', '', 'X3N82'),
      u('demo-u5', 5, 'B', '', null),
      u('demo-u6', 5, 'C', '', null),
      u('demo-u7', 4, 'A', '', null),
      u('demo-u8', 4, 'B', '', null),
      u('demo-u9', 4, 'C', '', null),
    ];
  }

  /// Backend JSON `error` field; fallback when Supabase returns HTML/plain.
  String _errorCode(Map<String, dynamic> body) {
    final raw = body['error'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return 'unknown_backend_response';
  }
}

class ManagerInviteListResult {
  const ManagerInviteListResult({
    required this.units,
    this.buildingName,
  });

  final List<ManagerUnitOption> units;
  final String? buildingName;
}

class ManagerUnitOption {
  const ManagerUnitOption({
    required this.id,
    required this.floor,
    required this.doorNumber,
    required this.block,
    required this.label,
    this.inviteCode,
    this.inviteExpiresAt,
  });

  final String id;
  final int? floor;
  final String doorNumber;
  final String block;
  final String label;

  /// Active unit invite code from server, if any.
  final String? inviteCode;
  final DateTime? inviteExpiresAt;
}

class CreatedUnitInvite {
  const CreatedUnitInvite({
    required this.code,
    required this.unitId,
    this.expiresAt,
  });

  final String code;
  final String unitId;
  final DateTime? expiresAt;
}

final managerInviteRepositoryProvider = Provider<ManagerInviteRepository>(
  (ref) {
    if (Env.demoMode) {
      return ManagerInviteRepository.disabled();
    }
    return ManagerInviteRepository(dio: ref.watch(dioProvider));
  },
);
