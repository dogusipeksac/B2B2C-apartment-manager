import 'dart:convert';

import 'package:apartment_manager/features/auth/domain/user_role.dart';
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
  }) = _LocalSession;

  factory LocalSession.fromJson(Map<String, dynamic> json) =>
      _$LocalSessionFromJson(json);
}

/// Persists invite-based session under a single secure-storage key (JSON).
class LocalSessionRepository {
  LocalSessionRepository(this._storage);

  static const storageKey = 'local_session';

  final FlutterSecureStorage _storage;

  Future<LocalSession?> load() async {
    final raw = await _storage.read(key: storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return LocalSession.fromJson(map);
    } on Object {
      return null;
    }
  }

  Future<void> save(LocalSession session) async {
    await _storage.write(
      key: storageKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: storageKey);
  }

  Future<bool> hasSession() async {
    final s = await load();
    return s != null;
  }
}
