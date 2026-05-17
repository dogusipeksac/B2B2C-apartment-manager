/// Turkish-relative time phrases for list subtitles.
String formatRelativeTimeTr(DateTime then) {
  final diff = DateTime.now().difference(then);
  if (diff.isNegative || diff.inSeconds < 60) {
    return 'Az önce';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} dk önce';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} saat önce';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} gün önce';
  }
  if (diff.inDays < 14) {
    return '1 hafta önce';
  }
  if (diff.inDays < 30) {
    return '${diff.inDays ~/ 7} hafta önce';
  }
  return '${diff.inDays ~/ 30} ay önce';
}
