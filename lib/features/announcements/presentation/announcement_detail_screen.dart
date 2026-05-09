import 'package:apartment_manager/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({
    required this.announcementId,
    super.key,
  });

  final String announcementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(announcementRepositoryProvider);

    return FutureBuilder(
      future: repo.byId(announcementId),
      builder: (context, snapshot) {
        final row = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.announcementDetailTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (row == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.announcementDetailTitle)),
            body: Center(child: Text(l10n.catalogEmptyTitle)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.announcementDetailTitle),
            actions: [
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                row.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      row.authorName.isEmpty
                          ? '?'
                          : row.authorName.substring(0, 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${row.authorName} · ${row.roleLabel}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(row.body, style: Theme.of(context).textTheme.bodyLarge),
              if (row.attachmentName != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text(row.attachmentName!),
                    subtitle: Text(row.attachmentSizeLabel ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: ListTile(
              leading: const CircleAvatar(child: Text('M')),
              title: TextField(
                decoration: InputDecoration(
                  hintText: 'Yorum yaz... (${row.commentCount})',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.send_outlined),
                onPressed: () {},
              ),
            ),
          ),
        );
      },
    );
  }
}
