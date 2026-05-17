import 'dart:async';
import 'dart:math' as math;

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/setup/data/building_setup_repository.dart';
import 'package:apartment_manager/features/setup/data/turkey_locations_repository.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Manager flow: 4-step building setup (mockup 3.3–3.5).
/// Completes via Edge Function when not in demo mode.
class BuildingSetupWizardScreen extends ConsumerStatefulWidget {
  const BuildingSetupWizardScreen({super.key});

  @override
  ConsumerState<BuildingSetupWizardScreen> createState() =>
      _BuildingSetupWizardScreenState();
}

class _BuildingSetupWizardScreenState
    extends ConsumerState<BuildingSetupWizardScreen> {
  final _page = PageController();
  final _buildingFormKey = GlobalKey<FormState>();
  int _step = 0;

  final _name = TextEditingController(
    text: Env.demoMode ? 'Yeşil Vadi Apartmanı' : '',
  );
  final _address = TextEditingController(
    text: Env.demoMode ? '' : '',
  );
  final _yearBuilt = TextEditingController(
    text: Env.demoMode ? '2008' : '',
  );

  int? _selectedProvinceId;
  int? _selectedDistrictId;
  bool _demoDefaultsApplied = false;

  final _singleBlock = ValueNotifier<bool>(true);
  final _floors = ValueNotifier<int>(Env.demoMode ? 6 : 1);
  final _perFloor = ValueNotifier<int>(Env.demoMode ? 3 : 1);

  final _namingAutomatic = ValueNotifier<bool>(true);
  final _showAllFloors = ValueNotifier<bool>(false);
  final _highlightUnit = ValueNotifier<String?>(
    Env.demoMode ? '3A' : null,
  );

  /// Tutar kuruş cinsinden (₺1.500,00 → 150000).
  final _duesKurus = ValueNotifier<int>(150_000);
  final _dueDay = ValueNotifier<int>(5);
  final _lateFeeEnabled = ValueNotifier<bool>(true);
  final _smsReminder = ValueNotifier<bool>(false);

  static const _dueDayChoices = <int>[1, 5, 10, 15, 20];

  bool _finalizeBusy = false;

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _address.dispose();
    _yearBuilt.dispose();
    _singleBlock.dispose();
    _floors.dispose();
    _perFloor.dispose();
    _namingAutomatic.dispose();
    _showAllFloors.dispose();
    _highlightUnit.dispose();
    _duesKurus.dispose();
    _dueDay.dispose();
    _lateFeeEnabled.dispose();
    _smsReminder.dispose();
    super.dispose();
  }

  int get _totalUnits => _floors.value * _perFloor.value;

  String _formatTry(int kurus) {
    final fmt = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return fmt.format(kurus / 100);
  }

  void _goHome(BuildContext context) {
    context.go('/home');
  }

  Future<void> _completeSetup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_namingAutomatic.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeFeatureSoon)),
      );
      return;
    }

    final location = _resolveSelectedLocation();
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.setupProvinceRequired)),
      );
      return;
    }

    if (Env.demoMode) {
      _goHome(context);
      return;
    }

    // Always read persisted session from disk (not cached FutureProvider).
    final session =
        await ref.read(localSessionRepositoryProvider).load();
    if (session == null ||
        session.role != UserRole.buildingAdmin ||
        session.sessionToken == null ||
        session.sessionToken!.isEmpty) {
      if (context.mounted) {
        context.go('/setup/admin-invite');
      }
      return;
    }

    if (session.buildingId != null && session.buildingId!.isNotEmpty) {
      if (!context.mounted) {
        return;
      }
      _goHome(context);
      return;
    }

    final city = location.$1;
    final district = location.$2;

    setState(() => _finalizeBusy = true);
    try {
      final result =
          await ref.read(buildingSetupRepositoryProvider).finalizeBuilding(
                session: session,
                buildingName: _name.text.trim(),
                address: _address.text.trim(),
                city: city,
                district: district,
                monthlyDuesKurus: _duesKurus.value,
                duesDueDay: _dueDay.value,
                lateFeeEnabled: _lateFeeEnabled.value,
                singleBlock: _singleBlock.value,
                floors: _floors.value,
                perFloor: _perFloor.value,
                namingAutomatic: _namingAutomatic.value,
                managerFullName: session.fullName,
              );

      final updated = session.copyWith(
        buildingId: result.buildingId,
        profileId: result.profileId,
        buildingName: result.buildingLabel,
        savedAt: DateTime.now(),
      );
      await ref.read(localSessionRepositoryProvider).save(updated);
      ref.notifyLocalSessionChanged();

      if (!context.mounted) {
        return;
      }
      _goHome(context);
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
        SnackBar(content: Text(l10n.setupFinalizeFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _finalizeBusy = false);
      }
    }
  }

  void _back(BuildContext context) {
    if (_step == 0) {
      context.go('/setup/account-type');
      return;
    }
    setState(() => _step -= 1);
    unawaited(
      _page.previousPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  (String, String)? _resolveSelectedLocation() {
    final provinces = ref.read(turkeyProvincesProvider).value;
    if (provinces == null ||
        _selectedProvinceId == null ||
        _selectedDistrictId == null) {
      return null;
    }
    for (final p in provinces) {
      if (p.id != _selectedProvinceId) {
        continue;
      }
      for (final d in p.districts) {
        if (d.id == _selectedDistrictId) {
          return (p.name, d.name);
        }
      }
    }
    return null;
  }

  void _applyDemoLocationDefaults(List<TurkeyProvince> provinces) {
    if (!Env.demoMode || _demoDefaultsApplied) {
      return;
    }
    TurkeyProvince? istanbul;
    for (final p in provinces) {
      if (p.name == 'İstanbul') {
        istanbul = p;
        break;
      }
    }
    istanbul ??= provinces.isNotEmpty ? provinces.first : null;
    if (istanbul == null) {
      return;
    }
    TurkeyDistrict? kadikoy;
    for (final d in istanbul.districts) {
      if (d.name == 'Kadıköy') {
        kadikoy = d;
        break;
      }
    }
    kadikoy ??=
        istanbul.districts.isNotEmpty ? istanbul.districts.first : null;
    if (kadikoy == null) {
      return;
    }
    _selectedProvinceId = istanbul.id;
    _selectedDistrictId = kadikoy.id;
    _demoDefaultsApplied = true;
  }

  void _next(BuildContext context) {
    if (_finalizeBusy) {
      return;
    }
    if (_step == 0) {
      final valid = _buildingFormKey.currentState?.validate() ?? false;
      if (!valid) {
        return;
      }
    }
    if (_step >= 3) {
      unawaited(_completeSetup(context));
      return;
    }
    setState(() => _step += 1);
    unawaited(
      _page.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final apart = context.apart;

    ref.listen<AsyncValue<List<TurkeyProvince>>>(turkeyProvincesProvider, (
      _,
      next,
    ) {
      next.whenData((provinces) {
        if (!mounted || _demoDefaultsApplied || !Env.demoMode) {
          return;
        }
        setState(() => _applyDemoLocationDefaults(provinces));
      });
    });

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 4,
                  minHeight: 4,
                  backgroundColor: apart.outlineMuted,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepBuilding(context, l10n),
                  _stepStructure(context, l10n),
                  _stepUnits(context, l10n),
                  _stepDues(context, l10n),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  filledButtonTheme: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.outlined,
                        onPressed: () => _back(context),
                        child: Text(l10n.navBack),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        isLoading: _finalizeBusy,
                        onPressed: () => _next(context),
                        child: _step >= 3
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.setupCompleteWizard),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.setupWizardProceed),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wizardTopBar(
    BuildContext context,
    AppLocalizations l10n, {
    required int stepIndex,
    required String stepShortTitle,
    VoidCallback? onSkip,
    Widget? preferredTrailing,
  }) {
    final theme = Theme.of(context);
    final apart = context.apart;

    final trailing = preferredTrailing ??
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: onSkip,
          child: Text(l10n.setupWizardSkip),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => _back(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.setupWizardStepProgress(stepIndex + 1, 4),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: apart.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  stepShortTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _stepBuilding(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final apart = context.apart;
    final provincesAsync = ref.watch(turkeyProvincesProvider);

    return Form(
      key: _buildingFormKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _wizardTopBar(
            context,
            l10n,
            stepIndex: 0,
            stepShortTitle: l10n.setupWizardStep1AppBar,
            onSkip: () => _goHome(context),
          ),
          Text(
            l10n.setupWizardLetsMeetBuilding,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.setupWizardChangeLaterShort,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: apart.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.setupBuildingNameLabel,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l10n.setupFinalizeBuildingNameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          provincesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.setupProvincesLoadError,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    ref.invalidate(turkeyProvincesProvider);
                  },
                  child: Text(l10n.setupProvincesRetry),
                ),
              ],
            ),
            data: (provinces) {
              final selectedProvince = _findProvince(provinces, _selectedProvinceId);
              final districts = selectedProvince?.districts ?? const <TurkeyDistrict>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    key: ValueKey<int?>(_selectedProvinceId),
                    initialValue: _selectedProvinceId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.setupProvinceLabel,
                    ),
                    items: provinces
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedProvinceId = v;
                        _selectedDistrictId = null;
                      });
                    },
                    validator: (v) {
                      if (v == null) {
                        return l10n.setupProvinceRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: ValueKey('d-$_selectedProvinceId-$_selectedDistrictId'),
                    initialValue: districts.any((d) => d.id == _selectedDistrictId)
                        ? _selectedDistrictId
                        : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.setupDistrictLabel,
                    ),
                    items: districts
                        .map(
                          (d) => DropdownMenuItem<int>(
                            value: d.id,
                            child: Text(d.name),
                          ),
                        )
                        .toList(),
                    onChanged: _selectedProvinceId == null
                        ? null
                        : (v) {
                            setState(() => _selectedDistrictId = v);
                          },
                    validator: (v) {
                      if (_selectedProvinceId == null || v == null) {
                        return l10n.setupDistrictRequired;
                      }
                      return null;
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.setupAddressLabel,
              hintText: l10n.setupAddressHint,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l10n.setupAddressRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _yearBuilt,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.setupYearBuiltOptional,
              hintText: l10n.setupYearBuiltHint,
            ),
          ),
        ],
      ),
    );
  }

  TurkeyProvince? _findProvince(
    List<TurkeyProvince> provinces,
    int? provinceId,
  ) {
    if (provinceId == null) {
      return null;
    }
    for (final p in provinces) {
      if (p.id == provinceId) {
        return p;
      }
    }
    return null;
  }

  Widget _stepStructure(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _wizardTopBar(
          context,
          l10n,
          stepIndex: 1,
          stepShortTitle: l10n.setupWizardStep2AppBar,
          onSkip: () => _goHome(context),
        ),
        Text(
          l10n.setupWizardStructureHeadline,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.setupWizardStructureSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: apart.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.setupBlockCountLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
            color: apart.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: _singleBlock,
          builder: (context, single, _) {
            return Row(
              children: [
                Expanded(
                  child: _StructureBlockCard(
                    title: l10n.setupSingleBlock,
                    selected: single,
                    onTap: () => _singleBlock.value = true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StructureBlockCard(
                    title: l10n.setupMultipleBlocks,
                    selected: !single,
                    onTap: () => _singleBlock.value = false,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _StepperCard(
          label: l10n.setupFloorCountLabel,
          notifier: _floors,
          min: 1,
          max: 40,
        ),
        const SizedBox(height: 12),
        _StepperCard(
          label: l10n.setupWizardPerFloorLabel,
          notifier: _perFloor,
          min: 1,
          max: 12,
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<int>(
          valueListenable: _floors,
          builder: (context, floors, _) {
            return ValueListenableBuilder<int>(
              valueListenable: _perFloor,
              builder: (context, per, _) {
                final count = floors * per;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: scheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: theme.textTheme.labelMedium?.copyWith(
                              height: 1.35,
                              color: scheme.onSurface,
                            ),
                            children: [
                              TextSpan(
                                text: l10n.setupStructureCountBold('$count'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: l10n.setupStructureSummaryTail(
                                  '$floors',
                                  '$per',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _stepUnits(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final apart = context.apart;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _wizardTopBar(
          context,
          l10n,
          stepIndex: 2,
          stepShortTitle: l10n.setupWizardUnitsCountLabel('$_totalUnits'),
          preferredTrailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.homeFeatureSoon)),
              );
            },
            child: Text(l10n.setupWizardUnitsEdit),
          ),
        ),
        Text(
          l10n.setupWizardUnitsInstruction,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: apart.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: _namingAutomatic,
          builder: (context, auto, _) {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: apart.chipInactiveBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NamingToggleChip(
                      label: l10n.setupNamingAutomatic,
                      selected: auto,
                      onTap: () => _namingAutomatic.value = true,
                    ),
                  ),
                  Expanded(
                    child: _NamingToggleChip(
                      label: l10n.setupNamingCustom,
                      selected: !auto,
                      onTap: () => _namingAutomatic.value = false,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: _showAllFloors,
          builder: (context, expanded, _) {
            return ValueListenableBuilder<int>(
              valueListenable: _floors,
              builder: (context, floors, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _perFloor,
                  builder: (context, perFloor, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: _highlightUnit,
                      builder: (context, highlight, _) {
                        final limit =
                            expanded ? floors : math.min(3, floors);
                        final children = <Widget>[];
                        for (var fi = 1; fi <= limit; fi++) {
                          children.add(
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 6,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n.managerFloorHeading('$fi'),
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    l10n.managerFloorUnitCount('$perFloor'),
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: apart.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          final rowLabels = <String>[];
                          for (var k = 0; k < perFloor; k++) {
                            rowLabels.add(
                              '$fi${String.fromCharCode(65 + k)}',
                            );
                          }
                          children.add(
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: rowLabels.map((label) {
                                final selected = highlight == label;
                                return _UnitPill(
                                  label: label,
                                  selected: selected,
                                  onTap: () => _highlightUnit.value = label,
                                );
                              }).toList(),
                            ),
                          );
                        }
                        if (floors > 3) {
                          final tail = List.generate(
                            floors - 3,
                            (i) => '${i + 4}',
                          ).join(', ');
                          children.add(
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                              onPressed: () {
                                _showAllFloors.value = !expanded;
                              },
                              child: Text(
                                expanded
                                    ? l10n.setupWizardCollapseFloors
                                    : l10n.setupShowMoreFloorsDetail(
                                        tail,
                                      ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: children,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _stepDues(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final apart = context.apart;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _wizardTopBar(
          context,
          l10n,
          stepIndex: 3,
          stepShortTitle: l10n.setupWizardStep4AppBar,
          onSkip: () => _goHome(context),
        ),
        Text(
          l10n.setupDuesHeadline,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.setupDuesSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: apart.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<int>(
          valueListenable: _duesKurus,
          builder: (context, kurus, _) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.setupDuesMonthlyPerUnitLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTry(kurus),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.setupPerApartmentSuffix,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MoneyAdjChip(
                        label: '−100',
                        onTap: () => _duesKurus.value =
                            math.max(0, _duesKurus.value - 10_000),
                        variant: _MoneyAdjVariant.negative,
                      ),
                      _MoneyAdjChip(
                        label: '−50',
                        onTap: () => _duesKurus.value =
                            math.max(0, _duesKurus.value - 5_000),
                        variant: _MoneyAdjVariant.negative,
                      ),
                      _MoneyAdjChip(
                        label: '+50',
                        onTap: () => _duesKurus.value += 5_000,
                        variant: _MoneyAdjVariant.positive,
                      ),
                      _MoneyAdjChip(
                        label: '+100',
                        onTap: () => _duesKurus.value += 10_000,
                        variant: _MoneyAdjVariant.positive,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          l10n.setupDueDayLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<int>(
          valueListenable: _dueDay,
          builder: (context, day, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dueDayChoices.map((d) {
                final sel = day == d;
                return _DueDayChip(
                  day: d,
                  selected: sel,
                  onTap: () => _dueDay.value = d,
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: _lateFeeEnabled,
          builder: (context, v, _) {
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.setupLateFeeTitle),
              subtitle: Text(
                l10n.setupLateFeeSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: apart.onSurfaceVariant,
                ),
              ),
              value: v,
              activeThumbColor: AppTheme.primary,
              onChanged: (x) => _lateFeeEnabled.value = x,
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _smsReminder,
          builder: (context, v, _) {
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.setupSmsReminderTitle),
              subtitle: Text(
                l10n.setupSmsReminderSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: apart.onSurfaceVariant,
                ),
              ),
              value: v,
              activeThumbColor: AppTheme.primary,
              onChanged: (x) => _smsReminder.value = x,
            );
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: _duesKurus,
          builder: (context, kurus, _) {
            final total = kurus * _totalUnits;
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.setupTotalMonthlyCollection,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatTry(total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

enum _MoneyAdjVariant { negative, positive }

class _MoneyAdjChip extends StatelessWidget {
  const _MoneyAdjChip({
    required this.label,
    required this.onTap,
    required this.variant,
  });

  final String label;
  final VoidCallback onTap;
  final _MoneyAdjVariant variant;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final positive = variant == _MoneyAdjVariant.positive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: positive ? AppTheme.secondary : apart.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: positive ? AppTheme.secondary : apart.outlineMuted,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: positive
                ? const Color(0xFF1A1A1A)
                : AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DueDayChip extends StatelessWidget {
  const _DueDayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : apart.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primary : apart.outlineMuted,
          ),
        ),
        child: Text(
          '$day',
          style: theme.textTheme.titleSmall?.copyWith(
            color: selected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StructureBlockCard extends StatelessWidget {
  const _StructureBlockCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    return Material(
      color: selected ? theme.colorScheme.primaryContainer : apart.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primary : apart.outlineMuted,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppTheme.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppTheme.primary : apart.outlineMuted,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Center(
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.notifier,
    required this.min,
    required this.max,
  });

  final String label;
  final ValueNotifier<int> notifier;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;

    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, value, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: apart.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: apart.outlineMuted),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _RoundGreenIconButton(
                icon: Icons.remove,
                onPressed: () =>
                    notifier.value = (value - 1).clamp(min, max),
              ),
              SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    '$value',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              _RoundGreenIconButton(
                icon: Icons.add,
                onPressed: () =>
                    notifier.value = (value + 1).clamp(min, max),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoundGreenIconButton extends StatelessWidget {
  const _RoundGreenIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: AppTheme.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _NamingToggleChip extends StatelessWidget {
  const _NamingToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apart = context.apart;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? apart.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: selected ? AppTheme.cardShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? theme.colorScheme.onSurface
                      : apart.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitPill extends StatelessWidget {
  const _UnitPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : apart.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primary : apart.outlineMuted,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
