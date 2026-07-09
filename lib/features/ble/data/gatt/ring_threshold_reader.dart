import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_reader.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';

class RingThresholdReader {
  const RingThresholdReader._();

  static Future<RingThresholdConfig?> read(
    Map<String, BluetoothCharacteristic> characteristics,
  ) async {
    if (!characteristics.containsKey(BleRingKey.threshold)) {
      return null;
    }

    final bytes = await BleGattReader.read(
      characteristics,
      BleRingKey.threshold,
    );

    return BleValueDecoders.decodeRingThreshold(bytes);
  }
}
