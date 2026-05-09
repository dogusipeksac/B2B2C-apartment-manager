import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/widgets/error_view.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/features/home/presentation/manager_home_view.dart';
import 'package:apartment_manager/features/home/presentation/resident_home_shell.dart';
import 'package:apartment_manager/features/superadmin/presentation/superadmin_home_view.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root after login: demo persona chooses manager vs resident shell; prod uses
/// local session to pick manager vs resident UI.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final demo = Env.demoMode;

    if (!demo) {
      final sessionAsync = ref.watch(localSessionProvider);
      return sessionAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (Object error, StackTrace stackTrace) {
          debugPrint(
            'HomeScreen: session load failed (${error.runtimeType})',
          );
          return Scaffold(
            body: ErrorView(message: l10n.errorGeneric),
          );
        },
        data: (session) {
          if (session != null && session.role == UserRole.superAdmin) {
            return const SuperAdminHomeView();
          }

          final isManager = session != null &&
              session.role == UserRole.buildingAdmin &&
              session.buildingId != null &&
              session.buildingId!.isNotEmpty;

          if (isManager) {
            return const ManagerHomeView();
          }

          final profileAsync = ref.watch(currentProfileProvider);
          return profileAsync.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stackTrace) {
              debugPrint(
                'HomeScreen: profile load failed (${error.runtimeType})',
              );
              return ResidentHomeShell(
                displayName: session?.fullName ?? '',
                useDemoData: false,
                lockDemoModules: true,
                buildingName: session?.buildingName,
              );
            },
            data: (Profile? profile) {
              final name = profile?.fullName ?? session?.fullName ?? '';
              return ResidentHomeShell(
                displayName: name,
                useDemoData: false,
                lockDemoModules: true,
                buildingName: session?.buildingName,
              );
            },
          );
        },
      );
    }

    final profileAsync = ref.watch(currentProfileProvider);
    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) {
        debugPrint(
          'HomeScreen: profile load failed (${error.runtimeType})',
        );
        return Scaffold(
          body: ErrorView(message: l10n.errorGeneric),
        );
      },
      data: (Profile? profile) {
        final name = profile?.fullName ?? '';

        final personaAsync = ref.watch(demoPersonaProvider);
        return personaAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Scaffold(
            body: ErrorView(message: l10n.errorGeneric),
          ),
          data: (DemoPersona? persona) {
            if (persona == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/demo-role');
                }
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (persona == DemoPersona.superAdmin) {
              return SuperAdminHomeView(
                onSwitchPersona: () async {
                  await ref.read(demoPersonaProvider.notifier).choose(
                        DemoPersona.manager,
                      );
                },
              );
            }
            if (persona == DemoPersona.manager) {
              return ManagerHomeView(
                onSwitchToResident: () async {
                  await ref.read(demoPersonaProvider.notifier).choose(
                        DemoPersona.resident,
                      );
                },
              );
            }
            return ResidentHomeShell(
              displayName: name,
              useDemoData: true,
            );
          },
        );
      },
    );
  }
}
