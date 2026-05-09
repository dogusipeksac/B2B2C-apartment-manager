import 'package:apartment_manager/features/auth/data/profile_repository.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';

/// In-memory profile when app runs without Supabase (demo env flag).
class DemoProfileRepository implements ProfileRepository {
  Profile? _profile;

  @override
  Future<Profile?> getProfile(String userId) async => _profile;

  @override
  Future<Profile> upsertProfile(Profile profile) async {
    _profile = profile;
    return profile;
  }

  @override
  Future<void> updateNotificationToken({
    required String userId,
    required String token,
  }) async {
    final existing = _profile;
    if (existing == null) {
      return;
    }
    _profile = existing.copyWith(notificationToken: token);
  }
}
