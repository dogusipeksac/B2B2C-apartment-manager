import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

class CreateIssueInput {
  const CreateIssueInput({
    required this.title,
    required this.description,
    required this.category,
    required this.locationCode,
    required this.priority,
  });

  final String title;
  final String description;
  final IssueUiCategory category;
  final String locationCode;
  final IssueUiPriority priority;
}
