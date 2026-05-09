import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';
import 'package:apartment_manager/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnnouncementsListScreen extends ConsumerWidget {
  const AnnouncementsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(announcementsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(l10n.announcementsTitle),
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
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.catalogLoadError)),
        data: (rows) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final row = rows[i];
              return Opacity(
                opacity: row.read ? 0.55 : 1,
                child: Card(
                  child: InkWell(
                    onTap: () => context.push('/announcements/${row.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _CatChip(l10n: l10n, category: row.category),
                              Text(
                                row.relativeTime,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            row.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            row.snippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                child: Text(
                                  row.authorName.isNotEmpty
                                      ? row.authorName[0]
                                      : '?',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${row.authorName} · ${row.roleLabel}',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              Icon(
                                Icons.visibility_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              Text(' ${row.viewCount}'),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.comment_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              Text(' ${row.commentCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.l10n,
    required this.category,
  });

  final AppLocalizations l10n;
  final AnnouncementUiCategory category;

  @override
  Widget build(BuildContext context) {
    late Color fg;
    late Color bg;
    late String label;
    switch (category) {
      case AnnouncementUiCategory.pinned:
        fg = AppTheme.secondary;
        bg = AppTheme.secondary.withValues(alpha: 0.15);
        label = l10n.announcementCatPinned;
        break;
      case AnnouncementUiCategory.info:
        fg = const Color(0xFF1565C0);
        bg = const Color(0xFFE3F2FD);
        label = l10n.homeAnnouncementTagInfo;
        break;
      case AnnouncementUiCategory.maintenance:
        fg = AppTheme.secondary;
        bg = Colors.orange.shade50;
        label = l10n.announcementCatMaintenance;
        break;
      case AnnouncementUiCategory.urgent:
        fg = AppTheme.error;
        bg = AppTheme.error.withValues(alpha: 0.08);
        label = l10n.announcementCatUrgent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
