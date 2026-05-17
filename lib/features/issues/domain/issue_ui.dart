import 'package:apartment_manager/features/issues/domain/issue_comment_ui.dart';

enum IssueUiStatus {
  open,
  inProgress,
  resolved,
}

enum IssueUiPriority {
  low,
  medium,
  high,
}

enum IssueUiCategory {
  plumbing,
  electric,
  mechanical,
  other,
}

class IssueUi {
  const IssueUi({
    required this.id,
    required this.publicCode,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.priority,
    required this.category,
    required this.relativeTime,
    required this.commentCount,
    required this.assigneeLabel,
    required this.description,
    required this.photoCount,
    required this.isOwnReport,
    required this.avatarInitials,
    required this.footerAssigneeName,
    this.locationCode,
    this.comments = const [],
    this.createdAt,
    this.latestCommentPreview,
    this.latestCommentAuthor,
  });

  final String id;
  final String publicCode;
  final String title;
  final String subtitle;
  final IssueUiStatus status;
  final IssueUiPriority priority;
  final IssueUiCategory category;
  final String relativeTime;
  final int commentCount;
  final String assigneeLabel;
  final String description;
  final int photoCount;

  /// List row: "Senin bildirim" vs "{name} takipte".
  final bool isOwnReport;

  /// Two-letter avatar on list cards.
  final String avatarInitials;

  /// Short name for "takipte" footer (e.g. `Ayşe D.`). Empty if not shown.
  final String footerAssigneeName;

  /// Wire location code (`apartment`, `parking`, …); optional for demo rows.
  final String? locationCode;

  /// Manager / process notes (detail screen timeline).
  final List<IssueCommentUi> comments;

  final DateTime? createdAt;

  /// Last manager note preview (list cards).
  final String? latestCommentPreview;

  final String? latestCommentAuthor;
}
