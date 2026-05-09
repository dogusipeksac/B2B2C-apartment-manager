import 'package:apartment_manager/features/issues/data/issue_repository.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

class DemoIssueRepository implements IssueRepository {
  const DemoIssueRepository();

  List<IssueUi> get _rows => [
    const IssueUi(
      id: 'demo-issue-1',
      publicCode: '#A-127',
      title: 'Çatı su sızıntısı',
      subtitle: 'Çatı katı · Yüksek öncelik',
      status: IssueUiStatus.inProgress,
      priority: IssueUiPriority.high,
      category: IssueUiCategory.plumbing,
      relativeTime: '2 saat önce',
      commentCount: 4,
      assigneeLabel: 'Ayşe Demir',
      description:
          'Çatı katında yağmur sonrası su sızıntısı gözlemlendi. '
          'Merdiven sonundaki duvar nemleniyor.',
      photoCount: 2,
      isOwnReport: false,
      avatarInitials: 'AD',
      footerAssigneeName: 'Ayşe D.',
    ),
    const IssueUi(
      id: 'demo-issue-2',
      publicCode: '#A-126',
      title: 'Otopark kapısı kapanmıyor',
      subtitle: 'Otopark · Orta öncelik',
      status: IssueUiStatus.open,
      priority: IssueUiPriority.medium,
      category: IssueUiCategory.mechanical,
      relativeTime: '1 gün önce',
      commentCount: 2,
      assigneeLabel: '—',
      description: 'Otomatik kapı sensörü sürekli engel gösteriyor.',
      photoCount: 0,
      isOwnReport: true,
      avatarInitials: 'BK',
      footerAssigneeName: '',
    ),
    const IssueUi(
      id: 'demo-issue-3',
      publicCode: '#A-125',
      title: 'Asansör titreşimi',
      subtitle: 'Asansör · Düşük öncelik',
      status: IssueUiStatus.open,
      priority: IssueUiPriority.low,
      category: IssueUiCategory.electric,
      relativeTime: '3 gün önce',
      commentCount: 0,
      assigneeLabel: 'Teknik',
      description: 'Kabin hareket ederken anormal titreme var.',
      photoCount: 0,
      isOwnReport: false,
      avatarInitials: 'MK',
      footerAssigneeName: 'M. Kaya',
    ),
    const IssueUi(
      id: 'demo-issue-4',
      publicCode: '#A-124',
      title: 'Havalandırma fanı arızası',
      subtitle: 'Çatı · Düşük öncelik',
      status: IssueUiStatus.resolved,
      priority: IssueUiPriority.low,
      category: IssueUiCategory.mechanical,
      relativeTime: '5 gün önce',
      commentCount: 1,
      assigneeLabel: 'Yönetim',
      description: 'Motor değişimi yapıldı, arıza giderildi.',
      photoCount: 0,
      isOwnReport: false,
      avatarInitials: 'YD',
      footerAssigneeName: '',
    ),
    const IssueUi(
      id: 'demo-issue-5',
      publicCode: '#A-123',
      title: 'Bahçe sulama kaçağı',
      subtitle: 'Bahçe · Orta öncelik',
      status: IssueUiStatus.resolved,
      priority: IssueUiPriority.medium,
      category: IssueUiCategory.plumbing,
      relativeTime: '1 hafta önce',
      commentCount: 0,
      assigneeLabel: 'Yönetim',
      description: 'Boru tamiri tamamlandı.',
      photoCount: 1,
      isOwnReport: false,
      avatarInitials: 'SY',
      footerAssigneeName: '',
    ),
    const IssueUi(
      id: 'demo-issue-6',
      publicCode: '#A-122',
      title: 'Koridor aydınlatması',
      subtitle: 'Ortak alan · Düşük öncelik',
      status: IssueUiStatus.resolved,
      priority: IssueUiPriority.low,
      category: IssueUiCategory.electric,
      relativeTime: '10 gün önce',
      commentCount: 3,
      assigneeLabel: 'Yönetim',
      description: 'Armatür değişti.',
      photoCount: 0,
      isOwnReport: false,
      avatarInitials: 'ET',
      footerAssigneeName: '',
    ),
    const IssueUi(
      id: 'demo-issue-7',
      publicCode: '#A-121',
      title: 'Yangın merdiveni kapısı',
      subtitle: 'Yangın çıkışı · Yüksek öncelik',
      status: IssueUiStatus.resolved,
      priority: IssueUiPriority.high,
      category: IssueUiCategory.other,
      relativeTime: '2 hafta önce',
      commentCount: 0,
      assigneeLabel: 'Yönetim',
      description: 'Kilit ve kapı kolu yenilendi.',
      photoCount: 0,
      isOwnReport: false,
      avatarInitials: 'AK',
      footerAssigneeName: '',
    ),
  ];

  @override
  Future<IssueUi?> byId(String id) async {
    try {
      return _rows.firstWhere((e) => e.id == id);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<List<IssueUi>> listIssues() async => _rows;
}
