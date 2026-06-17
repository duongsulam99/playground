import 'package:flutter/material.dart';

/// Default unknown-route screen for super-app shell (no app-specific imports).
class SuperAppErrorPage extends StatelessWidget {
  const SuperAppErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Route not found.'),
      ),
    );
  }
}
