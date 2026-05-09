import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/features/issues/presentation/providers/issue_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IssuesKanbanScreen extends ConsumerWidget {
  const IssuesKanbanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(issuesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.issuesKanbanTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.catalogLoadError)),
        data: (List<IssueUi> rows) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _KanbanColumn(
                  title: 'Açık',
                  rows: rows
                      .where((r) => r.status == IssueUiStatus.open)
                      .toList(),
                ),
              ),
              Expanded(
                child: _KanbanColumn(
                  title: 'İşlemde',
                  rows: rows
                      .where((r) => r.status == IssueUiStatus.inProgress)
                      .toList(),
                ),
              ),
              Expanded(
                child: _KanbanColumn(
                  title: 'Çözüldü',
                  rows: rows
                      .where((r) => r.status == IssueUiStatus.resolved)
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<IssueUi> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const Divider(),
            ...rows.map(
              (IssueUi row) => ListTile(
                dense: true,
                title: Text(row.title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
