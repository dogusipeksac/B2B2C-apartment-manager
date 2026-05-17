import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ElectionStatusChip extends StatelessWidget {
  const ElectionStatusChip({required this.status, super.key});

  final ElectionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, bg, fg) = switch (status) {
      ElectionStatus.draft => (
        l10n.electionStatusDraft,
        AppTheme.info.withValues(alpha: 0.12),
        AppTheme.info,
      ),
      ElectionStatus.nominating => (
        l10n.electionStatusNominating,
        AppTheme.secondary.withValues(alpha: 0.12),
        AppTheme.secondary,
      ),
      ElectionStatus.active => (
        l10n.electionStatusActive,
        AppTheme.warning.withValues(alpha: 0.12),
        AppTheme.warning,
      ),
      ElectionStatus.closed => (
        l10n.electionStatusClosed,
        context.apart.onSurfaceVariant.withValues(alpha: 0.12),
        context.apart.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
