import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/widgets/invite_code_notes_dialog.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/utils/formatters.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/demo/presentation/providers/demo_persona_provider.dart';
import 'package:apartment_manager/features/profile/presentation/profile_home_tab.dart';
import 'package:apartment_manager/features/superadmin/data/superadmin_repository.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Super-admin shell: Ana sayfa, Kodlar, Apartmanlar, Profil (staff shell ile aynı nav).
class SuperadminShell extends ConsumerStatefulWidget {
  const SuperadminShell({
    required this.displayName,
    super.key,
    this.onSwitchPersona,
  });

  final String displayName;

  /// Demo-only: switch away from super-admin shell.
  final VoidCallback? onSwitchPersona;

  @override
  ConsumerState<SuperadminShell> createState() => _SuperadminShellState();
}

/// @deprecated Use [SuperadminShell]
typedef SuperAdminHomeView = SuperadminShell;

class _SuperadminShellState extends ConsumerState<SuperadminShell> {
  int _tabIndex = 0;
  bool _loading = true;
  Object? _error;
  List<SuperadminBuildingSummary> _buildings = [];
  List<SuperadminAdminCodeRow> _adminCodes = [];
  bool _creatingAdmin = false;
  String? _deletingBuildingId;

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
    final sheetResult = await showInviteCodeNotesDialog(
      context,
      title: l10n.superadminCreateManagerCode,
      subtitle: l10n.inviteCodeNotesSheetAdminSubtitle,
      hint: l10n.inviteCodeNotesAdminHint,
      initialPolicyId: AdminRedeemPolicy.reusable.wireValue,
      policyOptions: [
        InviteCodePolicyOption(
          id: AdminRedeemPolicy.reusable.wireValue,
          label: l10n.superadminAdminCodeMultiBadge,
          subtitle: l10n.inviteCodeNotesPolicyReusableHint,
          icon: Icons.repeat_rounded,
        ),
        InviteCodePolicyOption(
          id: AdminRedeemPolicy.singleUse.wireValue,
          label: l10n.superadminAdminCodeSingleBadge,
          subtitle: l10n.inviteCodeNotesPolicySingleHint,
          icon: Icons.looks_one_outlined,
        ),
      ],
    );
    if (!mounted || sheetResult == null) {
      return;
    }
    final policy = sheetResult.policyId ==
            AdminRedeemPolicy.singleUse.wireValue
        ? AdminRedeemPolicy.singleUse
        : AdminRedeemPolicy.reusable;
    final notes = sheetResult.notes;
    setState(() => _creatingAdmin = true);
    try {
      final session = await ref.read(localSessionRepositoryProvider).load();
      if (!mounted || session == null) {
        return;
      }
      final repo = ref.read(superadminRepositoryProvider);
      final created = await repo.createAdminInvite(
        session,
        policy: policy,
        notes: notes.isEmpty ? null : notes,
      );
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

  Future<void> _signOut(BuildContext context) async {
    try {
      if (Env.demoMode) {
        await ref.read(demoPersonaProvider.notifier).clear();
      }
      await ref.read(localSessionRepositoryProvider).clear();
      ref.notifyLocalSessionChanged();
      if (!context.mounted) {
        return;
      }
      context.go('/splash');
    } on AppException catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    }
  }

  List<Widget> _appBarActions(AppLocalizations l10n) {
    return [
      IconButton(
        tooltip: l10n.superadminRefresh,
        icon: const Icon(Icons.refresh_rounded),
        onPressed: _loading ? null : () => unawaited(_reload()),
      ),
      if (widget.onSwitchPersona != null)
        IconButton(
          tooltip: l10n.superadminDemoSwitch,
          icon: const Icon(Icons.swap_horiz_outlined),
          onPressed: widget.onSwitchPersona,
        ),
    ];
  }

  Widget _loadingOrErrorBody(
    AppLocalizations l10n,
    ThemeData theme, {
    required Widget child,
  }) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
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
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;

    final sessionAsync = ref.watch(localSessionProvider);
    final resolvedDisplay = sessionAsync.maybeWhen(
      data: (s) {
        final fn = s?.fullName?.trim();
        if (fn != null && fn.isNotEmpty) {
          return fn;
        }
        return widget.displayName;
      },
      orElse: () => widget.displayName,
    );

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _SuperadminHomePlaceholderTab(l10n: l10n, theme: theme, apart: apart),
          _SuperadminCodesPage(
            l10n: l10n,
            theme: theme,
            apart: apart,
            appBarActions: _appBarActions(l10n),
            body: _loadingOrErrorBody(
              l10n,
              theme,
              child: RefreshIndicator(
                onRefresh: _reload,
                child: _AdminCodesGridTab(
                  l10n: l10n,
                  theme: theme,
                  apart: apart,
                  codes: _adminCodes,
                  creating: _creatingAdmin,
                  onCreate: () => unawaited(_createAdminCode()),
                  onCopy: (code) async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.superadminCopied)),
                      );
                    }
                  },
                  onRevoke: (r) => unawaited(_confirmRevokeAdminCode(r)),
                ),
              ),
            ),
          ),
          _SuperadminBuildingsPage(
            l10n: l10n,
            theme: theme,
            apart: apart,
            appBarActions: _appBarActions(l10n),
            body: _loadingOrErrorBody(
              l10n,
              theme,
              child: RefreshIndicator(
                onRefresh: _reload,
                child: _BuildingsGridTab(
                  l10n: l10n,
                  theme: theme,
                  apart: apart,
                  buildings: _buildings,
                  deletingBuildingId: _deletingBuildingId,
                  onOpen: _openBuilding,
                  onDelete: (b) => unawaited(_confirmDeleteBuilding(b)),
                ),
              ),
            ),
          ),
          ProfileHomeTab(
            displayName: resolvedDisplay,
            onSignOut: () => _signOut(context),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.superadminNavHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.vpn_key_outlined),
            selectedIcon: const Icon(Icons.vpn_key_rounded),
            label: l10n.superadminNavManagerCodes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.apartment_outlined),
            selectedIcon: const Icon(Icons.apartment_rounded),
            label: l10n.superadminNavBuildings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.demoNavProfile,
          ),
        ],
      ),
    );
  }
}

class _SuperadminCodesPage extends StatelessWidget {
  const _SuperadminCodesPage({
    required this.l10n,
    required this.theme,
    required this.apart,
    required this.appBarActions,
    required this.body,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;
  final List<Widget> appBarActions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.superadminSectionManagerCodes),
        actions: appBarActions,
      ),
      body: body,
    );
  }
}

class _SuperadminBuildingsPage extends StatelessWidget {
  const _SuperadminBuildingsPage({
    required this.l10n,
    required this.theme,
    required this.apart,
    required this.appBarActions,
    required this.body,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;
  final List<Widget> appBarActions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.superadminSectionBuildings),
        actions: appBarActions,
      ),
      body: body,
    );
  }
}

class _SuperadminHomePlaceholderTab extends StatelessWidget {
  const _SuperadminHomePlaceholderTab({
    required this.l10n,
    required this.theme,
    required this.apart,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(title: Text(l10n.superadminDashboardTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 56,
                color: apart.onSurfaceTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.superadminHomeComingSoon,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: apart.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCodesGridTab extends StatelessWidget {
  const _AdminCodesGridTab({
    required this.l10n,
    required this.theme,
    required this.apart,
    required this.codes,
    required this.creating,
    required this.onCreate,
    required this.onCopy,
    required this.onRevoke,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;
  final List<SuperadminAdminCodeRow> codes;
  final bool creating;
  final VoidCallback onCreate;
  final Future<void> Function(String code) onCopy;
  final void Function(SuperadminAdminCodeRow row) onRevoke;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (Env.demoMode)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _DemoBanner(l10n: l10n, theme: theme),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _CodesHeader(
              l10n: l10n,
              theme: theme,
              apart: apart,
              creating: creating,
              onCreate: onCreate,
            ),
          ),
        ),
        if (codes.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.superadminNoAdminCodesYet,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: apart.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final row = codes[index];
                  return _ManagerCodeGridTile(
                    row: row,
                    l10n: l10n,
                    theme: theme,
                    apart: apart,
                    onCopy: () => onCopy(row.code),
                    onRevoke: () => onRevoke(row),
                  );
                },
                childCount: codes.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _BuildingsGridTab extends StatelessWidget {
  const _BuildingsGridTab({
    required this.l10n,
    required this.theme,
    required this.apart,
    required this.buildings,
    required this.deletingBuildingId,
    required this.onOpen,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;
  final List<SuperadminBuildingSummary> buildings;
  final String? deletingBuildingId;
  final void Function(SuperadminBuildingSummary b) onOpen;
  final void Function(SuperadminBuildingSummary b) onDelete;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (Env.demoMode)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _DemoBanner(l10n: l10n, theme: theme),
            ),
          ),
        if (buildings.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.superadminNoBuildings,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: apart.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final b = buildings[index];
                  return _BuildingGridTile(
                    building: b,
                    l10n: l10n,
                    theme: theme,
                    apart: apart,
                    busyDelete: deletingBuildingId == b.id,
                    onOpen: () => onOpen(b),
                    onDelete: () => onDelete(b),
                  );
                },
                childCount: buildings.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _CodesHeader extends StatelessWidget {
  const _CodesHeader({
    required this.l10n,
    required this.theme,
    required this.apart,
    required this.creating,
    required this.onCreate,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;
  final bool creating;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryContainer,
            AppTheme.primaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: apart.outlineMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.superadminAdminCodePolicyHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryDark.withValues(alpha: 0.85),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          _StatusChip(
            label: l10n.superadminAdminCodeMultiBadge,
            color: AppTheme.primary,
            background: AppTheme.primary.withValues(alpha: 0.12),
            icon: Icons.repeat_rounded,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: creating ? null : onCreate,
            icon: creating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.superadminCreateManagerCode),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerCodeGridTile extends StatelessWidget {
  const _ManagerCodeGridTile({
    required this.row,
    required this.l10n,
    required this.theme,
    required this.apart,
    required this.onCopy,
    required this.onRevoke,
  });

  final SuperadminAdminCodeRow row;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;
  final VoidCallback onCopy;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final revoked = row.status == 'revoked';
    final statusLabel = revoked
        ? l10n.superadminAdminCodeStatusRevoked
        : l10n.superadminAdminCodeStatusActive;
    final statusColor = revoked ? theme.colorScheme.error : AppTheme.success;
    final statusBg = revoked
        ? AppTheme.errorContainer
        : AppTheme.primaryContainer.withValues(alpha: 0.65);

    return Material(
      color: apart.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: apart.outlineMuted),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusChip(
              label: statusLabel,
              color: statusColor,
              background: statusBg,
            ),
            const Spacer(),
            Text(
              row.code,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                fontSize: 18,
                height: 1.1,
                color: revoked
                    ? apart.onSurfaceTertiary
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (row.expiresAt != null) ...[
              const SizedBox(height: 6),
              Text(
                formatDate(row.expiresAt!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: apart.onSurfaceVariant,
                ),
              ),
            ],
            if (row.notes != null && row.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                row.notes!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: apart.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: AppTheme.primary,
                      minimumSize: const Size(40, 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (!revoked) ...[
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    tooltip: l10n.superadminRevokeAdminCode,
                    onPressed: onRevoke,
                    icon: const Icon(Icons.block_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.errorContainer,
                      foregroundColor: theme.colorScheme.error,
                      minimumSize: const Size(40, 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildingGridTile extends StatelessWidget {
  const _BuildingGridTile({
    required this.building,
    required this.l10n,
    required this.theme,
    required this.apart,
    required this.busyDelete,
    required this.onOpen,
    required this.onDelete,
  });

  final SuperadminBuildingSummary building;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ApartmanTokens apart;
  final bool busyDelete;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sub = <String>[
      if (building.district.isNotEmpty) building.district,
      if (building.city.isNotEmpty) building.city,
    ].join(', ');
    final subtitle = sub.isEmpty ? building.address : sub;

    return Material(
      color: apart.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: apart.outlineMuted),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    building.name.isNotEmpty ? building.name : '—',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: apart.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        l10n.superadminBuildingInviteTitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: l10n.superadminDeleteBuildingTitle,
                visualDensity: VisualDensity.compact,
                onPressed: busyDelete ? null : onDelete,
                icon: busyDelete
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

