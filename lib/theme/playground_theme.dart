import 'package:flutter_supper_app_core/core.dart';

import 'playground_theme_config.dart';

final class PlaygroundTheme {
  const PlaygroundTheme._();

  // ── Predefined themes ──
  static final ThemeData light = AppTheme.buildFrom(
    PlaygroundThemeConfig.config,
    Brightness.light,
  );
  static final ThemeData dark = AppTheme.buildFrom(
    PlaygroundThemeConfig.config,
    Brightness.dark,
  );
}
