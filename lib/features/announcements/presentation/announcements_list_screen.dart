import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';
import 'package:apartment_manager/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.5** — Duyuru feed (filtre chip’leri, kart gölgesi, sol accent).
class AnnouncementsListScreen extends ConsumerStatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  ConsumerState<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState
    extends ConsumerState<AnnouncementsListScreen> {
  int _filterIdx = 0;

  List<String> _chipLabels(AppLocalizations l10n, List<AnnouncementUi> all) {
    final total = '${all.length}';
    final pinned = all
        .where((r) => r.category == AnnouncementUiCategory.pinned)
        .length;
    return [
      l10n.announcementsChipAll(total),
      l10n.announcementsChipPinned('$pinned'),
      l10n.announcementsChipUrgent,
      l10n.announcementsChipInfo,
      l10n.announcementsChipMaintenance,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(announcementsListProvider);
    final apart = context.apart;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.announcementsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: apart.surface,
              elevation: 1,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.homeFeatureSoon)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.catalogLoadError)),
        data: (rows) {
          final labels = _chipLabels(l10n, rows);
          final filtered = _applyFilter(rows, _filterIdx);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(labels.length, (i) {
                        final active = _filterIdx == i;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i < labels.length - 1 ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterIdx = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 28,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppTheme.primary
                                    : apart.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: active
                                      ? AppTheme.primary
                                      : apart.outlineMuted,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : apart.onSurfaceVariant,
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final row = filtered[i];
                    final isPinned =
                        row.category == AnnouncementUiCategory.pinned;
                    return Opacity(
                      opacity: row.read ? 0.72 : 1,
                      child: _AnnouncementCard(
                        row: row,
                        l10n: l10n,
                        isPinned: isPinned,
                        onTap: () => context.push('/announcements/${row.id}'),
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
              (r) =>
                  r.category == AnnouncementUiCategory.maintenance ||
                  r.secondaryCategory == AnnouncementUiCategory.maintenance,
            )
            .toList();
      default:
        return rows;
    }
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.row,
    required this.l10n,
    required this.isPinned,
    required this.onTap,
  });

  final AnnouncementUi row;
  final AppLocalizations l10n;
  final bool isPinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    final timeLine = row.read
        ? '${row.relativeTime} · ${l10n.announcementsReadLabel}'
        : row.relativeTime;

    // Avoid `Ink` here: inside sliver lists it can size to zero and show an
    // empty white box while decoration still paints.
    return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: apart.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: apart.cardShadow,
              // Uniform border color required when using borderRadius (Flutter
              // assertion). Pinned accent is drawn as a separate strip below.
              border: Border.all(color: apart.outlineMuted),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  if (isPinned)
                    const Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 3,
                      child: ColoredBox(color: AppTheme.secondary),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isPinned ? 17 : 14,
                      14,
                      16,
                      14,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: _CategoryChip(
                                l10n: l10n,
                                category: row.category,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeLine,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: apart.onSurfaceTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          row.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: isPinned ? 16 : 15,
                            height: 1.25,
                            color: row.read
                                ? apart.onSurfaceVariant
                                : scheme.onSurface,
                          ),
                        ),
                        if (row.snippet.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            row.snippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: apart.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _AuthorAvatar(
                              name: row.authorName,
                              category: row.category,
                              size: isPinned ? 24 : 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${row.authorName} · ${row.roleLabel}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: apart.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.visibility_outlined,
                              size: 15,
                              color: apart.onSurfaceTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${row.viewCount}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: apart.onSurfaceTertiary,
                              ),
                            ),
                            if (row.commentCount > 0) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 14,
                                color: apart.onSurfaceTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${row.commentCount}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: apart.onSurfaceTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.l10n,
    required this.category,
  });

  final AppLocalizations l10n;
  final AnnouncementUiCategory category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (fg, bg, label) = switch (category) {
      AnnouncementUiCategory.pinned => (
        const Color(0xFFB57400),
        scheme.secondaryContainer,
        '⭐ ${l10n.announcementCatPinned}',
      ),
      AnnouncementUiCategory.info => (
        scheme.tertiary,
        scheme.tertiaryContainer,
        l10n.homeAnnouncementTagInfo,
      ),
      AnnouncementUiCategory.maintenance => (
        scheme.secondary,
        scheme.secondaryContainer,
        l10n.announcementCatMaintenance,
      ),
      AnnouncementUiCategory.urgent => (
        scheme.error,
        scheme.errorContainer,
        l10n.announcementCatUrgent,
      ),
    };
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
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    required this.name,
    required this.category,
    required this.size,
  });

  final String name;
  final AnnouncementUiCategory category;
  final double size;

  Color get _bg {
    switch (category) {
      case AnnouncementUiCategory.info:
        return AppTheme.info;
      case AnnouncementUiCategory.urgent:
        return AppTheme.error;
      case AnnouncementUiCategory.maintenance:
        return AppTheme.primary;
      case AnnouncementUiCategory.pinned:
        return AppTheme.primary;
    }
  }

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
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
