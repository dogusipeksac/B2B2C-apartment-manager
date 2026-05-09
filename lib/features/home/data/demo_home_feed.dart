import 'package:apartment_manager/core/demo/demo_sample_data.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';

enum HomeAnnouncementTag { pin, info }

/// Feed row for announcements (resident home + lists).
class HomeAnnouncementItem {
  const HomeAnnouncementItem({
    required this.title,
    required this.author,
    required this.tag,
  });

  final String title;
  final String author;
  final HomeAnnouncementTag tag;
}

/// Feed row for issues.
class HomeIssueItem {
  const HomeIssueItem({
    required this.title,
    required this.statusLabel,
    required this.updatedTimePhrase,
  });

  final String title;
  final String statusLabel;

  /// Short phrase for [AppLocalizations.homeIssueUpdatedAgo], e.g. "2 saat".
  final String updatedTimePhrase;
}

/// Aidat tab row.
class HomeDuesItem {
  const HomeDuesItem({
    required this.title,
    required this.subtitle,
    required this.isPaid,
  });

  final String title;
  final String subtitle;
  final bool isPaid;
}

/// Resident dashboard + tab lists (demo fills values; prod uses empty).
class ResidentHomeData {
  const ResidentHomeData({
    required this.openDebtLira,
    required this.hasDebt,
    required this.dueDateShort,
    required this.delayStatus,
    required this.announcements,
    required this.issues,
    required this.duesLines,
  });

  factory ResidentHomeData.demo(AppLocalizations l10n) {
    return ResidentHomeData(
      openDebtLira: DemoSampleData.openDebtLira,
      hasDebt: true,
      dueDateShort: l10n.demoSampleDateShort,
      delayStatus: l10n.demoSampleDelay,
      announcements: [
        HomeAnnouncementItem(
          title: l10n.homeDemoElevatorAnnouncementTitle,
          author: l10n.homeDemoElevatorAnnouncementAuthor,
          tag: HomeAnnouncementTag.pin,
        ),
        HomeAnnouncementItem(
          title: l10n.homeDemoHotWaterTitle,
          author: l10n.homeDemoHotWaterAuthor,
          tag: HomeAnnouncementTag.info,
        ),
      ],
      issues: [
        HomeIssueItem(
          title: l10n.homeDemoRoofLeakTitle,
          statusLabel: l10n.homeIssueStatusInProgress,
          updatedTimePhrase: l10n.homeDemoIssueUpdatedHours,
        ),
      ],
      duesLines: [
        HomeDuesItem(
          title: l10n.homeDemoDuesMarchTitle,
          subtitle: l10n.homeDemoDuesMarchSubtitle,
          isPaid: false,
        ),
        HomeDuesItem(
          title: l10n.homeDemoDuesFebTitle,
          subtitle: l10n.homeDemoDuesFebSubtitle,
          isPaid: true,
        ),
      ],
    );
  }

  static const ResidentHomeData empty = ResidentHomeData(
    openDebtLira: 0,
    hasDebt: false,
    dueDateShort: '',
    delayStatus: '',
    announcements: [],
    issues: [],
    duesLines: [],
  );

  final int openDebtLira;
  final bool hasDebt;
  final String dueDateShort;
  final String delayStatus;
  final List<HomeAnnouncementItem> announcements;
  final List<HomeIssueItem> issues;
  final List<HomeDuesItem> duesLines;
}

/// Manager dashboard metrics + chart series (demo only for now).
class ManagerHomeData {
  const ManagerHomeData({
    required this.collectionPercent,
    required this.incomeLira,
    required this.incomeDeltaPercent,
    required this.openDebtLira,
    required this.openDebtUnits,
    required this.openIssuesCount,
    required this.highPriorityCount,
    required this.notificationBadgeCount,
    required this.incomeSeriesK,
    required this.expenseSeriesK,
    required this.chartMonthLabels,
  });

  factory ManagerHomeData.demo(List<String> monthLabels) {
    assert(monthLabels.length == 6, 'chart expects six month labels');
    return ManagerHomeData(
      collectionPercent: 78,
      incomeLira: 28080,
      incomeDeltaPercent: 12,
      openDebtLira: 7920,
      openDebtUnits: 5,
      openIssuesCount: 3,
      highPriorityCount: 1,
      notificationBadgeCount: 3,
      incomeSeriesK: const [22, 24, 23, 25, 27, 28],
      expenseSeriesK: const [14, 15, 14, 16, 15, 16],
      chartMonthLabels: monthLabels,
    );
  }

  final int collectionPercent;
  final int incomeLira;
  final int incomeDeltaPercent;
  final int openDebtLira;
  final int openDebtUnits;
  final int openIssuesCount;
  final int highPriorityCount;
  final int notificationBadgeCount;

  /// Thousands of TRY — chart rods scale together.
  final List<double> incomeSeriesK;
  final List<double> expenseSeriesK;
  final List<String> chartMonthLabels;
}
