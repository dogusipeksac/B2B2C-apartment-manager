import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/manager/data/manager_invite_repository.dart';
import 'package:apartment_manager/features/superadmin/data/superadmin_repository.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Single-unit invite: QR, code, copy, share (resident redeems this code).
class UnitInviteDetailScreen extends ConsumerStatefulWidget {
  const UnitInviteDetailScreen({
    required this.unitId,
    this.initialUnit,
    this.superadminBuildingId,
    super.key,
  });

  final String unitId;
  final ManagerUnitOption? initialUnit;

  /// When set, loads/creates invites via [SuperadminRepository] for this building.
  final String? superadminBuildingId;

  @override
  ConsumerState<UnitInviteDetailScreen> createState() =>
      _UnitInviteDetailScreenState();
}

class _UnitInviteDetailScreenState
    extends ConsumerState<UnitInviteDetailScreen> {
  ManagerUnitOption? _unit;
  bool _loading = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
    unawaited(_refresh());
  }

  String _shortDoor(ManagerUnitOption u) {
    final f = u.floor;
    final d = u.doorNumber.trim();
    if (f != null && d.isNotEmpty) {
      return '$f$d';
    }
    return u.label;
  }

  String _spacedCode(String code) {
    final c = code.trim().toUpperCase();
    return c.split('').join(' ');
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted) {
        return;
      }
      if (session == null) {
        setState(() => _loading = false);
        return;
      }
      final ManagerInviteListResult result;
      if (widget.superadminBuildingId != null) {
        final srepo = ref.read(superadminRepositoryProvider);
        result = await srepo.listUnitsForBuilding(
          session,
          widget.superadminBuildingId!,
        );
      } else {
        final repo = ref.read(managerInviteRepositoryProvider);
        result = await repo.listUnits(session);
      }
      if (!mounted) {
        return;
      }
      ManagerUnitOption? match;
      for (final u in result.units) {
        if (u.id == widget.unitId) {
          match = u;
          break;
        }
      }
      setState(() {
        _unit = match ?? _unit;
        _loading = false;
      });
    } on AppException {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _creating = true);
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted) {
        return;
      }
      if (session == null) {
        context.go('/setup/account-type');
        return;
      }
      final CreatedUnitInvite result;
      if (widget.superadminBuildingId != null) {
        final srepo = ref.read(superadminRepositoryProvider);
        result = await srepo.createUnitInvite(
          session,
          buildingId: widget.superadminBuildingId!,
          unitId: widget.unitId,
        );
      } else {
        final repo = ref.read(managerInviteRepositoryProvider);
        result = await repo.createInvite(
          session,
          unitId: widget.unitId,
        );
      }
      if (!mounted) {
        return;
      }
      final prev = _unit;
      if (prev != null) {
        setState(() {
          _unit = ManagerUnitOption(
            id: prev.id,
            floor: prev.floor,
            doorNumber: prev.doorNumber,
            block: prev.block,
            label: prev.label,
            inviteCode: result.code,
            inviteExpiresAt: result.expiresAt ?? prev.inviteExpiresAt,
          );
          _creating = false;
        });
      } else {
        setState(() => _creating = false);
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.managerInviteCodeCreated)),
      );
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() => _creating = false);
      final msg = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.managerInviteFailed)),
      );
    }
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.managerInviteCopied)),
    );
  }

  Future<void> _share(AppLocalizations l10n, String code) async {
    await Share.share(
      l10n.managerInviteShareBody(code),
      subject: l10n.managerInviteTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;
    final u = _unit;

    final headline = u != null
        ? l10n.managerInviteDetailHeadline(_shortDoor(u))
        : l10n.managerInviteTitle;

    final dateFmt = DateFormat.yMMMMd('tr_TR');

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.managerInviteTitle),
      ),
      body: _loading && u == null
          ? const Center(child: CircularProgressIndicator())
          : u == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.managerInviteFailed,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (Env.demoMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InfoBanner(
                      text: l10n.managerInviteDemoBanner,
                      color: theme.colorScheme.tertiaryContainer,
                      onColor: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                Text(
                  headline,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.managerInviteDetailSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: apart.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                if (u.inviteCode != null && u.inviteCode!.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          QrImageView(
                            data: u.inviteCode!.trim().toUpperCase(),
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.managerInviteDavetCodeCaps,
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              color: apart.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: SelectableText(
                                  _spacedCode(u.inviteCode!),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => unawaited(
                                  _copy(u.inviteCode!),
                                ),
                                icon: const Icon(Icons.copy_rounded),
                                tooltip: l10n.managerInviteCopy,
                              ),
                            ],
                          ),
                          if (u.inviteExpiresAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _validityLine(
                                l10n,
                                u.inviteExpiresAt!,
                                dateFmt,
                              ),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: apart.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.managerInviteShareHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ShareCircle(
                        icon: Icons.chat_rounded,
                        color: const Color(0xFF25D366),
                        label: l10n.managerInviteShareWhatsapp,
                        onTap: () => unawaited(_share(l10n, u.inviteCode!)),
                      ),
                      _ShareCircle(
                        icon: Icons.email_outlined,
                        color: theme.colorScheme.primary,
                        label: l10n.managerInviteShareEmail,
                        onTap: () => unawaited(_share(l10n, u.inviteCode!)),
                      ),
                      _ShareCircle(
                        icon: Icons.sms_outlined,
                        color: AppTheme.warning,
                        label: l10n.managerInviteShareSms,
                        onTap: () => unawaited(_share(l10n, u.inviteCode!)),
                      ),
                      _ShareCircle(
                        icon: Icons.share_rounded,
                        color: apart.onSurfaceVariant,
                        label: l10n.managerInviteShareMore,
                        onTap: () => unawaited(_share(l10n, u.inviteCode!)),
                      ),
                    ],
                  ),
                ] else ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.vpn_key_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.managerInviteGenerateAction,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _creating
                                ? null
                                : () => unawaited(_generate()),
                            icon: _creating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded),
                            label: Text(l10n.managerInviteGenerateAction),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.homeFeatureSoon)),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.warningContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: apart.outlineMuted),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.groups_outlined, color: AppTheme.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.managerInviteBulkTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.managerInviteBulkSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: apart.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: apart.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _validityLine(
    AppLocalizations l10n,
    DateTime expiresAt,
    DateFormat dateFmt,
  ) {
    final days = expiresAt.difference(DateTime.now()).inDays;
    final safeDays = days < 0 ? 0 : days;
    final until = dateFmt.format(expiresAt);
    return '${l10n.managerInviteValidDays('$safeDays')} · '
        '${l10n.managerInviteValidUntilDate(until)}';
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.text,
    required this.color,
    required this.onColor,
  });

  final String text;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: onColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCircle extends StatelessWidget {
  const _ShareCircle({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: apart.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
