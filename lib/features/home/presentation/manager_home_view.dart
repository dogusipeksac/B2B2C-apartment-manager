import 'dart:async';
import 'dart:math' as math;

import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/features/home/data/demo_home_feed.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Manager role home (design preview; demo data only until backend exists).
class ManagerHomeView extends StatelessWidget {
  const ManagerHomeView({
    required this.onSwitchToResident,
    super.key,
  });

  final VoidCallback onSwitchToResident;

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final months = _chartMonths(context);
    final data = ManagerHomeData.demo(months);

    final maxChart = math.max(
      data.incomeSeriesK.reduce(math.max),
      data.expenseSeriesK.reduce(math.max),
    );
    final maxY = maxChart * 1.15;

    final tr = Localizations.localeOf(context).languageCode == 'tr';
    final deltaLabel =
        tr ? '%${data.incomeDeltaPercent}' : '${data.incomeDeltaPercent}%';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: Drawer(
        child: SafeArea(
          child: ListTile(
            leading: const Icon(Icons.apartment_outlined),
            title: Text(l10n.homeDemoSwitchResident),
            onTap: () {
              Navigator.of(context).pop();
              onSwitchToResident();
            },
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeManagerBuildingLine,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              l10n.homeManagerMonthYear,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
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
                  onPressed: () => _soon(context, l10n),
                ),
                if (data.notificationBadgeCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${data.notificationBadgeCount}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
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
                        backgroundColor:
                            AppTheme.primary.withValues(alpha: 0.12),
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
                        color: AppTheme.primary,
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
                      '${data.openIssuesCount}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.homeManagerHighPrioritySuffix(
                        '${data.highPriorityCount}',
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
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeChartSixMonths,
                    style: theme.textTheme.titleSmall,
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
                    height: 220,
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
          const SizedBox(height: 16),
          Text(
            l10n.homeQuickActionsSection,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: [
              _QuickTile(
                icon: Icons.add_circle_outline,
                label: l10n.homeQuickNewPeriod,
                onTap: () => _open(context, '/manager/periods'),
              ),
              _QuickTile(
                icon: Icons.campaign_outlined,
                label: l10n.homeQuickSendAnnouncement,
                onTap: () => _soon(context, l10n),
              ),
              _QuickTile(
                icon: Icons.mail_outline,
                label: l10n.homeQuickSendInvite,
                onTap: () => _open(context, '/manager/invite'),
              ),
              _QuickTile(
                icon: Icons.receipt_long_outlined,
                label: l10n.homeQuickAddExpense,
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
                color: theme.colorScheme.outline,
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
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
