import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

abstract class BleDeviceRemoteDataSource {
  String get deviceId;

  Future<BleConnectionStatus> connect();

  Future<void> disconnect();
}
