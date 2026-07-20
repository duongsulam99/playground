import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../model/ble_device_info_model.dart';
import '../../../source/remote/abstract/capabilities/ble_device_gatt_access.dart';

/// Đọc metadata MyoBand/Ring qua GATT — logic đặc thù thiết bị, tách khỏi device source.
class GattRingReader {
  static const logger = Logger(className: 'GattRingReader');

  static Future<BleDeviceInfoModel> readInfo({
    required BleDeviceGattAccess gatt,
    required VulcanDeviceType scannedType,
  }) async {
    final nameBytes = await gatt.readCharacteristic(BleRingKey.nameChar);
    final versionBytes = await gatt.readCharacteristic(BleRingKey.ota);
    final hardwareBytes = await gatt.readCharacteristic(BleRingKey.hardwareChar);
    final batteryBytes = await gatt.readCharacteristic(BleRingKey.battery);

    final name = BleValueDecoders.decodeUtf8(nameBytes);
    final firmwareVersion = BleValueDecoders.decodeUtf8(versionBytes);
    final hardwareId = BleValueDecoders.decodeHardwareId(hardwareBytes);
    final batteryPercent = BleValueDecoders.decodeBatteryPercent(batteryBytes);
    final resolvedType = VulcanDeviceType.fromHardwareId(hardwareId);

    final effectiveType = resolvedType == VulcanDeviceType.none
        ? scannedType
        : resolvedType;

    final threshold = await readThreshold(gatt);

    return BleDeviceInfoModel(
      name: name,
      firmwareVersion: firmwareVersion,
      hardwareId: hardwareId,
      resolvedType: effectiveType,
      batteryPercent: batteryPercent,
      thresholdConfig: threshold,
    );
  }

  /// Trả `null` khi thiết bị không có characteristic threshold.
  static Future<RingThresholdConfig?> readThreshold(
    BleDeviceGattAccess gatt,
  ) async {
    try {
      final bytes = await gatt.readCharacteristic(BleRingKey.threshold);
      return BleValueDecoders.decodeRingThreshold(bytes);
    } on BleCharacteristicNotFoundException {
      return null;
    }
  }
}
