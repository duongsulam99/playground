import 'package:flutter/material.dart';

import '../../animations/scale_transition.dart';

class AnimatedLoading extends StatelessWidget {
  const AnimatedLoading({
    required this.child,
    required this.color,
    super.key,
    required this.isLoading,
    this.indicatorSize = 24,
    this.strokeWidth = 2.5,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder = ScaleTransitionAnimation.transitionBuilder,
  });

  final Widget child;
  final bool isLoading;
  final Color color;
  final double indicatorSize;
  final double strokeWidth;
  final Duration duration;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: transitionBuilder,
      child: isLoading
          ? _LoadingOverlay(
              key: const ValueKey('animated_loading'),
              color: color,
              indicatorSize: indicatorSize,
              strokeWidth: strokeWidth,
              child: child,
            )
          : KeyedSubtree(
              key: const ValueKey('animated_content'),
              child: child,
            ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({
    required this.color,
    required this.indicatorSize,
    required this.strokeWidth,
    required this.child,
    super.key,
  });

  final Widget child;
  final Color color;
  final double indicatorSize;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // invisible child to stabilize animation
        Opacity(opacity: 0.0, child: child),

        // loading indicator
        SizedBox(
          height: indicatorSize,
          width: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
