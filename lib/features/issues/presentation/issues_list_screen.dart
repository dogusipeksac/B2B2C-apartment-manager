import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/features/issues/presentation/providers/issue_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class IssuesListScreen extends ConsumerWidget {
  const IssuesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(issuesListProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.issuesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.homeFeatureSoon)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.secondary,
        onPressed: () => context.push('/issues/create'),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.catalogLoadError)),
        data: (rows) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final row = rows[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                    child: Icon(
                      _icon(row.category),
                      color: AppTheme.primary,
                    ),
                  ),
                  title: Text(row.title),
                  subtitle: Text(
                    '${row.publicCode} · ${row.relativeTime}\n${row.subtitle}',
                  ),
                  isThreeLine: true,
                  trailing: row.priority == IssueUiPriority.high
                      ? Icon(Icons.priority_high, color: AppTheme.error)
                      : null,
                  onTap: () => context.push('/issues/${row.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _icon(IssueUiCategory c) {
    switch (c) {
      case IssueUiCategory.plumbing:
        return Icons.water_damage_outlined;
      case IssueUiCategory.electric:
        return Icons.electric_bolt_outlined;
      case IssueUiCategory.mechanical:
        return Icons.precision_manufacturing_outlined;
      case IssueUiCategory.other:
        return Icons.build_outlined;
    }
  }
}
