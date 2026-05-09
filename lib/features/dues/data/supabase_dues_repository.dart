import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:apartment_manager/features/dues/data/dues_repository.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';

/// Loads from Supabase (`dues_invoices`, `dues_periods`) — wired incrementally.
class SupabaseDuesRepository implements DuesRepository {
  @override
  Future<DuesInvoiceUi?> invoiceById(String id) async {
    final rows = await listInvoices();
    try {
      return rows.firstWhere((e) => e.id == id);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<List<DuesInvoiceUi>> listInvoices() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    // TODO: join dues_invoices ↔ dues_periods ↔ memberships for current building.
    await supabase.from('profiles').select('id').eq('id', user.id).maybeSingle();
    return [];
  }

  @override
  Future<DuesDebtSummaryUi?> debtSummary() async {
    final list = await listInvoices();
    if (list.isEmpty) {
      return null;
    }
    var open = 0;
    var unpaid = 0;
    for (final row in list) {
      final due = row.amountDueKurus;
      if (due > 0) {
        unpaid++;
        open += due;
      }
    }
    return DuesDebtSummaryUi(
      openDebtKurus: open,
      unpaidCount: unpaid,
      lateLabel: '',
    );
  }
}
