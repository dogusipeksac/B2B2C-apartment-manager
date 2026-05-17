import 'package:shared_preferences/shared_preferences.dart';

/// UI default for "remember me" on invite login screens.
abstract final class SessionPreferencesStorage {
  static const _rememberMeKey = 'auth_remember_me_default_v1';

  static Future<bool> loadRememberMeDefault() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? true;
  }

  static Future<void> saveRememberMeDefault(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }
}
