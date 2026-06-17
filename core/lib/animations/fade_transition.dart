import 'package:flutter/material.dart';

class FadeTransitionAnimation {
  static Widget transitionBuilder(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
