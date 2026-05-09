import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';
import 'package:apartment_manager/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.5** — Duyuru feed: PIN/kategori chip, okundu durumu.
class AnnouncementsListScreen extends ConsumerStatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  ConsumerState<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState
    extends ConsumerState<AnnouncementsListScreen> {
  int _filterIdx = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(announcementsListProvider);

    final filterLabels = [
      'Tümü',
      '📌 Sabit',
      '⚠️ Acil',
      'Bilgi',
      'Bakım',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.announcementsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.homeFeatureSoon)),
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.catalogLoadError)),
        data: (rows) {
          final filtered = _applyFilter(rows, _filterIdx);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(filterLabels.length, (i) {
                        final active = _filterIdx == i;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i < filterLabels.length - 1 ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterIdx = i),
                            child: Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppTheme.primary
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: active
                                      ? AppTheme.primary
                                      : AppTheme.outlineMuted,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                filterLabels[i],
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : AppTheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final row = filtered[i];
                    final isPinned =
                        row.category == AnnouncementUiCategory.pinned;
                    return Opacity(
                      opacity: row.read ? 0.7 : 1.0,
                      child: Material(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () =>
                              context.push('/announcements/${row.id}'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(
                                  color: isPinned
                                      ? AppTheme.secondary
                                      : AppTheme.outlineMuted,
                                  width: isPinned ? 3 : 1,
                                ),
                                top: const BorderSide(
                                  color: AppTheme.outlineMuted,
                                ),
                                right: const BorderSide(
                                  color: AppTheme.outlineMuted,
                                ),
                                bottom: const BorderSide(
                                  color: AppTheme.outlineMuted,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _CatChip(
                                      l10n: l10n,
                                      category: row.category,
                                      pinned: isPinned,
                                    ),
                                    Text(
                                      row.relativeTime +
                                          (row.read ? ' · Okundu' : ''),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppTheme.onSurfaceTertiary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  row.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: row.category ==
                                                AnnouncementUiCategory.pinned
                                            ? 16
                                            : 15,
                                        color: row.read
                                            ? AppTheme.onSurfaceVariant
                                            : null,
                                      ),
                                ),
                                if (row.snippet.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    row.snippet,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                                if (!row.read) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _AuthorAvatar(
                                        name: row.authorName,
                                        size: row.category ==
                                                AnnouncementUiCategory.pinned
                                            ? 24
                                            : 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${row.authorName} · ${row.roleLabel}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color:
                                                    AppTheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                      if (row.viewCount > 0) ...[
                                        Text(
                                          '👁 ${row.viewCount}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color:
                                                    AppTheme.onSurfaceTertiary,
                                              ),
                                        ),
                                        if (row.commentCount > 0)
                                          const SizedBox(width: 12),
                                      ],
                                      if (row.commentCount > 0)
                                        Text(
                                          '💬 ${row.commentCount}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color:
                                                    AppTheme.onSurfaceTertiary,
                                              ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AnnouncementUi> _applyFilter(
    List<AnnouncementUi> rows,
    int idx,
  ) {
    switch (idx) {
      case 1:
        return rows
            .where((r) => r.category == AnnouncementUiCategory.pinned)
            .toList();
      case 2:
        return rows
            .where((r) => r.category == AnnouncementUiCategory.urgent)
            .toList();
      case 3:
        return rows
            .where((r) => r.category == AnnouncementUiCategory.info)
            .toList();
      case 4:
        return rows
            .where(
              (r) => r.category == AnnouncementUiCategory.maintenance,
            )
            .toList();
      default:
        return rows;
    }
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.l10n,
    required this.category,
    required this.pinned,
  });

  final AppLocalizations l10n;
  final AnnouncementUiCategory category;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    late Color fg;
    late Color bg;
    late String label;
    switch (category) {
      case AnnouncementUiCategory.pinned:
        fg = AppTheme.secondary;
        bg = AppTheme.secondaryContainer;
        label = '📌 ${l10n.announcementCatPinned}';
      case AnnouncementUiCategory.info:
        fg = AppTheme.info;
        bg = AppTheme.infoContainer;
        label = l10n.homeAnnouncementTagInfo;
      case AnnouncementUiCategory.maintenance:
        fg = AppTheme.warning;
        bg = AppTheme.warningContainer;
        label = l10n.announcementCatMaintenance;
      case AnnouncementUiCategory.urgent:
        fg = AppTheme.error;
        bg = AppTheme.errorContainer;
        label = l10n.announcementCatUrgent;
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

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    required this.name,
    required this.size,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
