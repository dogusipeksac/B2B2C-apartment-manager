import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';

/// Loads dues rows for the current user + building context (RLS on Supabase).
abstract class DuesRepository {
  Future<List<DuesInvoiceUi>> listInvoices();

  Future<DuesDebtSummaryUi?> debtSummary();

  Future<DuesInvoiceUi?> invoiceById(String id);
}
