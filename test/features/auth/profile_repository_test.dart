import 'package:apartment_manager/features/auth/data/profile_repository.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  FakeProfileRemoteDataSource({
    Map<String, dynamic>? getRowResult,
    Map<String, dynamic>? upsertResult,
  })  : _getRowResult = getRowResult,
        _upsertResult = upsertResult;

  final Map<String, dynamic>? _getRowResult;
  final Map<String, dynamic>? _upsertResult;

  @override
  Future<Map<String, dynamic>?> getProfileRow(String userId) async {
    return _getRowResult;
  }

  @override
  Future<Map<String, dynamic>> upsertProfileRow(
    Map<String, dynamic> row,
  ) async {
    return _upsertResult ?? row;
  }

  @override
  Future<void> updateNotificationToken({
    required String userId,
    required String token,
  }) async {}
}

void main() {
  test('getProfile(userId) → Profile döner', () async {
    final repo = SupabaseProfileRepository(
      remoteDataSource: FakeProfileRemoteDataSource(
        getRowResult: {
          'id': 'u1',
          'fullName': 'Ada Lovelace',
          'phone': null,
          'email': 'ada@example.com',
          'avatarUrl': null,
          'language': 'tr',
        },
      ),
    );

    final result = await repo.getProfile('u1');
    expect(
      result,
      const Profile(
        id: 'u1',
        fullName: 'Ada Lovelace',
        language: 'tr',
        email: 'ada@example.com',
      ),
    );
  });

  test('upsertProfile → başarılı', () async {
    final repo = SupabaseProfileRepository(
      remoteDataSource: FakeProfileRemoteDataSource(
        upsertResult: {
          'id': 'u1',
          'fullName': 'Ada Lovelace',
          'phone': null,
          'email': 'ada@example.com',
          'avatarUrl': null,
          'language': 'tr',
        },
      ),
    );

    const profile = Profile(
      id: 'u1',
      fullName: 'Ada Lovelace',
      language: 'tr',
      email: 'ada@example.com',
    );

    final result = await repo.upsertProfile(profile);
    expect(result, profile);
  });
}
