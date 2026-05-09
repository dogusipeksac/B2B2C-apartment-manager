import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpenseNewScreen extends StatelessWidget {
  const ExpenseNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.managerExpenseTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '₺3.450,00',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          TextField(
            decoration: InputDecoration(labelText: l10n.issueFieldTitle),
          ),
          AppButton(
            onPressed: () => context.pop(),
            child: Text(l10n.demoExpenseSave),
          ),
        ],
      ),
    );
  }
}
