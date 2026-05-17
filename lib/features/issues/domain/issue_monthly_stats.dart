/// Manager dashboard issue counts for a calendar month.
class IssueMonthlyStats {
  const IssueMonthlyStats({
    required this.year,
    required this.month,
    required this.opened,
    required this.resolved,
    required this.pending,
    required this.highPriorityPending,
  });

  final int year;
  final int month;
  final int opened;
  final int resolved;
  final int pending;
  final int highPriorityPending;

  factory IssueMonthlyStats.fromWire(Map<String, dynamic> wire) {
    int readInt(String key, int fallback) {
      final v = wire[key];
      if (v is int) {
        return v;
      }
      if (v is num) {
        return v.toInt();
      }
      return fallback;
    }

    final now = DateTime.now();
    return IssueMonthlyStats(
      year: readInt('year', now.year),
      month: readInt('month', now.month),
      opened: readInt('opened', 0),
      resolved: readInt('resolved', 0),
      pending: readInt('pending', 0),
      highPriorityPending: readInt('high_priority_pending', 0),
    );
  }

  /// Demo dashboard when [Env.demoMode].
  factory IssueMonthlyStats.demo({int? year, int? month}) {
    final now = DateTime.now();
    return IssueMonthlyStats(
      year: year ?? now.year,
      month: month ?? now.month,
      opened: 5,
      resolved: 2,
      pending: 3,
      highPriorityPending: 1,
    );
  }
}
