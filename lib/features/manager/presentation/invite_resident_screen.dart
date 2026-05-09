import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/manager/data/manager_invite_repository.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sakin davet kodu oluşturma — Edge fonksiyonu manager_invite.
class InviteResidentScreen extends ConsumerStatefulWidget {
  const InviteResidentScreen({super.key});

  @override
  ConsumerState<InviteResidentScreen> createState() =>
      _InviteResidentScreenState();
}

class _InviteResidentScreenState extends ConsumerState<InviteResidentScreen> {
  String? _generatedCode;
  String? _selectedUnitId;
  bool _loadingUnits = true;
  bool _creating = false;
  Object? _unitsError;
  List<ManagerUnitOption> _units = [];

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
      final repo = ref.read(managerInviteRepositoryProvider);
      final result = await repo.listUnits(session);
      if (!mounted) {
        return;
      }
      final units = result.units;
      final bn = result.buildingName?.trim();
      if (bn != null &&
          bn.isNotEmpty &&
          (session.buildingName == null ||
              session.buildingName!.trim().isEmpty)) {
        final merged = session.copyWith(
          buildingName: bn,
          savedAt: DateTime.now(),
        );
        await ref.read(localSessionRepositoryProvider).save(merged);
        ref.notifyLocalSessionChanged();
      }
      setState(() {
        _units = units;
        _selectedUnitId = units.isEmpty ? null : units.first.id;
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
      final repo = ref.read(managerInviteRepositoryProvider);
      final uid = _selectedUnitId;
      final result = await repo.createInvite(
        session,
        unitId: uid,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _generatedCode = result.code;
        _creating = false;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.managerInviteFailed)),
      );
    }
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.managerInviteCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(title: Text(l10n.managerInviteTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
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
          ref
              .watch(localSessionProvider)
              .when(
                data: (s) {
                  final n = s?.buildingName?.trim();
                  if (n == null || n.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            n,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
          const SizedBox(height: 20),
          if (_loadingUnits)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
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
                    onPressed: _loadingUnits
                        ? null
                        : () => unawaited(_loadUnits()),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.managerInviteRetry),
                  ),
              ],
            )
          else if (_units.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.managerInviteNoUnits,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: apart.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => unawaited(_loadUnits()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.managerInviteRetry),
                ),
              ],
            )
          else ...[
            if (_units.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.door_front_door_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(_units.first.label),
                    subtitle: Text(l10n.managerInviteSelectedUnitHint),
                  ),
                ),
              ),
            if (_units.length > 1)
              DropdownButtonFormField<String>(
                key: ValueKey<String>(_selectedUnitId ?? ''),
                initialValue: _selectedUnitId,
                decoration: InputDecoration(
                  labelText: l10n.managerInviteSelectUnit,
                  border: const OutlineInputBorder(),
                ),
                items: _units
                    .map(
                      (u) => DropdownMenuItem<String>(
                        value: u.id,
                        child: Text(u.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedUnitId = v),
              ),
            if (_units.length > 1) const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _creating || _units.isEmpty
                  ? null
                  : () => unawaited(_generate()),
              icon: _creating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.vpn_key_outlined),
              label: Text(l10n.managerInviteGenerate),
            ),
          ],
          if (_generatedCode != null) ...[
            const SizedBox(height: 28),
            Text(
              l10n.managerInviteYourCode,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _generatedCode!,
              style: theme.textTheme.headlineMedium?.copyWith(
                letterSpacing: 6,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => unawaited(_copyCode(context, _generatedCode!)),
              icon: const Icon(Icons.copy_rounded),
              label: Text(l10n.managerInviteCopy),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.managerInviteShareHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: apart.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
