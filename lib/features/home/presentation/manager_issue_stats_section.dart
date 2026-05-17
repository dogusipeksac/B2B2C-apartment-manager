import 'dart:math' as math;

import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/home/presentation/providers/manager_issue_stats_provider.dart';
import 'package:apartment_manager/features/issues/domain/issue_monthly_stats.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Issue opened / resolved / pending chart with month filter.
class ManagerIssueStatsSection extends ConsumerStatefulWidget {
  const ManagerIssueStatsSection({super.key});

  @override
  ConsumerState<ManagerIssueStatsSection> createState() =>
      _ManagerIssueStatsSectionState();
}

class _ManagerIssueStatsSectionState
    extends ConsumerState<ManagerIssueStatsSection> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;
    final ManagerIssueStatsKey key = (
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );
    final statsAsync = ref.watch(managerIssueStatsProvider(key));

    final localeTag = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr_TR'
        : 'en_US';
    final monthLabel = DateFormat.yMMMM(localeTag).format(_selectedMonth);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final canGoForward = _selectedMonth.isBefore(currentMonth);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeIssueStatsTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.homeIssueStatsPrevMonth,
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    monthLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.homeIssueStatsNextMonth,
                  onPressed: canGoForward
                      ? () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month + 1,
                            );
                          });
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            statsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.errorGeneric,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: apart.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              data: (stats) => _StatsBody(stats: stats),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final IssueMonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final maxVal = math.max(
      1,
      math.max(stats.opened, math.max(stats.resolved, stats.pending)),
    );
    final maxY = maxVal.toDouble() * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatChip(
                label: l10n.homeIssueStatsOpened,
                value: stats.opened,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatChip(
                label: l10n.homeIssueStatsResolved,
                value: stats.resolved,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatChip(
                label: l10n.homeIssueStatsPending,
                value: stats.pending,
                color: AppTheme.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LegendDot(
              color: AppTheme.primary,
              label: l10n.homeIssueStatsOpened,
            ),
            const SizedBox(width: 12),
            _LegendDot(
              color: AppTheme.success,
              label: l10n.homeIssueStatsResolved,
            ),
            const SizedBox(width: 12),
            _LegendDot(
              color: AppTheme.warning,
              label: l10n.homeIssueStatsPending,
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
                      final labels = [
                        l10n.homeIssueStatsOpened,
                        l10n.homeIssueStatsResolved,
                        l10n.homeIssueStatsPending,
                      ];
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          labels[i],
                          style: theme.textTheme.labelSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: maxY > 0 ? math.max(1, maxY / 4) : 1,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: stats.opened.toDouble(),
                      color: AppTheme.primary,
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: stats.resolved.toDouble(),
                      color: AppTheme.success,
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: stats.pending.toDouble(),
                      color: AppTheme.warning,
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.apart.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
        ],
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
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
