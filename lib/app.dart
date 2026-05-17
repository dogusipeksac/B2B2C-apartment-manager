import 'package:apartment_manager/core/preferences/app_preferences_provider.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:apartment_manager/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final prefsAsync = ref.watch(appPreferencesProvider);

    return prefsAsync.when(
      loading: () => const _BootstrapApp(),
      error: (_, _) => _AppShell(
        router: router,
        preferences: AppPreferences.defaults,
      ),
      data: (prefs) => _AppShell(
        router: router,
        preferences: prefs,
      ),
    );
  }
}

class _BootstrapApp extends StatelessWidget {
  const _BootstrapApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.router,
    required this.preferences,
  });

  final GoRouter router;
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: preferences.themeMode,
      locale: preferences.locale,
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
