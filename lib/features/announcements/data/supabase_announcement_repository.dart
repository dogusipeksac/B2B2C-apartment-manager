import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:apartment_manager/features/announcements/data/announcement_repository.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';

class SupabaseAnnouncementRepository implements AnnouncementRepository {
  @override
  Future<AnnouncementUi?> byId(String id) async {
    final list = await listAnnouncements();
    try {
      return list.firstWhere((e) => e.id == id);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<List<AnnouncementUi>> listAnnouncements() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    // TODO: announcements where building_id = current membership.
    await supabase.from('profiles').select('id').eq('id', user.id).maybeSingle();
    return [];
  }
}
