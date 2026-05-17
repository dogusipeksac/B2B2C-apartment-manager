import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/issues/domain/issue_comment_ui.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/features/issues/presentation/issue_status_update_sheet.dart';
import 'package:apartment_manager/features/issues/presentation/issue_subtitle.dart';
import 'package:apartment_manager/features/issues/presentation/providers/issue_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Arıza detay — süreç notları yönetici ve sakin için aynı.
class IssueDetailScreen extends ConsumerWidget {
  const IssueDetailScreen({
    required this.issueId,
    super.key,
  });

  final String issueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(localSessionProvider).value;
    final isManager = session?.role == UserRole.buildingAdmin ||
        session?.role == UserRole.buildingCoAdmin;
    final async = ref.watch(issueDetailProvider(issueId));

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.issueDetailTitle)),
        body: Center(child: Text(l10n.errorGeneric)),
      );
    }

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.issueDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.issueDetailTitle)),
        body: Center(
          child: Text(
            error is AppException ? error.userMessage : l10n.errorGeneric,
          ),
        ),
      ),
      data: (row) {
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
          ),
          bottomNavigationBar: isManager
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: scheme.onSecondary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _openStatusUpdate(
                        context,
                        ref,
                        session,
                        row,
                        l10n,
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 22),
                      label: Text(l10n.issueManagerUpdateStatus),
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(issueDetailProvider(issueId));
              ref.invalidate(issuesListProvider);
              await ref.read(issueDetailProvider(issueId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  issueSubtitle(l10n, row),
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
                _TimelineCard(l10n: l10n, row: row, comments: row.comments),
                const SizedBox(height: 24),
              ],
            ),
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

  Future<void> _openStatusUpdate(
    BuildContext context,
    WidgetRef ref,
    LocalSession session,
    IssueUi row,
    AppLocalizations l10n,
  ) async {
    final input = await showIssueStatusUpdateSheet(
      context: context,
      currentStatus: row.status,
      issueCode: row.publicCode,
    );

    if (input == null || !context.mounted) {
      return;
    }
    if (input.status == row.status &&
        (input.note == null || input.note!.isEmpty)) {
      return;
    }

    try {
      await ref.read(issueRepositoryProvider).updateStatus(
        session,
        issueId: row.id,
        status: input.status,
        note: input.note,
      );
      ref.invalidate(issuesListProvider);
      ref.invalidate(issueDetailProvider(row.id));
      await ref.read(issueDetailProvider(row.id).future);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.issueStatusUpdated)),
      );
    } on AppException catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    }
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
    required this.comments,
  });

  final AppLocalizations l10n;
  final IssueUi row;
  final List<IssueCommentUi> comments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final timeFmt = DateFormat.Hm('tr_TR');
    final reportedAt = row.createdAt ?? DateTime.now();

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
              time: timeFmt.format(reportedAt),
              caption: row.title,
            ),
            if (comments.isEmpty &&
                row.latestCommentPreview != null &&
                row.latestCommentPreview!.isNotEmpty) ...[
              const Divider(height: 20),
              _TimelineRow(
                dotColor: _statusDotColor(row.status),
                ring: _statusRingColor(row.status),
                title: _statusLabel(l10n, row.status),
                time: timeFmt.format(DateTime.now()),
                note: row.latestCommentPreview,
                noteFooter: row.latestCommentAuthor?.isNotEmpty ?? false
                    ? row.latestCommentAuthor
                    : null,
              ),
            ] else if (comments.isEmpty &&
                row.status != IssueUiStatus.open) ...[
              const Divider(height: 20),
              _TimelineRow(
                dotColor: _statusDotColor(row.status),
                ring: _statusRingColor(row.status),
                title: _statusLabel(l10n, row.status),
                time: l10n.issueTimelinePending,
              ),
            ],
            for (var i = 0; i < comments.length; i++) ...[
              const Divider(height: 20),
              _commentRow(l10n, comments[i], timeFmt),
            ],
          ],
        ),
      ),
    );
  }

  Widget _commentRow(
    AppLocalizations l10n,
    IssueCommentUi comment,
    DateFormat timeFmt,
  ) {
    final status = comment.statusUpdate;
    final title = status != null
        ? _statusLabel(l10n, status)
        : l10n.issueTimelineManagerNote;

    return _TimelineRow(
      dotColor: status != null
          ? _statusDotColor(status)
          : AppTheme.warning,
      ring: status != null
          ? _statusRingColor(status)
          : AppTheme.warningContainer,
      title: title,
      time: timeFmt.format(comment.createdAt),
      note: comment.body.isNotEmpty ? comment.body : null,
      noteFooter: comment.authorName.isNotEmpty ? comment.authorName : null,
    );
  }

  String _statusLabel(AppLocalizations l10n, IssueUiStatus status) {
    return switch (status) {
      IssueUiStatus.open => l10n.duesFilterOpen,
      IssueUiStatus.inProgress => l10n.issueTimelineInProgress,
      IssueUiStatus.resolved => l10n.issueTimelineResolved,
    };
  }

  Color _statusDotColor(IssueUiStatus status) {
    return switch (status) {
      IssueUiStatus.open => AppTheme.info,
      IssueUiStatus.inProgress => AppTheme.warning,
      IssueUiStatus.resolved => AppTheme.success,
    };
  }

  Color _statusRingColor(IssueUiStatus status) {
    return switch (status) {
      IssueUiStatus.open => AppTheme.infoContainer,
      IssueUiStatus.inProgress => AppTheme.warningContainer,
      IssueUiStatus.resolved => const Color(0xFFE8F5E9),
    };
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
                    border: Border.all(color: apart.outlineMuted),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      if (noteFooter != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            noteFooter!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: apart.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
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
