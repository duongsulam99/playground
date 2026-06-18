import 'package:get_it/get_it.dart';
import 'package:vulcan_mobile_playground/features/ble/data/repository/ble_repository_impl.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/ble_device_data_source_factory.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/ble_remote_data_source.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/flutter_blue_plus_data_source.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/connect_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/disconnect_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/start_scan.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/stop_scan.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/watch_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/watch_scan_results.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_bloc.dart';

void initBleInjection(GetIt sl) {
  if (sl.isRegistered<BleBloc>()) return;

  sl.registerFactory(BleDeviceDataSourceFactory.new);

  sl.registerLazySingleton<BleRemoteDataSource>(
    () => FlutterBluePlusDataSource(deviceFactory: sl()),
  );

  sl.registerLazySingleton<BleRepository>(
    () => BleRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => WatchAdapterStatus(repository: sl()));
  sl.registerFactory(() => WatchScanResults(repository: sl()));
  sl.registerFactory(() => StartScan(repository: sl()));
  sl.registerFactory(() => StopScan(repository: sl()));
  sl.registerFactory(() => ConnectDevice(repository: sl()));
  sl.registerFactory(() => DisconnectDevice(repository: sl()));

  sl.registerLazySingleton<BleBloc>(
    () => BleBloc(
      watchAdapterStatus: sl(),
      watchScanResults: sl(),
      startScan: sl(),
      stopScan: sl(),
      connectDevice: sl(),
      disconnectDevice: sl(),
    ),
  );

  sl<BleBloc>();
}
