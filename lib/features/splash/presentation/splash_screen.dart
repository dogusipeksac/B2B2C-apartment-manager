import 'dart:async';

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/onboarding/onboarding_storage.dart';
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
        final localSession =
            await ref.read(localSessionRepositoryProvider).load();
        if (!mounted) {
          return;
        }

        if (kDebugMode) {
          final label = localSession == null ? 'null' : 'non-null';
          debugPrint('splash: local session is $label');
        }
        if (localSession == null) {
          final seenOnboarding =
              await OnboardingStorage.hasSeenOnboarding();
          if (!mounted) {
            return;
          }
          if (!seenOnboarding) {
            if (kDebugMode) {
              debugPrint('splash: go(/onboarding)');
            }
            context.go('/onboarding');
            return;
          }
          if (kDebugMode) {
            debugPrint('splash: go(/setup/account-type)');
          }
          context.go('/setup/account-type');
          return;
        }

        if (kDebugMode) {
          debugPrint('splash: go(/home)');
        }
        context.go('/home');
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
        context.go('/setup/account-type');
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
        context.go('/setup/account-type');
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.15,
            colors: [
              Color(0xFF2A7C33),
              Color(0xFF11421A),
              Color(0xFF003300),
            ],
            stops: [0, 0.65, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                l10n.appTitle,
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.splashTagline,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFC9DCCD),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
