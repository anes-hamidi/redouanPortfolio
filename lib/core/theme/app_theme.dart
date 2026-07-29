import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Application theme definitions
abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.navy,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        primary: AppColors.navy,
        secondary: AppColors.gold,
        surface: AppColors.cream,
      ),
      fontFamily: 'serif',
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.gold,
      scaffoldBackgroundColor: const Color(0xFF090D16),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.gold,
        primary: AppColors.gold,
        secondary: AppColors.navy,
        surface: const Color(0xFF111726),
      ),
      fontFamily: 'serif',
      useMaterial3: true,
    );
  }
}
