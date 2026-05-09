import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/features/issues/presentation/providers/issue_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **5.3** — Arıza detay + süreç özeti (demo).
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

    return FutureBuilder<IssueUi?>(
      future: repo.byId(issueId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.issueDetailTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final row = snapshot.data;
        if (row == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.issueDetailTitle)),
            body: Center(child: Text(l10n.catalogEmptyTitle)),
          );
        }

        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final apart = context.apart;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              row.publicCode,
              style: theme.textTheme.titleSmall,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.homeFeatureSoon)),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusChip(
                    label: _statusLabel(l10n, row.status),
                    color: _statusColor(row.status),
                    bg: _statusBg(row.status),
                  ),
                  if (row.priority == IssueUiPriority.high)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '▲ ${l10n.issuePriorityHigh}',
                        style: TextStyle(
                          color: scheme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                row.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                row.subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: apart.onSurfaceVariant,
                ),
              ),
              if (row.photoCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6F8071), Color(0xFF3a4a3d)],
                    ),
                  ),
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          '${row.photoCount} foto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                row.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.issueTimelineSection,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: apart.onSurfaceVariant,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _TimelineCard(l10n: l10n, row: row),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(AppLocalizations l10n, IssueUiStatus s) {
    return switch (s) {
      IssueUiStatus.open => l10n.duesFilterOpen,
      IssueUiStatus.inProgress => l10n.issueTimelineInProgress,
      IssueUiStatus.resolved => l10n.duesFilterPaid,
    };
  }

  Color _statusColor(IssueUiStatus s) {
    return switch (s) {
      IssueUiStatus.open => AppTheme.info,
      IssueUiStatus.inProgress => AppTheme.warning,
      IssueUiStatus.resolved => AppTheme.success,
    };
  }

  Color _statusBg(IssueUiStatus s) {
    return switch (s) {
      IssueUiStatus.open => AppTheme.infoContainer,
      IssueUiStatus.inProgress => AppTheme.warningContainer,
      IssueUiStatus.resolved => const Color(0xFFE8F5E9),
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.l10n,
    required this.row,
  });

  final AppLocalizations l10n;
  final IssueUi row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelineRow(
              dotColor: AppTheme.success,
              ring: scheme.primaryContainer,
              title: l10n.issueTimelineReported,
              time: '11:24',
              caption: l10n.issueDemoReportedBy,
            ),
            const Divider(height: 20),
            _TimelineRow(
              dotColor: AppTheme.info,
              ring: scheme.tertiaryContainer,
              title: l10n.issueTimelineSeen,
              time: '11:42',
              caption: l10n.issueTimelineSeenBody(row.assigneeLabel),
            ),
            if (row.status != IssueUiStatus.open) ...[
              const Divider(height: 20),
              _TimelineRow(
                dotColor: AppTheme.warning,
                ring: AppTheme.warningContainer,
                title: l10n.issueTimelineInProgress,
                time: '14:08',
                note: l10n.issueDemoInProgressNote,
                noteFooter: l10n.issueDemoManagerName,
              ),
            ],
            const Divider(height: 20),
            Row(
              children: [
                _DotOutline(),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.issueTimelineResolved,
                        style: TextStyle(
                          fontSize: 13,
                          color: apart.onSurfaceTertiary,
                        ),
                      ),
                      Text(
                        row.status == IssueUiStatus.resolved
                            ? '10:00'
                            : l10n.issueTimelinePending,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: apart.onSurfaceTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.dotColor,
    required this.ring,
    required this.title,
    required this.time,
    this.caption,
    this.note,
    this.noteFooter,
  });

  final Color dotColor;
  final Color ring;
  final String title;
  final String time;
  final String? caption;
  final String? note;
  final String? noteFooter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    time,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceTertiary,
                    ),
                  ),
                ],
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: apart.onSurfaceVariant,
                  ),
                ),
              if (note != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: apart.scaffoldBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"$note"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (noteFooter != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            noteFooter!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: apart.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DotOutline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final apart = context.apart;
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: scheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: apart.outlineMuted, width: 2),
      ),
    );
  }
}
