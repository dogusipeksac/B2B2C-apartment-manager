import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';
import 'package:apartment_manager/features/dues/presentation/providers/dues_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  const PaymentCheckoutScreen({
    required this.invoiceId,
    super.key,
  });

  final String invoiceId;

  @override
  ConsumerState<PaymentCheckoutScreen> createState() =>
      _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends ConsumerState<PaymentCheckoutScreen> {
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(duesRepositoryProvider);

    return FutureBuilder<DuesInvoiceUi?>(
      future: repo.invoiceById(widget.invoiceId),
      builder: (context, snapshot) {
        final inv = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.paymentTitle)),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : inv == null
                  ? Center(child: Text(l10n.catalogEmptyTitle))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          '${inv.periodLabel} · ${formatTL(inv.amountDueKurus / 100)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: RadioListTile<int>(
                            value: 1,
                            groupValue: 1,
                            onChanged: (_) {},
                            title: const Text('Visa **** 4729'),
                            subtitle: const Text('Mehmet Yılmaz · 08/27'),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: Text(l10n.paymentNewCard),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.homeFeatureSoon)),
                            );
                          },
                        ),
                        TextField(
                          controller: _cvv,
                          decoration: const InputDecoration(labelText: 'CVV'),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              l10n.payment3dInfo,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.paymentTotal(
                            formatTL(inv.amountDueKurus / 100),
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                onPressed: loading || inv == null
                    ? null
                    : () => context.go('/payment/success'),
                icon: const Icon(Icons.lock_outline),
                child: Text(l10n.paymentSecurePay),
              ),
            ),
          ),
        );
      },
    );
  }
}
