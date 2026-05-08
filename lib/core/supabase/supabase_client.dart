import 'package:apartment_manager/core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientWrapper {
  const SupabaseClientWrapper._();

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

Future<void> initSupabase() async {
  await SupabaseClientWrapper.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
