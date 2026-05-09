import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/superadmin/data/superadmin_repository.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Super-admin dashboard: all buildings, manager codes, deep links to invites.
class SuperAdminHomeView extends ConsumerStatefulWidget {
  const SuperAdminHomeView({
    super.key,
    this.onSwitchPersona,
  });

  /// Demo-only: switch away from super-admin shell.
  final VoidCallback? onSwitchPersona;

  @override
  ConsumerState<SuperAdminHomeView> createState() => _SuperAdminHomeViewState();
}

class _SuperAdminHomeViewState extends ConsumerState<SuperAdminHomeView> {
  bool _loading = true;
  Object? _error;
  List<SuperadminBuildingSummary> _buildings = [];
  List<SuperadminAdminCodeRow> _adminCodes = [];
  bool _creatingAdmin = false;
  String? _deletingBuildingId;
  AdminRedeemPolicy _adminRedeemPolicy = AdminRedeemPolicy.singleUse;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted) {
        return;
      }
      if (session == null) {
        setState(() {
          _loading = false;
          _error = 'no_session';
        });
        return;
      }
      final repo = ref.read(superadminRepositoryProvider);
      final buildings = await repo.listBuildings(session);
      final codes = await repo.listAdminCodes(session);
      if (!mounted) {
        return;
      }
      setState(() {
        _buildings = buildings;
        _adminCodes = codes;
        _loading = false;
      });
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _createAdminCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (_creatingAdmin) {
      return;
    }
    setState(() => _creatingAdmin = true);
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted || session == null) {
        return;
      }
      final repo = ref.read(superadminRepositoryProvider);
      final created =
          await repo.createAdminInvite(session, policy: _adminRedeemPolicy);
      if (!mounted) {
        return;
      }
      await Clipboard.setData(ClipboardData(text: created.code));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.superadminManagerCodeCreated)),
      );
      await _reload();
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _creatingAdmin = false);
      }
    }
  }

  Future<void> _confirmRevokeAdminCode(SuperadminAdminCodeRow r) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (r.status == 'revoked') {
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.superadminRevokeAdminCodeTitle),
        content: Text(l10n.superadminRevokeAdminCodeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.navBack),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.superadminRevokeAdminCodeConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) {
      return;
    }
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted || session == null) {
        return;
      }
      final repo = ref.read(superadminRepositoryProvider);
      await repo.revokeAdminCode(session, r.code);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.superadminCodeRevoked)),
      );
      if (Env.demoMode) {
        setState(() {
          _adminCodes = _adminCodes.where((x) => x.code != r.code).toList();
        });
      } else {
        await _reload();
      }
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    }
  }

  void _openBuilding(SuperadminBuildingSummary b) {
    final name = Uri.encodeComponent(b.name);
    unawaited(
      context.push<void>(
        '/superadmin/building/${b.id}?name=$name',
      ),
    );
  }

  Future<void> _confirmDeleteBuilding(SuperadminBuildingSummary b) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.superadminDeleteBuildingTitle),
        content: Text(l10n.superadminDeleteBuildingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.navBack),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.superadminDeleteBuildingConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) {
      return;
    }

    setState(() => _deletingBuildingId = b.id);
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted || session == null) {
        return;
      }
      final repo = ref.read(superadminRepositoryProvider);
      await repo.deleteBuilding(session, b.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.superadminBuildingDeleted)),
      );
      if (Env.demoMode) {
        setState(() {
          _buildings = _buildings.where((x) => x.id != b.id).toList();
        });
      } else {
        await _reload();
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
        SnackBar(content: Text(l10n.superadminDeleteBuildingFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingBuildingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;
    final demoSwitch = widget.onSwitchPersona != null;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.superadminDashboardTitle),
        actions: [
          IconButton(
            tooltip: l10n.superadminRefresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : () => unawaited(_reload()),
          ),
          if (demoSwitch)
            IconButton(
              tooltip: l10n.superadminDemoSwitch,
              icon: const Icon(Icons.swap_horiz_outlined),
              onPressed: widget.onSwitchPersona,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _reload();
        },
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    _error == 'no_session'
                        ? l10n.managerInviteNoSessionHint
                        : _error is AppException
                        ? (_error! as AppException).userMessage
                        : l10n.errorGeneric,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => unawaited(_reload()),
                    child: Text(l10n.managerInviteRetry),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  if (Env.demoMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
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
                              color: theme.colorScheme.tertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.superadminDemoBanner,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Text(
                    l10n.superadminSectionManagerCodes,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.superadminAdminCodePolicyHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: apart.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.superadminAdminCodePolicySingle),
                        selected:
                            _adminRedeemPolicy == AdminRedeemPolicy.singleUse,
                        onSelected: (_) {
                          setState(() {
                            _adminRedeemPolicy = AdminRedeemPolicy.singleUse;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text(l10n.superadminAdminCodePolicyReusable),
                        selected:
                            _adminRedeemPolicy == AdminRedeemPolicy.reusable,
                        onSelected: (_) {
                          setState(() {
                            _adminRedeemPolicy = AdminRedeemPolicy.reusable;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _creatingAdmin ? null : () => unawaited(_createAdminCode()),
                    icon: _creatingAdmin
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(l10n.superadminCreateManagerCode),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_adminCodes.isEmpty)
                    Text(
                      l10n.superadminNoAdminCodesYet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: apart.onSurfaceVariant,
                      ),
                    )
                  else
                    ..._adminCodes.take(12).map(
                          (r) {
                            final policyLabel =
                                r.policy == AdminRedeemPolicy.reusable
                                ? l10n.superadminAdminCodePolicyReusable
                                : l10n.superadminAdminCodePolicySingle;
                            final canRevoke = r.status != 'revoked';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  r.code,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                subtitle: Text(
                                  '$policyLabel · ${r.status} · '
                                  '${r.createdAt ?? '-'}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (canRevoke)
                                      IconButton(
                                        tooltip:
                                            l10n.superadminRevokeAdminCode,
                                        icon: Icon(
                                          Icons.cancel_outlined,
                                          color: theme.colorScheme.error,
                                        ),
                                        onPressed: () => unawaited(
                                          _confirmRevokeAdminCode(r),
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded),
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: r.code),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(l10n.superadminCopied),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.superadminSectionBuildings,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_buildings.isEmpty)
                    Text(
                      l10n.superadminNoBuildings,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: apart.onSurfaceVariant,
                      ),
                    )
                  else
                    ..._buildings.map(
                      (b) {
                        final sub = <String>[
                          if (b.district.isNotEmpty) b.district,
                          if (b.city.isNotEmpty) b.city,
                        ].join(', ');
                        final busyDelete = _deletingBuildingId == b.id;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primary.withValues(alpha: 0.15),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: AppTheme.primary,
                              ),
                            ),
                            title: Text(
                              b.name.isNotEmpty ? b.name : '—',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              sub.isEmpty ? b.address : sub,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: l10n.superadminDeleteBuildingTitle,
                                  icon: busyDelete
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          Icons.delete_outline_rounded,
                                          color: theme.colorScheme.error,
                                        ),
                                  onPressed: busyDelete
                                      ? null
                                      : () => unawaited(
                                            _confirmDeleteBuilding(b),
                                          ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: apart.onSurfaceVariant,
                                ),
                              ],
                            ),
                            onTap: () => _openBuilding(b),
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
