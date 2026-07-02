import 'package:flutter/material.dart';

import 'app_theme_config.dart';
import 'extensions/app_colors.dart';
import 'extensions/app_text_theme.dart';

/// Single orchestrator for the app design system.
abstract final class AppTheme {
  const AppTheme._();

  // ── Predefined themes ──
  static final ThemeData light = buildFrom(
    AppThemeConfig.defaults,
    Brightness.light,
  );
  static final ThemeData dark = buildFrom(
    AppThemeConfig.defaults,
    Brightness.dark,
  );

  /// Builds a [ThemeData] from the given [AppThemeConfig] and [Brightness].
  static ThemeData buildFrom(AppThemeConfig config, Brightness brightness) {
    final colors = config.colorsFor(brightness);
    final typography = AppTextTheme.fromTokens(
      config.typography,
      colors: colors,
    );
    final dimensions = config.dimensions;
    final extraExtensions = config.extraExtensions?.call(brightness) ?? [];

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: _colorScheme(colors, config.seedColor, brightness),
      scaffoldBackgroundColor: colors.background,
      textTheme: typography.materialTextTheme,
      extensions: [colors, typography, dimensions, ...extraExtensions],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: typography.headingMedium,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.radius12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          textStyle: typography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimensions.radius8),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: dimensions.spacing16,
          vertical: dimensions.spacing12,
        ),
        hintStyle: typography.bodySmall.copyWith(color: colors.textDisabled),
        labelStyle: typography.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius8),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius8),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius8),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
    );
  }

  static ColorScheme _colorScheme(
    AppColors colors,
    Color seedColor,
    Brightness brightness,
  ) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ).copyWith(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      error: colors.error,
      outline: colors.border,
    );
  }
}
