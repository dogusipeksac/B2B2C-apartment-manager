import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/error_view.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:apartment_manager/features/elections/presentation/election_nominate_ui.dart';
import 'package:apartment_manager/features/elections/presentation/election_visuals.dart';
import 'package:apartment_manager/features/elections/presentation/providers/election_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ElectionDetailScreen extends ConsumerStatefulWidget {
  const ElectionDetailScreen({required this.electionId, super.key});

  final String electionId;

  @override
  ConsumerState<ElectionDetailScreen> createState() =>
      _ElectionDetailScreenState();
}

class _ElectionDetailScreenState extends ConsumerState<ElectionDetailScreen> {
  String? _selectedCandidateId;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(electionDetailProvider(widget.electionId));
      ref.invalidate(electionsListProvider);
      ref.invalidate(activeElectionProvider);
      await ref.read(electionDetailProvider(widget.electionId).future);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.userMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _vote(ElectionDetailUi detail) async {
    final candidateId = _selectedCandidateId;
    if (candidateId == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.electionSelectCandidate)),
      );
      return;
    }
    final session = ref.read(localSessionProvider).value;
    if (session == null) {
      return;
    }
    await _run(() => ref.read(electionRepositoryProvider).vote(
          session,
          electionId: widget.electionId,
          candidateId: candidateId,
        ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.electionVoteSuccess),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;
    final detailAsync = ref.watch(electionDetailProvider(widget.electionId));

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(title: Text(l10n.electionDetailTitle)),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.userMessage : l10n.errorGeneric,
          action: TextButton(
            onPressed: () =>
                ref.invalidate(electionDetailProvider(widget.electionId)),
            child: Text(l10n.managerInviteRetry),
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return Center(child: Text(l10n.electionNotFound));
          }

          final election = detail.election;
          final session = ref.watch(localSessionProvider).value;
          final showNominate = shouldShowNominatePanel(
            detail: detail,
            session: session,
          );
          final isManager = session?.role == UserRole.buildingAdmin ||
              session?.role == UserRole.buildingCoAdmin;
          final localeTag = Localizations.localeOf(context).languageCode == 'tr'
              ? 'tr_TR'
              : 'en_US';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(electionDetailProvider(widget.electionId));
              await ref.read(electionDetailProvider(widget.electionId).future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ElectionHeroCard(
                  title: election.title,
                  status: election.status,
                  subtitle: election.description.isNotEmpty
                      ? election.description
                      : switch (election.status) {
                          ElectionStatus.nominating =>
                            l10n.electionNominatingBannerTitle,
                          ElectionStatus.active =>
                            l10n.electionActiveBannerTitle,
                          _ => null,
                        },
                ),
                const SizedBox(height: 16),
                if (showNominate) ...[
                  _NominateSelfPanel(
                    status: election.status,
                    isManager: isManager,
                    busy: _busy,
                    onNominate: () => _run(() async {
                      final session = ref.read(localSessionProvider).value!;
                      await ref
                          .read(electionRepositoryProvider)
                          .nominate(session, widget.electionId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.electionNominateSuccess),
                          ),
                        );
                      }
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
                if (election.nominationsCloseAt != null)
                  Text(
                    l10n.electionNominationsCloseAtLabel(
                      DateFormat.yMMMd(localeTag)
                          .format(election.nominationsCloseAt!),
                    ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: apart.onSurfaceVariant,
                    ),
                  ),
                if (election.closesAt != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: election.nominationsCloseAt != null ? 4 : 0,
                    ),
                    child: Text(
                      l10n.electionClosesAtLabel(
                        DateFormat.yMMMd(localeTag).format(election.closesAt!),
                      ),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: apart.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (detail.totalVotes != null &&
                    election.status == ElectionStatus.active)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.electionParticipationCount('${detail.totalVotes}'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: apart.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: AppTheme.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          detail.resultsVisible
                              ? l10n.electionResultsPublicHint
                              : l10n.electionSecretBallotHint,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (detail.canManage) ...[
                  const SizedBox(height: 16),
                  _AdminActions(
                    detail: detail,
                    busy: _busy,
                    onStartNominations: () => _run(() async {
                      final session = ref.read(localSessionProvider).value!;
                      await ref
                          .read(electionRepositoryProvider)
                          .startElection(session, widget.electionId);
                    }),
                    onStartVoting: () => _run(() async {
                      final session = ref.read(localSessionProvider).value!;
                      await ref
                          .read(electionRepositoryProvider)
                          .startVoting(session, widget.electionId);
                    }),
                    onClose: () => _run(() async {
                      final session = ref.read(localSessionProvider).value!;
                      await ref
                          .read(electionRepositoryProvider)
                          .closeElection(session, widget.electionId);
                    }),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.electionCandidatesSection,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (detail.candidates.isEmpty)
                  Text(
                    l10n.electionNoCandidates,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: apart.onSurfaceVariant,
                    ),
                  )
                else
                  ...detail.candidates.map(
                    (c) => ElectionCandidateCard(
                      candidate: c,
                      resultsVisible: detail.resultsVisible,
                      selectable: detail.canVote,
                      selected: _selectedCandidateId == c.id,
                      onTap: detail.canVote
                          ? () => setState(() => _selectedCandidateId = c.id)
                          : null,
                    ),
                  ),
                if (detail.hasVoted && !detail.resultsVisible) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.electionYouVotedSecret,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (detail.canVote) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppTheme.primary,
                    ),
                    onPressed: _busy ? null : () => _vote(detail),
                    icon: const Icon(Icons.how_to_vote_rounded),
                    label: Text(l10n.electionSubmitVote),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NominateSelfPanel extends StatelessWidget {
  const _NominateSelfPanel({
    required this.status,
    required this.isManager,
    required this.busy,
    required this.onNominate,
  });

  final ElectionStatus status;
  final bool isManager;
  final bool busy;
  final VoidCallback onNominate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDraft = status == ElectionStatus.draft;
    final title = isDraft && isManager
        ? l10n.electionNominateSelfManager
        : l10n.electionNominateSelfResident;
    final hint = isDraft
        ? l10n.electionNominateDraftHint
        : l10n.electionNominateNominatingHint;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary.withValues(alpha: 0.12),
            AppTheme.secondary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: AppTheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.apart.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppTheme.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: busy ? null : onNominate,
            icon: const Icon(Icons.how_to_reg_rounded),
            label: Text(l10n.electionNominateSelf),
          ),
        ],
      ),
    );
  }
}

class _AdminActions extends StatelessWidget {
  const _AdminActions({
    required this.detail,
    required this.busy,
    required this.onStartNominations,
    required this.onStartVoting,
    required this.onClose,
  });

  final ElectionDetailUi detail;
  final bool busy;
  final VoidCallback onStartNominations;
  final VoidCallback onStartVoting;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (detail.canStartNominations)
          FilledButton.icon(
            onPressed: busy ? null : onStartNominations,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(l10n.electionStartNominationsAction),
          ),
        if (detail.canStartVoting)
          FilledButton.icon(
            onPressed: busy ? null : onStartVoting,
            icon: const Icon(Icons.how_to_vote_rounded),
            label: Text(l10n.electionStartVotingAction),
          ),
        if (detail.election.status == ElectionStatus.active)
          FilledButton.tonalIcon(
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.stop_rounded),
            label: Text(l10n.electionCloseAction),
          ),
      ],
    );
  }
}
