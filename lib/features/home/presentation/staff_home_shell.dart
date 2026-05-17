import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/features/issues/presentation/issues_list_screen.dart';
import 'package:apartment_manager/features/profile/presentation/profile_home_tab.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation: Ana sayfa + Profil (yönetici ve sistem yöneticisi).
class StaffHomeShell extends ConsumerStatefulWidget {
  const StaffHomeShell({
    required this.homeTab,
    required this.displayName,
    super.key,
  });

  final Widget homeTab;
  final String displayName;

  @override
  ConsumerState<StaffHomeShell> createState() => _StaffHomeShellState();
}

class _StaffHomeShellState extends ConsumerState<StaffHomeShell> {
  int _tabIndex = 0;

  Future<void> _signOut(BuildContext context) async {
    try {
      if (Env.demoMode) {
        await ref.read(demoPersonaProvider.notifier).clear();
      }
      await ref.read(localSessionRepositoryProvider).clear();
      ref.notifyLocalSessionChanged();
      if (!context.mounted) {
        return;
      }
      context.go('/splash');
    } on AppException catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final apart = context.apart;

    final sessionAsync = ref.watch(localSessionProvider);
    final resolvedDisplay = sessionAsync.maybeWhen(
      data: (s) {
        final fn = s?.fullName?.trim();
        if (fn != null && fn.isNotEmpty) {
          return fn;
        }
        return widget.displayName;
      },
      orElse: () => widget.displayName,
    );

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          widget.homeTab,
          const IssuesListScreen(allowCreate: false),
          ProfileHomeTab(
            displayName: resolvedDisplay,
            onSignOut: () => _signOut(context),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.demoNavHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.build_outlined),
            selectedIcon: const Icon(Icons.build),
            label: l10n.demoNavIssues,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.demoNavProfile,
          ),
        ],
      ),
    );
  }
}
