import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

class BleGattReader {
  const BleGattReader._();

  static Future<List<int>> read(
    Map<String, BluetoothCharacteristic> characteristics,
    String key,
  ) async {
    final characteristic = characteristics[key];

    /// If the characteristic is not found, throw an exception
    if (characteristic == null) {
      throw BleCharacteristicNotFoundException('Characteristic $key not found');
    }

    return characteristic.read();
  }
}
