import 'package:apartment_manager/app.dart';
import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/demo/data/demo_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  if (!Env.demoMode) {
    await initSupabase();
  }

  runApp(
    ProviderScope(
      overrides: Env.demoMode
          ? [
              profileRepositoryProvider.overrideWithValue(
                DemoProfileRepository(),
              ),
            ]
          : const [],
      child: const App(),
    ),
  );
}
