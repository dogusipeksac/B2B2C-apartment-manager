import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user finished the welcome carousel (mockup 1.2).
abstract final class OnboardingStorage {
  static const _key = 'has_seen_onboarding_v1';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
