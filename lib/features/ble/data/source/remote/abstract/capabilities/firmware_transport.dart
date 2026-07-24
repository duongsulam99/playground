/// Firmware OTA transport over BLE (notify + MTU).
abstract interface class FirmwareTransport {
  Future<void> writeOta(List<int> data, {int timeout = 15});

  Future<void> setUpdateFirmware(bool enabled);

  Stream<List<int>> watchUpdateNotifications();

  int getNegotiatedMtu();
}
