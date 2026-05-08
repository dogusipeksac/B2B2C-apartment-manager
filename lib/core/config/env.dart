import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  const Env._();

  static const _keySupabaseUrl = 'SUPABASE_URL';
  static const _keySupabaseAnonKey = 'SUPABASE_ANON_KEY';

  static Future<void> load() async {
    await dotenv.load();

    final url = dotenv.env[_keySupabaseUrl];
    final anonKey = dotenv.env[_keySupabaseAnonKey];

    if (url == null || url.trim().isEmpty) {
      throw const AppException.unknown();
    }
    if (anonKey == null || anonKey.trim().isEmpty) {
      throw const AppException.unknown();
    }
  }

  static String get supabaseUrl {
    final value = dotenv.env[_keySupabaseUrl];
    if (value == null || value.trim().isEmpty) {
      throw const AppException.unknown();
    }
    return value;
  }

  static String get supabaseAnonKey {
    final value = dotenv.env[_keySupabaseAnonKey];
    if (value == null || value.trim().isEmpty) {
      throw const AppException.unknown();
    }
    return value;
  }
}
