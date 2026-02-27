import 'package:flutter/material.dart';

/// Central color tokens for LocaleKit.
///
/// Both dark and light themes reference these values
/// to ensure consistency across themes.
abstract final class AppColors {
  // Brand
  static const Color brand = Color(0xFF6C63FF);
  static const Color brandLight = Color(0xFF9D97FF);
  static const Color brandDark = Color(0xFF4A42CC);

  // Status indicators
  static const Color statusTranslated = Color(0xFF4CAF50);   // green
  static const Color statusMissing = Color(0xFFF44336);      // red
  static const Color statusModified = Color(0xFFFFC107);     // amber
  static const Color statusIgnored = Color(0xFF9E9E9E);      // grey
  static const Color statusAuto = Color(0xFF2196F3);         // blue

  // Dark surface palette
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkOnBackground = Color(0xFFE8E8E8);
  static const Color darkOnSurface = Color(0xFFCFCFCF);
  static const Color darkBorder = Color(0xFF3A3A3A);

  // Light surface palette
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEEEEE);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF333333);
  static const Color lightBorder = Color(0xFFDDDDDD);
}
