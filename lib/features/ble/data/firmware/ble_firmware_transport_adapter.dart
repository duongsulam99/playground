import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/features/firmware/data/firmware_ble_transport.dart';

import '../source/remote/impl.dart';

/// Cầu nối feature firmware ↔ BLE data layer.
///
/// Feature firmware chỉ biết [FirmwareBleTransport]; adapter delegate
/// xuống [BleRemoteDataSourceImpl] qua thiết bị đã connect.
class BleFirmwareTransportAdapter implements FirmwareBleTransport {
  const BleFirmwareTransportAdapter({required this._dataSource});

  final BleRemoteDataSourceImpl _dataSource;

  @override
  Future<void> writeOta(String deviceId, List<int> data, {int timeout = 15}) {
    return _dataSource
        .findDeviceConnected(deviceId)
        .writeCharacteristic(BleRingKey.ota, data, timeout: timeout);
  }

  @override
  Future<void> startFirmwareUpdate(String deviceId, bool enabled) {
    return _dataSource
        .findDeviceConnected(deviceId)
        .setUpdateFirmware(enabled);
  }

  @override
  Stream<List<int>> watchFirmwareUpdate(String deviceId) {
    return _dataSource
        .findDeviceConnected(deviceId)
        .watchUpdateNotifications();
  }

  @override
  int getCurrentMtu(String deviceId) {
    return _dataSource.findDeviceConnected(deviceId).getNegotiatedMtu();
  }

  @override
  String getDeviceId(String deviceId) => deviceId;
}
