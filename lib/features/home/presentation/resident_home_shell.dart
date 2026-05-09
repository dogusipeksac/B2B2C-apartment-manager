import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/demo_module_lock_overlay.dart';
import 'package:apartment_manager/features/announcements/presentation/announcements_list_screen.dart';
import 'package:apartment_manager/features/auth/presentation/building_name_hydrate.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/features/dues/presentation/dues_list_screen.dart';
import 'package:apartment_manager/features/home/data/demo_home_feed.dart';
import 'package:apartment_manager/features/issues/presentation/issues_list_screen.dart';
import 'package:apartment_manager/features/profile/presentation/profile_home_tab.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Resident shell: bottom navigation + sakin ana sayfa (mockup bölüm 2.1).
class ResidentHomeShell extends ConsumerStatefulWidget {
  const ResidentHomeShell({
    required this.displayName,
    required this.useDemoData,
    this.lockDemoModules = false,
    this.buildingName,
    super.key,
  });

  final String displayName;
  final bool useDemoData;

  /// When true (prod), mock dashboard blocks show lock overlay.
  final bool lockDemoModules;

  /// From LocalSession / backend; replaces demo header line when set.
  final String? buildingName;

  @override
  ConsumerState<ResidentHomeShell> createState() => _ResidentHomeShellState();
}

class _ResidentHomeShellState extends ConsumerState<ResidentHomeShell> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Env.demoMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(hydrateBuildingNameFromEdge(ref));
      });
    }
  }

  ResidentHomeData _data(AppLocalizations l10n) {
    return widget.useDemoData
        ? ResidentHomeData.demo(l10n)
        : ResidentHomeData.empty;
  }

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
    final sessionAsync = ref.watch(localSessionProvider);
    final session = sessionAsync.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );
    final resolvedBuilding =
        session != null &&
            session.buildingName != null &&
            session.buildingName!.trim().isNotEmpty
        ? session.buildingName!.trim()
        : widget.buildingName?.trim();
    final resolvedDisplay =
        session != null &&
            session.fullName != null &&
            session.fullName!.trim().isNotEmpty
        ? session.fullName!.trim()
        : widget.displayName;

    final data = _data(l10n);
    final apart = context.apart;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _ResidentDashboardTab(
            displayName: resolvedDisplay,
            data: data,
            showDemoBanner: Env.demoMode,
            lockDemoModules: widget.lockDemoModules,
            buildingName: resolvedBuilding,
            onSeeAllAnnouncements: () => setState(() => _tabIndex = 2),
            onSeeAllIssues: () => setState(() => _tabIndex = 3),
          ),
          const DuesListScreen(),
          const AnnouncementsListScreen(),
          const IssuesListScreen(),
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
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments),
            label: l10n.demoNavFinance,
          ),
          NavigationDestination(
            icon: const Icon(Icons.campaign_outlined),
            selectedIcon: const Icon(Icons.campaign),
            label: l10n.demoNavAnnouncements,
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

class _ResidentDashboardTab extends StatelessWidget {
  const _ResidentDashboardTab({
    required this.displayName,
    required this.data,
    required this.showDemoBanner,
    required this.lockDemoModules,
    required this.buildingName,
    required this.onSeeAllAnnouncements,
    required this.onSeeAllIssues,
  });

  final String displayName;
  final ResidentHomeData data;
  final bool showDemoBanner;
  final bool lockDemoModules;
  final String? buildingName;
  final VoidCallback onSeeAllAnnouncements;
  final VoidCallback onSeeAllIssues;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    final name = displayName.isEmpty ? '—' : displayName;
    final bn = buildingName?.trim();
    final headerBuildingLine = (bn != null && bn.isNotEmpty)
        ? '${l10n.residentRolePrefix} · $bn'
        : (showDemoBanner
              ? l10n.demoBuildingHeaderLine
              : l10n.residentBuildingHeaderFallback);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDemoBanner)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Card(
                      color: theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.demoHubSubtitle,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            Chip(
                              label: Text(l10n.demoBadge),
                              padding: EdgeInsets.zero,
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Container(
                  color: apart.surface,
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headerBuildingLine,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: apart.onSurfaceVariant,
                                letterSpacing: 0.48,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                height: 1.33,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.demoHelloName(name),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                height: 24 / 18,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          fixedSize: const Size(40, 40),
                        ),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_outlined),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: apart.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.homeFeatureSoon)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                DemoModuleLockOverlay(
                  locked: lockDemoModules,
                  message: l10n.demoModuleLockedBody,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (data.hasDebt)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.debtGradientStart,
                                  AppTheme.debtGradientEnd,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.error.withValues(alpha: 0.25),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.demoOpenDebt,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD9D9),
                                    fontSize: 12,
                                    letterSpacing: 0.72,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatTL(data.openDebtLira),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    height: 40 / 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l10n.demoDueLabel(
                                          data.dueDateShort,
                                          data.delayStatus,
                                        ),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              height: 20 / 14,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.secondary,
                                      foregroundColor: scheme.onSecondary,
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.homeFeatureSoon),
                                        ),
                                      );
                                    },
                                    child: Text(l10n.demoPayNow),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Card(
                            color: scheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.homeNoOutstandingDebt,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (data.announcements.isEmpty)
                          Text(
                            l10n.homeEmptyNoRecords,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          )
                        else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.campaign_outlined,
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          l10n.homeRecentAnnouncements,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor:
                                              theme.colorScheme.primary,
                                        ),
                                        onPressed: onSeeAllAnnouncements,
                                        child: Text(
                                          l10n.homeSeeAll,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                letterSpacing: 0.48,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  for (
                                    var i = 0;
                                    i < data.announcements.length;
                                    i++
                                  ) ...[
                                    if (i > 0)
                                      const Divider(height: 1)
                                    else
                                      const SizedBox.shrink(),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: i == 0 ? 0 : 8,
                                        bottom:
                                            i == data.announcements.length - 1
                                            ? 0
                                            : 8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _AnnouncementTagChip(
                                            tag: data.announcements[i].tag,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.announcements[i].title,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        height: 20 / 14,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  data.announcements[i].author,
                                                  style: theme
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: apart
                                                            .onSurfaceVariant,
                                                        fontSize: 12,
                                                        height: 16 / 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (data.issues.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.homeEmptyNoRecords,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          )
                        else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.build_outlined,
                                        size: 18,
                                        color: AppTheme.warning,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          l10n.homeOpenIssuesSection,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor:
                                              theme.colorScheme.primary,
                                        ),
                                        onPressed: onSeeAllIssues,
                                        child: Text(
                                          l10n.homeSeeAll,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                letterSpacing: 0.48,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  for (final item in data.issues)
                                    Builder(
                                      builder: (context) {
                                        final updatedPhrase = l10n
                                            .homeIssueUpdatedAgo(
                                              item.updatedTimePhrase,
                                            );
                                        final statusDetail =
                                            '${item.statusLabel} · '
                                            '$updatedPhrase';
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: scheme.tertiaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ),
                                              ),
                                              child: Icon(
                                                Icons.water_drop_outlined,
                                                color: scheme.tertiary,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.title,
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          height: 20 / 14,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    statusDetail,
                                                    style: theme
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          color: apart
                                                              .onSurfaceVariant,
                                                          fontSize: 12,
                                                          height: 16 / 12,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Chip(
                                              label: Text(
                                                item.statusLabel,
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: AppTheme.warning,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 11,
                                                    ),
                                              ),
                                              backgroundColor:
                                                  AppTheme.warningContainer,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _AnnouncementTagChip extends StatelessWidget {
  const _AnnouncementTagChip({required this.tag});

  final HomeAnnouncementTag tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    switch (tag) {
      case HomeAnnouncementTag.pin:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.push_pin_outlined,
                size: 10,
                color: Color(0xFF8A5A00),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.homeAnnouncementTagPin,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF8A5A00),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.4,
                  height: 1,
                ),
              ),
            ],
          ),
        );
      case HomeAnnouncementTag.info:
        return Chip(
          label: Text(
            l10n.homeAnnouncementTagInfo,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.info,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              height: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide.none,
          backgroundColor: AppTheme.infoContainer,
        );
    }
  }
}
