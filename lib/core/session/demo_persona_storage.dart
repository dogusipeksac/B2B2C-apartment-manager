import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [DemoPersona] for demo builds only.
abstract final class DemoPersonaStorage {
  static const _key = 'demo_persona_v1';

  static Future<DemoPersona?> read() async {
    if (!Env.demoMode) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    switch (raw) {
      case 'resident':
        return DemoPersona.resident;
      case 'manager':
        return DemoPersona.manager;
      case 'superAdmin':
        return DemoPersona.superAdmin;
      default:
        return null;
    }
  }

  static Future<void> write(DemoPersona persona) async {
    if (!Env.demoMode) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, persona.name);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
