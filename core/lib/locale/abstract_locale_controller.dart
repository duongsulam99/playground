import 'package:flutter/material.dart';

/// Contract for the app's active [Locale] and locale changes.
///
/// Extends [ValueNotifier] so widgets can listen via [ListenableBuilder].
abstract class AbstractLocaleController extends ValueNotifier<Locale> {
  AbstractLocaleController(super.initialLocale);

  static const supportedLocales = <Locale>[Locale('vi'), Locale('en')];
  static const fallback = Locale('vi');

  /// Switches the app locale and persists the choice.
  Future<void> setLocale(Locale locale);
}
