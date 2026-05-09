import 'package:apartment_manager/features/issues/data/issue_repository.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';

class DemoIssueRepository implements IssueRepository {
  const DemoIssueRepository();

  List<IssueUi> get _rows => [
        const IssueUi(
          id: 'demo-issue-1',
          publicCode: '#A-127',
          title: 'Çatı su sızıntısı',
          subtitle: 'Çatı · Yüksek öncelik',
          status: IssueUiStatus.inProgress,
          priority: IssueUiPriority.high,
          category: IssueUiCategory.plumbing,
          relativeTime: '2 saat önce',
          commentCount: 2,
          assigneeLabel: 'Yönetim',
          description:
              'Çatı katında yağmur sonrası su sızıntısı gözlemlendi. '
              'Merdiven sonundaki duvar nemleniyor.',
          photoCount: 2,
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
          commentCount: 0,
          assigneeLabel: '—',
          description: 'Otomatik kapı sensörü sürekli engel gösteriyor.',
          photoCount: 0,
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
