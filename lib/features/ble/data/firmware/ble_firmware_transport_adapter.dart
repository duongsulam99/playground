import 'package:vulcan_mobile_playground/features/firmware/data/firmware_ble_transport.dart';

import '../source/remote/abstract/ble_remote_data_source.dart';

/// Cầu nối feature firmware ↔ BLE data layer.
///
/// Feature firmware chỉ biết [FirmwareBleTransport]; adapter delegate
/// xuống [BleRemoteDataSource] qua thiết bị đã connect.
class BleFirmwareTransportAdapter implements FirmwareBleTransport {
  const BleFirmwareTransportAdapter({required this._dataSource});

  final BleRemoteDataSource _dataSource;

  @override
  Future<void> writeOta(String deviceId, List<int> data, {int timeout = 15}) {
    return _dataSource
        .findConnectedDevice(deviceId)
        .writeOta(data, timeout: timeout);
  }

  @override
  Future<void> startFirmwareUpdate(String deviceId, bool enabled) {
    return _dataSource
        .findConnectedDevice(deviceId)
        .setUpdateFirmware(enabled);
  }

  @override
  Stream<List<int>> watchFirmwareUpdate(String deviceId) {
    return _dataSource
        .findConnectedDevice(deviceId)
        .watchUpdateNotifications();
  }

  @override
  int getCurrentMtu(String deviceId) {
    return _dataSource.findConnectedDevice(deviceId).getNegotiatedMtu();
  }

  @override
  String getDeviceId(String deviceId) => deviceId;
}
