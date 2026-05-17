import 'package:apartment_manager/core/device/device_id_provider.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/auth/data/session_preferences_storage.dart';
import 'package:apartment_manager/features/auth/data/profile_repository.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifies GoRouter when persisted session changes (save / clear).
class SessionRefreshNotifier extends ChangeNotifier {
  void notifySessionChanged() => notifyListeners();
}

final sessionRefreshNotifierProvider =
    Provider<SessionRefreshNotifier>((ref) {
  final notifier = SessionRefreshNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

final localSessionRepositoryProvider = Provider<LocalSessionRepository>(
  (ref) => LocalSessionRepository(ref.watch(flutterSecureStorageProvider)),
);

/// Cached local invite-based session (null if logged out).
final localSessionProvider = FutureProvider<LocalSession?>((ref) {
  return ref.watch(localSessionRepositoryProvider).load();
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(),
);

/// Remote profile row when [LocalSession.profileId] is set.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final session = await ref.watch(localSessionProvider.future);
  final profileId = session?.profileId;
  if (profileId == null || profileId.isEmpty) {
    return null;
  }
  return ref.watch(profileRepositoryProvider).getProfile(profileId);
});

extension LocalSessionPersistenceRef on WidgetRef {
  /// Call after LocalSessionRepository.save / clear.
  void notifyLocalSessionChanged() {
    invalidate(localSessionProvider);
    invalidate(currentProfileProvider);
    read(sessionRefreshNotifierProvider).notifySessionChanged();
  }

  /// Persists session (secure storage if [rememberMe], else until app closes).
  Future<void> persistLocalSession(
    LocalSession session, {
    required bool rememberMe,
  }) async {
    final deviceId = await read(deviceIdProvider.future);
    await read(localSessionRepositoryProvider).save(
      session.copyWith(
        deviceId: deviceId,
        rememberMe: rememberMe,
        savedAt: DateTime.now(),
      ),
    );
    await SessionPreferencesStorage.saveRememberMeDefault(rememberMe);
    notifyLocalSessionChanged();
  }
}
