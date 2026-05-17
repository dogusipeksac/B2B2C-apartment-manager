import 'dart:convert';

import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_session.freezed.dart';
part 'local_session.g.dart';

@freezed
abstract class LocalSession with _$LocalSession {
  const factory LocalSession({
    required String deviceId,
    @UserRoleConverter() required UserRole role,
    required DateTime savedAt,
    String? buildingId,
    String? unitId,
    String? profileId,
    String? fullName,
    String? sessionToken,
    /// Cached from finalize or invite APIs for dashboard titles.
    String? buildingName,
    /// When true, session is restored on next app launch (secure storage).
    @Default(true) bool rememberMe,
  }) = _LocalSession;

  factory LocalSession.fromJson(Map<String, dynamic> json) =>
      _$LocalSessionFromJson(json);
}

/// Persists invite-based session under a single secure-storage key (JSON).
class LocalSessionRepository {
  LocalSessionRepository(this._storage);

  static const storageKey = 'local_session';

  final FlutterSecureStorage _storage;

  /// In-memory session when [LocalSession.rememberMe] is false (until app closes).
  LocalSession? _ephemeralSession;

  Future<LocalSession?> load() async {
    if (_ephemeralSession != null) {
      return _ephemeralSession;
    }
    final raw = await _storage.read(key: storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final session = LocalSession.fromJson(map);
      if (!session.rememberMe) {
        return null;
      }
      return session;
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('LocalSessionRepository.load failed: $e');
        debugPrintStack(stackTrace: st);
      }
      return null;
    }
  }

  Future<void> save(LocalSession session) async {
    if (session.rememberMe) {
      _ephemeralSession = null;
      await _storage.write(
        key: storageKey,
        value: jsonEncode(session.toJson()),
      );
    } else {
      _ephemeralSession = session;
      await _storage.delete(key: storageKey);
    }
  }

  Future<void> clear() async {
    _ephemeralSession = null;
    await _storage.delete(key: storageKey);
  }

  Future<bool> hasSession() async {
    final s = await load();
    return s != null;
  }
}
