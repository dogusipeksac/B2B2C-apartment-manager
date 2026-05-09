import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';
import 'package:apartment_manager/features/dues/presentation/providers/dues_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.2** — Aidat detay: tutar dökümü, gecikme uyarısı, fatura.
class DuesDetailScreen extends ConsumerWidget {
  const DuesDetailScreen({
    required this.invoiceId,
    super.key,
  });

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(duesRepositoryProvider);

    return FutureBuilder<DuesInvoiceUi?>(
      future: repo.invoiceById(invoiceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.duesDetailTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final row = snapshot.data;
        if (row == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.duesDetailTitle)),
            body: Center(child: Text(l10n.catalogEmptyTitle)),
          );
        }

        final theme = Theme.of(context);
        final isOverdue = row.status == DuesInvoiceUiStatus.overdue;
        final dueStr = formatTL(row.amountDueKurus / 100);

        return Scaffold(
          appBar: AppBar(
            title: Text(row.periodLabel),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isOverdue) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorContainer,
                    border: Border.all(color: const Color(0xFFF4C7C7)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${row.daysLate} gün gecikti',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppTheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Her geçen gün için %0,067 faiz işliyor.',
                              style: TextStyle(
                                color: Color(0xFF7A1A1A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÖDENECEK TUTAR',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₺',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _amountInteger(row.amountDueKurus / 100),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            _amountDecimal(row.amountDueKurus / 100),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      _DetailRow(
                        label: 'Aidat',
                        value: formatTL(row.amountKurus / 100),
                      ),
                      if (row.lateFeeKurus > 0) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          label: l10n
                              .duesLineLateFee('${row.daysLate}'),
                          value: '+ ${formatTL(row.lateFeeKurus / 100)}',
                          valueColor: AppTheme.warning,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _MetaRow(
                      label: l10n.duesDetailApartmentTitle,
                      value: l10n.duesDetailApartmentValue,
                    ),
                    const Divider(height: 1),
                    _MetaRow(
                      label: l10n.duesDetailPeriodTitle,
                      value: '1–31 ${row.periodLabel.split(' ').last}',
                    ),
                    const Divider(height: 1),
                    _MetaRow(
                      label: l10n.duesDetailDueTitle,
                      value: formatDate(row.dueDate),
                      valueColor: isOverdue ? AppTheme.error : null,
                    ),
                    const Divider(height: 1),
                    _MetaRow(
                      label: l10n.duesDetailInvoiceTitle,
                      value: row.invoiceCode,
                      isMonospace: true,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.onSurfaceVariant,
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () {},
                icon: const Icon(Icons.info_outline_rounded, size: 14),
                label: const Text(
                  'Aidat dağılımını gör',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.pop(),
                      child: Text(l10n.commonClose),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      onPressed: () => context.push(
                        '/payment/checkout?invoice=${Uri.encodeComponent(invoiceId)}',
                      ),
                      child: Text(l10n.duesPayCta(dueStr)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _amountInteger(double v) {
    final s = v.toStringAsFixed(2);
    return s.split('.')[0];
  }

  String _amountDecimal(double v) {
    final s = v.toStringAsFixed(2);
    return ',${s.split('.')[1]}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: valueColor,
              ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isMonospace = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: valueColor,
              fontFeatures: isMonospace
                  ? const [FontFeature.tabularFigures()]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
