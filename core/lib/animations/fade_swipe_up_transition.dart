import 'package:flutter/material.dart';

import 'swipe_up_animation.dart';

class FadeSwipeUpTransition {
  static Widget transitionBuilder(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SwipeUpAnimation.transitionBuilder(child, animation),
    );
  }
}
