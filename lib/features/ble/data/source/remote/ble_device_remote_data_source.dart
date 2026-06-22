import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../model/ble_device_info.dart';

abstract class BleDeviceRemoteDataSource {
  String get deviceId;

  VulcanDeviceType get deviceType;

  Future<BleConnectionStatus> connect();

  Future<void> disconnect();

  Future<BleDeviceInfoModel> readDeviceInfo();

  Future<void> Function()? get onNotifyListening;

  Future<void> Function()? get onNotifyStopListening;
}
