import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:apartment_manager/features/issues/data/issue_repository.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

class SupabaseIssueRepository implements IssueRepository {
  @override
  Future<IssueUi?> byId(String id) async {
    final list = await listIssues();
    try {
      return list.firstWhere((e) => e.id == id);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<List<IssueUi>> listIssues() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    // TODO: issues where building_id matches membership.
    await supabase.from('profiles').select('id').eq('id', user.id).maybeSingle();
    return [];
  }
}
