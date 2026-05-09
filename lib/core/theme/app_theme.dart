import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from `Apartman Yonetici.html` (Inter, M3-inspired kit).
class AppTheme {
  const AppTheme._();

  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color primaryDark = Color(0xFF003300);
  static const Color primaryContainer = Color(0xFFE8F2E9);
  static const Color secondary = Color(0xFFFFA000);
  static const Color secondaryContainer = Color(0xFFFFF4DD);
  static const Color error = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFDECEC);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningContainer = Color(0xFFFFF1DF);
  static const Color info = Color(0xFF1976D2);
  static const Color infoContainer = Color(0xFFE3EDF9);
  static const Color scaffoldBg = Color(0xFFF5F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color outlineMuted = Color(0xFFE5E7EB);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color onSurfaceTertiary = Color(0xFF9CA3AF);
  static const Color debtGradientStart = Color(0xFFC62828);
  static const Color debtGradientEnd = Color(0xFF9B1C1C);
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
    );

    final scheme = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: primaryDark,
      secondary: secondary,
      onSecondary: Color(0xFF1A1A1A),
      secondaryContainer: secondaryContainer,
      tertiary: info,
      tertiaryContainer: infoContainer,
      error: error,
      surface: surface,
      onSurface: Color(0xFF1A1A1A),
      onSurfaceVariant: onSurfaceVariant,
      outline: outlineMuted,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        shape: const Border(
          bottom: BorderSide(color: outlineMuted),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: outlineMuted),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: surface,
        indicatorColor: primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: selected ? primary : onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primary, width: 1.5),
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: _textTheme(base.textTheme),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
        error: error,
      ),
      textTheme: _textTheme(base.textTheme),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    final inter = GoogleFonts.interTextTheme(base);
    return inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: inter.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: inter.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: inter.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: inter.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: inter.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: inter.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      bodyMedium: inter.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      bodySmall: inter.bodySmall?.copyWith(fontWeight: FontWeight.w400),
      labelLarge: inter.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: inter.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: inter.labelSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
