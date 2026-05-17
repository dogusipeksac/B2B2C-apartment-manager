import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app locale and theme mode.
abstract final class AppPreferencesStorage {
  static const _themeKey = 'app_theme_mode_v1';
  static const _localeKey = 'app_locale_v1';

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final wire = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeKey, wire);
  }

  static Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localeKey);
    return switch (raw) {
      'en' => const Locale('en'),
      'tr' => const Locale('tr'),
      _ => const Locale('tr'),
    };
  }

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final code = locale.languageCode;
    await prefs.setString(
      _localeKey,
      code == 'en' ? 'en' : 'tr',
    );
  }
}
