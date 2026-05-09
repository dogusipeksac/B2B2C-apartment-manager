import 'package:apartment_manager/features/announcements/data/announcement_repository.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';

class DemoAnnouncementRepository implements AnnouncementRepository {
  const DemoAnnouncementRepository();

  List<AnnouncementUi> get _rows => [
        const AnnouncementUi(
          id: 'demo-ann-1',
          title: 'Asansör bakımı · 12 Mart Çarşamba',
          snippet:
              '10:00–14:00 arası asansör kullanılamayacaktır. Acil durumlarda '
              'merdiven kullanılmalıdır...',
          authorName: 'Ayşe Demir',
          roleLabel: 'Yönetici',
          category: AnnouncementUiCategory.pinned,
          secondaryCategory: AnnouncementUiCategory.maintenance,
          relativeTime: '2 gün önce',
          viewCount: 24,
          commentCount: 3,
          read: false,
          detailMetaLine: '10 Mart, 14:32 · 24 görüntülenme',
          body:
              'Değerli komşularımız,\n\n'
              '**12 Mart Çarşamba** günü 10:00 – 14:00 saatleri arasında '
              'asansörümüzün yıllık periyodik bakımı yapılacaktır. Bu süre '
              'zarfında asansör kullanılamayacak olup, lütfen merdivenleri '
              'tercih ediniz.\n\n'
              'Hareket kısıtlı komşularımız için 3. ve 4. kat sakinleri '
              "Mehmet Bey'den (3A) destek isteyebilir.",
          attachmentName: 'bakim-rapor.pdf',
          attachmentSizeLabel: '2.4 MB',
        ),
        const AnnouncementUi(
          id: 'demo-ann-2',
          title: 'Sıcak su kesintisi 14:00–16:00',
          snippet:
              'Kazan dairesinde rutin bakım yapılacak. Süreç tamamlandığında '
              'bilgilendirme yapılacaktır.',
          authorName: 'Ali Kaya',
          roleLabel: 'Yönetici',
          category: AnnouncementUiCategory.info,
          relativeTime: '5 saat önce',
          viewCount: 18,
          commentCount: 0,
          read: false,
          detailMetaLine: '9 Mart, 09:15 · 18 görüntülenme',
          body:
              'Kazan dairesinde rutin bakım yapılacaktır. '
              '**14:00–16:00** saatleri arasında sıcak su kesintisi '
              'olabilir.',
          attachmentName: null,
          attachmentSizeLabel: null,
        ),
        const AnnouncementUi(
          id: 'demo-ann-3',
          title: 'Çatı izolasyon çalışması başladı',
          snippet: 'Gürültü ve kokuya karşı pencerelerinizi kapalı tutunuz.',
          authorName: 'Ayşe Demir',
          roleLabel: 'Yönetici',
          category: AnnouncementUiCategory.maintenance,
          relativeTime: '1 gün önce',
          viewCount: 31,
          commentCount: 7,
          read: false,
          detailMetaLine: '8 Mart, 11:00 · 31 görüntülenme',
          body:
              'Çatı izolasyon çalışması başlamıştır. '
              'İş güvenliği için bahçe tarafına çıkmayınız.',
          attachmentName: null,
          attachmentSizeLabel: null,
        ),
        const AnnouncementUi(
          id: 'demo-ann-4',
          title: 'Su deposu temizliği · 10 Mart',
          snippet: '',
          authorName: 'Site Yönetimi',
          roleLabel: 'Yönetici',
          category: AnnouncementUiCategory.urgent,
          relativeTime: '3 gün önce',
          viewCount: 42,
          commentCount: 0,
          read: true,
          detailMetaLine: '6 Mart, 08:00 · 42 görüntülenme',
          body: 'Şebeke suyu deposu planlı temizlik kapsamında geçici olarak '
              'boşaltılacaktır.',
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
