import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:apartment_manager/features/elections/presentation/election_status_chip.dart';
import 'package:apartment_manager/features/elections/presentation/providers/election_providers.dart';
import 'package:apartment_manager/core/widgets/error_view.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ElectionsListScreen extends ConsumerWidget {
  const ElectionsListScreen({super.key});

  bool _isAdmin(UserRole? role) =>
      role == UserRole.buildingAdmin || role == UserRole.buildingCoAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;
    final listAsync = ref.watch(electionsListProvider);
    final activeAsync = ref.watch(activeElectionProvider);
    final session = ref.watch(localSessionProvider).value;
    final isAdmin = _isAdmin(session?.role);

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.electionListTitle),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/elections/create'),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.electionCreateFab),
            )
          : null,
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e is AppException ? e.userMessage : l10n.errorGeneric,
          action: TextButton(
            onPressed: () => ref.invalidate(electionsListProvider),
            child: Text(l10n.managerInviteRetry),
          ),
        ),
        data: (rows) {
          final active = activeAsync.value;
          final showActiveNominate = active != null &&
              (active.status == ElectionStatus.nominating ||
                  (isAdmin && active.status == ElectionStatus.draft) ||
                  (active.status == ElectionStatus.active && !active.hasVoted));

          if (rows.isEmpty && !showActiveNominate) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.electionListEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: apart.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(electionsListProvider);
              ref.invalidate(activeElectionProvider);
              await ref.read(electionsListProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length + (showActiveNominate ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                if (showActiveNominate && i == 0) {
                  return _ActiveNominateCta(
                    election: active,
                    onTap: () => context.push('/elections/${active.id}'),
                  );
                }
                final idx = showActiveNominate ? i - 1 : i;
                final row = rows[idx];
                return _ElectionCard(
                  election: row,
                  onTap: () => context.push('/elections/${row.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActiveNominateCta extends StatelessWidget {
  const _ActiveNominateCta({
    required this.election,
    required this.onTap,
  });

  final ElectionUi election;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      elevation: 4,
      shadowColor: AppTheme.secondary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                AppTheme.secondary.withValues(alpha: 0.12),
                AppTheme.secondary.withValues(alpha: 0.22),
              ],
            ),
            border: Border.all(
              color: AppTheme.secondary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.person_add_alt_1_rounded, color: AppTheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.electionListNominateCta,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        election.title,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ElectionCard extends StatelessWidget {
  const _ElectionCard({
    required this.election,
    required this.onTap,
  });

  final ElectionUi election;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final isActive = election.status == ElectionStatus.active;

    if (isActive) {
      return Material(
        elevation: 4,
        shadowColor: AppTheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.06),
                  AppTheme.primary.withValues(alpha: 0.14),
                ],
              ),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _ElectionCardBody(
                election: election,
                l10n: l10n,
                theme: theme,
                highlight: true,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: _ElectionCardBody(
            election: election,
            l10n: l10n,
            theme: theme,
            highlight: false,
          ),
        ),
      ),
    );
  }
}

class _ElectionCardBody extends StatelessWidget {
  const _ElectionCardBody({
    required this.election,
    required this.l10n,
    required this.theme,
    required this.highlight,
  });

  final ElectionUi election;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (highlight)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.how_to_vote_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
            ElectionStatusChip(status: election.status),
            const Spacer(),
            if (election.hasVoted)
              Icon(
                Icons.how_to_vote,
                size: 18,
                color: AppTheme.primary,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          election.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (election.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            election.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.apart.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.electionCandidateCount('${election.candidateCount}'),
          style: theme.textTheme.labelSmall?.copyWith(
            color: context.apart.onSurfaceVariant,
            fontWeight: highlight ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
