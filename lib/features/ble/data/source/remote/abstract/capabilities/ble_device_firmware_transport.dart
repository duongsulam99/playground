/// Firmware OTA transport over BLE (notify + MTU).
abstract interface class BleDeviceFirmwareTransport {
  Future<void> writeOta(List<int> data, {int timeout = 15});

  Future<void> setUpdateFirmware(bool enabled);

  Stream<List<int>> watchUpdateNotifications();

  int getNegotiatedMtu();
}
