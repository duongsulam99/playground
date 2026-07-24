import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../entities/ble_battery_snapshot.dart';
import '../entities/ble_device_info.dart';
import '../entities/ble_device_stream_snapshot.dart';
import '../entities/ble_scan_snapshot.dart';

abstract class BleRepository {
  Stream<Either<Failure, BleAdapterStatus>> watchAdapterStatus();

  Stream<Either<Failure, BleScanSnapshot>> watchScanResults();

  Stream<Either<Failure, BleDeviceStreamSnapshot>> watchDeviceData(
    String deviceId,
  );

  Stream<Either<Failure, BleBatterySnapshot>> watchBattery(String deviceId);

  Stream<Either<Failure, BleConnectionStatus>> watchConnectionStatus(
    String deviceId,
  );

  Future<Either<Failure, Unit>> startScan({
    List<VulcanDeviceType>? filterTypes,
  });

  Future<Either<Failure, Unit>> stopScan();

  Future<Either<Failure, BleConnectionStatus>> connect(String deviceId);

  Future<Either<Failure, Unit>> disconnect(String deviceId);

  Future<Either<Failure, BleDeviceInfo>> readDeviceInfo(String deviceId);

  Future<Either<Failure, Unit>> startDeviceStream(String deviceId);

  Future<Either<Failure, Unit>> stopDeviceStream(String deviceId);
}
