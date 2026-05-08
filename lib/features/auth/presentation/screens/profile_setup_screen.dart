import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/utils/validators.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/core/widgets/app_scaffold.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _form = FormGroup({
    'fullName': FormControl<String>(validators: [Validators.required]),
  });

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.profileSetupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ReactiveForm(
          formGroup: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReactiveTextField<String>(
                formControlName: 'fullName',
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(hintText: l10n.fullNameHint),
                validationMessages: {
                  ValidationMessage.required: (_) => l10n.errorGeneric,
                },
              ),
              const SizedBox(height: 16),
              AppButton(
                isLoading: _saving,
                onPressed: user == null || _saving
                    ? null
                    : () async {
                        _form.markAllAsTouched();
                        if (!_form.valid) {
                          return;
                        }

                        final fullName =
                            (_form.control('fullName').value as String).trim();
                        final requiredError = validateRequired(
                          fullName,
                          message: l10n.errorGeneric,
                        );
                        final minLengthError = validateMinLength(
                          fullName,
                          minLength: 2,
                          message: l10n.errorGeneric,
                        );
                        if (requiredError != null || minLengthError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.errorGeneric)),
                          );
                          return;
                        }

                        setState(() => _saving = true);
                        try {
                          final repo = ref.read(profileRepositoryProvider);
                          await repo.upsertProfile(
                            Profile(
                              id: user.id,
                              fullName: fullName,
                              language: 'tr',
                              email: user.email,
                              phone: user.phone,
                            ),
                          );

                          if (!context.mounted) {
                            return;
                          }
                          context.go('/home');
                        } on AppException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.userMessage)),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _saving = false);
                          }
                        }
                      },
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
