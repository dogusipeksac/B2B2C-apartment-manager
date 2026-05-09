import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.4** — Ödeme başarılı: tick, makbuz özeti, PDF indir.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tick circle with rings
                    SizedBox(
                      width: 144,
                      height: 144,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 144,
                            height: 144,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF4FAF5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 116,
                            height: 116,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.success.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.paymentSuccessTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.paymentSuccessBody,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ReceiptRow(
                              label: l10n.paymentReceiptAmountLabel,
                              value: l10n.paymentReceiptAmountValue,
                            ),
                            const SizedBox(height: 8),
                            _ReceiptRow(
                              label: l10n.paymentReceiptPeriodLabel,
                              value: l10n.paymentReceiptPeriodValue,
                            ),
                            const SizedBox(height: 8),
                            _ReceiptRow(
                              label: l10n.paymentReceiptTxnLabel,
                              value: l10n.paymentReceiptTxnValue,
                              isMonospace: true,
                            ),
                            const SizedBox(height: 8),
                            _ReceiptRow(
                              label: l10n.paymentReceiptMethodLabel,
                              value: l10n.paymentReceiptMethodValue,
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                  color: AppTheme.success,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '3D Secure ile onaylandı',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text('PDF indirme yakında'),
                            ),
                          ),
                      child: const Text(
                        'Makbuzu indir (PDF)',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.go('/home'),
                      child: Text(l10n.duesMyTitle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      onPressed: () => context.go('/home'),
                      child: Text(l10n.demoNavHome),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  final String label;
  final String value;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFeatures:
                isMonospace ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
      ],
    );
  }
}
