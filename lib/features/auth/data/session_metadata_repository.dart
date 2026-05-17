import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hydrates session UI labels via Edge (service role); bypasses client RLS.
class SessionMetadataRepository {
  SessionMetadataRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<String?> fetchBuildingName(LocalSession session) async {
    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      return null;
    }

    final url = '${Env.supabaseUrl}/functions/v1/session_metadata';
    final response = await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
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
    final raw = response.data;
    final body = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    if (status == 200 &&
        body['success'] == true &&
        body['building_name'] is String) {
      final n = (body['building_name'] as String).trim();
      return n.isEmpty ? null : n;
    }

    return null;
  }

  /// Returns false when the server rejects device_id + session_token.
  Future<bool> isSessionValid(LocalSession session) async {
    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      return false;
    }

    final url = '${Env.supabaseUrl}/functions/v1/session_metadata';
    try {
      final response = await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{
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
      if (status == 401 || status == 404) {
        return false;
      }
      if (status == 200) {
        final raw = response.data;
        final body = raw is Map<String, dynamic>
            ? raw
            : raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};
        return body['success'] == true;
      }
      return true;
    } on Object {
      return true;
    }
  }
}

final sessionMetadataRepositoryProvider = Provider<SessionMetadataRepository>(
  (ref) => SessionMetadataRepository(dio: ref.watch(dioProvider)),
);
