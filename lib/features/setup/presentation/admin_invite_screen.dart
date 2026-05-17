import 'dart:async';

import 'package:apartment_manager/core/device/device_id_provider.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/domain/code_preview.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/data/session_preferences_storage.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/auth/presentation/widgets/remember_me_checkbox.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Manager invite — UI aligned with resident “Davet kodu” screen (mockup).
class AdminInviteScreen extends ConsumerStatefulWidget {
  const AdminInviteScreen({super.key});

  @override
  ConsumerState<AdminInviteScreen> createState() => _AdminInviteScreenState();
}

enum _VerifyPhase {
  idle,
  loading,
  validAdmin,
  resumePreview,
  invalidNotFound,
  invalidWrongType,
}

class _AdminOtpFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var t = newValue.text.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    if (t.length > 8) {
      t = t.substring(0, 8);
    }
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

class _AdminInviteScreenState extends ConsumerState<AdminInviteScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  _VerifyPhase _phase = _VerifyPhase.idle;
  CodePreview? _verifiedPreview;
  /// From Edge probe — existing manager registration for this device + code.
  String? _resumeBuildingName;
  bool _busy = false;
  bool _rememberMe = true;

  static const _otpLength = 8;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onCodeChanged);
    _focusNode.addListener(() => setState(() {}));
    unawaited(_loadRememberDefault());
  }

  Future<void> _loadRememberDefault() async {
    final value = await SessionPreferencesStorage.loadRememberMeDefault();
    if (mounted) {
      setState(() => _rememberMe = value);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _otpController
      ..removeListener(_onCodeChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final raw = _otpController.text;
    _debounce?.cancel();

    if (_phase == _VerifyPhase.resumePreview) {
      setState(() {
        _phase = _VerifyPhase.idle;
        _resumeBuildingName = null;
      });
    }

    if (raw.length < _otpLength) {
      setState(() {
        _phase = _VerifyPhase.idle;
        _verifiedPreview = null;
        _resumeBuildingName = null;
      });
      return;
    }

    setState(() {
      _phase = _VerifyPhase.loading;
      _verifiedPreview = null;
      _resumeBuildingName = null;
    });

    final code = normalizeInviteCode(raw);
    _debounce = Timer(const Duration(milliseconds: 420), () async {
      if (!mounted || normalizeInviteCode(_otpController.text) != code) {
        return;
      }
      try {
        final repo = ref.read(inviteCodeRepositoryProvider);
        final preview = await repo.validateCode(code);
        if (!mounted || normalizeInviteCode(_otpController.text) != code) {
          return;
        }
        if (preview == null) {
          setState(() {
            _phase = _VerifyPhase.invalidNotFound;
            _verifiedPreview = null;
          });
          return;
        }
        if (preview.codeType != InviteCodeType.admin) {
          setState(() {
            _phase = _VerifyPhase.invalidWrongType;
            _verifiedPreview = null;
          });
          return;
        }

        final deviceId = await ref.read(deviceIdProvider.future);
        final probe = await repo.probeAdminInvite(code, deviceId);
        if (!mounted || normalizeInviteCode(_otpController.text) != code) {
          return;
        }

        setState(() {
          _verifiedPreview = preview;
          if (probe.wouldResume) {
            _phase = _VerifyPhase.resumePreview;
            final bn = probe.buildingName?.trim();
            _resumeBuildingName =
                (bn != null && bn.isNotEmpty) ? bn : null;
          } else {
            _phase = _VerifyPhase.validAdmin;
            _resumeBuildingName = null;
          }
        });
      } on AppException {
        if (!mounted) {
          return;
        }
        setState(() {
          _phase = _VerifyPhase.invalidNotFound;
          _verifiedPreview = null;
        });
      } on Object {
        if (!mounted) {
          return;
        }
        setState(() {
          _phase = _VerifyPhase.invalidNotFound;
          _verifiedPreview = null;
        });
      }
    });
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final code = normalizeInviteCode(_otpController.text);
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminInviteCodeTooShort)),
      );
      return;
    }

    if (_phase != _VerifyPhase.validAdmin &&
        _phase != _VerifyPhase.resumePreview) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _phase == _VerifyPhase.invalidWrongType
                ? l10n.adminInviteNotAdminCode
                : l10n.adminInviteCodeNotFound,
          ),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final repo = ref.read(inviteCodeRepositoryProvider);
      final deviceId = await ref.read(deviceIdProvider.future);
      final session = await repo.redeemCode(code, deviceId);
      if (session.role != UserRole.buildingAdmin) {
        await ref.read(localSessionRepositoryProvider).clear();
        ref.notifyLocalSessionChanged();
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminInviteUnexpectedError)),
        );
        return;
      }
      await ref.persistLocalSession(session, rememberMe: _rememberMe);
      if (!mounted) {
        return;
      }
      final hasBuilding = session.buildingId != null &&
          session.buildingId!.trim().isNotEmpty;
      if (hasBuilding) {
        if (!mounted) {
          return;
        }
        context.go('/home');
      } else {
        context.go('/setup/wizard');
      }
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
        SnackBar(content: Text(l10n.adminInviteUnexpectedError)),
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
    final code = _otpController.text;
    final isResumeUi = _phase == _VerifyPhase.resumePreview;
    final canPrimary = (_phase == _VerifyPhase.validAdmin ||
            _phase == _VerifyPhase.resumePreview) &&
        !_busy &&
        code.length == _otpLength;
    final primaryEnabled = canPrimary;
    final headline = isResumeUi
        ? l10n.adminInviteResumeHeadline
        : l10n.adminInviteHeadline;
    final hint = isResumeUi
        ? l10n.adminInviteResumeSubtitle
        : l10n.adminInviteEightCharHint;

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
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hint,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: apart.onSurfaceVariant,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildOtpRow(context, apart, theme),
                    const SizedBox(height: 20),
                    if (_phase == _VerifyPhase.loading &&
                        code.length == _otpLength)
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
                            l10n.adminInviteChecking,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: apart.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    if (_phase == _VerifyPhase.resumePreview)
                      _AdminResumeCard(
                        l10n: l10n,
                        buildingTitle: _resumeBuildingName,
                      ),
                    if (_phase == _VerifyPhase.validAdmin)
                      _AdminVerifiedCard(
                        l10n: l10n,
                        preview: _verifiedPreview,
                      ),
                    if ((_phase == _VerifyPhase.invalidNotFound ||
                            _phase == _VerifyPhase.invalidWrongType) &&
                        code.length == _otpLength)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _phase == _VerifyPhase.invalidWrongType
                              ? l10n.adminInviteNotAdminCode
                              : l10n.adminInviteCodeNotFound,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed:
                        !primaryEnabled ? null : () => unawaited(_submit()),
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
                                ? l10n.adminInviteResumeSignIn
                                : l10n.adminInvitePrimaryButton,
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
                  const SizedBox(height: 12),
                  _InviteFooterRow(l10n: l10n, apart: apart),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpRow(
    BuildContext context,
    ApartmanTokens apart,
    ThemeData theme,
  ) {
    final code = _otpController.text;
    final activeIndex =
        code.length >= _otpLength ? _otpLength - 1 : code.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusNode.requestFocus,
      child: SizedBox(
        height: 52,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _otpLength; i++) ...[
                  if (i == 4)
                    SizedBox(
                      width: 12,
                      child: Center(
                        child: Text(
                          '-',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: apart.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _OtpCell(
                        char: i < code.length ? code[i] : null,
                        focused: _focusNode.hasFocus && i == activeIndex,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Theme(
              data: theme.copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: TextField(
                controller: _otpController,
                focusNode: _focusNode,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  _AdminOtpFormatter(),
                ],
                style: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 18,
                  height: 1,
                ),
                cursorColor: Colors.transparent,
                showCursor: false,
                maxLength: _otpLength,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  filled: false,
                ),
                onSubmitted: (_) => unawaited(_submit()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// OTP cell — grey border; focused slot uses green border only (no fill).
class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.char,
    required this.focused,
  });

  final String? char;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    final letter = char == null || char!.isEmpty ? null : char;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = (w * 1.15).clamp(44.0, 52.0);
        final fontSize = (w * 0.52).clamp(15.0, 19.0);
        final radius = (w * 0.22).clamp(8.0, 11.0);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: apart.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: focused ? AppTheme.primary : apart.outlineMuted,
              width: focused ? 2 : 1,
            ),
          ),
          child: letter == null
              ? null
              : Text(
                  letter,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    fontSize: fontSize,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
        );
      },
    );
  }
}

class _AdminResumeCard extends StatelessWidget {
  const _AdminResumeCard({
    required this.l10n,
    this.buildingTitle,
  });

  final AppLocalizations l10n;
  final String? buildingTitle;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    final name = buildingTitle?.trim();
    final title = (name != null && name.isNotEmpty)
        ? name
        : l10n.adminInviteVerifiedCardTitle;

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
                l10n.adminInviteResumeCardBadge,
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
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.adminInviteResumeCardBody,
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

class _AdminVerifiedCard extends StatelessWidget {
  const _AdminVerifiedCard({
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
    final detailLine = _previewDetailLine(preview, l10n);
    final displayTitle =
        hasBuilding ? buildingName : l10n.adminInviteVerifiedCardTitle;

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
                l10n.adminInviteVerifiedBadge,
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
                  Icons.home_rounded,
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
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasBuilding
                          ? detailLine
                          : l10n.adminInviteVerifiedCardBody,
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

  String _previewDetailLine(CodePreview? p, AppLocalizations l10n) {
    if (p == null) {
      return l10n.adminInviteVerifiedCardBody;
    }
    final parts = <String>[];
    final unit = p.unitLabel?.trim();
    final addr = p.address?.trim();
    if (unit != null && unit.isNotEmpty) {
      parts.add(unit);
    }
    if (addr != null && addr.isNotEmpty) {
      parts.add(addr);
    }
    if (parts.isEmpty) {
      return l10n.adminInviteVerifiedCardBody;
    }
    return parts.join(' · ');
  }
}

class _InviteFooterRow extends StatelessWidget {
  const _InviteFooterRow({
    required this.l10n,
    required this.apart,
  });

  final AppLocalizations l10n;
  final ApartmanTokens apart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: apart.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inviteFooterNoCodeNotice)),
            );
          },
          child: Text(
            l10n.inviteFooterNoCode,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: apart.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          '·',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: apart.onSurfaceTertiary,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inviteFooterQrSoon)),
            );
          },
          child: Text(
            l10n.inviteFooterScanQr,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
