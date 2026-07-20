import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'abstract/ble_device_capabilities.dart';
import 'ble_device_runtime.dart';

/// Implementation mặc định cho mọi thiết bị Vulcan (GATT + connect + OTA).
///
/// Stream/info cụ thể do implementation riêng compose [BleDeviceRuntime]
/// (vd. [VulcanMyoBandDevice]).
class BleDeviceRemoteDataSourceImpl implements BleDeviceRemoteDataSource {
  BleDeviceRemoteDataSourceImpl({required this._runtime});

  BleDeviceRemoteDataSourceImpl.fromDevice({
    required BluetoothDevice device,
    required VulcanDeviceType deviceType,
  }) : _runtime = BleDeviceRuntime(device: device, deviceType: deviceType);

  final BleDeviceRuntime _runtime;

  @override
  String get deviceId => _runtime.deviceId;

  @override
  VulcanDeviceType get deviceType => _runtime.deviceType;

  @override
  BleDeviceStreaming? get streaming => null;

  @override
  BleDeviceInfoSource? get info => null;

  @override
  Stream<BleConnectionStatus> watchConnectionStatus() =>
      _runtime.watchConnectionStatus();

  @override
  Future<BleConnectionStatus> connect() => _runtime.connect();

  @override
  Future<void> disconnect() => _runtime.disconnect();

  @override
  Future<List<int>> readCharacteristic(String characteristicKey) =>
      _runtime.readCharacteristic(characteristicKey);

  @override
  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  }) => _runtime.writeCharacteristic(characteristicKey, data, timeout: timeout);

  @override
  Future<void> setUpdateFirmware(bool enabled) =>
      _runtime.setUpdateFirmware(enabled);

  @override
  Stream<List<int>> watchUpdateNotifications() =>
      _runtime.watchUpdateNotifications();

  @override
  int getNegotiatedMtu() => _runtime.getNegotiatedMtu();
}
