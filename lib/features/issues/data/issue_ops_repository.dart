import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/issues/data/issue_mapper.dart';
import 'package:apartment_manager/features/issues/domain/create_issue_input.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Issues CRUD via Edge Function (device session, service role).
class IssueOpsRepository {
  IssueOpsRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const _urlPath = '/functions/v1/issue_ops';

  Future<List<IssueUi>> listIssues(LocalSession session) async {
    final body = await _post(session, <String, dynamic>{'action': 'list'});
    final list = body['issues'];
    if (list is! List<dynamic>) {
      return [];
    }
    return list.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
      return issueUiFromWire(m);
    }).toList();
  }

  Future<IssueUi?> getIssue(LocalSession session, String issueId) async {
    final body = await _post(session, <String, dynamic>{
      'action': 'get',
      'issue_id': issueId,
    });
    final issue = body['issue'];
    if (issue is! Map) {
      return null;
    }
    final m = Map<String, dynamic>.from(issue);
    var comments = commentsFromWire(body['comments'] as List<dynamic>?);
    // Fallback: comments nested on issue payload (forward-compat).
    if (comments.isEmpty && m['comments'] is List<dynamic>) {
      comments = commentsFromWire(m['comments'] as List<dynamic>?);
    }
    return issueUiFromWire(m, comments: comments);
  }

  Future<String> createIssue(
    LocalSession session,
    CreateIssueInput input,
  ) async {
    final body = await _post(session, <String, dynamic>{
      'action': 'create',
      'title': input.title.trim(),
      'description': input.description.trim(),
      'category': categoryWireValue(input.category),
      'priority': priorityWireValue(input.priority),
      'location_code': input.locationCode,
    });
    return body['issue_id'] as String? ?? '';
  }

  Future<void> updateStatus(
    LocalSession session, {
    required String issueId,
    required IssueUiStatus status,
    String? note,
  }) async {
    final body = await _post(session, <String, dynamic>{
      'action': 'update_status',
      'issue_id': issueId,
      'status': statusWireValue(status),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
    // Comment saved server-side; caller should invalidate detail provider.
    if (body['comment'] == null && note != null && note.trim().isNotEmpty) {
      // Legacy deploy without comment response — still ok.
    }
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
          code: 'issue_ops_not_deployed',
        );
      }
      final body = _bodyMap(rawData);
      if (status == 404 && body.isEmpty) {
        throw const AppException.validation(
          code: 'issue_ops_not_deployed',
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
    // Supabase gateway JWT rejection (issue_ops verify_jwt must be false).
    final gatewayCode = body['code'] as String?;
    if (status == 401 &&
        gatewayCode != null &&
        gatewayCode.contains('JWT')) {
      throw const AppException.validation(code: 'issue_ops_not_deployed');
    }

    if (status >= 500) {
      throw AppException.server(code: body['error'] as String?);
    }
    if (status == 401 || status == 403) {
      final err = body['error'] as String?;
      throw AppException.auth(code: err);
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

final issueOpsRepositoryProvider = Provider<IssueOpsRepository>(
  (ref) => IssueOpsRepository(dio: ref.watch(dioProvider)),
);
