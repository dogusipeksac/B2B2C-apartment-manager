import 'dart:async';

import 'package:apartment_manager/core/config/app_features.dart';
import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/building_name_hydrate.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/manager/data/manager_invite_repository.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.7** — Profil: koyu yeşil header, apartman kartı, ayar listesi.
class ProfileHomeTab extends ConsumerStatefulWidget {
  const ProfileHomeTab({
    required this.displayName,
    required this.onSignOut,
    super.key,
  });

  final String displayName;
  final VoidCallback onSignOut;

  @override
  ConsumerState<ProfileHomeTab> createState() => _ProfileHomeTabState();
}

class _ProfileHomeTabState extends ConsumerState<ProfileHomeTab> {
  String? _managerUnitLabel;

  @override
  void initState() {
    super.initState();
    if (!Env.demoMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_hydrateBuilding());
        unawaited(_syncManagerUnit());
      });
    }
  }

  Future<void> _hydrateBuilding() async {
    await hydrateBuildingNameFromEdge(ref);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _syncManagerUnit() async {
    final session = await ref.read(localSessionRepositoryProvider).load();
    if (session == null ||
        session.role != UserRole.buildingAdmin ||
        session.buildingId == null ||
        session.buildingId!.isEmpty) {
      return;
    }
    try {
      final result =
          await ref.read(managerInviteRepositoryProvider).listUnits(session);
      if (!mounted) {
        return;
      }
      var label = result.myUnitLabel;
      final myId = result.myUnitId;
      if (label == null && myId != null) {
        for (final u in result.units) {
          if (u.id == myId) {
            label = u.label;
            break;
          }
        }
      }
      if (myId != null &&
          myId.isNotEmpty &&
          session.unitId != myId) {
        final updated = session.copyWith(
          unitId: myId,
          savedAt: DateTime.now(),
        );
        await ref.persistLocalSession(
          updated,
          rememberMe: session.rememberMe,
        );
      }
      setState(() => _managerUnitLabel = label);
    } on Object {
      // Non-blocking; profile still usable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    final demo = Env.demoMode;
    final personaAsync = ref.watch(demoPersonaProvider);
    final session = ref
        .watch(localSessionProvider)
        .maybeWhen(
          data: (s) => s,
          orElse: () => null,
        );

    final demoPersona = demo
        ? personaAsync.maybeWhen(
            data: (p) => p,
            orElse: () => null,
          )
        : null;

    final fn = session?.fullName?.trim();
    final resolvedName = (!demo && fn != null && fn.isNotEmpty)
        ? fn
        : widget.displayName;

    final bn = session?.buildingName?.trim();
    final hasBuildingName = bn != null && bn.isNotEmpty;

    final isSuperAdmin = AppFeatures.superAdminEnabled &&
        (demo
            ? demoPersona == DemoPersona.superAdmin
            : session?.role == UserRole.superAdmin);

    final isManager = demo
        ? demoPersona == DemoPersona.manager
        : session?.role == UserRole.buildingAdmin;

    final buildingIdTrimmed = session?.buildingId?.trim();
    final hasBuildingId =
        buildingIdTrimmed != null && buildingIdTrimmed.isNotEmpty;

    final managerUnitId = session?.unitId?.trim();
    final hasManagerUnit =
        managerUnitId != null && managerUnitId.isNotEmpty;
    final managerUnitLabel = _managerUnitLabel?.trim();
    final showClaimUnit =
        isManager && !demo && hasBuildingId && !hasManagerUnit;

    String cardTitle() {
      if (isSuperAdmin) {
        return hasBuildingName ? bn : l10n.demoPersonaSuperAdminTitle;
      }
      if (hasBuildingName) {
        return bn;
      }
      if (demo) {
        return l10n.profileDemoCardTitle;
      }
      if (hasBuildingId) {
        return l10n.profileCardFetchingBuildingTitle;
      }
      return l10n.profileCardNoBuildingTitle;
    }

    String cardBody() {
      if (isSuperAdmin) {
        return l10n.accountRoleSuperAdminShortBody;
      }
      if (hasBuildingName) {
        if (isManager) {
          if (managerUnitLabel != null && managerUnitLabel.isNotEmpty) {
            return l10n.profileCardSubtitleManagerWithUnit(managerUnitLabel);
          }
          return l10n.profileCardSubtitleManager;
        }
        return l10n.profileCardSubtitleResident;
      }
      if (demo) {
        return l10n.profileDemoCardSubtitle;
      }
      if (hasBuildingId) {
        return l10n.profileCardFetchingBuildingBody;
      }
      return l10n.profileCardNoBuildingBody;
    }

    final initials = resolvedName.isNotEmpty
        ? resolvedName
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0] : '')
              .join()
              .toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
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
                            onPressed: () => context.push('/settings'),
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
                                  resolvedName.isEmpty ? '—' : resolvedName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                if (hasBuildingName) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    bn,
                                    style: const TextStyle(
                                      color: Color(0xFFc9dccd),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    _HeaderChip(
                                      label: isSuperAdmin
                                          ? l10n.profileBadgeSuperAdmin
                                          : isManager
                                              ? l10n.profileBadgeManager
                                              : l10n.profileBadgeResident,
                                    ),
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
                            color: scheme.primaryContainer,
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
                                cardTitle(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cardBody(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: apart.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: apart.onSurfaceTertiary,
                        ),
                      ],
                    ),
                  ),
                ),

                if (showClaimUnit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Card(
                      color: scheme.primaryContainer.withValues(alpha: 0.35),
                      child: ListTile(
                        leading: Icon(
                          Icons.home_work_outlined,
                          color: scheme.primary,
                        ),
                        title: Text(
                          l10n.profileMenuClaimUnit,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          l10n.profileClaimUnitSubtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            height: 1.35,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: apart.onSurfaceTertiary,
                        ),
                        onTap: () async {
                          final saved = await context.push<bool>(
                            '/manager/claim-unit',
                          );
                          if (saved == true && mounted) {
                            await _syncManagerUnit();
                          }
                        },
                      ),
                    ),
                  ),

                if (demo)
                  personaAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
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
                              final next = persona == DemoPersona.manager
                                  ? DemoPersona.resident
                                  : DemoPersona.manager;
                              await ref
                                  .read(demoPersonaProvider.notifier)
                                  .choose(next);
                            },
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 12),
                _SectionLabel(label: l10n.profileSectionAccount),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.person_outline_rounded,
                        label: l10n.profileMenuProfileInfo,
                        onTap: () async {
                          final saved = await context.push<bool>(
                            '/profile/edit',
                          );
                          if (saved == true && mounted) {
                            setState(() {});
                          }
                        },
                        showDivider: true,
                      ),
                      if (isManager && hasBuildingId && !demo)
                        _MenuRow(
                          icon: Icons.door_front_door_outlined,
                          label: hasManagerUnit
                              ? l10n.profileCardSubtitleManagerWithUnit(
                                  managerUnitLabel ?? managerUnitId,
                                )
                              : l10n.profileMenuClaimUnit,
                          onTap: () async {
                            final saved = await context.push<bool>(
                              '/manager/claim-unit',
                            );
                            if (saved == true && mounted) {
                              await _syncManagerUnit();
                            }
                          },
                          showDivider: true,
                        ),
                      _MenuRow(
                        icon: Icons.notifications_outlined,
                        label: l10n.profileMenuNotifications,
                        onTap: () {},
                        showDivider: true,
                      ),
                      _MenuRow(
                        icon: Icons.credit_card_outlined,
                        label: l10n.profileMenuSavedCards,
                        badge: '1',
                        onTap: () {},
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _SectionLabel(label: l10n.profileSectionSupport),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.help_outline_rounded,
                        label: l10n.profileMenuHelpCenter,
                        onTap: () {},
                        showDivider: true,
                      ),
                      _MenuRow(
                        icon: Icons.logout_rounded,
                        label: l10n.signOut,
                        onTap: widget.onSignOut,
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
                    color: apart.onSurfaceTertiary,
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
        color: context.apart.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    final apart = context.apart;
    final fg = isDestructive ? AppTheme.error : scheme.onSurface;
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
                      color: apart.chipInactiveBg,
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
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: apart.onSurfaceTertiary,
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
