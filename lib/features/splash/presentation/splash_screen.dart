import 'dart:async';

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) {
        return;
      }

      try {
        if (kDebugMode) {
          debugPrint('splash: timer fired, checking session');
        }
        final session = ref.read(authRepositoryProvider).currentSession;
        if (!mounted) {
          return;
        }

        if (kDebugMode) {
          final label = session == null ? 'null' : 'non-null';
          debugPrint('splash: session is $label');
        }
        if (session == null) {
          if (kDebugMode) {
            debugPrint('splash: go(/login)');
          }
          context.go('/login');
          return;
        }

        if (kDebugMode) {
          debugPrint('splash: fetching profile');
        }
        final profile = await ref.read(currentProfileProvider.future);
        if (!mounted) {
          return;
        }

        final fullName = profile?.fullName.trim() ?? '';
        if (fullName.isEmpty) {
          if (kDebugMode) {
            debugPrint('splash: go(/profile-setup)');
          }
          context.go('/profile-setup');
        } else {
          if (kDebugMode) {
            debugPrint('splash: go(/home)');
          }
          context.go('/home');
        }
      } on AppException catch (e) {
        if (!mounted) {
          return;
        }
        if (kDebugMode) {
          debugPrint('splash redirect AppException: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.userMessage)),
        );
        context.go('/login');
      } on Object catch (e, st) {
        if (!mounted) {
          return;
        }
        if (kDebugMode) {
          debugPrint('splash redirect error: $e');
          debugPrintStack(stackTrace: st);
        }
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
