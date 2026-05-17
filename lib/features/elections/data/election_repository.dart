import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';

abstract class ElectionRepository {
  Future<List<ElectionUi>> listElections(LocalSession session);

  Future<ElectionUi?> activeElection(LocalSession session);

  Future<ElectionDetailUi?> getElection(
    LocalSession session,
    String electionId,
  );

  Future<String> createElection(
    LocalSession session, {
    required String title,
    String? description,
    DateTime? nominationsCloseAt,
    DateTime? closesAt,
  });

  Future<void> startElection(LocalSession session, String electionId);

  Future<void> startVoting(LocalSession session, String electionId);

  Future<void> closeElection(LocalSession session, String electionId);

  Future<void> nominate(LocalSession session, String electionId);

  Future<void> vote(
    LocalSession session, {
    required String electionId,
    required String candidateId,
  });
}
