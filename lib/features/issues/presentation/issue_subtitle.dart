import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';

String issueSubtitle(AppLocalizations l10n, IssueUi row) {
  if (row.subtitle.trim().isNotEmpty) {
    return row.subtitle;
  }
  final loc = _locationLabel(l10n, row.locationCode);
  final pri = _priorityLabel(l10n, row.priority);
  if (loc.isNotEmpty) {
    return '$loc · $pri';
  }
  return pri;
}

String _locationLabel(AppLocalizations l10n, String? code) {
  return switch (code?.trim()) {
    'apartment' => l10n.issueLocationApartment,
    'parking' => l10n.issueLocationParking,
    'roof' => l10n.issueLocationRoof,
    'garden' => l10n.issueLocationGarden,
    'elevator' => l10n.issueLocationElevator,
    _ => '',
  };
}

String _priorityLabel(AppLocalizations l10n, IssueUiPriority priority) {
  return switch (priority) {
    IssueUiPriority.low => l10n.issuePriorityLow,
    IssueUiPriority.medium => l10n.issuePriorityMedium,
    IssueUiPriority.high => l10n.issuePriorityHigh,
  };
}
