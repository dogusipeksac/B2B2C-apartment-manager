import 'package:apartment_manager/core/utils/relative_time.dart';
import 'package:apartment_manager/features/issues/domain/issue_comment_ui.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

final _statusCommentPrefix = RegExp(
  r'^\[status:([a-z_]+)\]\s*(.*)$',
  caseSensitive: false,
  dotAll: true,
);

(IssueUiStatus?, String) _parseCommentBody(String raw) {
  final trimmed = raw.trim();
  final match = _statusCommentPrefix.firstMatch(trimmed);
  if (match == null) {
    return (null, trimmed);
  }
  final status = _statusFromWire(match.group(1));
  final text = match.group(2)?.trim() ?? '';
  return (status, text);
}

List<IssueCommentUi> commentsFromWire(List<dynamic>? raw) {
  if (raw == null) {
    return const [];
  }
  return raw.map((item) {
    final m = Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
    final createdRaw = m['created_at'];
    var created = DateTime.now();
    if (createdRaw is String) {
      created = DateTime.tryParse(createdRaw)?.toLocal() ?? created;
    }
    final rawBody = m['body'] as String? ?? '';
    final (statusUpdate, body) = _parseCommentBody(rawBody);
    return IssueCommentUi(
      id: m['id'] as String? ?? '',
      body: body,
      authorName: (m['author_name'] as String?)?.trim() ?? '',
      createdAt: created,
      statusUpdate: statusUpdate,
    );
  }).toList();
}

IssueUi issueUiFromWire(
  Map<String, dynamic> wire, {
  List<IssueCommentUi> comments = const [],
}) {
  final createdRaw = wire['created_at'];
  DateTime? created;
  if (createdRaw is String) {
    created = DateTime.tryParse(createdRaw);
  }

  final publicCode = (wire['public_code'] as String?)?.trim();
  final code = (publicCode != null && publicCode.isNotEmpty)
      ? publicCode
      : '#—';

  final assigneeName = (wire['assignee_name'] as String?)?.trim() ?? '';

  return IssueUi(
    id: wire['id'] as String? ?? '',
    publicCode: code,
    title: wire['title'] as String? ?? '',
    subtitle: '',
    status: _statusFromWire(wire['status'] as String?),
    priority: _priorityFromWire(wire['priority'] as String?),
    category: _categoryFromWire(wire['category'] as String?),
    relativeTime: created != null
        ? formatRelativeTimeTr(created.toLocal())
        : '',
    commentCount: wire['comment_count'] as int? ?? 0,
    assigneeLabel: assigneeName.isNotEmpty ? assigneeName : '—',
    description: wire['description'] as String? ?? '',
    photoCount: wire['photo_count'] as int? ?? 0,
    isOwnReport: wire['is_own_report'] == true,
    avatarInitials: wire['avatar_initials'] as String? ?? '??',
    footerAssigneeName: wire['footer_assignee_name'] as String? ?? '',
    locationCode: wire['location_code'] as String?,
    comments: comments,
    createdAt: created?.toLocal(),
    latestCommentPreview:
        (wire['latest_comment_preview'] as String?)?.trim(),
    latestCommentAuthor:
        (wire['latest_comment_author'] as String?)?.trim(),
  );
}

IssueUiStatus _statusFromWire(String? raw) {
  switch (raw?.trim().toLowerCase()) {
    case 'in_progress':
      return IssueUiStatus.inProgress;
    case 'resolved':
    case 'closed':
      return IssueUiStatus.resolved;
    default:
      return IssueUiStatus.open;
  }
}

IssueUiPriority _priorityFromWire(String? raw) {
  switch (raw?.trim().toLowerCase()) {
    case 'low':
      return IssueUiPriority.low;
    case 'high':
    case 'urgent':
      return IssueUiPriority.high;
    default:
      return IssueUiPriority.medium;
  }
}

IssueUiCategory _categoryFromWire(String? raw) {
  switch (raw?.trim().toLowerCase()) {
    case 'plumbing':
      return IssueUiCategory.plumbing;
    case 'electric':
      return IssueUiCategory.electric;
    case 'elevator':
    case 'heating':
    case 'cleaning':
    case 'security':
    case 'common_area':
      return IssueUiCategory.mechanical;
    default:
      return IssueUiCategory.other;
  }
}

String categoryWireValue(IssueUiCategory category) {
  return switch (category) {
    IssueUiCategory.plumbing => 'plumbing',
    IssueUiCategory.electric => 'electric',
    IssueUiCategory.mechanical => 'mechanical',
    IssueUiCategory.other => 'other',
  };
}

String priorityWireValue(IssueUiPriority priority) {
  return switch (priority) {
    IssueUiPriority.low => 'low',
    IssueUiPriority.medium => 'medium',
    IssueUiPriority.high => 'high',
  };
}

String statusWireValue(IssueUiStatus status) {
  return switch (status) {
    IssueUiStatus.open => 'open',
    IssueUiStatus.inProgress => 'in_progress',
    IssueUiStatus.resolved => 'resolved',
  };
}
