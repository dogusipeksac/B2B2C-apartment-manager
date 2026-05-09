import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/error_view.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';
import 'package:apartment_manager/features/dues/presentation/providers/dues_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Aidat listesi (tab veya tam ekran).
class DuesListScreen extends ConsumerWidget {
  const DuesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final asyncInvoices = ref.watch(duesInvoicesProvider);
    final asyncDebt = ref.watch(duesDebtSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(l10n.duesMyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.homeFeatureSoon)),
              );
            },
          ),
        ],
      ),
      body: asyncInvoices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorView(message: l10n.catalogLoadError),
        data: (rows) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              asyncDebt.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) {
                  if (summary == null || summary.openDebtKurus <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      color: AppTheme.error,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.duesOpenDebt,
                              style: const TextStyle(
                                color: Color(0xFFFFD9D9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatTL(summary.openDebtKurus / 100),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.duesUnpaidSummary(
                                '${summary.unpaidCount}',
                                summary.lateLabel,
                              ),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.secondary,
                                  foregroundColor: Colors.black87,
                                ),
                                onPressed: () {
                                  DuesInvoiceUi? overdue;
                                  for (final r in rows) {
                                    if (r.status == DuesInvoiceUiStatus.overdue) {
                                      overdue = r;
                                      break;
                                    }
                                  }
                                  final id =
                                      overdue?.id ??
                                          (rows.isNotEmpty ? rows.first.id : null);
                                  if (id != null) {
                                    context.push('/invoice/$id');
                                  }
                                },
                                child: Text(l10n.duesPayNow),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(label: l10n.duesFilterAll),
                  _FilterChip(label: l10n.duesFilterOpen),
                  _FilterChip(label: l10n.duesFilterPaid),
                  _FilterChip(label: l10n.duesFilterLate),
                ],
              ),
              const SizedBox(height: 16),
              Text('2026', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ...rows.map(
                (row) => Card(
                  child: ListTile(
                    leading: _MonthBadge(date: row.dueDate),
                    title: Text(row.periodLabel),
                    subtitle: Text(row.subtitle),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTL(row.amountKurus / 100),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _statusLabel(l10n, row.status),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _statusColor(row.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => context.push('/invoice/${row.id}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _statusColor(DuesInvoiceUiStatus s) {
    switch (s) {
      case DuesInvoiceUiStatus.paid:
        return AppTheme.primary;
      case DuesInvoiceUiStatus.overdue:
        return AppTheme.error;
      default:
        return AppTheme.secondary;
    }
  }

  String _statusLabel(AppLocalizations l10n, DuesInvoiceUiStatus s) {
    switch (s) {
      case DuesInvoiceUiStatus.paid:
        return l10n.duesFilterPaid;
      case DuesInvoiceUiStatus.overdue:
        return l10n.duesFilterLate;
      default:
        return l10n.duesFilterOpen;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      padding: EdgeInsets.zero,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }
}

class _MonthBadge extends StatelessWidget {
  const _MonthBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    const months = [
      'OCA',
      'ŞUB',
      'MAR',
      'NIS',
      'MAY',
      'HAZ',
      'TEM',
      'AĞU',
      'EYL',
      'EKİ',
      'KAS',
      'ARA',
    ];
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            months[date.month - 1],
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            '${date.day}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
