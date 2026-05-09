import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/widgets/error_view.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/features/home/presentation/manager_home_view.dart';
import 'package:apartment_manager/features/home/presentation/resident_home_shell.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root after login: demo persona chooses manager vs resident shell; prod uses resident + empty repos until wired.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(currentProfileProvider);
    final demo = Env.demoMode;

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

        if (!demo) {
          return ResidentHomeShell(
            displayName: name,
            useDemoData: false,
          );
        }

        final personaAsync = ref.watch(demoPersonaProvider);
        return personaAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Scaffold(
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
