import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';

/// "Yönetici (Doğuş)" / "Sakin (22A)" style labels.
String electionCandidateLabel(
  AppLocalizations l10n,
  ElectionCandidateUi candidate,
) {
  switch (candidate.role) {
    case ElectionCandidateRole.manager:
      final name = candidate.firstName.isNotEmpty
          ? candidate.firstName
          : candidate.displayName;
      return l10n.electionCandidateManager(name);
    case ElectionCandidateRole.resident:
      final unit = candidate.unitLabel?.trim();
      if (unit != null && unit.isNotEmpty) {
        return l10n.electionCandidateResident(unit);
      }
      return l10n.electionCandidateResidentNoUnit;
  }
}
