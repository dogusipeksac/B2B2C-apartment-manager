enum ElectionStatus { draft, nominating, active, closed }

enum ElectionCandidateRole { manager, resident }

class ElectionCandidateUi {
  const ElectionCandidateUi({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.initials,
    required this.role,
    required this.isSelf,
    this.unitLabel,
    this.voteCount,
  });

  final String id;
  final String displayName;
  final String firstName;
  final String initials;
  final ElectionCandidateRole role;
  final String? unitLabel;
  final bool isSelf;
  final int? voteCount;
}

class ElectionUi {
  const ElectionUi({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.closesAt,
    this.nominationsCloseAt,
    this.startedAt,
    this.closedAt,
    this.createdAt,
    this.candidateCount = 0,
    this.hasVoted = false,
  });

  final String id;
  final String title;
  final String description;
  final ElectionStatus status;
  final DateTime? closesAt;
  final DateTime? nominationsCloseAt;
  final DateTime? startedAt;
  final DateTime? closedAt;
  final DateTime? createdAt;
  final int candidateCount;
  final bool hasVoted;
}

class ElectionDetailUi {
  const ElectionDetailUi({
    required this.election,
    required this.candidates,
    required this.hasVoted,
    required this.canVote,
    required this.canNominate,
    required this.canManage,
    required this.resultsVisible,
    this.canStartNominations = false,
    this.canStartVoting = false,
    this.totalVotes,
  });

  final ElectionUi election;
  final List<ElectionCandidateUi> candidates;
  final bool hasVoted;
  final bool canVote;
  final bool canNominate;
  final bool canManage;
  final bool resultsVisible;
  final bool canStartNominations;
  final bool canStartVoting;
  final int? totalVotes;
}
