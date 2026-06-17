import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';

abstract class BleRepository {
  Stream<Either<Failure, BleAdapterStatus>> watchAdapterStatus();

  Stream<Either<Failure, List<BleDiscoveredDevice>>> watchScanResults();

  Future<Either<Failure, Unit>> startScan({List<VulcanDeviceType>? filterTypes});

  Future<Either<Failure, Unit>> stopScan();

  Future<Either<Failure, BleConnectionStatus>> connect(String deviceId);

  Future<Either<Failure, Unit>> disconnect();
}
