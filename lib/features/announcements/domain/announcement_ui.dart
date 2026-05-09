enum AnnouncementUiCategory {
  pinned,
  info,
  maintenance,
  urgent,
}

class AnnouncementUi {
  const AnnouncementUi({
    required this.id,
    required this.title,
    required this.snippet,
    required this.authorName,
    required this.roleLabel,
    required this.category,
    required this.relativeTime,
    required this.viewCount,
    required this.commentCount,
    required this.read,
    required this.body,
    required this.attachmentName,
    required this.attachmentSizeLabel,
    this.secondaryCategory,
    this.detailMetaLine,
  });

  final String id;
  final String title;
  final String snippet;
  final String authorName;
  final String roleLabel;
  final AnnouncementUiCategory category;
  final String relativeTime;
  final int viewCount;
  final int commentCount;
  final bool read;
  final String body;
  final String? attachmentName;
  final String? attachmentSizeLabel;

  /// Second tag on detail (e.g. pin + maintenance → "SABİT · BAKIM").
  final AnnouncementUiCategory? secondaryCategory;

  /// Optional subtitle under author ("10 Mart, 14:32 · 24 görüntülenme").
  final String? detailMetaLine;
}
