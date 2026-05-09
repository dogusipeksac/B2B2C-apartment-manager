import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/device/device_id_provider.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/domain/code_preview.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sakin — yöneticinin oluşturduğu 5 karakterlik birim davet kodu ile katılım.
class ResidentInviteScreen extends ConsumerStatefulWidget {
  const ResidentInviteScreen({super.key});

  @override
  ConsumerState<ResidentInviteScreen> createState() =>
      _ResidentInviteScreenState();
}

class _CodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var t = newValue.text.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    if (t.length > 5) {
      t = t.substring(0, 5);
    }
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

class _ResidentInviteScreenState extends ConsumerState<ResidentInviteScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _busy = false;
  Timer? _previewDebounce;
  CodePreview? _preview;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeEdited);
  }

  void _onCodeEdited() {
    _previewDebounce?.cancel();
    final normalized = normalizeInviteCode(_codeController.text);
    if (normalized.length != 5) {
      if (_preview != null) {
        setState(() => _preview = null);
      }
      return;
    }
    if (Env.demoMode) {
      if (_preview != null) {
        setState(() => _preview = null);
      }
      return;
    }
    _previewDebounce = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) {
        return;
      }
      try {
        final repo = ref.read(inviteCodeRepositoryProvider);
        final p = await repo.validateCode(normalized);
        if (!mounted) {
          return;
        }
        setState(() => _preview = p);
      } on AppException {
        if (!mounted) {
          return;
        }
        setState(() => _preview = null);
      } on Object {
        if (!mounted) {
          return;
        }
        setState(() => _preview = null);
      }
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _codeController
      ..removeListener(_onCodeEdited)
      ..dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final raw = normalizeInviteCode(_codeController.text);
    if (raw.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.residentInviteCodeTooShort)),
      );
      return;
    }
    final name = _nameController.text.trim();
    if (name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.residentInviteNameTooShort)),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(inviteCodeRepositoryProvider);
      final session = await repo.redeemCode(raw, deviceId, fullName: name);
      await ref.read(localSessionRepositoryProvider).save(session);
      ref.notifyLocalSessionChanged();
      if (!context.mounted) {
        return;
      }
      context.go('/home');
    } on AppException catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } on Object {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.residentInviteUnexpected)),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/setup/account-type'),
        ),
        title: Text(l10n.residentInviteScreenTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.residentInviteScreenBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: apart.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (Env.demoMode) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.onTertiaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.residentInvitePreviewDemo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [_CodeFormatter()],
              decoration: InputDecoration(
                labelText: l10n.residentInviteCodeLabel,
                hintText: l10n.residentInviteCodeHint,
                border: const OutlineInputBorder(),
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
              maxLength: 5,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
            ),
            if (!Env.demoMode && _preview != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.residentInvitePreviewTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_preview!.codeType == InviteCodeType.admin)
                        Text(
                          l10n.residentInviteWrongCodeType,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.error,
                          ),
                        )
                      else ...[
                        if (_preview!.buildingName != null &&
                            _preview!.buildingName!.trim().isNotEmpty)
                          Text(
                            _preview!.buildingName!.trim(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (_preview!.unitLabel != null &&
                            _preview!.unitLabel!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _preview!.unitLabel!.trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: apart.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.residentInviteFullNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _busy ? null : () => unawaited(_submit(context)),
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.residentInviteSubmit),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/setup/account-type'),
              child: Text(l10n.residentInviteBackToRole),
            ),
          ],
        ),
      ),
    );
  }
}
