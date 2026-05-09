import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mockup **4.7** — Profil: koyu yeşil header, apartman kartı, ayar listesi.
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

    final isManager =
        demo && personaAsync.value == DemoPersona.manager;

    final initials = displayName.isNotEmpty
        ? displayName
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Dark green header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF11421A), AppTheme.primary],
                ),
              ),
              padding: const EdgeInsets.only(bottom: 24),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.profileMenuTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.homeFeatureSoon)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 3,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFA000),
                                  Color(0xFFF57C00),
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 22,
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
                                  style:
                                      theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'mehmet.yilmaz@gmail.com',
                                  style: const TextStyle(
                                    color: Color(0xFFc9dccd),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    _HeaderChip(
                                      label: isManager
                                          ? l10n.profileBadgeManager
                                          : l10n.profileBadgeResident,
                                    ),
                                    const _HeaderChip(label: 'Daire 3A'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Apartman kartı
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.demoInvitePreviewTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.demoInvitePreviewSubtitle,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppTheme.onSurfaceTertiary,
                        ),
                      ],
                    ),
                  ),
                ),

                if (demo)
                  personaAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (persona) {
                      if (persona == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.swap_horiz_outlined),
                            title: Text(
                              persona == DemoPersona.manager
                                  ? l10n.profileSwitchToResident
                                  : l10n.profileSwitchToManager,
                            ),
                            onTap: () async {
                              await ref
                                  .read(demoPersonaProvider.notifier)
                                  .choose(
                                    persona == DemoPersona.manager
                                        ? DemoPersona.resident
                                        : DemoPersona.manager,
                                  );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 12),
                const _SectionLabel(label: 'HESAP'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Profil bilgileri',
                        onTap: () {},
                        showDivider: true,
                      ),
                      _MenuRow(
                        icon: Icons.notifications_outlined,
                        label: 'Bildirim ayarları',
                        onTap: () {},
                        showDivider: true,
                      ),
                      _MenuRow(
                        icon: Icons.credit_card_outlined,
                        label: 'Kayıtlı kartlar',
                        badge: '1',
                        onTap: () {},
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const _SectionLabel(label: 'DESTEK'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.help_outline_rounded,
                        label: 'Yardım merkezi',
                        onTap: () {},
                        showDivider: true,
                      ),
                      _MenuRow(
                        icon: Icons.logout_rounded,
                        label: l10n.signOut,
                        onTap: onSignOut,
                        isDestructive: true,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  l10n.profileVersionFooter,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.showDivider,
    this.badge,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;
  final String? badge;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive ? AppTheme.error : const Color(0xFF404040);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: fg,
                      fontWeight: isDestructive
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.outlineMuted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (!isDestructive)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppTheme.onSurfaceTertiary,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
