import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/device/device_id_provider.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/session_preferences_storage.dart';
import 'package:apartment_manager/features/auth/domain/code_preview.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/widgets/invite_otp_input.dart';
import 'package:apartment_manager/features/auth/presentation/widgets/remember_me_checkbox.dart';
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

enum _ResidentPhase {
  idle,
  loading,
  validNew,
  resumePreview,
  invalidNotFound,
  invalidWrongType,
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
  static const _codeLength = 5;

  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _nameController = TextEditingController();
  bool _busy = false;
  bool _rememberMe = true;
  Timer? _previewDebounce;
  _ResidentPhase _phase = _ResidentPhase.idle;
  CodePreview? _preview;
  String? _resumeBuildingName;
  String? _resumeUnitLabel;

  /// Probe said an existing registration exists (keep through submit).
  bool _knownResume = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeEdited);
    void refreshFocus() => setState(() {});
    _codeFocusNode.addListener(refreshFocus);
    _nameFocusNode.addListener(refreshFocus);
    unawaited(_loadRememberDefault());
  }

  Future<void> _loadRememberDefault() async {
    final value = await SessionPreferencesStorage.loadRememberMeDefault();
    if (mounted) {
      setState(() => _rememberMe = value);
    }
  }

  void _onCodeEdited() {
    _previewDebounce?.cancel();
    final normalized = normalizeInviteCode(_codeController.text);

    if (_phase == _ResidentPhase.resumePreview) {
      setState(() {
        _phase = _ResidentPhase.idle;
        _resumeBuildingName = null;
        _resumeUnitLabel = null;
        _knownResume = false;
      });
    }

    if (normalized.length != _codeLength) {
      setState(() {
        _phase = _ResidentPhase.idle;
        _preview = null;
        _resumeBuildingName = null;
        _resumeUnitLabel = null;
      });
      return;
    }

    if (Env.demoMode) {
      setState(() {
        _phase = _ResidentPhase.validNew;
        _preview = null;
      });
      return;
    }

    setState(() {
      _phase = _ResidentPhase.loading;
      _preview = null;
      _resumeBuildingName = null;
      _resumeUnitLabel = null;
    });

    _previewDebounce = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted || normalizeInviteCode(_codeController.text) != normalized) {
        return;
      }
      try {
        final repo = ref.read(inviteCodeRepositoryProvider);
        final deviceId = await ref.read(deviceIdProvider.future);
        final previewFuture = repo.validateCode(normalized);
        final probeFuture = repo.probeResidentInvite(normalized, deviceId);
        final preview = await previewFuture;
        final probe = await probeFuture;
        if (!mounted ||
            normalizeInviteCode(_codeController.text) != normalized) {
          return;
        }

        if (preview != null && preview.codeType == InviteCodeType.admin) {
          setState(() {
            _phase = _ResidentPhase.invalidWrongType;
            _preview = preview;
          });
          return;
        }

        if (probe.wouldResume) {
          setState(() {
            _phase = _ResidentPhase.resumePreview;
            _knownResume = true;
            _preview = preview;
            _resumeBuildingName = probe.buildingName?.trim();
            _resumeUnitLabel = probe.unitLabel?.trim();
          });
          return;
        }

        if (preview != null && preview.codeType == InviteCodeType.unit) {
          setState(() {
            _phase = _ResidentPhase.validNew;
            _preview = preview;
          });
          return;
        }

        setState(() {
          _phase = _ResidentPhase.invalidNotFound;
          _preview = null;
        });
      } on AppException {
        if (!mounted) {
          return;
        }
        setState(() {
          _phase = _ResidentPhase.invalidNotFound;
          _preview = null;
        });
      } on Object {
        if (!mounted) {
          return;
        }
        setState(() {
          _phase = _ResidentPhase.invalidNotFound;
          _preview = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _codeController
      ..removeListener(_onCodeEdited)
      ..dispose();
    _codeFocusNode.dispose();
    _nameFocusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final raw = normalizeInviteCode(_codeController.text);
    if (raw.length < _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.residentInviteCodeTooShort)),
      );
      return;
    }

    final isResume =
        _phase == _ResidentPhase.resumePreview || _knownResume;
    if (!isResume &&
        _phase != _ResidentPhase.validNew) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _phase == _ResidentPhase.invalidWrongType
                ? l10n.residentInviteWrongCodeType
                : l10n.adminInviteCodeNotFound,
          ),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    if (!isResume && name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.residentInviteNameTooShort)),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(inviteCodeRepositoryProvider);
      final session = await repo.redeemCode(
        raw,
        deviceId,
        fullName: name.isNotEmpty ? name : null,
      );
      await ref.persistLocalSession(session, rememberMe: _rememberMe);
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
    final apart = context.apart;
    final theme = Theme.of(context);
    final code = _codeController.text;
    final isResumeUi =
        _phase == _ResidentPhase.resumePreview || _knownResume;
    final canSubmit = (isResumeUi || _phase == _ResidentPhase.validNew) &&
        !_busy &&
        code.length == _codeLength;
    final headline = isResumeUi
        ? l10n.residentInviteResumeHeadline
        : l10n.residentInviteHeadline;
    final hint = isResumeUi
        ? l10n.residentInviteResumeSubtitle
        : l10n.residentInviteJoinHint;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: apart.scaffoldBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/setup/account-type'),
        ),
        title: Text(
          l10n.residentInvitePlaceholderTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      headline,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hint,
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
                                  color:
                                      theme.colorScheme.onTertiaryContainer,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _SectionCaps(label: l10n.residentInviteCodeSection),
                    const SizedBox(height: 10),
                    InviteOtpInput(
                      length: _codeLength,
                      controller: _codeController,
                      focusNode: _codeFocusNode,
                      inputFormatters: [_CodeFormatter()],
                      onSubmitted: (_) => unawaited(_submit(context)),
                    ),
                    const SizedBox(height: 20),
                    if (_phase == _ResidentPhase.loading &&
                        code.length == _codeLength)
                      Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.residentInviteChecking,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: apart.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    if (isResumeUi)
                      _ResidentResumeCard(
                        l10n: l10n,
                        buildingTitle: _resumeBuildingName,
                        unitLabel: _resumeUnitLabel,
                      ),
                    if (!isResumeUi &&
                        !Env.demoMode &&
                        _preview != null &&
                        _phase == _ResidentPhase.validNew)
                      _ResidentVerifiedCard(
                        l10n: l10n,
                        preview: _preview,
                      ),
                    if ((_phase == _ResidentPhase.invalidNotFound ||
                            _phase == _ResidentPhase.invalidWrongType) &&
                        code.length == _codeLength)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _phase == _ResidentPhase.invalidWrongType
                              ? l10n.residentInviteWrongCodeType
                              : l10n.adminInviteCodeNotFound,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    if (!isResumeUi) ...[
                      const SizedBox(height: 24),
                      _SectionCaps(label: l10n.residentInviteAccountSection),
                      const SizedBox(height: 10),
                      InviteFormRow(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        hintText: l10n.residentInviteFullNameLabel,
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: canSubmit
                        ? () => unawaited(_submit(context))
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          apart.outlineMuted.withValues(alpha: 0.6),
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
                            isResumeUi
                                ? l10n.residentInviteResumeSignIn
                                : l10n.residentInviteSubmit,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  RememberMeCheckbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v),
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

class _SectionCaps extends StatelessWidget {
  const _SectionCaps({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: context.apart.onSurfaceVariant,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ResidentResumeCard extends StatelessWidget {
  const _ResidentResumeCard({
    required this.l10n,
    this.buildingTitle,
    this.unitLabel,
  });

  final AppLocalizations l10n;
  final String? buildingTitle;
  final String? unitLabel;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    final name = buildingTitle?.trim();
    final title = (name != null && name.isNotEmpty)
        ? name
        : l10n.residentInvitePreviewTitle;
    final unit = unitLabel?.trim();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppTheme.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.residentInviteResumeCardBadge,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit != null && unit.isNotEmpty
                          ? unit
                          : l10n.residentInviteResumeCardBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: apart.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResidentVerifiedCard extends StatelessWidget {
  const _ResidentVerifiedCard({
    required this.l10n,
    required this.preview,
  });

  final AppLocalizations l10n;
  final CodePreview? preview;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    final buildingName = preview?.buildingName?.trim();
    final hasBuilding = buildingName != null && buildingName.isNotEmpty;
    final unit = preview?.unitLabel?.trim();
    final displayTitle =
        hasBuilding ? buildingName : l10n.residentInvitePreviewTitle;
    final detail = unit != null && unit.isNotEmpty
        ? unit
        : l10n.residentInviteScreenBody;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.residentInviteVerifiedBadge,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.door_front_door_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasBuilding ? detail : l10n.residentInviteJoinHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: apart.onSurfaceVariant,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
