import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Mockup **6.1** — Daireler grid (demo veri).
class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text('${l10n.managerUnitsTitle} · 18'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.homeFeatureSoon)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: 6,
        itemBuilder: (context, floor) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.managerFloorHeading('${floor + 1}'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: apart.onSurfaceVariant,
                        letterSpacing: 0.48,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.managerFloorUnitCount('3'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: apart.onSurfaceTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final u in ['A', 'B', 'C'])
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: u != 'C' ? 8 : 0,
                          ),
                          child: _UnitCell(
                            label: '${floor + 1}$u',
                            highlight: floor == 2 && u == 'A',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UnitCell extends StatelessWidget {
  const _UnitCell({
    required this.label,
    this.highlight = false,
  });

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? scheme.primaryContainer : apart.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? AppTheme.primary : apart.outlineMuted,
          width: highlight ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: highlight ? AppTheme.primary : null,
        ),
      ),
    );
  }
}
