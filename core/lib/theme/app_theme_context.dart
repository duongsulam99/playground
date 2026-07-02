import 'package:flutter/material.dart';

import 'extensions/app_colors.dart';
import 'extensions/app_dimensions.dart';
import 'extensions/app_text_theme.dart';

extension AppThemeContext on BuildContext {
  // ── Material standard (ngắn gọn) ──
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  // ── Semantic colors (dễ hiểu) ──
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get surfaceColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;
  bool get isDarkTheme => theme.brightness == Brightness.dark;

  // ── Custom extensions (semantic) ──
  AppColors get colors => theme.extension<AppColors>()!;
  AppTextTheme get textTheme => theme.extension<AppTextTheme>()!;
  AppDimensions get dimensions => theme.extension<AppDimensions>()!;

  // ── Responsive (tích hợp Sizer có sẵn) ──
}
