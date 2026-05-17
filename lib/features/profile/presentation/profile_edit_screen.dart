import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/profile/data/profile_ops_repository.dart';
import 'package:apartment_manager/features/profile/domain/profile_details.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Edit display name; building, unit and invite code are read-only.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  Object? _loadError;
  ProfileDetails? _details;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted) {
        return;
      }
      if (session == null) {
        setState(() {
          _loadError = 'no_session';
          _loading = false;
        });
        return;
      }
      final details =
          await ref.read(profileOpsRepositoryProvider).getProfile(session);
      if (!mounted) {
        return;
      }
      _nameController.text = details.fullName?.trim() ?? '';
      setState(() {
        _details = details;
        _loading = false;
      });
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = e;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final session = await ref.read(localSessionRepositoryProvider).load();
    if (session == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final savedName = await ref
          .read(profileOpsRepositoryProvider)
          .updateFullName(session, fullName: name);

      final profileId = _details?.profileId ?? session.profileId;
      final updated = session.copyWith(
        fullName: savedName,
        profileId: profileId,
        buildingName: _details?.buildingName ?? session.buildingName,
        savedAt: DateTime.now(),
      );
      await ref.persistLocalSession(
        updated,
        rememberMe: session.rememberMe,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileEditSaved)),
      );
      context.pop(true);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.profileEditTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _loadError is AppException
                      ? (_loadError! as AppException).userMessage
                      : l10n.errorGeneric,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(
                    l10n.profileEditEditableSection,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.fullNameFieldLabel,
                          hintText: l10n.fullNameHint,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.length < 2) {
                            return l10n.profileEditNameRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.profileEditLinkedSection,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.profileEditReadOnlyHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: apart.onSurfaceTertiary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        _ReadOnlyField(
                          label: l10n.profileEditBuildingLabel,
                          value: _details?.buildingName,
                          showDivider: true,
                        ),
                        _ReadOnlyField(
                          label: l10n.profileEditUnitLabel,
                          value: _details?.unitLabel,
                          showDivider: true,
                        ),
                        _ReadOnlyField(
                          label: l10n.profileEditInviteCodeLabel,
                          value: _details?.inviteCode,
                          monospace: true,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  if (Env.demoMode) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.profileDemoCardSubtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: apart.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.profileEditSave),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.monospace = false,
    required this.showDivider,
  });

  final String label;
  final String? value;
  final bool monospace;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    final display = value != null && value!.trim().isNotEmpty
        ? value!.trim()
        : '—';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: apart.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  display,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: monospace
                        ? const [FontFeature.tabularFigures()]
                        : null,
                    letterSpacing: monospace ? 0.6 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: apart.outlineMuted.withValues(alpha: 0.65),
          ),
      ],
    );
  }
}
