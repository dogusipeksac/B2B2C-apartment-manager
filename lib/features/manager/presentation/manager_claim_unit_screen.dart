import 'dart:async';
import 'dart:math' show min;

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/manager/data/manager_invite_repository.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Manager picks their own unit from the building list (no invite code).
class ManagerClaimUnitScreen extends ConsumerStatefulWidget {
  const ManagerClaimUnitScreen({super.key});

  @override
  ConsumerState<ManagerClaimUnitScreen> createState() =>
      _ManagerClaimUnitScreenState();
}

class _ManagerClaimUnitScreenState extends ConsumerState<ManagerClaimUnitScreen> {
  bool _loading = true;
  Object? _error;
  List<ManagerUnitOption> _units = [];
  String? _selectedId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
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
      final result =
          await ref.read(managerInviteRepositoryProvider).listUnits(session);
      if (!mounted) {
        return;
      }
      setState(() {
        _units = result.units;
        _selectedId = result.myUnitId ?? session.unitId;
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final unitId = _selectedId;
    if (unitId == null || unitId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.setupManagerUnitRequired)),
      );
      return;
    }

    final session = await ref.read(localSessionRepositoryProvider).load();
    if (session == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      final result = await ref
          .read(managerInviteRepositoryProvider)
          .assignMyUnit(session, unitId: unitId);

      final updated = session.copyWith(
        unitId: result.unitId,
        profileId: result.profileId ?? session.profileId,
        savedAt: DateTime.now(),
      );
      await ref.persistLocalSession(
        updated,
        rememberMe: session.rememberMe,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileClaimUnitSuccess)),
      );
      context.pop(true);
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _shortDoor(ManagerUnitOption u) {
    final f = u.floor;
    final d = u.doorNumber.trim();
    if (f != null && d.isNotEmpty) {
      return '$f$d';
    }
    return u.label;
  }

  Map<int, List<ManagerUnitOption>> _groupByFloor(List<ManagerUnitOption> units) {
    final map = <int, List<ManagerUnitOption>>{};
    for (final u in units) {
      final f = u.floor ?? 0;
      map.putIfAbsent(f, () => []).add(u);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.doorNumber.compareTo(b.doorNumber));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.profileClaimUnitTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error is AppException
                      ? (_error! as AppException).userMessage
                      : l10n.errorGeneric,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    l10n.profileClaimUnitSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: apart.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    children: _buildFloorSections(l10n, theme, apart),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: AppButton(
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                      child: Text(l10n.profileClaimUnitConfirm),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildFloorSections(
    AppLocalizations l10n,
    ThemeData theme,
    ApartmanTokens apart,
  ) {
    final byFloor = _groupByFloor(_units);
    final floors = byFloor.keys.toList()..sort();
    final children = <Widget>[];

    for (final floor in floors) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(
            l10n.managerFloorHeading('$floor'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      children.addAll(_rowsForFloor(byFloor[floor] ?? [], theme, apart, l10n));
    }
    return children;
  }

  List<Widget> _rowsForFloor(
    List<ManagerUnitOption> units,
    ThemeData theme,
    ApartmanTokens apart,
    AppLocalizations l10n,
  ) {
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
                      ? _ClaimUnitTile(
                          unit: slice[j],
                          shortLabel: _shortDoor(slice[j]),
                          selected: _selectedId == slice[j].id,
                          onTap: () => setState(() {
                            _selectedId = slice[j].id;
                          }),
                          managerBadge: l10n.managerUnitBadgeManager,
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

class _ClaimUnitTile extends StatelessWidget {
  const _ClaimUnitTile({
    required this.unit,
    required this.shortLabel,
    required this.selected,
    required this.onTap,
    required this.managerBadge,
  });

  final ManagerUnitOption unit;
  final String shortLabel;
  final bool selected;
  final VoidCallback onTap;
  final String managerBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    final borderColor = selected ? AppTheme.primary : apart.outlineMuted;

    return Material(
      color: apart.surface,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            boxShadow: selected ? null : apart.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 3,
                color: selected ? AppTheme.primary : apart.outlineMuted,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Column(
                  children: [
                    if (unit.isManagerUnit) ...[
                      Text(
                        managerBadge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      shortLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(height: 6),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                    ],
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
