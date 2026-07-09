import 'package:get_it/get_it.dart';

import '../data/firmware/ble_firmware_transport_adapter.dart';
import '../data/source/isolate/stream_decode/ble_stream_decode_isolate.dart';
import '../data/repository/ble_repository_impl.dart';
import '../data/source/remote/device_factory.dart';
import '../data/source/remote/abstract/ble_remote_data_source.dart';
import '../data/source/remote/impl.dart';
import '../domain/repository/ble_repository.dart';
import '../domain/usecase/connect_device.dart';
import '../domain/usecase/disconnect_device.dart';
import '../domain/usecase/read_device_info.dart';
import '../domain/usecase/start_device_stream.dart';
import '../domain/usecase/start_scan.dart';
import '../domain/usecase/stop_device_stream.dart';
import '../domain/usecase/stop_scan.dart';
import '../domain/usecase/watch_adapter_status.dart';
import '../domain/usecase/watch_device_connection.dart';
import '../domain/usecase/watch_device_data.dart';
import '../domain/usecase/watch_scan_results.dart';
import '../presentation/bloc/ble/ble_bloc.dart';

// Firmware transport adapter
/// Is used to adapt the firmware transport interface 
/// to the underlying BLE data source implementation.
import '../../firmware/data/firmware_ble_transport.dart';

Future<void> initBleInjection(GetIt sl) async {
  if (sl.isRegistered<BleBloc>()) return;

  sl.registerFactory(BleDeviceDataSourceFactory.new);
  sl.registerSingletonAsync<BleStreamDecodeIsolate>(
    BleStreamDecodeIsolate.create,
  );

  sl.registerLazySingleton<BleRemoteDataSourceImpl>(
    () => BleRemoteDataSourceImpl(
      deviceFactory: sl(),
      decodeIsolate: sl<BleStreamDecodeIsolate>(),
    ),
  );

  sl.registerLazySingleton<BleRemoteDataSource>(
    () => sl<BleRemoteDataSourceImpl>(),
  );

  sl.registerLazySingleton<FirmwareBleTransport>(
    () => BleFirmwareTransportAdapter(
      dataSource: sl<BleRemoteDataSourceImpl>(),
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
  sl.registerFactory(() => StartDeviceStream(repository: sl()));
  sl.registerFactory(() => StopDeviceStream(repository: sl()));

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
      startDeviceStream: sl(),
      stopDeviceStream: sl(),
    ),
  );

  await sl.allReady();
  sl<BleBloc>();
}
