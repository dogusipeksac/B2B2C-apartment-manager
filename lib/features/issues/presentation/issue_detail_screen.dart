import 'package:apartment_manager/features/issues/presentation/providers/issue_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IssueDetailScreen extends ConsumerWidget {
  const IssueDetailScreen({
    required this.issueId,
    super.key,
  });

  final String issueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(issueRepositoryProvider);

    return FutureBuilder(
      future: repo.byId(issueId),
      builder: (context, snapshot) {
        final row = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.issueDetailTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (row == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.issueDetailTitle)),
            body: Center(child: Text(l10n.catalogEmptyTitle)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(row.publicCode),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                row.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(row.description),
              const SizedBox(height: 24),
              Text(
                'Süreç',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Bildirildi'),
              ),
              const ListTile(
                leading: Icon(Icons.visibility, color: Colors.blue),
                title: Text('Görüldü'),
              ),
              ListTile(
                leading: const Icon(Icons.hourglass_top, color: Colors.orange),
                title: Text(row.status.name),
              ),
            ],
          ),
        );
      },
    );
  }
}
