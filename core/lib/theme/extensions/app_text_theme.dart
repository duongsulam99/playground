import 'package:flutter/material.dart';

import '../tokens/typography_tokens.dart';
import 'app_colors.dart';

@immutable
class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme({
    required this.displayLarge,
    required this.headingLarge,
    required this.headingMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.caption,
  });

  final TextStyle displayLarge;
  final TextStyle headingLarge;
  final TextStyle headingMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle caption;

  factory AppTextTheme.fromTokens(
    TypographyTokens tokens, {
    required AppColors colors,
  }) {
    return AppTextTheme(
      displayLarge: TypographyTokens.style(
        size: tokens.displayLargeSize,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.3,
      ),
      headingLarge: TypographyTokens.style(
        size: tokens.headingLargeSize,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.3,
      ),
      headingMedium: TypographyTokens.style(
        size: tokens.headingMediumSize,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.3,
      ),
      bodyLarge: TypographyTokens.style(
        size: tokens.bodyLargeSize,
        color: colors.textPrimary,
        height: 1.4,
      ),
      bodyMedium: TypographyTokens.style(
        size: tokens.bodyMediumSize,
        color: colors.textPrimary,
        height: 1.4,
      ),
      bodySmall: TypographyTokens.style(
        size: tokens.bodySmallSize,
        color: colors.textSecondary,
        height: 1.4,
      ),
      labelLarge: TypographyTokens.style(
        size: tokens.labelLargeSize,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.2,
      ),
      caption: TypographyTokens.style(
        size: tokens.captionSize,
        color: colors.textSecondary,
        height: 1.2,
      ),
    );
  }

  TextTheme get materialTextTheme => TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelSmall: caption,
      );

  @override
  AppTextTheme copyWith({
    TextStyle? displayLarge,
    TextStyle? headingLarge,
    TextStyle? headingMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? caption,
  }) {
    return AppTextTheme(
      displayLarge: displayLarge ?? this.displayLarge,
      headingLarge: headingLarge ?? this.headingLarge,
      headingMedium: headingMedium ?? this.headingMedium,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTextTheme lerp(ThemeExtension<AppTextTheme>? other, double t) {
    if (other is! AppTextTheme) return this;
    return AppTextTheme(
      displayLarge:
          TextStyle.lerp(displayLarge, other.displayLarge, t) ?? displayLarge,
      headingLarge:
          TextStyle.lerp(headingLarge, other.headingLarge, t) ?? headingLarge,
      headingMedium: TextStyle.lerp(headingMedium, other.headingMedium, t) ??
          headingMedium,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t) ?? bodyLarge,
      bodyMedium:
          TextStyle.lerp(bodyMedium, other.bodyMedium, t) ?? bodyMedium,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t) ?? bodySmall,
      labelLarge:
          TextStyle.lerp(labelLarge, other.labelLarge, t) ?? labelLarge,
      caption: TextStyle.lerp(caption, other.caption, t) ?? caption,
    );
  }
}
