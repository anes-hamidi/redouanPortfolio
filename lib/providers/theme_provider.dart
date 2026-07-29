import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod StateNotifier for managing App Theme Mode (Light / Dark)
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

/// Global Riverpod Provider for Theme Mode
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
