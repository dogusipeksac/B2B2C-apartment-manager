import 'dart:async';
import 'dart:math' show min;

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/manager/data/manager_invite_repository.dart';
import 'package:apartment_manager/features/superadmin/data/superadmin_repository.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Super-admin: unit grid for any building (same invite UX as manager).
class SuperadminBuildingInviteScreen extends ConsumerStatefulWidget {
  const SuperadminBuildingInviteScreen({
    required this.buildingId,
    this.buildingName,
    super.key,
  });

  final String buildingId;
  final String? buildingName;

  @override
  ConsumerState<SuperadminBuildingInviteScreen> createState() =>
      _SuperadminBuildingInviteScreenState();
}

enum _InviteChip { all, withCode, withoutCode }

class _SuperadminBuildingInviteScreenState
    extends ConsumerState<SuperadminBuildingInviteScreen> {
  bool _loadingUnits = true;
  Object? _unitsError;
  List<ManagerUnitOption> _units = [];
  _InviteChip _chip = _InviteChip.all;

  @override
  void initState() {
    super.initState();
    unawaited(_loadUnits());
  }

  Future<void> _loadUnits() async {
    setState(() {
      _loadingUnits = true;
      _unitsError = null;
    });
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted) {
        return;
      }
      if (session == null) {
        setState(() {
          _loadingUnits = false;
          _unitsError = 'no_session';
        });
        return;
      }
      final repo = ref.read(superadminRepositoryProvider);
      final result = await repo.listUnitsForBuilding(session, widget.buildingId);
      if (!mounted) {
        return;
      }
      setState(() {
        _units = result.units;
        _loadingUnits = false;
      });
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _unitsError = e;
        _loadingUnits = false;
      });
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _unitsError = e;
        _loadingUnits = false;
      });
    }
  }

  List<ManagerUnitOption> get _filtered {
    switch (_chip) {
      case _InviteChip.all:
        return _units;
      case _InviteChip.withCode:
        return _units.where((u) => u.inviteCode != null).toList();
      case _InviteChip.withoutCode:
        return _units.where((u) => u.inviteCode == null).toList();
    }
  }

  int _countWithCode() => _units
      .where((u) => u.inviteCode != null && u.inviteCode!.isNotEmpty)
      .length;

  int _countWithoutCode() => _units.length - _countWithCode();

  String _shortDoor(ManagerUnitOption u) {
    final f = u.floor;
    final d = u.doorNumber.trim();
    if (f != null && d.isNotEmpty) {
      return '$f$d';
    }
    return u.label;
  }

  Map<int, List<ManagerUnitOption>> _groupByFloor(
    List<ManagerUnitOption> units,
  ) {
    final map = <int, List<ManagerUnitOption>>{};
    for (final u in units) {
      final fl = u.floor ?? 0;
      map.putIfAbsent(fl, () => []).add(u);
    }
    return map;
  }

  Future<void> _openDetail(ManagerUnitOption u) async {
    await context.push<void>(
      '/superadmin/building/${widget.buildingId}/invite/unit/${u.id}',
      extra: u,
    );
    if (mounted) {
      await _loadUnits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;

    final filtered = _filtered;
    final byFloor = _groupByFloor(filtered);
    final floors = byFloor.keys.toList()..sort((a, b) => b.compareTo(a));

    final titleName = widget.buildingName?.trim();
    final appBarTitle = titleName != null && titleName.isNotEmpty
        ? titleName
        : l10n.superadminBuildingInviteTitle;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text('$appBarTitle · ${_units.length}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                        l10n.managerInviteDemoBanner,
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
            l10n.managerInviteSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: apart.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SaFilterChip(
                  label: '${l10n.managerInviteFilterAll} · ${_units.length}',
                  selected: _chip == _InviteChip.all,
                  onTap: () => setState(() => _chip = _InviteChip.all),
                  filled: true,
                ),
                const SizedBox(width: 8),
                _SaFilterChip(
                  label:
                      '${l10n.managerInviteFilterWithCode} · ${_countWithCode()}',
                  selected: _chip == _InviteChip.withCode,
                  onTap: () => setState(() => _chip = _InviteChip.withCode),
                  accent: AppTheme.success,
                ),
                const SizedBox(width: 8),
                _SaFilterChip(
                  label:
                      '${l10n.managerInviteFilterWithoutCode} · ${_countWithoutCode()}',
                  selected: _chip == _InviteChip.withoutCode,
                  onTap: () => setState(() => _chip = _InviteChip.withoutCode),
                  accent: apart.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingUnits)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_unitsError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _unitsError == 'no_session'
                      ? l10n.managerInviteNoSessionHint
                      : _unitsError is AppException
                      ? (_unitsError! as AppException).userMessage
                      : l10n.managerInviteFailed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                if (_unitsError == 'no_session')
                  FilledButton(
                    onPressed: () => context.go('/setup/account-type'),
                    child: Text(l10n.residentInviteBackToRole),
                  )
                else
                  OutlinedButton.icon(
                    onPressed:
                        _loadingUnits ? null : () => unawaited(_loadUnits()),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.managerInviteRetry),
                  ),
              ],
            )
          else if (_units.isEmpty)
            Text(
              l10n.managerInviteNoUnits,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: apart.onSurfaceVariant,
              ),
            )
          else if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.managerInviteFilterEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: apart.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final floor in floors) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.managerFloorHeading('$floor'),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: apart.onSurfaceVariant,
                            letterSpacing: 0.48,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          l10n.managerFloorUnitCount(
                            '${byFloor[floor]?.length ?? 0}',
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: apart.onSurfaceTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._rowsForFloor(byFloor[floor] ?? []),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  List<Widget> _rowsForFloor(List<ManagerUnitOption> units) {
    final rows = <Widget>[];
    for (var i = 0; i < units.length; i += 3) {
      final end = min(i + 3, units.length);
      final slice = units.sublist(i, end);
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < 3; j++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: j < 2 ? 8 : 0),
                  child: j < slice.length
                      ? _SaUnitTile(
                          unit: slice[j],
                          shortLabel: _shortDoor(slice[j]),
                          onTap: () => unawaited(_openDetail(slice[j])),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      );
      rows.add(const SizedBox(height: 8));
    }
    return rows;
  }
}

class _SaFilterChip extends StatelessWidget {
  const _SaFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.filled = false,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool filled;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    final fg = accent ?? AppTheme.primary;
    final bg = selected
        ? (filled ? fg : fg.withValues(alpha: 0.12))
        : apart.surface;
    final textColor = selected && filled ? Colors.white : fg;
    final border = selected ? fg : apart.outlineMuted;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _SaUnitTile extends StatelessWidget {
  const _SaUnitTile({
    required this.unit,
    required this.shortLabel,
    required this.onTap,
  });

  final ManagerUnitOption unit;
  final String shortLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    final code = unit.inviteCode?.trim();
    final hasCode = code != null && code.isNotEmpty;
    final topColor = hasCode ? AppTheme.success : apart.outlineMuted;

    return Material(
      color: apart.surface,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: apart.outlineMuted),
            boxShadow: apart.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 3,
                color: topColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Column(
                  children: [
                    Text(
                      shortLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasCode ? code : '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: hasCode ? 0.8 : 0,
                        color: hasCode
                            ? AppTheme.success
                            : apart.onSurfaceVariant,
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
