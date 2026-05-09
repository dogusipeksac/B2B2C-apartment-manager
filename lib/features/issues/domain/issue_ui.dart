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
}
