import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';

import '../../ble/data/source/remote/ble_remote_data_source.dart';

class FirmwareBleTransport {
  const FirmwareBleTransport(this._bleRemoteDataSource);

  final BleRemoteDataSource _bleRemoteDataSource;

  Future<void> writeOta(String deviceId, List<int> data, {int timeout = 15}) {
    return _bleRemoteDataSource.writeCharacteristic(
      deviceId,
      BleRingKey.ota,
      data,
      timeout: timeout,
    );
  }

  Future<void> setUpdateFirmware(String deviceId, bool enabled) {
    return _bleRemoteDataSource.setUpdateFirmware(deviceId, enabled);
  }

  Stream<List<int>> watchUpdateNotifications(String deviceId) {
    return _bleRemoteDataSource.watchUpdateNotifications(deviceId);
  }

  int getNegotiatedMtu(String deviceId) {
    return _bleRemoteDataSource.getNegotiatedMtu(deviceId);
  }

  String getBleDeviceId(String deviceId) => deviceId;
}
