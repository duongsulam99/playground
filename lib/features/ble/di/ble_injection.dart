import 'package:get_it/get_it.dart';

import '../data/source/stream/ble_stream_decoder_factory.dart';
import '../data/repository/ble_repository_impl.dart';
import '../data/source/remote/ble_device_data_source_factory.dart';
import '../data/source/remote/ble_remote_data_source.dart';
import '../data/source/remote/flutter_blue_plus_data_source.dart';
import '../domain/repository/ble_repository.dart';
import '../domain/usecase/connect_device.dart';
import '../domain/usecase/disconnect_device.dart';
import '../domain/usecase/read_device_info.dart';
import '../domain/usecase/start_scan.dart';
import '../domain/usecase/stop_scan.dart';
import '../domain/usecase/watch_adapter_status.dart';
import '../domain/usecase/watch_device_connection.dart';
import '../domain/usecase/watch_device_data.dart';
import '../domain/usecase/watch_scan_results.dart';
import '../presentation/bloc/ble/ble_bloc.dart';

void initBleInjection(GetIt sl) {
  if (sl.isRegistered<BleBloc>()) return;

  sl.registerFactory(BleDeviceDataSourceFactory.new);
  sl.registerFactory(BleStreamDecoderFactory.new);

  sl.registerLazySingleton<BleRemoteDataSource>(
    () => FlutterBluePlusDataSource(
      deviceFactory: sl(),
      decoderFactory: sl(),
    ),
  );

  sl.registerLazySingleton<BleRepository>(
    () => BleRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => WatchAdapterStatus(repository: sl()));
  sl.registerFactory(() => WatchScanResults(repository: sl()));
  sl.registerFactory(() => WatchDeviceData(repository: sl()));
  sl.registerFactory(() => WatchDeviceConnection(repository: sl()));
  sl.registerFactory(() => StartScan(repository: sl()));
  sl.registerFactory(() => StopScan(repository: sl()));
  sl.registerFactory(() => ConnectDevice(repository: sl()));
  sl.registerFactory(() => DisconnectDevice(repository: sl()));
  sl.registerFactory(() => ReadDeviceInfo(repository: sl()));

  sl.registerLazySingleton<BleBloc>(
    () => BleBloc(
      watchAdapterStatus: sl(),
      watchScanResults: sl(),
      watchDeviceData: sl(),
      watchDeviceConnection: sl(),
      startScan: sl(),
      stopScan: sl(),
      connectDevice: sl(),
      disconnectDevice: sl(),
      readDeviceInfo: sl(),
    ),
  );

  sl<BleBloc>();
}
