import 'package:flutter/material.dart';

class CafeColors {
  static const background = Color(0xFFC7B7A1);
  static const surface = Color(0xFFE9DDCB);
  static const dark = Color(0xFF2F2116);
  static const muted = Color(0xFF5D523A);
  static const accent = Color(0xFFFFC83D);
  static const heart = Color(0xFFD7302F);
}

ThemeData buildCafeTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CafeColors.dark,
      brightness: Brightness.light,
      primary: CafeColors.dark,
      secondary: CafeColors.accent,
      surface: CafeColors.surface,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: CafeColors.background,
    textTheme: base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        color: CafeColors.dark,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        color: CafeColors.dark,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        color: CafeColors.dark,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: CafeColors.dark,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        color: CafeColors.dark,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: CafeColors.dark),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: CafeColors.muted),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        color: CafeColors.muted,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CafeColors.dark, width: 1.4),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CafeColors.dark, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF9D2F2F), width: 1.4),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF9D2F2F), width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CafeColors.dark,
        foregroundColor: CafeColors.background,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: CafeColors.dark,
      contentTextStyle: const TextStyle(
        color: CafeColors.background,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
