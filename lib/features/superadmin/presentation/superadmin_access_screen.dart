import 'dart:async';

import 'package:apartment_manager/core/device/device_id_provider.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Production-only entry: backend-validated super-admin access code (see
/// `SUPERADMIN_ACCESS_CODE` on Edge `redeem_code`).
class SuperadminAccessScreen extends ConsumerStatefulWidget {
  const SuperadminAccessScreen({super.key});

  @override
  ConsumerState<SuperadminAccessScreen> createState() =>
      _SuperadminAccessScreenState();
}

class _SuperadminAccessScreenState extends ConsumerState<SuperadminAccessScreen> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final raw = _controller.text.trim();
    if (raw.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.superadminAccessCodeTooShort)),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final repo = ref.read(inviteCodeRepositoryProvider);
      final deviceId = await ref.read(deviceIdProvider.future);
      final code = normalizeInviteCode(raw);
      final session = await repo.redeemCode(code, deviceId);
      if (session.role != UserRole.superAdmin) {
        await ref.read(localSessionRepositoryProvider).clear();
        ref.notifyLocalSessionChanged();
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.superadminAccessWrongRole)),
        );
        return;
      }
      await ref.read(localSessionRepositoryProvider).save(session);
      ref.notifyLocalSessionChanged();
      if (!mounted) {
        return;
      }
      context.go('/home');
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.superadminAccessUnexpectedError)),
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
    final apart = context.apart;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: apart.scaffoldBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/setup/account-type'),
        ),
        title: Text(
          l10n.superadminAccessTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.superadminAccessHeadline,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.superadminAccessBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: apart.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(48),
                ],
                decoration: InputDecoration(
                  labelText: l10n.superadminAccessFieldLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => unawaited(_submit()),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _busy ? null : () => unawaited(_submit()),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.superadminAccessContinue,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
