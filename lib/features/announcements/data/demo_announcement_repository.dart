import 'package:apartment_manager/features/announcements/data/announcement_repository.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';

class DemoAnnouncementRepository implements AnnouncementRepository {
  const DemoAnnouncementRepository();

  List<AnnouncementUi> get _rows => [
        const AnnouncementUi(
          id: 'demo-ann-1',
          title: 'Asansör bakımı — 12 Mart Çarşamba',
          snippet:
              '12 Mart 10:00–12:00 arası bakım nedeniyle asansör kullanılamayacaktır.',
          authorName: 'Ayşe Demir',
          roleLabel: 'Yönetici',
          category: AnnouncementUiCategory.pinned,
          relativeTime: '2 gün önce',
          viewCount: 124,
          commentCount: 3,
          read: false,
          body:
              'Değerli sakinlerimiz, 12 Mart Çarşamba günü 10:00–12:00 arasında '
              'periyodik asansör bakımı yapılacaktır. Bu süre içinde asansör '
              'kullanımı mümkün olmayacaktır. Anlayışınız için teşekkür ederiz.',
          attachmentName: 'bakim-rapor.pdf',
          attachmentSizeLabel: '2.4 MB',
        ),
        const AnnouncementUi(
          id: 'demo-ann-2',
          title: 'Sıcak su kesintisi 14:00–16:00',
          snippet: 'Planlı bakım kapsamında sıcak su geçici olarak kesilecektir.',
          authorName: 'Ali Kaya',
          roleLabel: 'Yönetici',
          category: AnnouncementUiCategory.info,
          relativeTime: '5 saat önce',
          viewCount: 89,
          commentCount: 1,
          read: true,
          body: 'Bugün 14:00–16:00 arasında sıcak su şebeke bakımı yapılacaktır.',
          attachmentName: null,
          attachmentSizeLabel: null,
        ),
      ];

  @override
  Future<AnnouncementUi?> byId(String id) async {
    try {
      return _rows.firstWhere((e) => e.id == id);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<List<AnnouncementUi>> listAnnouncements() async => _rows;
}
