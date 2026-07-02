import 'package:flutter/material.dart';

import 'extensions/app_colors.dart';
import 'extensions/app_dimensions.dart';
import 'tokens/typography_tokens.dart';

typedef AppThemeExtensionsBuilder = List<ThemeExtension<dynamic>> Function(
  Brightness brightness,
);

/// Injectable theme configuration for app-level overrides and extensions.
class AppThemeConfig {
  const AppThemeConfig({
    this.lightColors = AppColors.light,
    this.darkColors = AppColors.dark,
    this.seedColor = Colors.deepPurple,
    this.typography = TypographyTokens.defaults,
    this.dimensions = AppDimensions.standard,
    this.extraExtensions,
  });

  final AppColors lightColors;
  final AppColors darkColors;
  final Color seedColor;
  final TypographyTokens typography;
  final AppDimensions dimensions;
  final AppThemeExtensionsBuilder? extraExtensions;

  // ── Defaults ──
  static const defaults = AppThemeConfig();

  // ── Helpers ──
  AppColors colorsFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkColors : lightColors;
}
