import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/issues/domain/create_issue_input.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/features/home/presentation/providers/manager_issue_stats_provider.dart';
import 'package:apartment_manager/features/issues/presentation/providers/issue_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mockup **5.2** — Yeni arıza bildirimi.
class IssueCreateScreen extends ConsumerStatefulWidget {
  const IssueCreateScreen({super.key});

  @override
  ConsumerState<IssueCreateScreen> createState() => _IssueCreateScreenState();
}

class _IssueCreateScreenState extends ConsumerState<IssueCreateScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  IssueUiCategory _category = IssueUiCategory.mechanical;
  _IssueLocation _location = _IssueLocation.parking;
  IssueUiPriority _priority = IssueUiPriority.medium;
  bool _hasDemoPhoto = false;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.issueCreateAppBarTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LabeledField(
                    label: l10n.issueFieldTitle.toUpperCase(),
                    child: TextField(
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: l10n.issueFieldTitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.issueCategorySection,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CategoryGrid(
                    selected: _category,
                    onPick: (c) => setState(() => _category = c),
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.issueLocationSection,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final loc in _IssueLocation.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _LocationChip(
                              label: _locationLabel(l10n, loc),
                              selected: _location == loc,
                              onTap: () =>
                                  setState(() => _location = loc),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.issuePrioritySection,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: apart.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _PriorityCard(
                          label: l10n.issuePriorityLow,
                          selected: _priority == IssueUiPriority.low,
                          onTap: () => setState(
                            () => _priority = IssueUiPriority.low,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityCard(
                          label: l10n.issuePriorityMedium,
                          selected: _priority == IssueUiPriority.medium,
                          accent: true,
                          onTap: () => setState(
                            () => _priority = IssueUiPriority.medium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityCard(
                          label: l10n.issuePriorityHigh,
                          selected: _priority == IssueUiPriority.high,
                          onTap: () => setState(
                            () => _priority = IssueUiPriority.high,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: l10n.issueFieldDescription.toUpperCase(),
                    child: TextField(
                      controller: _body,
                      minLines: 4,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        hintText: l10n.issueDescriptionPlaceholder,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _PhotoSlot(
                        dashed: true,
                        label: l10n.issuePhotoAdd,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.issuePhotoComingSoon),
                            ),
                          );
                          setState(() => _hasDemoPhoto = true);
                        },
                      ),
                      if (_hasDemoPhoto) ...[
                        const SizedBox(width: 8),
                        _PhotoThumb(
                          onRemove: () =>
                              setState(() => _hasDemoPhoto = false),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppButton(
                onPressed: _submitting ? null : () => _submit(context, l10n),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.issueSubmit),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _locationLabel(AppLocalizations l10n, _IssueLocation loc) {
    return switch (loc) {
      _IssueLocation.apartment => l10n.issueLocationApartment,
      _IssueLocation.parking => l10n.issueLocationParking,
      _IssueLocation.roof => l10n.issueLocationRoof,
      _IssueLocation.garden => l10n.issueLocationGarden,
      _IssueLocation.elevator => l10n.issueLocationElevator,
    };
  }

  String _locationWire(_IssueLocation loc) {
    return switch (loc) {
      _IssueLocation.apartment => 'apartment',
      _IssueLocation.parking => 'parking',
      _IssueLocation.roof => 'roof',
      _IssueLocation.garden => 'garden',
      _IssueLocation.elevator => 'elevator',
    };
  }

  Future<void> _submit(BuildContext context, AppLocalizations l10n) async {
    final title = _title.text.trim();
    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.issueFieldTitle)),
      );
      return;
    }

    final session = await ref.read(localSessionProvider.future);
    if (session == null) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
      return;
    }
    if (session.sessionToken == null || session.sessionToken!.isEmpty) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            const AppException.auth(code: 'no_session_token').userMessage,
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = ref.read(issueRepositoryProvider);
      await repo.createIssue(
        session,
        CreateIssueInput(
          title: title,
          description: _body.text.trim(),
          category: _category,
          locationCode: _locationWire(_location),
          priority: _priority,
        ),
      );
      ref.invalidate(issuesListProvider);
      ref.invalidate(managerIssueStatsProvider);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Env.demoMode ? l10n.issueSubmittedDemo : l10n.issueSubmittedSuccess,
          ),
        ),
      );
      context.pop();
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
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

enum _IssueLocation {
  apartment,
  parking,
  roof,
  garden,
  elevator,
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.apart.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selected,
    required this.onPick,
    required this.l10n,
  });

  final IssueUiCategory selected;
  final ValueChanged<IssueUiCategory> onPick;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        IssueUiCategory.plumbing,
        Icons.water_damage_outlined,
        l10n.issueCategoryWater,
      ),
      (
        IssueUiCategory.electric,
        Icons.bolt_outlined,
        l10n.issueCategoryElectric,
      ),
      (
        IssueUiCategory.mechanical,
        Icons.build_outlined,
        l10n.issueCategoryMechanical,
      ),
      (
        IssueUiCategory.other,
        Icons.home_outlined,
        l10n.issueCategoryOther,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _CategoryCell(
              icon: items[i].$2,
              label: items[i].$3,
              selected: selected == items[i].$1,
              onTap: () => onPick(items[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final apart = context.apart;
    final fg = selected ? scheme.primary : apart.onSurfaceVariant;
    return Material(
      color: selected ? scheme.primaryContainer : apart.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? scheme.primary : apart.outlineMuted,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final apart = context.apart;
    return Material(
      color: selected ? scheme.primary : apart.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? scheme.primary : apart.outlineMuted,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? scheme.onPrimary : apart.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final apart = context.apart;
    final amberPick = selected && accent;
    final greenPick = selected && !accent;
    return Material(
      color: amberPick ? scheme.secondaryContainer : apart.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: amberPick
                  ? scheme.secondary
                  : greenPick
                      ? scheme.primary
                      : apart.outlineMuted,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: amberPick
                  ? scheme.onSecondaryContainer
                  : greenPick
                      ? scheme.primary
                      : apart.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.dashed,
    required this.label,
    required this.onTap,
  });

  final bool dashed;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: apart.onSurfaceVariant,
            width: dashed ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 20,
              color: apart.onSurfaceTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFa8c0ad), Color(0xFF6F8071)],
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: const Text(
                '×',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
