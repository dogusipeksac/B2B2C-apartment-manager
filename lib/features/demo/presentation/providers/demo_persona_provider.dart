import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/session/demo_persona.dart';
import 'package:apartment_manager/core/session/demo_persona_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo build: which UX branch (resident vs manager). Null when not chosen yet.
class DemoPersonaNotifier extends AsyncNotifier<DemoPersona?> {
  @override
  Future<DemoPersona?> build() async {
    if (!Env.demoMode) {
      return null;
    }
    return DemoPersonaStorage.read();
  }

  Future<void> choose(DemoPersona persona) async {
    await DemoPersonaStorage.write(persona);
    state = AsyncData(persona);
  }

  Future<void> clear() async {
    await DemoPersonaStorage.clear();
    state = const AsyncData(null);
  }
}

final demoPersonaProvider =
    AsyncNotifierProvider<DemoPersonaNotifier, DemoPersona?>(
  DemoPersonaNotifier.new,
);
