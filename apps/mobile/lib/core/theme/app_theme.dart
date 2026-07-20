import 'package:flutter/material.dart';
import '../design/app_colors.dart';
import '../design/app_radius.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
        seedColor: AppColors.primary, brightness: brightness);
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF10131A) : AppColors.canvas,
      fontFamilyFallback: const <String>['Rubik', 'Arial', 'sans-serif'],
      appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: scheme.onSurface),
      cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 1,
          color: dark ? const Color(0xFF1A1F2A) : AppColors.surface,
          shadowColor: Colors.black.withValues(alpha: .06),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card))),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button)))),
      navigationBarTheme: const NavigationBarThemeData(height: 72),
    );
  }
}
