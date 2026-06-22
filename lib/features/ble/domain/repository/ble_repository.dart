import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

import '../entities/ble_device_info.dart';
import '../entities/ble_discovered_device.dart';
import '../entities/ble_device_stream_snapshot.dart';

abstract class BleRepository {
  Stream<Either<Failure, BleAdapterStatus>> watchAdapterStatus();

  Stream<Either<Failure, Map<String, BleDiscoveredDevice>>> watchScanResults();

  Stream<Either<Failure, BleDeviceStreamSnapshot>>? watchDeviceData(
    String deviceId,
  );

  Future<Either<Failure, Unit>> startScan({
    List<VulcanDeviceType>? filterTypes,
  });

  Future<Either<Failure, Unit>> stopScan();

  Future<Either<Failure, BleConnectionStatus>> connect(String deviceId);

  Future<Either<Failure, Unit>> disconnect(String deviceId);

  Future<Either<Failure, BleDeviceInfo>> readDeviceInfo(String deviceId);
}
