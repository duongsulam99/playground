import 'package:flutter/material.dart';

import 'font_family.dart';

/// Raw typography scale (sizes & weights). Colors applied in [AppTextTheme].
class TypographyTokens {
  const TypographyTokens({
    required this.displayLargeSize,
    required this.headingLargeSize,
    required this.headingMediumSize,
    required this.bodyLargeSize,
    required this.bodyMediumSize,
    required this.bodySmallSize,
    required this.labelLargeSize,
    required this.captionSize,
  });

  final double displayLargeSize;
  final double headingLargeSize;
  final double headingMediumSize;
  final double bodyLargeSize;
  final double bodyMediumSize;
  final double bodySmallSize;
  final double labelLargeSize;
  final double captionSize;

  static const defaults = TypographyTokens(
    displayLargeSize: 32,
    headingLargeSize: 24,
    headingMediumSize: 20,
    bodyLargeSize: 18,
    bodyMediumSize: 16,
    bodySmallSize: 14,
    labelLargeSize: 14,
    captionSize: 12,
  );

  static TextStyle style({
    required double size,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: AppFontFamily.primary,
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
