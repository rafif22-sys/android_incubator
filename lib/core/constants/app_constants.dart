import 'package:flutter/material.dart';

class AppColors {
  // Base Palette
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF151E2E);
  static const Color surfaceElevated = Color(0xFF1F2B41);
  static const Color border = Color(0xFF222F43);
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Status & Telemetry Glowing Colors
  static const Color tempAccent = Color(0xFFEF4444); // Crimson Red
  static const Color humidAccent = Color(0xFF06B6D4); // Cyan
  static const Color lightAccent = Color(0xFFF59E0B); // Gold/Amber
  static const Color pressureAccent = Color(0xFF3B82F6); // Blue
  static const Color altitudeAccent = Color(0xFF10B981); // Emerald Green
  static const Color heaterAccent = Color(0xFFF97316); // Orange Flame

  // Connection states
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}

class AppThresholds {
  // Chicken Egg Incubation Thresholds (Standard)
  static const double minTemp = 37.0;
  static const double maxTemp = 38.5;
  static const double minHumid = 60.0;
  static const double maxHumid = 70.0;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.humidAccent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      useMaterial3: true,
      fontFamily: 'sans-serif',
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        elevation: 0,
      ),
    );
  }
}
