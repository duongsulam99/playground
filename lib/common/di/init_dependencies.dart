import 'package:flutter_supper_app_core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:vulcan_mobile_playground/common/local/hive_manager.dart';
import 'package:vulcan_mobile_playground/l10n/locale/locale_controller.dart';
import 'package:vulcan_mobile_playground/l10n/locale/locale_repository.dart';

import '../../features/ble/di/ble_injection.dart';
import '../../features/firmware/di/firmware_injection.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  serviceLocator.registerLazySingleton<AbstractLocaleRepository>(
    () => LocaleRepository(settingsBox: HiveManager.settingsBox),
  );
  serviceLocator.registerLazySingleton<AbstractLocaleController>(
    () => LocaleController(
      repository: serviceLocator<AbstractLocaleRepository>(),
    ),
  );

  await initBleInjection(serviceLocator);
  await initFirmwareInjection(serviceLocator);
}
