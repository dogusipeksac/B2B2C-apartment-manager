import 'dart:async' show unawaited;

import 'package:apartment_manager/core/preferences/app_preferences_provider.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Theme and language preferences (profile → settings).
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final apart = context.apart;
    final prefsAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.settingsLoadFailed,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: apart.onSurfaceVariant,
              ),
            ),
          ),
        ),
        data: (prefs) {
          final notifier = ref.read(appPreferencesProvider.notifier);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _SectionLabel(label: l10n.settingsSectionAppearance),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.settingsThemeLabel,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(l10n.settingsThemeLight),
                            icon: const Icon(Icons.light_mode_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(l10n.settingsThemeDark),
                            icon: const Icon(Icons.dark_mode_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(l10n.settingsThemeSystem),
                            icon: const Icon(Icons.phone_android_outlined, size: 18),
                          ),
                        ],
                        selected: {prefs.themeMode},
                        onSelectionChanged: (selected) {
                          final mode = selected.first;
                          unawaited(notifier.setThemeMode(mode));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionLabel(label: l10n.settingsSectionLanguage),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    _LocaleTile(
                      label: l10n.settingsLanguageTurkish,
                      subtitle: 'Türkçe',
                      selected: prefs.locale.languageCode == 'tr',
                      onTap: () => unawaited(
                        notifier.setLocale(const Locale('tr')),
                      ),
                      showDivider: true,
                    ),
                    _LocaleTile(
                      label: l10n.settingsLanguageEnglish,
                      subtitle: 'English',
                      selected: prefs.locale.languageCode == 'en',
                      onTap: () => unawaited(
                        notifier.setLocale(const Locale('en')),
                      ),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.settingsApplyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: apart.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: context.apart.onSurfaceVariant,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 20,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected ? scheme.primary : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: context.apart.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.success,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
