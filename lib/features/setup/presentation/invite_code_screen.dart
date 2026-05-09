import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final _controllers = List.generate(8, (_) => TextEditingController());
  final _focusNodes = List.generate(8, (_) => FocusNode());
  bool _preview = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupInviteTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.setupInviteHeadline,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 8; i++) ...[
                  SizedBox(
                    width: 36,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: const InputDecoration(counterText: ''),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                      ],
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 7) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        final full = _controllers.every(
                          (c) => (c.text.trim().length == 1),
                        );
                        setState(() => _preview = full);
                      },
                    ),
                  ),
                  if (i == 3) const Text(' - '),
                ],
              ],
            ),
            if (_preview) ...[
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.apartment_outlined),
                  title: Text(l10n.demoInvitePreviewTitle),
                  subtitle: Text(l10n.demoInvitePreviewSubtitle),
                ),
              ),
            ],
            const Spacer(),
            AppButton(
              onPressed: _preview ? () => context.go('/home') : null,
              child: Text(l10n.setupInviteJoin),
            ),
          ],
        ),
      ),
    );
  }
}
