import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';
import 'package:apartment_manager/features/announcements/presentation/providers/announcement_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **4.6** — Duyuru detay (etiketler, yazar, ek, yorum çubuğu).
class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({
    required this.announcementId,
    super.key,
  });

  final String announcementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(announcementRepositoryProvider);

    return FutureBuilder<AnnouncementUi?>(
      future: repo.byId(announcementId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.announcementDetailTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final row = snapshot.data;
        if (row == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.announcementDetailTitle)),
            body: Center(child: Text(l10n.catalogEmptyTitle)),
          );
        }

        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final apart = context.apart;

        return Scaffold(
          backgroundColor: apart.scaffoldBg,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              l10n.announcementDetailTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.homeFeatureSoon)),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailTagBanner(l10n: l10n, row: row),
                      const SizedBox(height: 10),
                      Text(
                        row.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: apart.outlineMuted),
                            bottom: BorderSide(color: apart.outlineMuted),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailAvatar(name: row.authorName),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          row.authorName,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          row.roleLabel,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: scheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    row.detailMetaLine ??
                                        l10n.announcementViewsFallback(
                                          '${row.viewCount}',
                                        ),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: apart.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ..._bodyParagraphs(context, row.body),
                      if (row.attachmentName != null) ...[
                        const SizedBox(height: 16),
                        _AttachmentTile(
                          name: row.attachmentName!,
                          sizeLabel: row.attachmentSizeLabel ?? '',
                          onDownload: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.announcementDownloadComingSoon),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Material(
                  color: apart.surface,
                  elevation: 4,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryLight,
                                AppTheme.primary,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'MY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.homeFeatureSoon)),
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.announcementCommentPlaceholder(
                                '${row.commentCount}',
                              ),
                              filled: true,
                              fillColor: apart.scaffoldBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              hintStyle: theme.textTheme.bodySmall?.copyWith(
                                color: apart.onSurfaceTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// `**bold**` segments + paragraph breaks (`\n\n`).
  List<Widget> _bodyParagraphs(BuildContext context, String body) {
    final theme = Theme.of(context);
    final onSurf = theme.colorScheme.onSurface;
    final base = theme.textTheme.bodyMedium?.copyWith(
          color: onSurf,
          height: 1.55,
          fontSize: 15,
        ) ??
        TextStyle(
          fontSize: 15,
          height: 1.55,
          color: onSurf,
        );
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    final paras = body.split('\n\n');
    final out = <Widget>[];
    for (var i = 0; i < paras.length; i++) {
      if (i > 0) {
        out.add(const SizedBox(height: 12));
      }
      out.add(
        SelectableText.rich(
          TextSpan(
            style: base,
            children: _boldSpans(paras[i], base, bold),
          ),
        ),
      );
    }
    return out;
  }

  List<TextSpan> _boldSpans(
    String paragraph,
    TextStyle base,
    TextStyle bold,
  ) {
    final parts = paragraph.split('**');
    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      spans.add(
        TextSpan(
          text: parts[i],
          style: i.isOdd ? bold : base,
        ),
      );
    }
    return spans;
  }
}

class _DetailTagBanner extends StatelessWidget {
  const _DetailTagBanner({
    required this.l10n,
    required this.row,
  });

  final AppLocalizations l10n;
  final AnnouncementUi row;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = _tagText(l10n);
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.secondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }

  String _tagText(AppLocalizations l10n) {
    final pin = row.category == AnnouncementUiCategory.pinned;
    final maint = row.secondaryCategory ==
            AnnouncementUiCategory.maintenance ||
        row.category == AnnouncementUiCategory.maintenance;
    if (pin && maint) {
      return l10n.announcementDetailTagPinnedMaintenance;
    }
    if (pin) {
      return '⭐ ${l10n.announcementCatPinned}';
    }
    return '';
  }
}

class _DetailAvatar extends StatelessWidget {
  const _DetailAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppTheme.primary,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.name,
    required this.sizeLabel,
    required this.onDownload,
  });

  final String name;
  final String sizeLabel;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    return Material(
      color: apart.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onDownload,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: apart.outlineMuted),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'PDF',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (sizeLabel.isNotEmpty)
                      Text(
                        sizeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: apart.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.download_rounded,
                color: apart.onSurfaceTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
