import 'package:apartment_manager/features/dues/data/dues_repository.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';

/// Deterministic demo invoices (matches HTML kit amounts).
class DemoDuesRepository implements DuesRepository {
  const DemoDuesRepository();

  List<DuesInvoiceUi> get _all => [
        DuesInvoiceUi(
          id: 'demo-inv-mar26',
          periodLabel: 'Mart 2026',
          amountKurus: 150000,
          paidKurus: 0,
          lateFeeKurus: 3000,
          dueDate: DateTime(2026, 3, 5),
          status: DuesInvoiceUiStatus.overdue,
          daysLate: 3,
          subtitle: 'Vade 5 Mart · 3 gün gecikti',
          invoiceCode: '#YV-2028-03-3A',
        ),
        DuesInvoiceUi(
          id: 'demo-inv-feb26',
          periodLabel: 'Şubat 2026',
          amountKurus: 150000,
          paidKurus: 150000,
          lateFeeKurus: 0,
          dueDate: DateTime(2026, 2, 5),
          status: DuesInvoiceUiStatus.paid,
          daysLate: 0,
          subtitle: 'Ödendi · 28 Şubat 2026',
          invoiceCode: '#YV-2028-02-3A',
        ),
        DuesInvoiceUi(
          id: 'demo-inv-jan26',
          periodLabel: 'Ocak 2026',
          amountKurus: 150000,
          paidKurus: 150000,
          lateFeeKurus: 0,
          dueDate: DateTime(2026, 1, 5),
          status: DuesInvoiceUiStatus.paid,
          daysLate: 0,
          subtitle: 'Ödendi',
          invoiceCode: '#YV-2028-01-3A',
        ),
      ];

  @override
  Future<DuesInvoiceUi?> invoiceById(String id) async {
    try {
      return _all.firstWhere((e) => e.id == id);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<List<DuesInvoiceUi>> listInvoices() async => _all;

  @override
  Future<DuesDebtSummaryUi?> debtSummary() async {
    const openKurus = 153000;
    return const DuesDebtSummaryUi(
      openDebtKurus: openKurus,
      unpaidCount: 2,
      lateLabel: '3 gün gecikti',
    );
  }
}
