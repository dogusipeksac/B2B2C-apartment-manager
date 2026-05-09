import 'package:apartment_manager/core/onboarding/onboarding_storage.dart';
import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mockup **1.2** — 3-slide welcome carousel (Skip + pager dots + Devam et).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slideCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishToLogin() async {
    await OnboardingStorage.markOnboardingSeen();
    if (!mounted) {
      return;
    }
    context.go('/setup/account-type');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    final isDark = theme.brightness == Brightness.dark;

    final slides = [
      (
        l10n.demoWelcomeSlide1Title,
        l10n.demoWelcomeSlide1Body,
      ),
      (
        l10n.demoWelcomeSlide2Title,
        l10n.demoWelcomeSlide2Body,
      ),
      (
        l10n.demoWelcomeSlide3Title,
        l10n.demoWelcomeSlide3Body,
      ),
    ];

    return Scaffold(
      backgroundColor: context.apart.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishToLogin,
                child: Text(
                  l10n.demoSkip,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slideCount,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final (title, body) = slides[index];
                  final heroGradient = isDark
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scheme.primaryContainer,
                            scheme.surfaceContainerHighest,
                          ],
                        )
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFE8F2E9),
                            Color(0xFFF5F7F5),
                          ],
                        );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 1 / 0.9,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: heroGradient,
                            ),
                            child: Center(
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: isDark
                                      ? scheme.primary
                                      : AppTheme.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.35 : 0.15,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.apartment_rounded,
                                  size: 64,
                                  color:
                                      isDark ? scheme.onPrimary : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: apart.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slideCount,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _page == i ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: _page == i
                              ? scheme.primary
                              : apart.outlineMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    onPressed: () async {
                      if (_page < _slideCount - 1) {
                        await _pageController.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        await _finishToLogin();
                      }
                    },
                    child: Text(l10n.continueButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
