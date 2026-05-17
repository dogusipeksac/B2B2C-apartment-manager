import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:apartment_manager/features/elections/presentation/election_candidate_label.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Gradient hero for election detail / list highlights.
class ElectionHeroCard extends StatelessWidget {
  const ElectionHeroCard({
    required this.title,
    required this.status,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final ElectionStatus status;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isActive = status == ElectionStatus.active;
    final isNominating = status == ElectionStatus.nominating;
    final statusLabel = switch (status) {
      ElectionStatus.draft => l10n.electionStatusDraft,
      ElectionStatus.nominating => l10n.electionStatusNominating,
      ElectionStatus.active => l10n.electionStatusActive,
      ElectionStatus.closed => l10n.electionStatusClosed,
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  AppTheme.primary,
                  const Color(0xFF1B5E20),
                ]
              : isNominating
              ? [
                  AppTheme.secondary,
                  const Color(0xFF00695C),
                ]
              : [
                  context.apart.onSurfaceVariant.withValues(alpha: 0.35),
                  context.apart.onSurfaceVariant.withValues(alpha: 0.55),
                ],
        ),
        boxShadow: isActive || isNominating
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive
                        ? Icons.how_to_vote_rounded
                        : isNominating
                        ? Icons.person_add_alt_1_rounded
                        : Icons.ballot_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ElectionCandidateRoleBadge extends StatelessWidget {
  const ElectionCandidateRoleBadge({required this.role, super.key});

  final ElectionCandidateRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isManager = role == ElectionCandidateRole.manager;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isManager
            ? AppTheme.secondary.withValues(alpha: 0.14)
            : AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isManager ? l10n.electionRoleBadgeManager : l10n.electionRoleBadgeResident,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isManager ? AppTheme.secondary : AppTheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class ElectionCandidateCard extends StatelessWidget {
  const ElectionCandidateCard({
    required this.candidate,
    required this.resultsVisible,
    required this.selectable,
    required this.selected,
    this.onTap,
    super.key,
  });

  final ElectionCandidateUi candidate;
  final bool resultsVisible;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final label = electionCandidateLabel(l10n, candidate);
    final isManager = candidate.role == ElectionCandidateRole.manager;
    final accent = isManager ? AppTheme.secondary : AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        elevation: selected ? 3 : 0,
        shadowColor: accent.withValues(alpha: 0.35),
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? accent
                : accent.withValues(alpha: selectable ? 0.35 : 0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          child: Text(
                            candidate.initials,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElectionCandidateRoleBadge(role: candidate.role),
                              const SizedBox(height: 6),
                              Text(
                                label,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (candidate.isSelf)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    l10n.electionCandidateYou,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (resultsVisible && candidate.voteCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n.electionVoteCount(
                                '${candidate.voteCount}',
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          )
                        else if (selectable)
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: selected ? accent : null,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
