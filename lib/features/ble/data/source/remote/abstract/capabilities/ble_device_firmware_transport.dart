/// Firmware OTA transport over BLE (notify + MTU).
abstract interface class BleDeviceFirmwareTransport {
  Future<void> setUpdateFirmware(bool enabled);

  Stream<List<int>> watchUpdateNotifications();

  int getNegotiatedMtu();
}
