import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/issues/data/demo_issue_repository.dart';
import 'package:apartment_manager/features/issues/data/issue_repository.dart';
import 'package:apartment_manager/features/issues/data/supabase_issue_repository.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final issueRepositoryProvider = Provider<IssueRepository>(
  (ref) {
    if (Env.demoMode) {
      return const DemoIssueRepository();
    }
    return SupabaseIssueRepository();
  },
);

final issuesListProvider = FutureProvider<List<IssueUi>>(
  (ref) => ref.watch(issueRepositoryProvider).listIssues(),
);
