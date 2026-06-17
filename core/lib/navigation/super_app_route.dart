import 'package:flutter/material.dart';

import 'super_app_error_page.dart';

/// Base routing for super-app: shared transition + template [onGenerateRoute].
///
/// Subclasses implement [resolveRoute] for known names; unhandled names use
/// [unknownRoute] (defaults to [SuperAppErrorPage] inside [transitionAnimation]).
abstract class SuperAppRoute {
  PageRouteBuilder<dynamic> transitionAnimation({
    required Widget child,
    required String routeName,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween<Offset>(begin: begin, end: end);
        final offsetAnimation = animation.drive(
          tween.chain(CurveTween(curve: curve)),
        );

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  /// Return a route for [settings.name], or `null` if this router does not handle it.
  Route<dynamic>? resolveRoute(RouteSettings settings);

  Route<dynamic> unknownRoute(RouteSettings settings) {
    final name = settings.name ?? '/unknown';
    return transitionAnimation(
      child: const SuperAppErrorPage(),
      routeName: name,
    );
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final resolved = resolveRoute(settings);
    if (resolved != null) return resolved;
    return null;
  }
}
