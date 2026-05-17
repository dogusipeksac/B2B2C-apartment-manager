import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Optional notes when creating an invite code (admin or unit).
///
/// Returns `null` if dismissed, empty string if confirmed with no note,
/// otherwise the trimmed note text.
Future<String?> showInviteCodeNotesDialog(
  BuildContext context, {
  required String title,
  required String hint,
}) {
  return showDialog<String?>(
    context: context,
    builder: (ctx) => _InviteCodeNotesDialog(
      title: title,
      hint: hint,
    ),
  );
}

class _InviteCodeNotesDialog extends StatefulWidget {
  const _InviteCodeNotesDialog({
    required this.title,
    required this.hint,
  });

  final String title;
  final String hint;

  @override
  State<_InviteCodeNotesDialog> createState() => _InviteCodeNotesDialogState();
}

class _InviteCodeNotesDialogState extends State<_InviteCodeNotesDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: const OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.navBack),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.of(context).pop(text.isEmpty ? '' : text);
          },
          child: Text(l10n.inviteCodeNotesCreate),
        ),
      ],
    );
  }
}
