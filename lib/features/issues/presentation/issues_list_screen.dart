import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/features/issues/presentation/providers/issue_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **5.1** — Arıza listesi (filtre chip’leri, kart gölgeleri, FAB).
class IssuesListScreen extends ConsumerStatefulWidget {
  const IssuesListScreen({super.key});

  @override
  ConsumerState<IssuesListScreen> createState() => _IssuesListScreenState();
}

class _IssuesListScreenState extends ConsumerState<IssuesListScreen> {
  int _filterIdx = 0;

  List<String> _chipLabels(AppLocalizations l10n, List<IssueUi> rows) {
    final n = rows.length;
    final open = rows.where((r) => r.status == IssueUiStatus.open).length;
    final prog = rows.where((r) => r.status == IssueUiStatus.inProgress).length;
    final res = rows.where((r) => r.status == IssueUiStatus.resolved).length;
    return [
      l10n.issuesChipAll('$n'),
      l10n.issuesChipOpen('$open'),
      l10n.issuesChipInProgress('$prog'),
      l10n.issuesChipResolved('$res'),
    ];
  }

  List<IssueUi> _applyFilter(List<IssueUi> rows, int idx) {
    switch (idx) {
      case 1:
        return rows.where((r) => r.status == IssueUiStatus.open).toList();
      case 2:
        return rows.where((r) => r.status == IssueUiStatus.inProgress).toList();
      case 3:
        return rows.where((r) => r.status == IssueUiStatus.resolved).toList();
      default:
        return rows;
    }
  }

  ({Color bg, Color fg, Color border}) _chipPalette(int i, bool selected) {
    if (selected) {
      return switch (i) {
        0 => (
          bg: AppTheme.primary,
          fg: Colors.white,
          border: AppTheme.primary,
        ),
        1 => (
          bg: AppTheme.info,
          fg: Colors.white,
          border: AppTheme.info,
        ),
        2 => (
          bg: AppTheme.warning,
          fg: Colors.white,
          border: AppTheme.warning,
        ),
        _ => (
          bg: AppTheme.success,
          fg: Colors.white,
          border: AppTheme.success,
        ),
      };
    }
    return switch (i) {
      0 => (
        bg: AppTheme.surface,
        fg: AppTheme.onSurfaceVariant,
        border: AppTheme.outlineMuted,
      ),
      1 => (
        bg: AppTheme.infoContainer,
        fg: AppTheme.info,
        border: AppTheme.info.withValues(alpha: 0.35),
      ),
      2 => (
        bg: AppTheme.warningContainer,
        fg: AppTheme.warning,
        border: AppTheme.warning.withValues(alpha: 0.35),
      ),
      _ => (
        bg: AppTheme.primaryContainer,
        fg: AppTheme.primary,
        border: AppTheme.primary.withValues(alpha: 0.35),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(issuesListProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.issuesTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: AppTheme.surface,
              elevation: 1,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.homeFeatureSoon)),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.secondary,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () => context.push('/issues/create'),
        child: const Icon(Icons.add, size: 28),
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
                        final p = _chipPalette(i, active);
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i < labels.length - 1 ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterIdx = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: p.bg,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: p.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  color: p.fg,
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final row = filtered[i];
                    return _IssueCard(
                      row: row,
                      l10n: l10n,
                      onTap: () => context.push('/issues/${row.id}'),
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
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.row,
    required this.l10n,
    required this.onTap,
  });

  final IssueUi row;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  String _statusBadgeLabel() {
    return switch (row.status) {
      IssueUiStatus.open => l10n.issuesBadgeOpen,
      IssueUiStatus.inProgress => l10n.issuesBadgeInProgress,
      IssueUiStatus.resolved => l10n.issuesBadgeResolved,
    };
  }

  ({Color bg, Color fg}) _statusBadgeColors() {
    return switch (row.status) {
      IssueUiStatus.open => (
        bg: AppTheme.infoContainer,
        fg: AppTheme.info,
      ),
      IssueUiStatus.inProgress => (
        bg: AppTheme.warningContainer,
        fg: AppTheme.warning,
      ),
      IssueUiStatus.resolved => (
        bg: AppTheme.primaryContainer,
        fg: AppTheme.success,
      ),
    };
  }

  (Color bg, Color fg, IconData icon) _categoryVisual() {
    return switch (row.category) {
      IssueUiCategory.plumbing => (
        AppTheme.infoContainer,
        AppTheme.info,
        Icons.water_drop_outlined,
      ),
      IssueUiCategory.electric => (
        AppTheme.warningContainer,
        AppTheme.warning,
        Icons.electric_bolt_outlined,
      ),
      IssueUiCategory.mechanical => (
        AppTheme.secondaryContainer,
        const Color(0xFFE65100),
        Icons.edit_outlined,
      ),
      IssueUiCategory.other => (
        AppTheme.primaryContainer,
        AppTheme.primary,
        Icons.build_outlined,
      ),
    };
  }

  Color _avatarBg() {
    if (row.isOwnReport) {
      return AppTheme.secondary;
    }
    return AppTheme.primary;
  }

  bool get _showFooter => row.status != IssueUiStatus.resolved;

  @override
  Widget build(BuildContext context) {
    final outer = Theme.of(context);
    final theme = outer.brightness == Brightness.dark
        ? outer.copyWith(textTheme: AppTheme.light().textTheme)
        : outer;
    final resolved = row.status == IssueUiStatus.resolved;
    final metaMuted = resolved
        ? AppTheme.onSurfaceVariant
        : AppTheme.onSurfaceTertiary;
    final titleColor = resolved
        ? AppTheme.onSurfaceVariant
        : const Color(0xFF1A1A1A);
    final sb = _statusBadgeColors();
    final (catBg, catFg, catIcon) = _categoryVisual();

    return Theme(
      data: theme,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
              border: Border.all(color: AppTheme.outlineMuted),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sb.bg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusBadgeLabel(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: sb.fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${row.publicCode} · ${row.relativeTime}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: metaMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          catIcon,
                          color: catFg,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                height: 1.25,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              row.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (row.priority == IssueUiPriority.high &&
                          row.status != IssueUiStatus.resolved)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.change_history_rounded,
                            color: AppTheme.error,
                            size: 22,
                          ),
                        ),
                    ],
                  ),
                  if (_showFooter) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _avatarBg(),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            row.avatarInitials.length > 2
                                ? row.avatarInitials.substring(0, 2)
                                : row.avatarInitials,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            row.isOwnReport
                                ? l10n.issuesFooterOwnReport
                                : l10n.issuesFooterTracking(
                                    row.footerAssigneeName,
                                  ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (row.commentCount > 0) ...[
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 15,
                            color: AppTheme.onSurfaceTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${row.commentCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.onSurfaceTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
