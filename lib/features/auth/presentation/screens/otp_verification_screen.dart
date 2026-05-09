import 'dart:async';

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/theme/auth_shell_colors.dart';
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

  String _formatMmSs(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

    return Scaffold(
      backgroundColor: AuthShellColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AuthShellColors.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        title: Text(
          l10n.otpAppBarTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AuthShellColors.border,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.otpHeadline,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.otpSentParagraph(widget.identifier),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AuthShellColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: MaterialPinField(
                        length: 6,
                        pinController: _pinController,
                        autoFocus: true,
                        theme: MaterialPinTheme(
                          spacing: 10,
                          borderRadius: BorderRadius.circular(12),
                          focusedBorderWidth: 1.5,
                          borderColor: AuthShellColors.border,
                          focusedBorderColor: scheme.primary,
                          fillColor: AuthShellColors.surface,
                          textStyle: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (resendEnabled)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.otpResendPrompt,
                            style: textTheme.bodySmall?.copyWith(
                              color: AuthShellColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: authState.isLoading
                                ? null
                                : () async {
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
                                  },
                            child: Text(
                              l10n.resendOtp,
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        l10n.otpResendLineCooldown(
                          _formatMmSs(_remaining),
                        ),
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: AuthShellColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: AppButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
