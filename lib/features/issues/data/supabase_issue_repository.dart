import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/issues/data/issue_ops_repository.dart';
import 'package:apartment_manager/features/issues/data/issue_repository.dart';
import 'package:apartment_manager/features/issues/domain/create_issue_input.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
class SupabaseIssueRepository implements IssueRepository {
  SupabaseIssueRepository(this._ops);

  final IssueOpsRepository _ops;

  @override
  Future<IssueUi?> byId(LocalSession session, String id) =>
      _ops.getIssue(session, id);

  @override
  Future<List<IssueUi>> listIssues(LocalSession session) =>
      _ops.listIssues(session);

  @override
  Future<String> createIssue(
    LocalSession session,
    CreateIssueInput input,
  ) =>
      _ops.createIssue(session, input);

  @override
  Future<void> updateStatus(
    LocalSession session, {
    required String issueId,
    required IssueUiStatus status,
    String? note,
  }) =>
      _ops.updateStatus(
        session,
        issueId: issueId,
        status: status,
        note: note,
      );
}
