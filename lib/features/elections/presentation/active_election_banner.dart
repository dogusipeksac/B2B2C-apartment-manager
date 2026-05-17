import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:apartment_manager/features/elections/presentation/providers/election_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Resident home — prominent active election CTA.
class ActiveElectionBanner extends ConsumerWidget {
  const ActiveElectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeAsync = ref.watch(activeElectionProvider);

    return activeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (election) {
        if (election == null) {
          return const SizedBox.shrink();
        }

        final isVoting = election.status == ElectionStatus.active;
        final isNominating = election.status == ElectionStatus.nominating;
        if (!isVoting && !isNominating) {
          return const SizedBox.shrink();
        }

        final voted = election.hasVoted;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            elevation: 6,
            shadowColor: AppTheme.primary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/elections/${election.id}'),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isNominating
                        ? [
                            AppTheme.secondary,
                            const Color(0xFF00695C),
                          ]
                        : const [
                            Color(0xFF2E7D32),
                            Color(0xFF1B5E20),
                          ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isNominating
                                  ? Icons.person_add_alt_1_rounded
                                  : Icons.how_to_vote_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isNominating
                                      ? l10n.electionNominatingBannerTitle
                                      : l10n.electionActiveBannerTitle,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  election.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            context.push('/elections/${election.id}'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isNominating
                                  ? Icons.person_add_alt_1_rounded
                                  : voted
                                  ? Icons.check_circle_outline
                                  : Icons.touch_app_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isNominating
                                  ? l10n.electionActiveBannerNominate
                                  : voted
                                  ? l10n.electionActiveBannerVoted
                                  : l10n.electionActiveBannerVote,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
