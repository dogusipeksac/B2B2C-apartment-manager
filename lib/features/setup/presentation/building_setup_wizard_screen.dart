import 'dart:async';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Manager wizard steps (demo prefilled). Maps to `buildings` + structure fields.
class BuildingSetupWizardScreen extends StatefulWidget {
  const BuildingSetupWizardScreen({super.key});

  @override
  State<BuildingSetupWizardScreen> createState() =>
      _BuildingSetupWizardScreenState();
}

class _BuildingSetupWizardScreenState extends State<BuildingSetupWizardScreen> {
  final _page = PageController();
  int _step = 0;

  final _name = TextEditingController(
    text: Env.demoMode ? 'Yeşil Vadi Apartmanı' : '',
  );
  final _address = TextEditingController(
    text: Env.demoMode ? 'Mahalle, sokak, no' : '',
  );
  final _floors = ValueNotifier<int>(Env.demoMode ? 6 : 1);
  final _perFloor = ValueNotifier<int>(Env.demoMode ? 3 : 1);

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _address.dispose();
    _floors.dispose();
    _perFloor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupWizardTitle)),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_step + 1) / 4),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _stepBuilding(context, l10n),
                _stepStructure(context, l10n),
                _stepPlaceholder(context, 'Daireler · özet'),
                _stepPlaceholder(context, 'Aidat planı'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      if (_step == 0) {
                        context.pop();
                        return;
                      }
                      setState(() => _step -= 1);
                      unawaited(
                        _page.previousPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        ),
                      );
                    },
                    child: Text(l10n.navBack),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      if (_step >= 3) {
                        context.go('/home');
                        return;
                      }
                      setState(() => _step += 1);
                      unawaited(
                        _page.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        ),
                      );
                    },
                    child: Text(l10n.continueButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBuilding(BuildContext context, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: l10n.setupBuildingNameLabel),
        ),
        TextField(
          controller: _address,
          decoration: InputDecoration(labelText: l10n.setupAddressLabel),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _stepStructure(BuildContext context, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.demoInvitePreviewSubtitle),
        const SizedBox(height: 16),
        ValueListenableBuilder<int>(
          valueListenable: _floors,
          builder: (context, v, _) {
            return Row(
              children: [
                Expanded(child: Text(l10n.setupFloorCountLabel)),
                IconButton(
                  onPressed: () => _floors.value = (v - 1).clamp(1, 40),
                  icon: const Icon(Icons.remove),
                ),
                Text('$v'),
                IconButton(
                  onPressed: () => _floors.value = (v + 1).clamp(1, 40),
                  icon: const Icon(Icons.add),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: _perFloor,
          builder: (context, v, _) {
            return Row(
              children: [
                Expanded(child: Text(l10n.setupWizardPerFloorLabel)),
                IconButton(
                  onPressed: () => _perFloor.value = (v - 1).clamp(1, 12),
                  icon: const Icon(Icons.remove),
                ),
                Text('$v'),
                IconButton(
                  onPressed: () => _perFloor.value = (v + 1).clamp(1, 12),
                  icon: const Icon(Icons.add),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _stepPlaceholder(BuildContext context, String title) {
    return Center(child: Text(title));
  }
}
