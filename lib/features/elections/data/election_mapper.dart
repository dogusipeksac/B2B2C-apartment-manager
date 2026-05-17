import 'package:apartment_manager/features/elections/domain/election_ui.dart';

ElectionStatus _statusFromWire(String? raw) {
  switch (raw) {
    case 'nominating':
      return ElectionStatus.nominating;
    case 'active':
      return ElectionStatus.active;
    case 'closed':
      return ElectionStatus.closed;
    default:
      return ElectionStatus.draft;
  }
}

DateTime? _parseTime(dynamic raw) {
  if (raw is String) {
    return DateTime.tryParse(raw)?.toLocal();
  }
  return null;
}

ElectionUi electionUiFromWire(Map<String, dynamic> wire) {
  return ElectionUi(
    id: wire['id'] as String? ?? '',
    title: wire['title'] as String? ?? '',
    description: wire['description'] as String? ?? '',
    status: _statusFromWire(wire['status'] as String?),
    closesAt: _parseTime(wire['closes_at']),
    nominationsCloseAt: _parseTime(wire['nominations_close_at']),
    startedAt: _parseTime(wire['started_at']),
    closedAt: _parseTime(wire['closed_at']),
    createdAt: _parseTime(wire['created_at']),
    candidateCount: wire['candidate_count'] as int? ?? 0,
    hasVoted: wire['has_voted'] == true,
  );
}

ElectionCandidateRole _roleFromWire(String? raw) {
  if (raw == 'manager') {
    return ElectionCandidateRole.manager;
  }
  return ElectionCandidateRole.resident;
}

ElectionCandidateUi candidateFromWire(Map<String, dynamic> wire) {
  final vc = wire['vote_count'];
  final displayName = (wire['display_name'] as String?)?.trim() ?? '—';
  final firstRaw = (wire['first_name'] as String?)?.trim();
  final firstName = (firstRaw != null && firstRaw.isNotEmpty)
      ? firstRaw
      : displayName.split(RegExp(r'\s+')).first;
  return ElectionCandidateUi(
    id: wire['id'] as String? ?? '',
    displayName: displayName,
    firstName: firstName,
    initials: (wire['initials'] as String?)?.trim() ?? '??',
    role: _roleFromWire(wire['role_kind'] as String?),
    unitLabel: (wire['unit_label'] as String?)?.trim(),
    isSelf: wire['is_self'] == true,
    voteCount: vc == null ? null : (vc as num).toInt(),
  );
}

ElectionDetailUi electionDetailFromWire(Map<String, dynamic> wire) {
  final electionMap = Map<String, dynamic>.from(
    wire['election'] as Map<dynamic, dynamic>? ?? {},
  );
  final list = wire['candidates'];
  final candidates = list is List
      ? list
          .map(
            (e) => candidateFromWire(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList()
      : <ElectionCandidateUi>[];

  final total = wire['total_votes'];
  return ElectionDetailUi(
    election: electionUiFromWire(electionMap),
    candidates: candidates,
    hasVoted: wire['has_voted'] == true,
    canVote: wire['can_vote'] == true,
    canNominate: wire['can_nominate'] == true,
    canManage: wire['can_manage'] == true,
    resultsVisible: wire['results_visible'] == true,
    canStartNominations: wire['can_start_nominations'] == true,
    canStartVoting: wire['can_start_voting'] == true,
    totalVotes: total == null ? null : (total as num).toInt(),
  );
}
