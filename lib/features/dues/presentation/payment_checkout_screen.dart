import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';
import 'package:apartment_manager/features/dues/presentation/providers/dues_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.3** — iyzico ödeme ekranı.
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

class _PaymentCheckoutScreenState
    extends ConsumerState<PaymentCheckoutScreen> {
  final _cvv = TextEditingController();
  int _selectedCard = 0; // 0 = kayıtlı kart, 1 = yeni kart

  @override
  void dispose() {
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;
    final scheme = theme.colorScheme;
    final repo = ref.watch(duesRepositoryProvider);

    return FutureBuilder<DuesInvoiceUi?>(
      future: repo.invoiceById(widget.invoiceId),
      builder: (context, snapshot) {
        final inv = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.paymentTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'iyzico',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: apart.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : inv == null
                  ? Center(child: Text(l10n.catalogEmptyTitle))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: apart.scaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MART 2026 · 3A',
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Yeşil Vadi Apt.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                formatTL(inv.amountDueKurus / 100),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'KAYITLI KART',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: apart.onSurfaceVariant,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _CardTile(
                          label: '•••• 4729',
                          sublabel: 'Mehmet Yılmaz · 09/27',
                          selected: _selectedCard == 0,
                          onTap: () => setState(() => _selectedCard = 0),
                        ),
                        const SizedBox(height: 8),
                        _NewCardTile(
                          label: l10n.paymentNewCard,
                          selected: _selectedCard == 1,
                          onTap: () => setState(() => _selectedCard = 1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CVV',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: apart.onSurfaceVariant,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _cvv,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '•••',
                              filled: true,
                              fillColor: apart.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: apart.outlineMuted,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 18,
                                color: scheme.tertiary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: scheme.onTertiaryContainer,
                                      height: 1.4,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: '3D Secure',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' ile güvenli ödeme. SMS doğrulama gelecek.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: apart.outlineMuted,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toplam',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: apart.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                formatTL(inv.amountDueKurus / 100),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    onPressed: (loading || inv == null)
                        ? null
                        : () => context.go('/payment/success'),
                    icon: const Icon(Icons.lock_outline),
                    child: Text(l10n.paymentSecurePay),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '3D Secure · iyzico ile korunmaktadır',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceTertiary,
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

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : apart.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primary : apart.outlineMuted,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A1A), Color(0xFF444444)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _NewCardTile extends StatelessWidget {
  const _NewCardTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 0.85,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: apart.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: apart.outlineMuted),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: apart.onSurfaceVariant,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: apart.onSurfaceTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _RadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppTheme.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppTheme.primary : apart.outlineMuted,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
