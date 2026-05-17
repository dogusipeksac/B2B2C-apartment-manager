import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/profile/domain/profile_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile read/update via Edge Function (service role).
class ProfileOpsRepository {
  ProfileOpsRepository({required Dio dio}) : _dio = dio, _disabled = false;

  ProfileOpsRepository.disabled() : _dio = Dio(), _disabled = true;

  final Dio _dio;
  final bool _disabled;

  Future<ProfileDetails> getProfile(LocalSession session) async {
    if (_disabled) {
      return ProfileDetails(
        fullName: session.fullName,
        buildingName: session.buildingName,
        unitLabel: null,
        inviteCode: null,
        profileId: session.profileId,
      );
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final body = await _post(
      session,
      <String, dynamic>{'action': 'get'},
    );

    return _parseDetails(body, session);
  }

  Future<String> updateFullName(
    LocalSession session, {
    required String fullName,
  }) async {
    final trimmed = fullName.trim();
    if (_disabled) {
      return trimmed;
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final body = await _post(
      session,
      <String, dynamic>{
        'action': 'update_name',
        'full_name': trimmed,
      },
    );

    final nameRaw = body['full_name'];
    if (nameRaw is String && nameRaw.trim().isNotEmpty) {
      return nameRaw.trim();
    }
    return trimmed;
  }

  Future<Map<String, dynamic>> _post(
    LocalSession session,
    Map<String, dynamic> data,
  ) async {
    final url = '${Env.supabaseUrl}/functions/v1/profile_ops';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        ...data,
        'device_id': session.deviceId,
        'session_token': session.sessionToken,
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
        code: 'profile_ops_not_deployed',
      );
    }
    final body = _bodyMap(rawData);
    if (status == 404 && body.isEmpty) {
      throw const AppException.validation(
        code: 'profile_ops_not_deployed',
      );
    }

    if (status >= 500) {
      throw AppException.server(code: body['error'] as String?);
    }
    if (status == 401 || status == 403) {
      throw AppException.auth(code: body['error'] as String?);
    }
    if (status == 404 || status == 409 || status == 422 || status == 400) {
      throw AppException.validation(code: _errorCode(body));
    }

    if (status == 200 && body['success'] == false) {
      throw AppException.validation(code: _errorCode(body));
    }

    if (status == 200 && body['success'] == true) {
      return body;
    }

    throw const AppException.unknown();
  }

  ProfileDetails _parseDetails(
    Map<String, dynamic> body,
    LocalSession session,
  ) {
    final fnRaw = body['full_name'];
    final fullName = fnRaw is String && fnRaw.trim().isNotEmpty
        ? fnRaw.trim()
        : session.fullName;

    final bnRaw = body['building_name'];
    final buildingName = bnRaw is String && bnRaw.trim().isNotEmpty
        ? bnRaw.trim()
        : session.buildingName;

    final ulRaw = body['unit_label'];
    final unitLabel = ulRaw is String && ulRaw.trim().isNotEmpty
        ? ulRaw.trim()
        : null;

    final codeRaw = body['invite_code'];
    final inviteCode = codeRaw is String && codeRaw.trim().isNotEmpty
        ? codeRaw.trim()
        : null;

    final pidRaw = body['profile_id'];
    final profileId = pidRaw is String && pidRaw.trim().isNotEmpty
        ? pidRaw.trim()
        : session.profileId;

    return ProfileDetails(
      fullName: fullName,
      buildingName: buildingName,
      unitLabel: unitLabel,
      inviteCode: inviteCode,
      profileId: profileId,
    );
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

  String _errorCode(Map<String, dynamic> body) {
    final raw = body['error'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return 'unknown_backend_response';
  }
}

final profileOpsRepositoryProvider = Provider<ProfileOpsRepository>((ref) {
  if (Env.demoMode) {
    return ProfileOpsRepository.disabled();
  }
  return ProfileOpsRepository(dio: ref.watch(dioProvider));
});
