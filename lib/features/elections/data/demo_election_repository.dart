import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/elections/data/election_repository.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';

class DemoElectionRepository implements ElectionRepository {
  const DemoElectionRepository();

  static const _activeId = 'demo-election-active';

  ElectionDetailUi get _activeDetail => ElectionDetailUi(
        election: ElectionUi(
          id: _activeId,
          title: '2026 Yönetici seçimi',
          description:
              'Gizli oy ile bir daire bir oy. Sonuçlar seçim kapanınca açıklanır.',
          status: ElectionStatus.active,
          closesAt: DateTime.now().add(const Duration(days: 5)),
          startedAt: DateTime.now().subtract(const Duration(days: 1)),
          candidateCount: 3,
          hasVoted: false,
        ),
        candidates: const [
          ElectionCandidateUi(
            id: 'c1',
            displayName: 'Ayşe Demir',
            firstName: 'Ayşe',
            initials: 'AD',
            role: ElectionCandidateRole.manager,
            isSelf: false,
          ),
          ElectionCandidateUi(
            id: 'c2',
            displayName: 'Zeynep Yılmaz',
            firstName: 'Zeynep',
            initials: 'ZY',
            role: ElectionCandidateRole.manager,
            isSelf: false,
          ),
          ElectionCandidateUi(
            id: 'c3',
            displayName: 'Mehmet Kaya',
            firstName: 'Mehmet',
            initials: 'MK',
            role: ElectionCandidateRole.resident,
            unitLabel: '22A',
            isSelf: true,
          ),
        ],
        hasVoted: false,
        canVote: true,
        canNominate: true,
        canManage: true,
        resultsVisible: false,
        totalVotes: 12,
      );

  @override
  Future<ElectionUi?> activeElection(LocalSession session) async {
    return _activeDetail.election;
  }

  @override
  Future<List<ElectionUi>> listElections(LocalSession session) async {
    return [
      _activeDetail.election,
      const ElectionUi(
        id: 'demo-election-closed',
        title: '2025 Yönetici seçimi',
        description: 'Tamamlandı',
        status: ElectionStatus.closed,
        closedAt: null,
        candidateCount: 2,
        hasVoted: true,
      ),
    ];
  }

  @override
  Future<ElectionDetailUi?> getElection(
    LocalSession session,
    String electionId,
  ) async {
    if (electionId == _activeId) {
      return _activeDetail;
    }
    if (electionId == 'demo-election-closed') {
      return const ElectionDetailUi(
        election: ElectionUi(
          id: 'demo-election-closed',
          title: '2025 Yönetici seçimi',
          description: 'Tamamlandı',
          status: ElectionStatus.closed,
          candidateCount: 2,
          hasVoted: true,
        ),
        candidates: [
          ElectionCandidateUi(
            id: 'c1',
            displayName: 'Ayşe Demir',
            firstName: 'Ayşe',
            initials: 'AD',
            role: ElectionCandidateRole.manager,
            isSelf: false,
            voteCount: 18,
          ),
          ElectionCandidateUi(
            id: 'c2',
            displayName: 'Mehmet Kaya',
            firstName: 'Mehmet',
            initials: 'MK',
            role: ElectionCandidateRole.resident,
            unitLabel: '6B',
            isSelf: true,
            voteCount: 14,
          ),
        ],
        hasVoted: true,
        canVote: false,
        canNominate: false,
        canManage: true,
        resultsVisible: true,
        totalVotes: 32,
      );
    }
    return null;
  }

  @override
  Future<String> createElection(
    LocalSession session, {
    required String title,
    String? description,
    DateTime? nominationsCloseAt,
    DateTime? closesAt,
  }) async =>
      'demo-election-new';

  @override
  Future<void> startElection(LocalSession session, String electionId) async {}

  @override
  Future<void> startVoting(LocalSession session, String electionId) async {}

  @override
  Future<void> closeElection(LocalSession session, String electionId) async {}

  @override
  Future<void> nominate(LocalSession session, String electionId) async {}

  @override
  Future<void> vote(
    LocalSession session, {
    required String electionId,
    required String candidateId,
  }) async {}
}
