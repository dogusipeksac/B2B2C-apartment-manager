import 'dart:async';

import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:apartment_manager/features/auth/presentation/screens/home_placeholder_screen.dart';
import 'package:apartment_manager/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:apartment_manager/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:apartment_manager/features/splash/presentation/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionStream = ref.watch(sessionStreamProvider);
  final refreshListenable = GoRouterRefreshStream(sessionStream);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const EmailEntryScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final identifier = state.uri.queryParameters['identifier'] ?? '';
          final channelRaw = state.uri.queryParameters['channel'] ?? 'email';
          final channel =
              channelRaw == 'phone' ? OtpChannel.phone : OtpChannel.email;
          return OtpVerificationScreen(
            identifier: identifier,
            channel: channel,
          );
        },
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePlaceholderScreen(),
      ),
    ],
    redirect: (context, state) async {
      final location = state.matchedLocation;
      if (location == '/splash') {
        return null;
      }

      final sessionAsync = ref.read(currentSessionProvider);
      if (sessionAsync.isLoading) {
        return null;
      }

      final session = sessionAsync.maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
      final isLogin = location == '/login';
      final isVerify = location == '/verify-otp';
      final isProfileSetup = location == '/profile-setup';

      if (session == null) {
        return (isLogin || isVerify) ? null : '/login';
      }

      Profile? profile;
      try {
        profile = await ref.read(currentProfileProvider.future);
      } on Object catch (e, st) {
        if (kDebugMode) {
          debugPrint('router redirect: currentProfileProvider failed: $e');
          debugPrintStack(stackTrace: st);
        }
        // If profile lookup fails, allow user to proceed to profile setup
        // instead of blocking navigation.
        return isProfileSetup ? null : '/profile-setup';
      }
      final fullName = profile?.fullName.trim() ?? '';
      final profileComplete = fullName.isNotEmpty;

      if (!profileComplete) {
        return isProfileSetup ? null : '/profile-setup';
      }

      if (isLogin || isVerify || isProfileSetup) {
        return '/home';
      }

      return null;
    },
  );
});
