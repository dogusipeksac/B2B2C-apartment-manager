import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

class IssueStatusUpdateInput {
  const IssueStatusUpdateInput({
    required this.status,
    this.note,
  });

  final IssueUiStatus status;
  final String? note;
}
