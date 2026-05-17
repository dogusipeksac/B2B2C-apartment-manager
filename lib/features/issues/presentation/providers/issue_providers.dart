import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/issues/data/demo_issue_repository.dart';
import 'package:apartment_manager/features/issues/data/issue_ops_repository.dart';
import 'package:apartment_manager/features/issues/data/issue_repository.dart';
import 'package:apartment_manager/features/issues/data/supabase_issue_repository.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final issueRepositoryProvider = Provider<IssueRepository>(
  (ref) {
    if (Env.demoMode) {
      return const DemoIssueRepository();
    }
    return SupabaseIssueRepository(ref.watch(issueOpsRepositoryProvider));
  },
);

/// [autoDispose] off: IndexedStack keeps this tab mounted; dispose caused reload loops.
final issuesListProvider = FutureProvider<List<IssueUi>>((ref) async {
  final sessionAsync = ref.watch(localSessionProvider);
  final session = sessionAsync.hasValue
      ? sessionAsync.value
      : await ref.read(localSessionProvider.future);
  if (session == null) {
    return [];
  }
  return ref.read(issueRepositoryProvider).listIssues(session);
});

/// Detail with timeline comments — manager and resident.
final issueDetailProvider = FutureProvider.family<IssueUi?, String>(
  (ref, issueId) async {
    final sessionAsync = ref.watch(localSessionProvider);
    final session = sessionAsync.hasValue
        ? sessionAsync.value
        : await ref.read(localSessionProvider.future);
    if (session == null) {
      return null;
    }
    return ref.read(issueRepositoryProvider).byId(session, issueId);
  },
);
