import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sakin davet kodu akışı (Durak sonrası bağlanacak).
class ResidentInvitePlaceholderScreen extends StatelessWidget {
  const ResidentInvitePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/setup/account-type'),
        ),
        title: Text(l10n.residentInvitePlaceholderTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.residentInvitePlaceholderBody,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/setup/account-type'),
              child: Text(l10n.residentInviteBackToRole),
            ),
          ],
        ),
      ),
    );
  }
}
