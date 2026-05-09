import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

abstract class IssueRepository {
  Future<List<IssueUi>> listIssues();

  Future<IssueUi?> byId(String id);
}
