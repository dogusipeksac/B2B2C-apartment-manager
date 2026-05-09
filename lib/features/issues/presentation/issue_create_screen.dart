import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IssueCreateScreen extends StatefulWidget {
  const IssueCreateScreen({super.key});

  @override
  State<IssueCreateScreen> createState() => _IssueCreateScreenState();
}

class _IssueCreateScreenState extends State<IssueCreateScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.issueNewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: l10n.issueFieldTitle),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _body,
            decoration: InputDecoration(labelText: l10n.issueFieldDescription),
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 24),
          AppButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.homeFeatureSoon)),
              );
              context.pop();
            },
            child: Text(l10n.issueSubmit),
          ),
        ],
      ),
    );
  }
}
