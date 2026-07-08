import 'package:get_it/get_it.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/ble_remote_data_source.dart';

import '../data/firmware_ble_transport.dart';
import '../data/remote/firmware_firebase_remote.dart';
import '../data/remote/firmware_remote_api.dart';
import '../data/repository/firmware_repository_impl.dart';
import '../domain/repository/firmware_repository.dart';
import '../domain/usecase/check_latest_firmware.dart';
import '../domain/usecase/execute_firmware_update.dart';
import '../presentation/bloc/firmware_update/firmware_update_bloc.dart';

const _firmwareApiBaseUrl = 'https://api.vulcan.placeholder';

Future<void> initFirmwareInjection(GetIt sl) async {
  if (sl.isRegistered<FirmwareRepository>()) return;

  sl.registerLazySingleton(FirmwareFirebaseRemote.new);
  sl.registerLazySingleton(() => FirmwareRemoteApi(baseUrl: _firmwareApiBaseUrl));
  sl.registerLazySingleton(
    () => FirmwareBleTransport(sl<BleRemoteDataSource>()),
  );

  sl.registerLazySingleton<FirmwareRepository>(
    () => FirmwareRepositoryImpl(
      firebaseRemote: sl(),
      restRemote: sl(),
      bleTransport: sl(),
    ),
  );

  sl.registerFactory(() => CheckLatestFirmware(repository: sl()));
  sl.registerFactory(() => ExecuteFirmwareUpdate(repository: sl()));
  sl.registerFactory(() => FirmwareUpdateBloc(checkLatestFirmware: sl()));
}
