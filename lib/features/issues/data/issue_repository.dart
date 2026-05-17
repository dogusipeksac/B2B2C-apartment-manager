import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/issues/domain/create_issue_input.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
abstract class IssueRepository {
  Future<List<IssueUi>> listIssues(LocalSession session);

  Future<IssueUi?> byId(LocalSession session, String id);

  Future<String> createIssue(LocalSession session, CreateIssueInput input);

  Future<void> updateStatus(
    LocalSession session, {
    required String issueId,
    required IssueUiStatus status,
    String? note,
  });
}
