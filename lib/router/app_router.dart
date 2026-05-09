import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona_storage.dart';
import 'package:apartment_manager/features/announcements/presentation/announcement_detail_screen.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/screens/login_placeholder_screen.dart';
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
import 'package:apartment_manager/features/setup/presentation/account_role_screen.dart';
import 'package:apartment_manager/features/setup/presentation/building_setup_wizard_screen.dart';
import 'package:apartment_manager/features/setup/presentation/resident_invite_placeholder_screen.dart';
import 'package:apartment_manager/features/splash/presentation/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(sessionRefreshNotifierProvider);

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
        builder: (context, state) => const LoginPlaceholderScreen(),
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
        path: '/issues/create',
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
        path: '/setup/account-type',
        builder: (context, state) => const AccountRoleScreen(),
      ),
      GoRoute(
        path: '/setup/resident-invite',
        builder: (context, state) => const ResidentInvitePlaceholderScreen(),
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
      if (location == '/issues/new') {
        return '/issues/create';
      }
      if (location == '/splash') {
        return null;
      }

      final localAsync = ref.read(localSessionProvider);
      if (localAsync.isLoading) {
        return null;
      }

      final local = localAsync.maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );

      if (local != null && location == '/onboarding') {
        return '/home';
      }

      final isLogin = location == '/login';
      final isOnboarding = location == '/onboarding';
      final isAccountType = location == '/setup/account-type';
      final isResidentInvite = location == '/setup/resident-invite';
      final isSetupWizard = location == '/setup/wizard';
      final isDemoRole = location == '/demo-role';

      if (!Env.demoMode && isDemoRole) {
        return '/home';
      }

      if (local == null) {
        final allowedUnauth = isLogin ||
            isOnboarding ||
            isAccountType ||
            isResidentInvite ||
            isSetupWizard;
        return allowedUnauth ? null : '/setup/account-type';
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

      if (isLogin) {
        return '/home';
      }

      return null;
    },
  );
});
