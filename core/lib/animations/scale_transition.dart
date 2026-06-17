import 'package:flutter/material.dart';

class ScaleTransitionAnimation {
  static Widget transitionBuilder(
    Widget child,
    Animation<double> animation,
  ) {
    return ScaleTransition(scale: animation, child: child);
  }
}
