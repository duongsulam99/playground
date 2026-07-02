import 'package:flutter/material.dart';

/// Raw color values. Not used directly in widgets — mapped via [AppColors].
class ColorTokens {
  const ColorTokens({
    required this.seed,
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color seed;
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static const light = ColorTokens(
    seed: Colors.deepPurple,
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE0E0E0),
    textPrimary: Color(0xFF1C1B1F),
    textSecondary: Color(0xFF49454F),
    textDisabled: Color(0xFF9E9E9E),
    success: Color(0xFF388E3C),
    warning: Color(0xFFF57C00),
    error: Color(0xFFD32F2F),
    info: Color(0xFF1976D2),
  );

  static const dark = ColorTokens(
    seed: Colors.deepPurple,
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    border: Color(0xFF3A3A3A),
    textPrimary: Color(0xFFE6E1E5),
    textSecondary: Color(0xFFCAC4D0),
    textDisabled: Color(0xFF757575),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFEF5350),
    info: Color(0xFF42A5F5),
  );

  static ColorTokens forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
