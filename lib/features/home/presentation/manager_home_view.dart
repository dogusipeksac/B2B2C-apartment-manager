import 'dart:async';
import 'dart:math' as math;

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/demo_module_lock_overlay.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/home/data/demo_home_feed.dart';
import 'package:apartment_manager/features/home/presentation/manager_issue_stats_section.dart';
import 'package:apartment_manager/features/home/presentation/providers/manager_issue_stats_provider.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Manager role home (design preview; demo data only until backend exists).
class ManagerHomeView extends ConsumerWidget {
  const ManagerHomeView({
    super.key,
    this.onSwitchToResident,
  });

  /// When null (production invite admin), demo-only switch controls are hidden.
  final VoidCallback? onSwitchToResident;

  List<String> _chartMonths(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    final localeName = code == 'tr' ? 'tr_TR' : 'en_US';
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - 5 + i);
      return DateFormat.MMM(localeName).format(d);
    });
  }

  void _open(BuildContext context, String path) {
    unawaited(context.push(path));
  }

  void _soon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.homeFeatureSoon)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final months = _chartMonths(context);
    final data = ManagerHomeData.demo(months);

    final sessionAsync = ref.watch(localSessionProvider);
    final bn = sessionAsync.maybeWhen(
      data: (s) => s?.buildingName?.trim(),
      orElse: () => null,
    );
    final buildingTopLine = (bn != null && bn.isNotEmpty)
        ? '${l10n.homeManagerRolePrefix} · $bn'
        : l10n.homeManagerBuildingFallback;
    final localeTag = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr_TR'
        : 'en_US';
    final monthYear = DateFormat.yMMMM(localeTag).format(DateTime.now());

    final maxChart = math.max(
      data.incomeSeriesK.reduce(math.max),
      data.expenseSeriesK.reduce(math.max),
    );
    final maxY = maxChart * 1.15;

    final tr = Localizations.localeOf(context).languageCode == 'tr';
    final deltaLabel = tr
        ? '%${data.incomeDeltaPercent}'
        : '${data.incomeDeltaPercent}%';
    final apart = context.apart;
    final scheme = theme.colorScheme;

    final showDemoSwitcher = onSwitchToResident != null;
    final useDemoData = Env.demoMode;

    final now = DateTime.now();
    final ManagerIssueStatsKey currentStatsKey = (
      year: now.year,
      month: now.month,
    );
    final currentStatsAsync = ref.watch(
      managerIssueStatsProvider(currentStatsKey),
    );
    final liveOpenIssues = currentStatsAsync.maybeWhen(
      data: (s) => s.pending,
      orElse: () => useDemoData ? data.openIssuesCount : null,
    );
    final liveHighPriority = currentStatsAsync.maybeWhen(
      data: (s) => s.highPriorityPending,
      orElse: () => useDemoData ? data.highPriorityCount : null,
    );

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      drawer: showDemoSwitcher
          ? Drawer(
              child: SafeArea(
                child: ListTile(
                  leading: const Icon(Icons.apartment_outlined),
                  title: Text(l10n.homeDemoSwitchResident),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSwitchToResident!();
                  },
                ),
              ),
            )
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showDemoSwitcher
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buildingTopLine,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              monthYear,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          if (showDemoSwitcher)
            IconButton(
              tooltip: l10n.homeDemoSwitchResident,
              icon: const Icon(Icons.swap_horiz_outlined),
              onPressed: onSwitchToResident,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => useDemoData
                      ? _soon(context, l10n)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.homeQuickLockedHint)),
                        ),
                ),
                if (data.notificationBadgeCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IgnorePointer(
                      child: Container(
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: apart.surface,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '${data.notificationBadgeCount}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          DemoModuleLockOverlay(
            locked: !useDemoData,
            message: l10n.homeManagerLockedPlaceholder,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.35,
              children: [
                _SummaryCard(
                  title: l10n.homeManagerCollectionLabel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '%${data.collectionPercent}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: data.collectionPercent / 100,
                          minHeight: 8,
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _SummaryCard(
                  title: l10n.homeManagerIncomeLabel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTL(data.incomeLira),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeManagerIncomeDelta(deltaLabel),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _SummaryCard(
                  title: l10n.homeManagerOpenDebtLabel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTL(data.openDebtLira),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeManagerUnitsSuffix('${data.openDebtUnits}'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _SummaryCard(
                  title: l10n.homeManagerOpenIssuesLabel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        liveOpenIssues != null ? '$liveOpenIssues' : '—',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeManagerHighPrioritySuffix(
                          liveHighPriority != null
                              ? '$liveHighPriority'
                              : '—',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const ManagerIssueStatsSection(),
          const SizedBox(height: 16),
          DemoModuleLockOverlay(
            locked: !useDemoData,
            message: l10n.homeManagerLockedPlaceholder,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.homeChartSixMonths,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            color: apart.onSurfaceTertiary,
                            size: 18,
                          ),
                          onPressed: () => useDemoData
                              ? _soon(context, l10n)
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.homeQuickLockedHint),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _LegendDot(
                          color: AppTheme.primary,
                          label: l10n.homeChartLegendIncome,
                        ),
                        const SizedBox(width: 16),
                        _LegendDot(
                          color: AppTheme.secondary,
                          label: l10n.homeChartLegendExpense,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 ||
                                      i >= data.chartMonthLabels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      data.chartMonthLabels[i],
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: maxY > 0 ? maxY / 4 : 1,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                            ),
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles(),
                          ),
                          barGroups: List.generate(6, (i) {
                            return BarChartGroupData(
                              x: i,
                              barsSpace: 4,
                              barRods: [
                                BarChartRodData(
                                  toY: data.incomeSeriesK[i],
                                  color: AppTheme.primary,
                                  width: 10,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: data.expenseSeriesK[i],
                                  color: AppTheme.secondary,
                                  width: 10,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homeQuickActionsSection,
            style: theme.textTheme.labelMedium?.copyWith(
              color: apart.onSurfaceVariant,
              letterSpacing: 0.52,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: [
              _QuickTile(
                iconBoxBg: scheme.primaryContainer,
                iconBoxFg: scheme.primary,
                icon: Icons.add_rounded,
                label: l10n.homeQuickNewPeriod,
                locked: !useDemoData,
                onTap: () => _open(context, '/manager/periods'),
              ),
              _QuickTile(
                iconBoxBg: scheme.secondaryContainer,
                iconBoxFg: scheme.secondary,
                icon: Icons.campaign_outlined,
                label: l10n.homeQuickSendAnnouncement,
                locked: !useDemoData,
                onTap: () => _soon(context, l10n),
              ),
              _QuickTile(
                iconBoxBg: scheme.tertiaryContainer,
                iconBoxFg: scheme.tertiary,
                icon: Icons.mail_outline_rounded,
                label: l10n.homeQuickSendInvite,
                onTap: () => _open(context, '/manager/invite'),
              ),
              _QuickTile(
                iconBoxBg: scheme.errorContainer,
                iconBoxFg: scheme.error,
                icon: Icons.payments_outlined,
                label: l10n.homeQuickAddExpense,
                locked: !useDemoData,
                onTap: () => _open(context, '/manager/expense/new'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: context.apart.onSurfaceVariant,
                letterSpacing: 0.48,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.iconBoxBg,
    required this.iconBoxFg,
    required this.icon,
    required this.label,
    required this.onTap,
    this.locked = false,
  });

  final Color iconBoxBg;
  final Color iconBoxFg;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.apart.outlineMuted),
      ),
      child: InkWell(
        onTap: () {
          if (locked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.homeQuickLockedHint)),
            );
            return;
          }
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBoxBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconBoxFg, size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (locked)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: context.apart.onSurfaceTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
