import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppDimensions extends ThemeExtension<AppDimensions> {
  const AppDimensions({
    required this.spacing4,
    required this.spacing8,
    required this.spacing12,
    required this.spacing16,
    required this.spacing20,
    required this.spacing24,
    required this.spacing32,
    required this.radius4,
    required this.radius8,
    required this.radius12,
    required this.radius16,
    required this.icon16,
    required this.icon20,
    required this.icon24,
  });

  final double spacing4;
  final double spacing8;
  final double spacing12;
  final double spacing16;
  final double spacing20;
  final double spacing24;
  final double spacing32;
  final double radius4;
  final double radius8;
  final double radius12;
  final double radius16;
  final double icon16;
  final double icon20;
  final double icon24;

  static const standard = AppDimensions(
    spacing4: 4,
    spacing8: 8,
    spacing12: 12,
    spacing16: 16,
    spacing20: 20,
    spacing24: 24,
    spacing32: 32,
    radius4: 4,
    radius8: 8,
    radius12: 12,
    radius16: 16,
    icon16: 16,
    icon20: 20,
    icon24: 24,
  );

  @override
  AppDimensions copyWith({
    double? spacing4,
    double? spacing8,
    double? spacing12,
    double? spacing16,
    double? spacing20,
    double? spacing24,
    double? spacing32,
    double? radius4,
    double? radius8,
    double? radius12,
    double? radius16,
    double? icon16,
    double? icon20,
    double? icon24,
  }) {
    return AppDimensions(
      spacing4: spacing4 ?? this.spacing4,
      spacing8: spacing8 ?? this.spacing8,
      spacing12: spacing12 ?? this.spacing12,
      spacing16: spacing16 ?? this.spacing16,
      spacing20: spacing20 ?? this.spacing20,
      spacing24: spacing24 ?? this.spacing24,
      spacing32: spacing32 ?? this.spacing32,
      radius4: radius4 ?? this.radius4,
      radius8: radius8 ?? this.radius8,
      radius12: radius12 ?? this.radius12,
      radius16: radius16 ?? this.radius16,
      icon16: icon16 ?? this.icon16,
      icon20: icon20 ?? this.icon20,
      icon24: icon24 ?? this.icon24,
    );
  }

  @override
  AppDimensions lerp(ThemeExtension<AppDimensions>? other, double t) {
    if (other is! AppDimensions) return this;
    return AppDimensions(
      spacing4: lerpDouble(spacing4, other.spacing4, t)!,
      spacing8: lerpDouble(spacing8, other.spacing8, t)!,
      spacing12: lerpDouble(spacing12, other.spacing12, t)!,
      spacing16: lerpDouble(spacing16, other.spacing16, t)!,
      spacing20: lerpDouble(spacing20, other.spacing20, t)!,
      spacing24: lerpDouble(spacing24, other.spacing24, t)!,
      spacing32: lerpDouble(spacing32, other.spacing32, t)!,
      radius4: lerpDouble(radius4, other.radius4, t)!,
      radius8: lerpDouble(radius8, other.radius8, t)!,
      radius12: lerpDouble(radius12, other.radius12, t)!,
      radius16: lerpDouble(radius16, other.radius16, t)!,
      icon16: lerpDouble(icon16, other.icon16, t)!,
      icon20: lerpDouble(icon20, other.icon20, t)!,
      icon24: lerpDouble(icon24, other.icon24, t)!,
    );
  }
}
