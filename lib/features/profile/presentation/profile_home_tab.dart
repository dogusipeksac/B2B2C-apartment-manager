import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileHomeTab extends ConsumerWidget {
  const ProfileHomeTab({
    required this.displayName,
    required this.onSignOut,
    super.key,
  });

  final String displayName;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final demo = Env.demoMode;
    final personaAsync = ref.watch(demoPersonaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(l10n.profileMenuTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.homeFeatureSoon)),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.secondary,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isEmpty ? '—' : displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              demo && personaAsync.value == DemoPersona.manager
                                  ? l10n.profileBadgeManager
                                  : l10n.profileBadgeResident,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            label: Text(l10n.demoBuildingHeaderLine),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(l10n.demoInvitePreviewTitle),
              subtitle: Text(l10n.demoInvitePreviewSubtitle),
            ),
          ),
          if (demo)
            personaAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (persona) {
                if (persona == null) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  leading: const Icon(Icons.swap_horiz_outlined),
                  title: Text(
                    persona == DemoPersona.manager
                        ? l10n.profileSwitchToResident
                        : l10n.profileSwitchToManager,
                  ),
                  onTap: () async {
                    await ref.read(demoPersonaProvider.notifier).choose(
                          persona == DemoPersona.manager
                              ? DemoPersona.resident
                              : DemoPersona.manager,
                        );
                  },
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: Text(l10n.setupInviteTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/setup/invite'),
          ),
          ListTile(
            leading: const Icon(Icons.domain_add_outlined),
            title: Text(l10n.setupWizardTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/setup/wizard'),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view_outlined),
            title: Text(l10n.managerUnitsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/manager/units'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize_outlined),
            title: Text(l10n.issuesKanbanTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/issues/kanban'),
          ),
          const Divider(),
          AppButton(
            variant: AppButtonVariant.secondary,
            onPressed: onSignOut,
            child: Text(l10n.signOut),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileVersionFooter,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
