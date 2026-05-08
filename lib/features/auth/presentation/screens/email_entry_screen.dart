import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/utils/validators.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/core/widgets/app_scaffold.dart';
import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
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

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.emailEntryTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ReactiveForm(
          formGroup: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReactiveTextField<String>(
                formControlName: 'email',
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: l10n.emailHint),
                validationMessages: {
                  ValidationMessage.required: (_) => l10n.errorEmailInvalid,
                  ValidationMessage.email: (_) => l10n.errorEmailInvalid,
                },
              ),
              const SizedBox(height: 16),
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
                      .sendOtp(identifier: email, channel: OtpChannel.email);

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
            ],
          ),
        ),
      ),
    );
  }
}
