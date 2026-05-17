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
    final scheme = theme.colorScheme;
    final prefsAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      backgroundColor: apart.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: apart.scaffoldBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: prefsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: scheme.primary),
        ),
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
                    _SettingsChoiceTile(
                      label: l10n.settingsThemeLight,
                      subtitle: l10n.settingsThemeLightHint,
                      icon: Icons.light_mode_outlined,
                      selected: prefs.themeMode == ThemeMode.light,
                      onTap: () =>
                          unawaited(notifier.setThemeMode(ThemeMode.light)),
                      showDivider: true,
                    ),
                    _SettingsChoiceTile(
                      label: l10n.settingsThemeDark,
                      subtitle: l10n.settingsThemeDarkHint,
                      icon: Icons.dark_mode_outlined,
                      selected: prefs.themeMode == ThemeMode.dark,
                      onTap: () =>
                          unawaited(notifier.setThemeMode(ThemeMode.dark)),
                      showDivider: true,
                    ),
                    _SettingsChoiceTile(
                      label: l10n.settingsThemeSystem,
                      subtitle: l10n.settingsThemeSystemHint,
                      icon: Icons.brightness_auto_outlined,
                      selected: prefs.themeMode == ThemeMode.system,
                      onTap: () =>
                          unawaited(notifier.setThemeMode(ThemeMode.system)),
                      showDivider: false,
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
                    _SettingsChoiceTile(
                      label: l10n.settingsLanguageTurkish,
                      subtitle: 'Türkçe',
                      icon: Icons.language_rounded,
                      selected: prefs.locale.languageCode == 'tr',
                      onTap: () => unawaited(
                        notifier.setLocale(const Locale('tr')),
                      ),
                      showDivider: true,
                    ),
                    _SettingsChoiceTile(
                      label: l10n.settingsLanguageEnglish,
                      subtitle: 'English',
                      icon: Icons.language_rounded,
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

class _SettingsChoiceTile extends StatelessWidget {
  const _SettingsChoiceTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;

    return Column(
      children: [
        Material(
          color: selected
              ? scheme.primaryContainer.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.45 : 0.85,
                )
              : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? scheme.primary : apart.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected ? scheme.onPrimaryContainer : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? scheme.onPrimaryContainer.withValues(
                                    alpha: 0.85,
                                  )
                                : apart.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: scheme.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: apart.outlineMuted.withValues(alpha: 0.65),
          ),
      ],
    );
  }
}
