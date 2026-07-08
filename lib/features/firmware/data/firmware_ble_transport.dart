import '../../ble/data/source/remote/ble_remote_data_source.dart';

class FirmwareBleTransport {
  const FirmwareBleTransport(this._bleRemoteDataSource);

  final BleRemoteDataSource _bleRemoteDataSource;

  Future<List<int>> readOta(String deviceId) {
    return _bleRemoteDataSource.readOtaCharacteristic(deviceId);
  }

  Future<void> writeOta(String deviceId, List<int> data, {int timeout = 15}) {
    return _bleRemoteDataSource.writeOtaCharacteristic(
      deviceId,
      data,
      timeout: timeout,
    );
  }

  Future<void> setOtaNotifyEnabled(String deviceId, bool enabled) {
    return _bleRemoteDataSource.setOtaNotifyEnabled(deviceId, enabled);
  }

  Stream<List<int>> watchOtaNotifications(String deviceId) {
    return _bleRemoteDataSource.watchOtaNotifications(deviceId);
  }

  int getNegotiatedMtu(String deviceId) {
    return _bleRemoteDataSource.getNegotiatedMtu(deviceId);
  }

  String getBleDeviceId(String deviceId) => deviceId;
}
