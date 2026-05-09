import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/core/utils/validators.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/theme/auth_shell_colors.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final FormGroup _form;
  StreamSubscription<dynamic>? _nameSubscription;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'fullName': FormControl<String>(validators: [Validators.required]),
      'phone': FormControl<String>(value: ''),
    });
    _nameSubscription = _form.control('fullName').valueChanges.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    unawaited(_nameSubscription?.cancel());
    super.dispose();
  }

  InputDecoration _fieldDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: AuthShellColors.surface,
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

  String _avatarInitials() {
    final raw = (_form.control('fullName').value as String?)?.trim() ?? '';
    if (raw.length >= 2) {
      final parts = raw.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
      final list = parts.toList();
      if (list.length >= 2) {
        return '${list[0][0]}${list[1][0]}'.toUpperCase();
      }
      return raw.substring(0, 2).toUpperCase();
    }
    return '?';
  }

  /// [presetPersona] when set (demo only): skip `/demo-role` and open `/home`.
  Future<void> _saveProfile({DemoPersona? presetPersona}) async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null) {
      return;
    }

    _form.markAllAsTouched();
    if (!_form.valid) {
      return;
    }

    final fullName = (_form.control('fullName').value as String).trim();
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

    final phoneRaw =
        (_form.control('phone').value as String?)?.trim() ?? '';
    if (phoneRaw.isNotEmpty) {
      final phoneErr = validatePhone(
        phoneRaw,
        message: l10n.errorGeneric,
      );
      if (phoneErr != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(phoneErr)),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final phoneFormatted =
          phoneRaw.isEmpty ? null : formatPhone(phoneRaw);
      await repo.upsertProfile(
        Profile(
          id: user.id,
          fullName: fullName,
          language: 'tr',
          email: user.email,
          phone: phoneFormatted,
        ),
      );

      // FutureProvider cache must refresh so router + HomeScreen see fullName.
      ref.invalidate(currentProfileProvider);
      await ref.read(currentProfileProvider.future);

      if (!mounted) {
        return;
      }

      if (presetPersona != null && Env.demoMode) {
        await ref.read(demoPersonaProvider.notifier).choose(presetPersona);
      }

      if (!mounted) {
        return;
      }

      if (presetPersona != null && Env.demoMode) {
        context.go('/home');
      } else {
        context.go(Env.demoMode ? '/demo-role' : '/home');
      }
    } on AppException catch (e) {
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
    final user = ref.watch(currentUserProvider);
    final textTheme = Theme.of(context).textTheme;

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
              context.go('/login');
            }
          },
        ),
        title: Text(
          l10n.profileSetupTitle,
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
                        l10n.profileHeadline,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.profileSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AuthShellColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4C8C4A),
                                  AppTheme.primary,
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _avatarInitials(),
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.profileAvatarTitle,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.profileAvatarSubtitle,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AuthShellColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.fullNameFieldLabel,
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w500,
                          color: AuthShellColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReactiveTextField<String>(
                        formControlName: 'fullName',
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: _fieldDecoration(context).copyWith(
                          hintText: l10n.fullNameHint,
                        ),
                        validationMessages: {
                          ValidationMessage.required: (_) => l10n.errorGeneric,
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.phoneFieldLabel,
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w500,
                          color: AuthShellColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ReactiveTextField<String>(
                        formControlName: 'phone',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: _fieldDecoration(context).copyWith(
                          hintText: l10n.phoneHint,
                        ),
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
                  if (Env.demoMode) ...[
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      isLoading: _saving,
                      onPressed: user == null || _saving
                          ? null
                          : () async {
                              await _saveProfile(
                                presetPersona: DemoPersona.resident,
                              );
                            },
                      child: Text(l10n.profileSetupDemoResident),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      isLoading: _saving,
                      onPressed: user == null || _saving
                          ? null
                          : () async {
                              await _saveProfile(
                                presetPersona: DemoPersona.manager,
                              );
                            },
                      child: Text(l10n.profileSetupDemoManager),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppButton(
                    isLoading: _saving,
                    onPressed: user == null || _saving
                        ? null
                        : () async {
                            await _saveProfile();
                          },
                    child: Text(l10n.continueButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
