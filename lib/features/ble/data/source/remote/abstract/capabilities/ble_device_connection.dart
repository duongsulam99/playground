import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

/// Connection lifecycle for a single BLE device instance.
abstract interface class BleDeviceConnection {
  String get deviceId;

  VulcanDeviceType get deviceType;

  Stream<BleConnectionStatus> watchConnectionStatus();

  Future<BleConnectionStatus> connect();

  Future<void> disconnect();
}
