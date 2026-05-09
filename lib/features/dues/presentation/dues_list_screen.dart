import 'dart:async';

import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/error_view.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';
import 'package:apartment_manager/features/dues/presentation/providers/dues_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.1** — Aidat geçmişi: borç kartı + filtre + ay listesi.
class DuesListScreen extends ConsumerStatefulWidget {
  const DuesListScreen({super.key});

  @override
  ConsumerState<DuesListScreen> createState() => _DuesListScreenState();
}

class _DuesListScreenState extends ConsumerState<DuesListScreen> {
  int _filterIdx = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final asyncInvoices = ref.watch(duesInvoicesProvider);
    final asyncDebt = ref.watch(duesDebtSummaryProvider);

    final filters = [
      l10n.duesFilterAll,
      l10n.duesFilterOpen,
      l10n.duesFilterPaid,
      l10n.duesFilterLate,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.duesMyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.homeFeatureSoon)),
            ),
          ),
        ],
      ),
      body: asyncInvoices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorView(message: l10n.catalogLoadError),
        data: (rows) {
          final filtered = _applyFilter(rows, _filterIdx);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: asyncDebt.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (summary) {
                    if (summary == null || summary.openDebtKurus <= 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
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
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AÇIK BORÇ',
                                    style: TextStyle(
                                      color: Color(0xFFFFD9D9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatTL(summary.openDebtKurus / 100),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.duesUnpaidSummary(
                                      '${summary.unpaidCount}',
                                      summary.lateLabel,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFFFFD9D9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.secondary,
                                foregroundColor: const Color(0xFF1A1A1A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                DuesInvoiceUi? overdue;
                                for (final r in rows) {
                                  if (r.status ==
                                      DuesInvoiceUiStatus.overdue) {
                                    overdue = r;
                                    break;
                                  }
                                }
                                final id = overdue?.id ??
                                    (rows.isNotEmpty ? rows.first.id : null);
                                if (id != null) {
                                  unawaited(
                                    context.push('/invoice/$id'),
                                  );
                                }
                              },
                              child: Text(l10n.duesPayNow),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(filters.length, (i) {
                        final active = _filterIdx == i;
                        return Padding(
                          padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterIdx = i),
                            child: Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppTheme.primary
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: active
                                      ? AppTheme.primary
                                      : AppTheme.outlineMuted,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                filters[i],
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : AppTheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '2026',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.48,
                    ),
                  ),
                ),
              ),
              SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final row = filtered[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: _InvoiceListItem(
                      row: row,
                      onTap: () => context.push('/invoice/${row.id}'),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  List<DuesInvoiceUi> _applyFilter(
    List<DuesInvoiceUi> rows,
    int filterIdx,
  ) {
    if (filterIdx == 1) {
      return rows
          .where((r) => r.status == DuesInvoiceUiStatus.open)
          .toList();
    }
    if (filterIdx == 2) {
      return rows
          .where((r) => r.status == DuesInvoiceUiStatus.paid)
          .toList();
    }
    if (filterIdx == 3) {
      return rows
          .where((r) => r.status == DuesInvoiceUiStatus.overdue)
          .toList();
    }
    return rows;
  }
}

class _InvoiceListItem extends StatelessWidget {
  const _InvoiceListItem({
    required this.row,
    required this.onTap,
  });

  final DuesInvoiceUi row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (badgeBg, badgeFg, chipBg, chipFg, chipLabel) =
        _statusTokens(context, row.status);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.outlineMuted),
          ),
          child: Row(
            children: [
              _MonthBadge(
                date: row.dueDate,
                bg: badgeBg,
                fg: badgeFg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.periodLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: row.status == DuesInvoiceUiStatus.overdue
                            ? AppTheme.error
                            : AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatTL(row.amountKurus / 100),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: row.status == DuesInvoiceUiStatus.paid
                          ? AppTheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      chipLabel,
                      style: TextStyle(
                        color: chipFg,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, Color, Color, String) _statusTokens(
    BuildContext context,
    DuesInvoiceUiStatus s,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (s) {
      case DuesInvoiceUiStatus.paid:
        return (
          const Color(0xFFE8F5E9),
          AppTheme.success,
          const Color(0xFFE8F5E9),
          AppTheme.success,
          l10n.duesFilterPaid,
        );
      case DuesInvoiceUiStatus.overdue:
        return (
          AppTheme.errorContainer,
          AppTheme.error,
          AppTheme.errorContainer,
          AppTheme.error,
          l10n.duesFilterLate,
        );
      case DuesInvoiceUiStatus.open:
      case DuesInvoiceUiStatus.partial:
        return (
          AppTheme.warningContainer,
          AppTheme.warning,
          AppTheme.warningContainer,
          AppTheme.warning,
          l10n.duesFilterOpen,
        );
    }
  }
}

class _MonthBadge extends StatelessWidget {
  const _MonthBadge({
    required this.date,
    required this.bg,
    required this.fg,
  });

  final DateTime date;
  final Color bg;
  final Color fg;

  static const _months = [
    'OCA', 'ŞUB', 'MAR', 'NİS', 'MAY', 'HAZ',
    'TEM', 'AĞU', 'EYL', 'EKİ', 'KAS', 'ARA',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _months[date.month - 1],
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          Text(
            '${date.year % 100}',
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
