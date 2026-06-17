import 'package:flutter_supper_app_core/core.dart';

import 'app.dart';
import 'common/di/init_dependencies.dart';
import 'common/local/hive_manager.dart';

Future<void> bootstrap() async {
  final Logger logger = const Logger(className: 'bootstrap');

  await runZonedGuarded(
    () async {
      await initializeApp();
    },
    (error, stackTrace) {
      logger.error('bootstrap', 'Uncaught error: $error\n$stackTrace');
    },
  );
}

Future<void> initializeApp() async {
  // Initialize Hive
  await HiveManager.init();

  // Initialize dependencies
  await initDependencies();

  // Run app
  runApp(const MyApp());
}
