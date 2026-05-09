import 'dart:math';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/manager/data/manager_invite_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin invite lifetime policy (Postgres `invite_codes.admin_redeem_policy`).
enum AdminRedeemPolicy {
  singleUse('single_use'),
  reusable('reusable');

  const AdminRedeemPolicy(this.wireValue);
  final String wireValue;
}

/// Cross-building operations via `superadmin_ops` Edge Function.
class SuperadminRepository {
  SuperadminRepository({required Dio dio}) : _dio = dio, _disabled = false;

  SuperadminRepository.disabled() : _dio = Dio(), _disabled = true;

  final Dio _dio;
  final bool _disabled;

  Future<List<SuperadminBuildingSummary>> listBuildings(
    LocalSession session,
  ) async {
    if (_disabled) {
      return const [
        SuperadminBuildingSummary(
          id: 'demo-b1',
          name: 'Örnek Sitesi A',
          city: 'İstanbul',
          district: 'Kadıköy',
          address: '',
        ),
        SuperadminBuildingSummary(
          id: 'demo-b2',
          name: 'Yeşil Vadi Apartmanı',
          city: 'Ankara',
          district: 'Çankaya',
          address: '',
        ),
      ];
    }

    final body = await _post(session, 'list_buildings');
    final raw = body['buildings'];
    if (raw is! List<dynamic>) {
      throw const AppException.unknown();
    }
    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map<dynamic, dynamic>);
      return SuperadminBuildingSummary(
        id: m['id'] as String? ?? '',
        name: (m['name'] as String?)?.trim() ?? '',
        city: (m['city'] as String?)?.trim() ?? '',
        district: (m['district'] as String?)?.trim() ?? '',
        address: (m['address'] as String?)?.trim() ?? '',
      );
    }).toList();
  }

  Future<List<SuperadminAdminCodeRow>> listAdminCodes(
    LocalSession session,
  ) async {
    if (_disabled) {
      return [
        SuperadminAdminCodeRow(
          id: 'demo-inv-1',
          code: 'DEMO1234',
          status: 'active',
          expiresAt: DateTime.now().add(const Duration(days: 60)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          policy: AdminRedeemPolicy.singleUse,
        ),
      ];
    }

    final body = await _post(session, 'list_admin_codes');
    final raw = body['codes'];
    if (raw is! List<dynamic>) {
      throw const AppException.unknown();
    }
    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map<dynamic, dynamic>);
      DateTime? exp;
      final expRaw = m['expires_at'];
      if (expRaw is String && expRaw.trim().isNotEmpty) {
        exp = DateTime.tryParse(expRaw.trim());
      }
      DateTime? created;
      final cr = m['created_at'];
      if (cr is String && cr.trim().isNotEmpty) {
        created = DateTime.tryParse(cr.trim());
      }
      final polRaw = m['admin_redeem_policy'] as String?;
      final policy = polRaw?.trim() == AdminRedeemPolicy.reusable.wireValue
          ? AdminRedeemPolicy.reusable
          : AdminRedeemPolicy.singleUse;
      return SuperadminAdminCodeRow(
        id: m['id'] as String? ?? '',
        code: m['code'] as String? ?? '',
        status: m['status'] as String? ?? '',
        expiresAt: exp,
        createdAt: created,
        policy: policy,
      );
    }).toList();
  }

  Future<SuperadminCreatedAdminInvite> createAdminInvite(
    LocalSession session, {
    AdminRedeemPolicy policy = AdminRedeemPolicy.singleUse,
  }) async {
    if (_disabled) {
      const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final rnd = Random();
      final buf = StringBuffer();
      for (var i = 0; i < 8; i++) {
        buf.write(alphabet[rnd.nextInt(alphabet.length)]);
      }
      return SuperadminCreatedAdminInvite(
        code: buf.toString(),
        expiresAt: DateTime.now().add(const Duration(days: 90)),
        policy: policy,
      );
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/superadmin_ops';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': 'create_admin_invite',
        'device_id': session.deviceId,
        'session_token': token,
        'admin_redeem_policy': policy.wireValue,
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
    final body = _bodyMap(response.data);
    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(code: _errorCode(body));
    }

    if (status == 200 &&
        body['success'] == true &&
        body['code'] is String) {
      DateTime? exp;
      final expRaw = body['expires_at'];
      if (expRaw is String && expRaw.trim().isNotEmpty) {
        exp = DateTime.tryParse(expRaw.trim());
      }
      final polRaw = body['admin_redeem_policy'] as String?;
      final resolvedPolicy = polRaw?.trim() == AdminRedeemPolicy.reusable.wireValue
          ? AdminRedeemPolicy.reusable
          : AdminRedeemPolicy.singleUse;
      return SuperadminCreatedAdminInvite(
        code: body['code']! as String,
        expiresAt: exp,
        policy: resolvedPolicy,
      );
    }

    throw const AppException.unknown();
  }

  Future<void> revokeAdminCode(
    LocalSession session,
    String code,
  ) async {
    if (_disabled) {
      return;
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/superadmin_ops';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': 'revoke_admin_code',
        'device_id': session.deviceId,
        'session_token': token,
        'code': code,
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
    final body = _bodyMap(response.data);
    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(code: _errorCode(body));
    }

    if (status == 200 && body['success'] == true) {
      return;
    }

    throw const AppException.unknown();
  }

  Future<ManagerInviteListResult> listUnitsForBuilding(
    LocalSession session,
    String buildingId,
  ) async {
    if (_disabled) {
      return ManagerInviteRepository.disabled().listUnits(session);
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/superadmin_ops';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': 'list_units',
        'device_id': session.deviceId,
        'session_token': token,
        'building_id': buildingId,
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
    final body = _bodyMap(rawData);
    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(code: _errorCode(body));
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
        final label = ManagerInviteRepository.formatUnitLabel(
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

  Future<CreatedUnitInvite> createUnitInvite(
    LocalSession session, {
    required String buildingId,
    String? unitId,
  }) async {
    if (_disabled) {
      return ManagerInviteRepository.disabled().createInvite(
        session,
        unitId: unitId,
      );
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/superadmin_ops';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': 'create_unit_invite',
        'device_id': session.deviceId,
        'session_token': token,
        'building_id': buildingId,
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
    final body = _bodyMap(response.data);
    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(code: _errorCode(body));
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

  Future<void> deleteBuilding(
    LocalSession session,
    String buildingId,
  ) async {
    if (_disabled) {
      return;
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/superadmin_ops';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': 'delete_building',
        'device_id': session.deviceId,
        'session_token': token,
        'building_id': buildingId,
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
    final body = _bodyMap(response.data);
    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(code: _errorCode(body));
    }

    if (status == 200 && body['success'] == true) {
      return;
    }

    throw const AppException.unknown();
  }

  Future<Map<String, dynamic>> _post(
    LocalSession session,
    String action,
  ) async {
    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/superadmin_ops';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'action': action,
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
    final body = _bodyMap(response.data);
    _throwIfHttpError(status, body);

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(code: _errorCode(body));
    }

    if (status == 200 && body['success'] == true) {
      return body;
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

  String _errorCode(Map<String, dynamic> body) {
    final raw = body['error'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return 'unknown_backend_response';
  }
}

class SuperadminBuildingSummary {
  const SuperadminBuildingSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.address,
  });

  final String id;
  final String name;
  final String city;
  final String district;
  final String address;
}

class SuperadminAdminCodeRow {
  const SuperadminAdminCodeRow({
    required this.id,
    required this.code,
    required this.status,
    this.expiresAt,
    this.createdAt,
    this.policy = AdminRedeemPolicy.singleUse,
  });

  final String id;
  final String code;
  final String status;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final AdminRedeemPolicy policy;
}

class SuperadminCreatedAdminInvite {
  const SuperadminCreatedAdminInvite({
    required this.code,
    this.expiresAt,
    this.policy = AdminRedeemPolicy.singleUse,
  });

  final String code;
  final DateTime? expiresAt;
  final AdminRedeemPolicy policy;
}

final superadminRepositoryProvider = Provider<SuperadminRepository>(
  (ref) {
    if (Env.demoMode) {
      return SuperadminRepository.disabled();
    }
    return SuperadminRepository(dio: ref.watch(dioProvider));
  },
);
