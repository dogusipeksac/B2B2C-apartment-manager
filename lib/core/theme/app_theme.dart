import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const Color primary = Color(0xFF1B5E20);
  static const Color secondary = Color(0xFFFFA000);
  static const Color error = Color(0xFFC62828);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
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
