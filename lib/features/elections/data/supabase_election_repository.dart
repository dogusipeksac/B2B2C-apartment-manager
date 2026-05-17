import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/elections/data/election_ops_repository.dart';
import 'package:apartment_manager/features/elections/data/election_repository.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';

class SupabaseElectionRepository implements ElectionRepository {
  SupabaseElectionRepository(this._ops);

  final ElectionOpsRepository _ops;

  @override
  Future<List<ElectionUi>> listElections(LocalSession session) =>
      _ops.listElections(session);

  @override
  Future<ElectionUi?> activeElection(LocalSession session) =>
      _ops.activeElection(session);

  @override
  Future<ElectionDetailUi?> getElection(
    LocalSession session,
    String electionId,
  ) =>
      _ops.getElection(session, electionId);

  @override
  Future<String> createElection(
    LocalSession session, {
    required String title,
    String? description,
    DateTime? nominationsCloseAt,
    DateTime? closesAt,
  }) =>
      _ops.createElection(
        session,
        title: title,
        description: description,
        nominationsCloseAt: nominationsCloseAt,
        closesAt: closesAt,
      );

  @override
  Future<void> startElection(LocalSession session, String electionId) =>
      _ops.startElection(session, electionId);

  @override
  Future<void> startVoting(LocalSession session, String electionId) =>
      _ops.startVoting(session, electionId);

  @override
  Future<void> closeElection(LocalSession session, String electionId) =>
      _ops.closeElection(session, electionId);

  @override
  Future<void> nominate(LocalSession session, String electionId) =>
      _ops.nominate(session, electionId);

  @override
  Future<void> vote(
    LocalSession session, {
    required String electionId,
    required String candidateId,
  }) =>
      _ops.vote(
        session,
        electionId: electionId,
        candidateId: candidateId,
      );
}
