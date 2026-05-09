import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.managerUnitsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, floor) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KAT ${floor + 1}', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var u in ['A', 'B', 'C'])
                    Chip(label: Text('${floor + 1}$u')),
                ],
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
