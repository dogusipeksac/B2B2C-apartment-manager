import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/features/announcements/presentation/announcements_list_screen.dart';
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
    super.key,
  });

  final String displayName;
  final bool useDemoData;

  @override
  ConsumerState<ResidentHomeShell> createState() => _ResidentHomeShellState();
}

class _ResidentHomeShellState extends ConsumerState<ResidentHomeShell> {
  int _tabIndex = 0;

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
      await ref.read(authRepositoryProvider).signOut();
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
    final data = _data(l10n);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _ResidentDashboardTab(
            displayName: widget.displayName,
            data: data,
            showDemoBanner: Env.demoMode,
            onSeeAllAnnouncements: () => setState(() => _tabIndex = 2),
            onSeeAllIssues: () => setState(() => _tabIndex = 3),
          ),
          const DuesListScreen(),
          const AnnouncementsListScreen(),
          const IssuesListScreen(),
          ProfileHomeTab(
            displayName: widget.displayName,
            onSignOut: () => _signOut(context),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        indicatorColor: AppTheme.primary.withValues(alpha: 0.2),
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
    required this.onSeeAllAnnouncements,
    required this.onSeeAllIssues,
  });

  final String displayName;
  final ResidentHomeData data;
  final bool showDemoBanner;
  final VoidCallback onSeeAllAnnouncements;
  final VoidCallback onSeeAllIssues;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = displayName.isEmpty ? '—' : displayName;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDemoBanner) ...[
                  Card(
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
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.demoHelloName(name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.demoBuildingHeaderLine,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.homeFeatureSoon)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (data.hasDebt)
                  Card(
                    color: AppTheme.error,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.demoOpenDebt,
                            style: const TextStyle(
                              color: Color(0xFFFFD9D9),
                              fontSize: 12,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTL(data.openDebtLira),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.demoDueLabel(
                              data.dueDateShort,
                              data.delayStatus,
                            ),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.secondary,
                                foregroundColor: Colors.black87,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.homeFeatureSoon)),
                                );
                              },
                              child: Text(l10n.demoPayNow),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    color: AppTheme.primary.withValues(alpha: 0.08),
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
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.homeRecentAnnouncements,
                      style: theme.textTheme.titleSmall,
                    ),
                    TextButton(
                      onPressed: data.announcements.isEmpty
                          ? null
                          : onSeeAllAnnouncements,
                      child: Text(l10n.homeSeeAll),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (data.announcements.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.homeEmptyNoRecords,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          )
        else
          SliverList.separated(
            itemBuilder: (context, index) {
              final item = data.announcements[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: Text(item.title),
                    subtitle: Text(item.author),
                    trailing: _AnnouncementTagChip(tag: item.tag),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 8),
            itemCount: data.announcements.length,
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.homeOpenIssuesSection,
                  style: theme.textTheme.titleSmall,
                ),
                TextButton(
                  onPressed:
                      data.issues.isEmpty ? null : onSeeAllIssues,
                  child: Text(l10n.homeSeeAll),
                ),
              ],
            ),
          ),
        ),
        if (data.issues.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.homeEmptyNoRecords,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          )
        else
          SliverList.separated(
            itemBuilder: (context, index) {
              final item = data.issues[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.build_outlined),
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.statusLabel} · '
                      '${l10n.homeIssueUpdatedAgo(item.updatedTimePhrase)}',
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 8),
            itemCount: data.issues.length,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
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
        return Chip(
          label: Text(
            l10n.homeAnnouncementTagPin,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.5)),
          backgroundColor: AppTheme.error.withValues(alpha: 0.08),
        );
      case HomeAnnouncementTag.info:
        return Chip(
          label: Text(
            l10n.homeAnnouncementTagInfo,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF1565C0),
              fontWeight: FontWeight.w700,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: const BorderSide(color: Color(0xFFBBDEFB)),
          backgroundColor: const Color(0xFFE3F2FD),
        );
    }
  }
}
