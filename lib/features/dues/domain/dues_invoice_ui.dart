/// UI row aligned with `dues_invoices` + period labels (amounts in kuruş).
enum DuesInvoiceUiStatus {
  open,
  partial,
  paid,
  overdue,
}

class DuesInvoiceUi {
  const DuesInvoiceUi({
    required this.id,
    required this.periodLabel,
    required this.amountKurus,
    required this.paidKurus,
    required this.lateFeeKurus,
    required this.dueDate,
    required this.status,
    required this.daysLate,
    required this.subtitle,
    required this.invoiceCode,
  });

  final String id;
  final String periodLabel;
  final int amountKurus;
  final int paidKurus;
  final int lateFeeKurus;
  final DateTime dueDate;
  final DuesInvoiceUiStatus status;
  final int daysLate;
  final String subtitle;
  final String invoiceCode;

  /// Remaining balance for this invoice (kuruş).
  int get amountDueKurus {
    if (status == DuesInvoiceUiStatus.paid) {
      return 0;
    }
    final base = amountKurus - paidKurus;
    if (status == DuesInvoiceUiStatus.overdue) {
      return base + lateFeeKurus;
    }
    return base;
  }
}

class DuesDebtSummaryUi {
  const DuesDebtSummaryUi({
    required this.openDebtKurus,
    required this.unpaidCount,
    required this.lateLabel,
  });

  final int openDebtKurus;
  final int unpaidCount;
  final String lateLabel;
}
