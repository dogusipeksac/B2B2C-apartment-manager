import 'package:apartment_manager/core/config/app_features.dart';
import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Post-splash entry: resident vs manager (mockup 3.1).
enum SetupAccountRole {
  resident,
  manager,
  superAdmin,
}

/// Hesap türü seçimi — yönetici kurulum / sakin davet kodu girişi.
class AccountRoleScreen extends ConsumerStatefulWidget {
  const AccountRoleScreen({super.key});

  @override
  ConsumerState<AccountRoleScreen> createState() => _AccountRoleScreenState();
}

class _AccountRoleScreenState extends ConsumerState<AccountRoleScreen> {
  SetupAccountRole _selected = SetupAccountRole.resident;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.demoPersonaScreenTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountRoleHeadline,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.accountRoleSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: apart.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SetupRoleCard(
                    iconBoxBg: AppTheme.primary,
                    iconBoxFg: Colors.white,
                    icon: Icons.person_outline,
                    title: l10n.accountRoleResidentShortTitle,
                    subtitle: l10n.accountRoleResidentShortBody,
                    selected: _selected == SetupAccountRole.resident,
                    onTap: () =>
                        setState(() => _selected = SetupAccountRole.resident),
                  ),
                  const SizedBox(height: 12),
                  _SetupRoleCard(
                    iconBoxBg: scheme.secondaryContainer,
                    iconBoxFg: scheme.secondary,
                    icon: Icons.shield_outlined,
                    title: l10n.accountRoleManagerShortTitle,
                    subtitle: l10n.accountRoleManagerShortBody,
                    selected: _selected == SetupAccountRole.manager,
                    onTap: () =>
                        setState(() => _selected = SetupAccountRole.manager),
                  ),
                  if (AppFeatures.superAdminEnabled) ...[
                    const SizedBox(height: 12),
                    _SetupRoleCard(
                      iconBoxBg: scheme.errorContainer,
                      iconBoxFg: scheme.error,
                      icon: Icons.admin_panel_settings_outlined,
                      title: l10n.accountRoleSuperAdminShortTitle,
                      subtitle: l10n.accountRoleSuperAdminShortBody,
                      selected: _selected == SetupAccountRole.superAdmin,
                      onTap: () => setState(
                        () => _selected = SetupAccountRole.superAdmin,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: scheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.demoPersonaTrialBanner,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onTertiaryContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: FilledButton(
              onPressed: () async {
                if (_selected == SetupAccountRole.manager) {
                  if (Env.demoMode) {
                    context.go('/setup/wizard');
                  } else {
                    context.go('/setup/admin-invite');
                  }
                } else if (_selected == SetupAccountRole.superAdmin &&
                    AppFeatures.superAdminEnabled) {
                  if (Env.demoMode) {
                    await ref
                        .read(demoPersonaProvider.notifier)
                        .choose(DemoPersona.superAdmin);
                    if (context.mounted) {
                      context.go('/home');
                    }
                  } else {
                    context.go('/setup/superadmin-access');
                  }
                } else {
                  context.go('/setup/resident-invite');
                }
              },
              child: Text(l10n.continueButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupRoleCard extends StatelessWidget {
  const _SetupRoleCard({
    required this.iconBoxBg,
    required this.iconBoxFg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final Color iconBoxBg;
  final Color iconBoxFg;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    return Material(
      color: selected ? scheme.primaryContainer : apart.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppTheme.primary : apart.outlineMuted,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBoxBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: iconBoxFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: apart.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        children: _inviteBoldSpan(subtitle),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

List<InlineSpan> _inviteBoldSpan(String text) {
  const marker = 'davet kodu';
  final lower = text.toLowerCase();
  final idx = lower.indexOf(marker);
  if (idx < 0) {
    return [TextSpan(text: text)];
  }
  final end = idx + marker.length;
  return [
    TextSpan(text: text.substring(0, idx)),
    TextSpan(
      text: text.substring(idx, end),
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
    TextSpan(text: text.substring(end)),
  ];
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppTheme.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppTheme.primary : apart.outlineMuted,
          width: 2,
        ),
      ),
      child: selected
          ? const Center(
              child: SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
