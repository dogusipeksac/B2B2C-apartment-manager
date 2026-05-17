import 'package:apartment_manager/core/preferences/app_preferences_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User-facing theme and language preferences.
class AppPreferences {
  const AppPreferences({
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  static const defaults = AppPreferences(
    themeMode: ThemeMode.light,
    locale: Locale('tr'),
  );

  AppPreferences copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesNotifier, AppPreferences>(
      AppPreferencesNotifier.new,
    );

class AppPreferencesNotifier extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() async {
    final themeMode = await AppPreferencesStorage.loadThemeMode();
    final locale = await AppPreferencesStorage.loadLocale();
    return AppPreferences(themeMode: themeMode, locale: locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(themeMode: mode));
    await AppPreferencesStorage.saveThemeMode(mode);
  }

  Future<void> setLocale(Locale locale) async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(locale: locale));
    await AppPreferencesStorage.saveLocale(locale);
  }
}
