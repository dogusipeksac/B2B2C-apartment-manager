import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:apartment_manager/features/auth/data/profile_repository.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotrue/gotrue.dart' hide OtpChannel;

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(),
);

final sessionStreamProvider = Provider<Stream<Session?>>(
  (ref) => ref.watch(authRepositoryProvider).sessionStream(),
);

final currentSessionProvider = StreamProvider<Session?>(
  (ref) => ref.watch(sessionStreamProvider),
);

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(currentSessionProvider).maybeWhen(
        data: (session) => session?.user,
        orElse: () => null,
      );
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return null;
  }

  return ref.watch(profileRepositoryProvider).getProfile(user.id);
});

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);

class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> sendOtp({
    required String identifier,
    required OtpChannel channel,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .sendOtp(identifier: identifier, channel: channel);
      state = const AsyncData(null);
      return true;
    } on AppException catch (e, st) {
      state = AsyncError(e, st);
      return false;
    } on Object catch (e, st) {
      state = AsyncError(const AppException.unknown(), st);
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String identifier,
    required String code,
    required OtpChannel channel,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOtp(identifier: identifier, code: code, channel: channel);
      state = const AsyncData(null);
      return true;
    } on AppException catch (e, st) {
      state = AsyncError(e, st);
      return false;
    } on Object catch (e, st) {
      state = AsyncError(const AppException.unknown(), st);
      return false;
    }
  }
}
