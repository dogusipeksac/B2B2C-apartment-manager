import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

class IssueCommentUi {
  const IssueCommentUi({
    required this.id,
    required this.body,
    required this.authorName,
    required this.createdAt,
    this.statusUpdate,
  });

  final String id;

  /// Display text (status prefix stripped).
  final String body;
  final String authorName;
  final DateTime createdAt;

  /// Set when comment encodes a manager status change.
  final IssueUiStatus? statusUpdate;
}
