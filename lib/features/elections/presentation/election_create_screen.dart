import 'dart:async';

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/elections/presentation/providers/election_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ElectionCreateScreen extends ConsumerStatefulWidget {
  const ElectionCreateScreen({super.key});

  @override
  ConsumerState<ElectionCreateScreen> createState() =>
      _ElectionCreateScreenState();
}

class _ElectionCreateScreenState extends ConsumerState<ElectionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _nominationsCloseAt;
  DateTime? _closesAt;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final session = ref.read(localSessionProvider).value;
    if (session == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      final id = await ref.read(electionRepositoryProvider).createElection(
        session,
        title: _title.text,
        description: _description.text,
        nominationsCloseAt: _nominationsCloseAt,
        closesAt: _closesAt,
      );
      ref.invalidate(electionsListProvider);
      if (!mounted) {
        return;
      }
      context.pop();
      if (id.isNotEmpty) {
        unawaited(context.push('/elections/$id'));
      }
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickDate({required bool nominations}) async {
    final now = DateTime.now();
    final current = nominations ? _nominationsCloseAt : _closesAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now.add(Duration(days: nominations ? 3 : 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (nominations) {
          _nominationsCloseAt = picked;
        } else {
          _closesAt = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.electionCreateTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                labelText: l10n.electionFieldTitle,
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return l10n.electionTitleValidation;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(
                labelText: l10n.electionFieldDescription,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.electionFieldNominationsCloseAt),
              subtitle: Text(
                _nominationsCloseAt == null
                    ? l10n.electionClosesAtOptional
                    : MaterialLocalizations.of(context).formatMediumDate(
                        _nominationsCloseAt!,
                      ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () => _pickDate(nominations: true),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.electionFieldClosesAt),
              subtitle: Text(
                _closesAt == null
                    ? l10n.electionClosesAtOptional
                    : MaterialLocalizations.of(context).formatMediumDate(
                        _closesAt!,
                      ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () => _pickDate(nominations: false),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.electionSecretHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.apart.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.electionCreateSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
