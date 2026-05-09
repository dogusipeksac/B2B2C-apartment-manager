import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **3.1** — rol seçimi: sakin vs yönetici.
class DemoRoleScreen extends ConsumerStatefulWidget {
  const DemoRoleScreen({super.key});

  @override
  ConsumerState<DemoRoleScreen> createState() => _DemoRoleScreenState();
}

class _DemoRoleScreenState extends ConsumerState<DemoRoleScreen> {
  DemoPersona _selected = DemoPersona.resident;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/profile-setup'),
        ),
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
                    l10n.demoPersonaScreenSubtitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bunu sonradan da değiştirebilirsin.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _RoleCard(
                    iconBoxBg: AppTheme.primary,
                    iconBoxFg: Colors.white,
                    icon: Icons.person_outline,
                    title: l10n.demoPersonaResidentTitle,
                    subtitle: l10n.demoPersonaResidentBody,
                    selected: _selected == DemoPersona.resident,
                    onTap: () =>
                        setState(() => _selected = DemoPersona.resident),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    iconBoxBg: AppTheme.secondaryContainer,
                    iconBoxFg: const Color(0xFFB57400),
                    icon: Icons.shield_outlined,
                    title: l10n.demoPersonaManagerTitle,
                    subtitle: l10n.demoPersonaManagerBody,
                    selected: _selected == DemoPersona.manager,
                    onTap: () =>
                        setState(() => _selected = DemoPersona.manager),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.infoContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppTheme.info,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: const Color(0xFF0E4E92),
                                height: 1.4,
                              ),
                              children: const [
                                TextSpan(text: 'İlk 30 gün '),
                                TextSpan(
                                  text: 'ücretsiz',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: '. Kart bilgisi gerekmez.'),
                              ],
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
                await ref
                    .read(demoPersonaProvider.notifier)
                    .choose(_selected);
                if (context.mounted) {
                  context.go('/home');
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
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
    return Material(
      color: selected ? AppTheme.primaryContainer : AppTheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.outlineMuted,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    Text(
                      subtitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.4,
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

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppTheme.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.outlineMuted,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
