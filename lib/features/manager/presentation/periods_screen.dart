import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PeriodsScreen extends StatelessWidget {
  const PeriodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.managerPeriodsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.demoPeriodActive, style: Theme.of(context).textTheme.labelMedium),
                  Text(
                    'Mart 2026',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: 0.78, color: AppTheme.primary),
                  Text('%78 ${l10n.demoPeriodCollectionRate}'),
                  const SizedBox(height: 8),
                  Text('${l10n.demoSampleDateShort} · 18 daire'),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Şubat 2026'),
            trailing: Text(formatTL(27000)),
          ),
        ],
      ),
    );
  }
}
