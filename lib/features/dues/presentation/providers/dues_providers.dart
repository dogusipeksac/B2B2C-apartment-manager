import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/dues/data/demo_dues_repository.dart';
import 'package:apartment_manager/features/dues/data/dues_repository.dart';
import 'package:apartment_manager/features/dues/data/supabase_dues_repository.dart';
import 'package:apartment_manager/features/dues/domain/dues_invoice_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final duesRepositoryProvider = Provider<DuesRepository>(
  (ref) {
    if (Env.demoMode) {
      return const DemoDuesRepository();
    }
    return SupabaseDuesRepository();
  },
);

final duesInvoicesProvider = FutureProvider<List<DuesInvoiceUi>>(
  (ref) => ref.watch(duesRepositoryProvider).listInvoices(),
);

final duesDebtSummaryProvider = FutureProvider<DuesDebtSummaryUi?>(
  (ref) => ref.watch(duesRepositoryProvider).debtSummary(),
);
