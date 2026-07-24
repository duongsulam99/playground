/// Generic GATT read/write (keys from `core/ble/gatt/keys`).
abstract interface class GattAccess {
  Future<List<int>> readCharacteristic(String characteristicKey);

  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  });
}
