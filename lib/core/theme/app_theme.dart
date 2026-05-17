import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from `Apartman Yonetici.html` (Inter, M3-inspired kit).
///
/// Typography: `ThemeData.fontFamily` is Inter (Google Fonts) in [light] and [dark].
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
      fontFamily: GoogleFonts.inter().fontFamily,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: onSurfaceTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineMuted, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineMuted, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
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
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryDark;
            }
            return onSurfaceVariant;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryContainer;
            }
            return surface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const BorderSide(color: primary, width: 1.5);
            }
            return const BorderSide(color: outlineMuted);
          }),
        ),
      ),
      textTheme: _textTheme(base.textTheme),
      extensions: const [ApartmanTokens.light],
    );
  }

  /// Dark palette aligned with light brand colors (green primary, amber accent).
  static ThemeData dark() {
    const dScaffold = Color(0xFF0F1412);
    const dSurface = Color(0xFF1A2120);

    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF66BB6A),
      onPrimary: const Color(0xFF052211),
      primaryContainer: const Color(0xFF1E3D28),
      onPrimaryContainer: const Color(0xFFC8E6C9),
      secondary: const Color(0xFFFFB74D),
      onSecondary: const Color(0xFF261300),
      secondaryContainer: const Color(0xFF5D4037),
      onSecondaryContainer: const Color(0xFFFFE0B2),
      tertiary: const Color(0xFF90CAF9),
      tertiaryContainer: const Color(0xFF1A3A5C),
      onTertiaryContainer: const Color(0xFFDCEEFE),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: dSurface,
      onSurface: const Color(0xFFE8ECEA),
      surfaceContainerHighest: const Color(0xFF2A322F),
      onSurfaceVariant: const Color(0xFFB8C0BC),
      outline: const Color(0xFF5C6762),
      outlineVariant: const Color(0xFF3D4844),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: scheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: dScaffold,
      colorScheme: scheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: ApartmanTokens.dark.onSurfaceTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: dSurface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        shape: Border(
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dSurface,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: dSurface,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
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
          side: BorderSide(color: scheme.primary, width: 1.5),
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurfaceVariant;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return scheme.surfaceContainerHighest;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: scheme.primary, width: 1.5);
            }
            return BorderSide(color: scheme.outlineVariant);
          }),
        ),
      ),
      textTheme: _textTheme(base.textTheme),
      extensions: const [ApartmanTokens.dark],
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

/// Theme-aware scaffold, surfaces, borders, and muted text (light/dark).
@immutable
class ApartmanTokens extends ThemeExtension<ApartmanTokens> {
  const ApartmanTokens({
    required this.scaffoldBg,
    required this.surface,
    required this.outlineMuted,
    required this.onSurfaceVariant,
    required this.onSurfaceTertiary,
    required this.chipInactiveBg,
    required this.cardShadow,
  });

  final Color scaffoldBg;
  final Color surface;
  final Color outlineMuted;
  final Color onSurfaceVariant;
  final Color onSurfaceTertiary;
  final Color chipInactiveBg;
  final List<BoxShadow> cardShadow;

  static const ApartmanTokens light = ApartmanTokens(
    scaffoldBg: AppTheme.scaffoldBg,
    surface: AppTheme.surface,
    outlineMuted: AppTheme.outlineMuted,
    onSurfaceVariant: AppTheme.onSurfaceVariant,
    onSurfaceTertiary: AppTheme.onSurfaceTertiary,
    chipInactiveBg: Color(0xFFF3F4F6),
    cardShadow: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
  );

  static const ApartmanTokens dark = ApartmanTokens(
    scaffoldBg: Color(0xFF0F1412),
    surface: Color(0xFF1A2120),
    outlineMuted: Color(0xFF3D4844),
    onSurfaceVariant: Color(0xFFB8C0BC),
    onSurfaceTertiary: Color(0xFF7A8580),
    chipInactiveBg: Color(0xFF252E2B),
    cardShadow: [
      BoxShadow(
        color: Color(0x59000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  @override
  ApartmanTokens copyWith({
    Color? scaffoldBg,
    Color? surface,
    Color? outlineMuted,
    Color? onSurfaceVariant,
    Color? onSurfaceTertiary,
    Color? chipInactiveBg,
    List<BoxShadow>? cardShadow,
  }) {
    return ApartmanTokens(
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      surface: surface ?? this.surface,
      outlineMuted: outlineMuted ?? this.outlineMuted,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onSurfaceTertiary: onSurfaceTertiary ?? this.onSurfaceTertiary,
      chipInactiveBg: chipInactiveBg ?? this.chipInactiveBg,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  ApartmanTokens lerp(ThemeExtension<ApartmanTokens>? other, double t) {
    if (other is! ApartmanTokens) return this;
    return ApartmanTokens(
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      outlineMuted: Color.lerp(outlineMuted, other.outlineMuted, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      onSurfaceTertiary: Color.lerp(
        onSurfaceTertiary,
        other.onSurfaceTertiary,
        t,
      )!,
      chipInactiveBg: Color.lerp(chipInactiveBg, other.chipInactiveBg, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

extension ApartmanThemeContext on BuildContext {
  ApartmanTokens get apart =>
      Theme.of(this).extension<ApartmanTokens>() ?? ApartmanTokens.light;
}
