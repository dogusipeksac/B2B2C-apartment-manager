import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/elections/data/election_mapper.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ElectionOpsRepository {
  ElectionOpsRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const _urlPath = '/functions/v1/election_ops';

  Future<List<ElectionUi>> listElections(LocalSession session) async {
    final body = await _post(session, {'action': 'list'});
    final list = body['elections'];
    if (list is! List<dynamic>) {
      return [];
    }
    return list
        .map(
          (raw) => electionUiFromWire(
            Map<String, dynamic>.from(raw as Map<dynamic, dynamic>),
          ),
        )
        .toList();
  }

  Future<ElectionUi?> activeElection(LocalSession session) async {
    final body = await _post(session, {'action': 'active'});
    final election = body['election'];
    if (election == null) {
      return null;
    }
    return electionUiFromWire(
      Map<String, dynamic>.from(election as Map<dynamic, dynamic>),
    );
  }

  Future<ElectionDetailUi?> getElection(
    LocalSession session,
    String electionId,
  ) async {
    final body = await _post(session, {
      'action': 'get',
      'election_id': electionId,
    });
    return electionDetailFromWire(body);
  }

  Future<String> createElection(
    LocalSession session, {
    required String title,
    String? description,
    DateTime? nominationsCloseAt,
    DateTime? closesAt,
  }) async {
    final body = await _post(session, {
      'action': 'create',
      'title': title.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      if (nominationsCloseAt != null)
        'nominations_close_at':
            nominationsCloseAt.toUtc().toIso8601String(),
      if (closesAt != null) 'closes_at': closesAt.toUtc().toIso8601String(),
    });
    return body['election_id'] as String? ?? '';
  }

  Future<void> startElection(LocalSession session, String electionId) async {
    await _post(session, {
      'action': 'start',
      'election_id': electionId,
    });
  }

  Future<void> startVoting(LocalSession session, String electionId) async {
    await _post(session, {
      'action': 'start_voting',
      'election_id': electionId,
    });
  }

  Future<void> closeElection(LocalSession session, String electionId) async {
    await _post(session, {
      'action': 'close',
      'election_id': electionId,
    });
  }

  Future<void> nominate(LocalSession session, String electionId) async {
    await _post(session, {
      'action': 'nominate',
      'election_id': electionId,
    });
  }

  Future<void> vote(
    LocalSession session, {
    required String electionId,
    required String candidateId,
  }) async {
    await _post(session, {
      'action': 'vote',
      'election_id': electionId,
      'candidate_id': candidateId,
    });
  }

  Future<Map<String, dynamic>> _post(
    LocalSession session,
    Map<String, dynamic> data,
  ) async {
    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}$_urlPath';
    try {
      final response = await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{
          ...data,
          'device_id': session.deviceId,
          'session_token': token,
          if (session.profileId != null && session.profileId!.isNotEmpty)
            'profile_id': session.profileId,
          if (session.unitId != null && session.unitId!.isNotEmpty)
            'unit_id': session.unitId,
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer ${Env.supabaseAnonKey}',
            'apikey': Env.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 25),
          receiveTimeout: const Duration(seconds: 25),
          validateStatus: (_) => true,
        ),
      );

      final status = response.statusCode ?? 0;
      final rawData = response.data;
      if (status == 404 &&
          (rawData is String || (rawData is Map && rawData.isEmpty))) {
        throw const AppException.validation(
          code: 'election_ops_not_deployed',
        );
      }
      final body = _bodyMap(rawData);
      if (status == 404 && body.isEmpty) {
        throw const AppException.validation(
          code: 'election_ops_not_deployed',
        );
      }

      _throwIfHttpError(status, body);

      if (status == 200 && body['success'] == false) {
        throw AppException.validation(code: _errorCode(body));
      }

      if (status == 200 && body['success'] == true) {
        return body;
      }

      throw const AppException.unknown();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AppException.network();
      }
      rethrow;
    }
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
    final gatewayCode = body['code'] as String?;
    if (status == 401 &&
        gatewayCode != null &&
        gatewayCode.contains('JWT')) {
      throw const AppException.validation(code: 'election_ops_not_deployed');
    }

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
    final err = body['error'];
    if (err is String && err.isNotEmpty) {
      return err;
    }
    return 'unknown_backend_response';
  }
}

final electionOpsRepositoryProvider = Provider<ElectionOpsRepository>(
  (ref) => ElectionOpsRepository(dio: ref.watch(dioProvider)),
);
