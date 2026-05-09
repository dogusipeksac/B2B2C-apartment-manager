import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona_storage.dart';
import 'package:apartment_manager/features/announcements/presentation/announcement_detail_screen.dart';
import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:apartment_manager/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:apartment_manager/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:apartment_manager/features/demo/presentation/demo_role_screen.dart';
import 'package:apartment_manager/features/dues/presentation/dues_detail_screen.dart';
import 'package:apartment_manager/features/dues/presentation/payment_checkout_screen.dart';
import 'package:apartment_manager/features/dues/presentation/payment_success_screen.dart';
import 'package:apartment_manager/features/home/presentation/home_screen.dart';
import 'package:apartment_manager/features/issues/presentation/issue_create_screen.dart';
import 'package:apartment_manager/features/issues/presentation/issue_detail_screen.dart';
import 'package:apartment_manager/features/issues/presentation/issues_kanban_screen.dart';
import 'package:apartment_manager/features/manager/presentation/expense_new_screen.dart';
import 'package:apartment_manager/features/manager/presentation/invite_resident_screen.dart';
import 'package:apartment_manager/features/manager/presentation/periods_screen.dart';
import 'package:apartment_manager/features/manager/presentation/units_screen.dart';
import 'package:apartment_manager/features/onboarding/presentation/onboarding_screen.dart';
import 'package:apartment_manager/features/setup/presentation/building_setup_wizard_screen.dart';
import 'package:apartment_manager/features/setup/presentation/invite_code_screen.dart';
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
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
        path: '/demo-role',
        builder: (context, state) => const DemoRoleScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/invoice/:id',
        builder: (context, state) => DuesDetailScreen(
          invoiceId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/payment/checkout',
        builder: (context, state) {
          final id = state.uri.queryParameters['invoice'] ?? '';
          return PaymentCheckoutScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: '/payment/success',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: '/announcements/:id',
        builder: (context, state) => AnnouncementDetailScreen(
          announcementId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/issues/new',
        builder: (context, state) => const IssueCreateScreen(),
      ),
      GoRoute(
        path: '/issues/kanban',
        builder: (context, state) => const IssuesKanbanScreen(),
      ),
      GoRoute(
        path: '/issues/:id',
        builder: (context, state) => IssueDetailScreen(
          issueId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/setup/invite',
        builder: (context, state) => const InviteCodeScreen(),
      ),
      GoRoute(
        path: '/setup/wizard',
        builder: (context, state) => const BuildingSetupWizardScreen(),
      ),
      GoRoute(
        path: '/manager/units',
        builder: (context, state) => const UnitsScreen(),
      ),
      GoRoute(
        path: '/manager/invite',
        builder: (context, state) => const InviteResidentScreen(),
      ),
      GoRoute(
        path: '/manager/periods',
        builder: (context, state) => const PeriodsScreen(),
      ),
      GoRoute(
        path: '/manager/expense/new',
        builder: (context, state) => const ExpenseNewScreen(),
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

      if (session != null && location == '/onboarding') {
        return '/home';
      }

      final isLogin = location == '/login';
      final isVerify = location == '/verify-otp';
      final isProfileSetup = location == '/profile-setup';
      final isOnboarding = location == '/onboarding';
      final isDemoRole = location == '/demo-role';

      if (!Env.demoMode && isDemoRole) {
        return '/home';
      }

      if (session == null) {
        return (isLogin || isVerify || isOnboarding) ? null : '/login';
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

      if (Env.demoMode && !isDemoRole) {
        final persona = await DemoPersonaStorage.read();
        if (persona == null) {
          return '/demo-role';
        }
      }

      if (isDemoRole && Env.demoMode) {
        final persona = await DemoPersonaStorage.read();
        if (persona != null) {
          return '/home';
        }
        return null;
      }

      if (isLogin || isVerify || isProfileSetup) {
        return '/home';
      }

      return null;
    },
  );
});
