import 'dart:async';

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/core/widgets/app_scaffold.dart';
import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    required this.identifier,
    required this.channel,
    super.key,
  });

  final String identifier;
  final OtpChannel channel;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _cooldownSeconds = 60;

  String _localizedError(AppLocalizations l10n, AppException e) {
    final key = e.mapOrNull(
      auth: (v) => v.messageKey,
      validation: (v) => v.messageKey,
      server: (v) => v.messageKey,
    );

    return switch (key) {
      'errorRateLimit' => l10n.errorRateLimit,
      'errorOtpExpired' => l10n.errorOtpExpired,
      'errorInvalidOtp' => l10n.errorInvalidOtp,
      'errorGeneric' => l10n.errorGeneric,
      _ => e.userMessage,
    };
  }

  final _pinController = PinInputController();
  Timer? _cooldownTimer;
  int _remaining = _cooldownSeconds;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _remaining = _cooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (err, _) {
          final message = switch (err) {
            AppException() => _localizedError(l10n, err),
            _ => l10n.errorGeneric,
          };
          final code = (err is AppException)
              ? err.mapOrNull(
                  auth: (v) => v.code,
                  validation: (v) => v.code,
                  server: (v) => v.code,
                )
              : null;

          final isRateLimit = code == 'rate_limit';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: Duration(seconds: isRateLimit ? 6 : 4),
              backgroundColor:
                  isRateLimit ? Theme.of(context).colorScheme.error : null,
            ),
          );
        },
      );
    });

    final resendEnabled = _remaining == 0 && !authState.isLoading;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.otpSubtitle(widget.identifier)),
            const SizedBox(height: 16),
            MaterialPinField(
              length: 6,
              pinController: _pinController,
              autoFocus: true,
              theme: MaterialPinTheme(
                cellSize: const Size(44, 48),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              isLoading: authState.isLoading,
              onPressed: () async {
                final code = _pinController.text.trim();
                if (code.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.errorInvalidOtp)),
                  );
                  return;
                }

                final ok = await ref
                    .read(authNotifierProvider.notifier)
                    .verifyOtp(
                      identifier: widget.identifier,
                      code: code,
                      channel: widget.channel,
                    );

                if (!context.mounted || !ok) {
                  return;
                }

                final profile = await ref.read(currentProfileProvider.future);
                if (!context.mounted) {
                  return;
                }

                final fullName = profile?.fullName.trim() ?? '';
                if (fullName.isEmpty) {
                  context.go('/profile-setup');
                } else {
                  context.go('/home');
                }
              },
              child: Text(l10n.verifyButton),
            ),
            const SizedBox(height: 12),
            AppButton(
              variant: AppButtonVariant.text,
              onPressed: resendEnabled
                  ? () async {
                      final ok = await ref
                          .read(authNotifierProvider.notifier)
                          .sendOtp(
                            identifier: widget.identifier,
                            channel: widget.channel,
                          );
                      if (!context.mounted) {
                        return;
                      }
                      if (ok) {
                        _startCooldown();
                      }
                    }
                  : null,
              child: _remaining > 0
                  ? Text(l10n.resendIn(_remaining))
                  : Text(l10n.resendOtp),
            ),
          ],
        ),
      ),
    );
  }
}
