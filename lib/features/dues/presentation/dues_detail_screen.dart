import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';
import 'package:apartment_manager/features/dues/presentation/providers/dues_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        final row = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.duesDetailTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (row == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.duesDetailTitle)),
            body: Center(child: Text(l10n.catalogEmptyTitle)),
          );
        }

        final theme = Theme.of(context);
        final dueStr = formatTL(row.amountDueKurus / 100);

        return Scaffold(
          appBar: AppBar(
            title: Text(row.periodLabel),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (row.status == DuesInvoiceUiStatus.overdue)
                Card(
                  color: AppTheme.error.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${row.daysLate} gün gecikti. Gecikme faizi uygulanıyor.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                color: AppTheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.duesAmountDue,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTL(row.amountDueKurus / 100),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${l10n.duesLineBase}: ${formatTL(row.amountKurus / 100)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (row.lateFeeKurus > 0)
                        Text(
                          '${l10n.duesLineLateFee('${row.daysLate}')}: +${formatTL(row.lateFeeKurus / 100)}',
                          style: const TextStyle(color: Color(0xFFFFE082)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n.duesDetailApartmentTitle),
                subtitle: Text(l10n.duesDetailApartmentValue),
              ),
              ListTile(
                title: Text(l10n.duesDetailPeriodTitle),
                subtitle: Text('1–31 ${row.periodLabel.split(' ').last}'),
              ),
              ListTile(
                title: Text(l10n.duesDetailDueTitle),
                subtitle: Text(
                  formatDate(row.dueDate),
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.error),
                ),
              ),
              ListTile(
                title: Text(l10n.duesDetailInvoiceTitle),
                subtitle: Text(row.invoiceCode),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
}
