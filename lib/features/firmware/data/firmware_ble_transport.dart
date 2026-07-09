abstract class FirmwareBleTransport {
  Future<void> writeOta(String deviceId, List<int> data, {int timeout = 15});

  Future<void> startFirmwareUpdate(String deviceId, bool enabled);

  Stream<List<int>> watchFirmwareUpdate(String deviceId);

  int getCurrentMtu(String deviceId);

  String getDeviceId(String deviceId);
}
