import 'package:flutter/material.dart';
import 'package:localekit/core/theme/app_colors.dart';

/// Provides [darkTheme] and [lightTheme] for LocaleKit.
///
/// Design principles (per PRD §7):
/// - Density-aware: compact padding throughout
/// - WCAG AA contrast in both variants
/// - Dark default with light toggle
abstract final class AppTheme {
  /// Material 3 dark theme.
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brand,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          outline: AppColors.darkBorder,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        visualDensity: VisualDensity.compact,
        cardTheme: const CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkOnSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkOnSurface,
          size: 18,
        ),
        textTheme: _textTheme(AppColors.darkOnBackground),
      );

  /// Material 3 light theme.
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.brand,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightOnSurface,
          surfaceContainerHighest: AppColors.lightSurfaceVariant,
          outline: AppColors.lightBorder,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        visualDensity: VisualDensity.compact,
        cardTheme: const CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder,
          thickness: 1,
          space: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightOnSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lightOnSurface,
          size: 18,
        ),
        textTheme: _textTheme(AppColors.lightOnBackground),
      );

  static TextTheme _textTheme(Color baseColor) => TextTheme(
        bodyLarge: TextStyle(color: baseColor, fontSize: 14),
        bodyMedium: TextStyle(color: baseColor, fontSize: 13),
        bodySmall: TextStyle(color: baseColor.withAlpha(180), fontSize: 12),
        labelLarge: TextStyle(
          color: baseColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        labelSmall:
            TextStyle(color: baseColor.withAlpha(180), fontSize: 11),
        titleMedium: TextStyle(
          color: baseColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
}
