import 'package:apartment_manager/app.dart';
import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await initSupabase();

  runApp(const ProviderScope(child: App()));
}
