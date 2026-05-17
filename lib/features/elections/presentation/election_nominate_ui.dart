import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';

/// Whether the nominate panel should show (API `can_nominate` only).
bool shouldShowNominatePanel({
  required ElectionDetailUi detail,
  required LocalSession? session,
}) {
  return detail.canNominate;
}
