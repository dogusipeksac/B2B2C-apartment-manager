import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';

abstract class AnnouncementRepository {
  Future<List<AnnouncementUi>> listAnnouncements();

  Future<AnnouncementUi?> byId(String id);
}
