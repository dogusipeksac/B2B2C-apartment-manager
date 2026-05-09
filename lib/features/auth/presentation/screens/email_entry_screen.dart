import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/utils/validators.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/theme/auth_shell_colors.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

class EmailEntryScreen extends ConsumerStatefulWidget {
  const EmailEntryScreen({super.key});

  @override
  ConsumerState<EmailEntryScreen> createState() => _EmailEntryScreenState();
}

class _EmailEntryScreenState extends ConsumerState<EmailEntryScreen> {
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

  final _form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
  });

  InputDecoration _emailDecoration(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: AuthShellColors.surface,
      hintText: l10n.emailHint,
      prefixIcon: const Icon(
        Icons.mail_outline_rounded,
        color: AuthShellColors.textMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AuthShellColors.border,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
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

    return Scaffold(
      backgroundColor: AuthShellColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AuthShellColors.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/splash');
            }
          },
        ),
        title: Text(
          l10n.emailEntryTitle,
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
                child: ReactiveForm(
                  formGroup: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.emailLoginHeadline,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.emailLoginSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AuthShellColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.emailFieldLabel,
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w500,
                          color: AuthShellColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReactiveTextField<String>(
                        formControlName: 'email',
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: _emailDecoration(context, l10n),
                        validationMessages: {
                          ValidationMessage.required: (_) =>
                              l10n.errorEmailInvalid,
                          ValidationMessage.email: (_) =>
                              l10n.errorEmailInvalid,
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AuthShellColors.textTertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.kvkkEmailNotice,
                              style: textTheme.labelSmall?.copyWith(
                                color: AuthShellColors.textTertiary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    isLoading: authState.isLoading,
                    onPressed: () async {
                      _form.markAllAsTouched();
                      if (!_form.valid) {
                        return;
                      }

                      final email =
                          (_form.control('email').value as String).trim();
                      final emailError = validateEmail(
                        email,
                        message: l10n.errorEmailInvalid,
                      );
                      if (emailError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(emailError)),
                        );
                        return;
                      }

                      final ok = await ref
                          .read(authNotifierProvider.notifier)
                          .sendOtp(
                            identifier: email,
                            channel: OtpChannel.email,
                          );

                      if (!context.mounted) {
                        return;
                      }

                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.otpSentToEmail(email))),
                        );
                        final encoded = Uri.encodeComponent(email);
                        context.go(
                          '/verify-otp?identifier=$encoded&channel=email',
                        );
                      }
                    },
                    child: Text(l10n.continueButton),
                  ),
                  const SizedBox(height: 12),
                  _EmailLoginLegalLine(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailLoginLegalLine extends StatefulWidget {
  @override
  State<_EmailLoginLegalLine> createState() => _EmailLoginLegalLineState();
}

class _EmailLoginLegalLineState extends State<_EmailLoginLegalLine> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = _showPlaceholder;
    _privacyTap = TapGestureRecognizer()..onTap = _showPlaceholder;
  }

  void _showPlaceholder() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.legalLinkPlaceholder)),
    );
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;

    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AuthShellColors.textMuted,
              height: 1.35,
            ),
        children: [
          TextSpan(text: l10n.loginLegalPrefix),
          TextSpan(
            text: l10n.loginLegalTerms,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w500,
            ),
            recognizer: _termsTap,
          ),
          TextSpan(text: l10n.loginLegalMiddle),
          TextSpan(
            text: l10n.loginLegalPrivacy,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w500,
            ),
            recognizer: _privacyTap,
          ),
          TextSpan(text: l10n.loginLegalSuffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
