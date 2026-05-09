import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class InviteResidentScreen extends StatelessWidget {
  const InviteResidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.managerInviteTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(l10n.demoInviteQrHelp, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade200,
                child: const Icon(Icons.qr_code_2, size: 120),
              ),
              const SizedBox(height: 16),
              SelectableText(
                'A7K3-9P2X',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
