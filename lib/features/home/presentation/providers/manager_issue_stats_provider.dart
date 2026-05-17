import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/issues/data/issue_ops_repository.dart';
import 'package:apartment_manager/features/issues/domain/issue_monthly_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ManagerIssueStatsKey = ({int year, int month});

final managerIssueStatsProvider =
    FutureProvider.family<IssueMonthlyStats, ManagerIssueStatsKey>(
  (ref, key) async {
    if (Env.demoMode) {
      return IssueMonthlyStats.demo(year: key.year, month: key.month);
    }

    final sessionAsync = ref.watch(localSessionProvider);
    final session = sessionAsync.hasValue
        ? sessionAsync.value
        : await ref.read(localSessionProvider.future);
    if (session == null) {
      return IssueMonthlyStats(
        year: key.year,
        month: key.month,
        opened: 0,
        resolved: 0,
        pending: 0,
        highPriorityPending: 0,
      );
    }

    return ref.read(issueOpsRepositoryProvider).fetchMonthlyStats(
          session,
          year: key.year,
          month: key.month,
        );
  },
);
