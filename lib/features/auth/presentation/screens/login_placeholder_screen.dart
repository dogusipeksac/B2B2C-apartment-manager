import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Temporary shell until invite-code login UI lands (Phase B — later stops).
class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emailEntryTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.emailLoginSubtitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
