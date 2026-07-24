import 'package:flutter/foundation.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'abstract/capabilities/index.dart';
import 'abstract/device_remote_datasrc.dart';
import 'ble_device_runtime.dart';
import 'device/ring/index.dart';

/// Base cho mọi [BleDeviceRemoteDataSource]: delegate mandatory capabilities
/// xuống [BleDeviceRuntime]. Subclass chỉ override optional capabilities
/// (streaming, info, ringSession) và hook lifecycle.
abstract base class BaseBleDeviceRemoteDataSource implements DeviceRemoteDS {
  BaseBleDeviceRemoteDataSource(this.runtime);

  @protected
  final BleDeviceRuntime runtime;

  @override
  DataStreaming? get streaming => null;

  @override
  InfoSource? get info => null;

  @override
  BleRingDeviceSession? get ringSession => null;

  @override
  String get deviceId => runtime.deviceId;

  @override
  VulcanDeviceType get deviceType => runtime.deviceType;

  @override
  Stream<BleConnectionStatus> watchConnectionStatus() =>
      runtime.watchConnectionStatus();

  @override
  Future<BleConnectionStatus> connect() async {
    final status = await runtime.connect();
    await onAfterConnect();
    return status;
  }

  @override
  Future<void> disconnect() async {
    await onBeforeDisconnect();
    await runtime.disconnect();
  }

  /// Hook sau GATT ready — subclass bật passive monitors (battery, …).
  @protected
  Future<void> onAfterConnect() async {}

  /// Hook cho subclass dọn tài nguyên trước khi ngắt kết nối.
  @protected
  Future<void> onBeforeDisconnect() async {}

  @override
  Future<List<int>> readCharacteristic(String characteristicKey) =>
      runtime.readCharacteristic(characteristicKey);

  @override
  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  }) => runtime.writeCharacteristic(characteristicKey, data, timeout: timeout);

  @override
  Future<void> writeOta(List<int> data, {int timeout = 15}) =>
      runtime.writeOta(data, timeout: timeout);

  @override
  Future<void> setUpdateFirmware(bool enabled) =>
      runtime.setUpdateFirmware(enabled);

  @override
  Stream<List<int>> watchUpdateNotifications() =>
      runtime.watchUpdateNotifications();

  @override
  int getNegotiatedMtu() => runtime.getNegotiatedMtu();
}
