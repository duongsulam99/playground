import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';

// Figma viewport used as the design baseline.
const num figmaDesignWidth = 375;
const num figmaDesignHeight = 812;
const num figmaDesignStatusBar = 0;

typedef ResponsiveBuild = Widget Function(
  BuildContext context,
  Orientation orientation,
  DeviceType deviceType,
);

class Sizer extends StatelessWidget {
  const Sizer({
    super.key,
    required this.builder,
  });

  /// Rebuilds the tree when layout constraints or orientation change.
  final ResponsiveBuild builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeUtils.setScreenSize(constraints, orientation);
            return builder(context, orientation, SizeUtils.deviceType);
          },
        );
      },
    );
  }
}

class SizeUtils {
  static late BoxConstraints boxConstraints;
  static late Orientation orientation;
  static late DeviceType deviceType;
  static late double height;
  static late double width;
  static late bool isTablet;

  static bool _isInitialized = false;

  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
  ) {
    boxConstraints = constraints;
    orientation = currentOrientation;

    if (orientation == Orientation.portrait) {
      width = boxConstraints.maxWidth.nonZero(defaultValue: figmaDesignWidth);
      height = boxConstraints.maxHeight.nonZero();
    } else {
      width = boxConstraints.maxHeight.nonZero(defaultValue: figmaDesignWidth);
      height = boxConstraints.maxWidth.nonZero();
    }

    final diagonalPixels = sqrt(width * width + height * height);
    final diagonalInches = diagonalPixels / (Platform.isIOS ? 132 : 160);

    final aspectRatio = width / height;
    final isLargeScreen = diagonalInches > 7.0;
    final hasTabletAspectRatio = aspectRatio >= 0.65 && aspectRatio <= 1.5;

    deviceType = (isLargeScreen && hasTabletAspectRatio)
        ? DeviceType.tablet
        : DeviceType.mobile;

    isTablet = deviceType == DeviceType.tablet;
    _isInitialized = true;
  }

  static bool get isInitialized => _isInitialized;
}

extension ResponsiveExtension on num {
  double get _width => SizeUtils.width;

  double get _height => SizeUtils.height;

  /// Width scale based on Figma width.
  double get h => (this * _width) / figmaDesignWidth;

  /// Height scale based on Figma height.
  double get v => (this * _height) / (figmaDesignHeight - figmaDesignStatusBar);

  /// Adaptive size for icon/image by selecting the smallest axis.
  double get adaptSize {
    final scaledHeight = v;
    final scaledWidth = h;
    return scaledHeight < scaledWidth
        ? scaledHeight.toRounded()
        : scaledWidth.toRounded();
  }

  /// Font size scale using adaptive size.
  double get fSize => adaptSize;
}

extension FormatExtension on double {
  double toRounded({int fractionDigits = 2}) {
    final mod = pow(10, fractionDigits).toDouble();
    return (this * mod).roundToDouble() / mod;
  }

  double nonZero({num defaultValue = 0.0}) {
    return this > 0 ? this : defaultValue.toDouble();
  }
}

enum DeviceType { mobile, tablet, desktop }
