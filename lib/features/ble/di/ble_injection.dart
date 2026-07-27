import 'package:get_it/get_it.dart';

import '../data/firmware/ble_firmware_transport_adapter.dart';
import '../data/source/isolate/decode/decode_worker.dart';
import '../data/source/isolate/scan/scan_parse_worker.dart';
import '../data/repository/ble_repository_impl.dart';
import '../data/source/remote/device_factory.dart';
import '../data/source/remote/abstract/ble_remote_data_source.dart';
import '../data/source/remote/ble_remote_data_source_impl.dart';
import '../domain/repository/ble_repository.dart';
import '../domain/usecase/connect_device.dart';
import '../domain/usecase/disconnect_device.dart';
import '../domain/usecase/read_device_info.dart';
import '../domain/usecase/start_device_stream.dart';
import '../domain/usecase/start_scan.dart';
import '../domain/usecase/stop_device_stream.dart';
import '../domain/usecase/stop_scan.dart';
import '../domain/usecase/watch_adapter_status.dart';
import '../domain/usecase/watch_battery.dart';
import '../domain/usecase/watch_device_connection.dart';
import '../domain/usecase/watch_device_data.dart';
import '../domain/usecase/watch_scan_results.dart';
import '../presentation/bloc/device/ble_device_bloc.dart';
import '../presentation/bloc/device/ble_device_bloc_registry.dart';
import '../presentation/bloc/manager/ble_manager_bloc.dart';

// Firmware transport adapter
/// Is used to adapt the firmware transport interface
/// to the underlying BLE data source implementation.
import '../../firmware/data/firmware_ble_transport.dart';

Future<void> initBleInjection(GetIt sl) async {
  if (sl.isRegistered<BleManagerBloc>()) return;

  sl.registerSingletonAsync<StreamDecodeWorker>(StreamDecodeWorker.create);
  sl.registerSingletonAsync<ScanParseWorker>(ScanParseWorker.create);

  sl.registerFactory(
    () => BleDeviceDataSourceFactory(decodeWorker: sl<StreamDecodeWorker>()),
  );

  sl.registerLazySingleton<BleRemoteDataSourceImpl>(
    () => BleRemoteDataSourceImpl(
      deviceFactory: sl(),
      scanParseWorker: sl<ScanParseWorker>(),
    ),
  );

  sl.registerLazySingleton<BleRemoteDataSource>(
    () => sl<BleRemoteDataSourceImpl>(),
  );

  sl.registerLazySingleton<FirmwareBleTransport>(
    () => BleFirmwareTransportAdapter(dataSource: sl<BleRemoteDataSource>()),
  );

  sl.registerLazySingleton<BleRepository>(
    () => BleRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => WatchAdapterStatus(repository: sl()));
  sl.registerFactory(() => WatchScanResults(repository: sl()));
  sl.registerFactory(() => WatchDeviceData(repository: sl()));
  sl.registerFactory(() => WatchDeviceConnection(repository: sl()));
  sl.registerFactory(() => WatchBattery(repository: sl()));
  sl.registerFactory(() => StartScan(repository: sl()));
  sl.registerFactory(() => StopScan(repository: sl()));
  sl.registerFactory(() => ConnectDevice(repository: sl()));
  sl.registerFactory(() => DisconnectDevice(repository: sl()));
  sl.registerFactory(() => ReadDeviceInfo(repository: sl()));
  sl.registerFactory(() => StartDeviceStream(repository: sl()));
  sl.registerFactory(() => StopDeviceStream(repository: sl()));

  sl.registerFactoryParam<BleDeviceBloc, BleDeviceBlocArgs, void>(
    (args, _) => BleDeviceBloc(
      deviceId: args.deviceId,
      scannedType: args.scannedType,
      watchDeviceData: sl(),
      watchBattery: sl(),
      readDeviceInfo: sl(),
      startDeviceStream: sl(),
      stopDeviceStream: sl(),
    ),
  );

  sl.registerLazySingleton<BleDeviceBlocRegistry>(
    () => BleDeviceBlocRegistry(
      createBloc: ({required deviceId, required scannedType}) =>
          sl<BleDeviceBloc>(
            param1: BleDeviceBlocArgs(
              deviceId: deviceId,
              scannedType: scannedType,
            ),
          ),
    ),
  );

  sl.registerLazySingleton<BleManagerBloc>(
    () => BleManagerBloc(
      watchAdapterStatus: sl(),
      watchScanResults: sl(),
      watchDeviceConnection: sl(),
      startScan: sl(),
      stopScan: sl(),
      connectDevice: sl(),
      disconnectDevice: sl(),
      deviceRegistry: sl(),
    ),
  );

  await sl.allReady();
  sl<BleManagerBloc>();
}
