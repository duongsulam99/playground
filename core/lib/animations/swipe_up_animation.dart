import 'package:flutter/material.dart';

class SwipeUpAnimation {
  static Widget transitionBuilder(
    Widget child,
    Animation<double> animation,
  ) {
    final isExiting = animation.status == AnimationStatus.reverse;

    final Tween<Offset> slideTween = isExiting
        ? Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          )
        : Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          );

    return SlideTransition(
      position: slideTween.animate(animation),
      child: child,
    );
  }
}
