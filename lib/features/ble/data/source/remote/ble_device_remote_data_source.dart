import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/myo_band_device_info.dart';

abstract class BleDeviceRemoteDataSource {
  String get deviceId;

  Future<BleConnectionStatus> connect();

  Future<void> disconnect();

  VulcanDeviceType get deviceType;

  Future<MyoBandDeviceInfo> readMyoBandDeviceInfo();
}
