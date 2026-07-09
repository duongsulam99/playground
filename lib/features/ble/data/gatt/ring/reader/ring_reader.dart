import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_reader.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/adapter/key.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';

import '../../../model/ble_device_info_model.dart';

/// Đọc metadata MyoBand/Ring qua GATT — logic đặc thù thiết bị, tách khỏi device source.
class GattRingReader {
  static const logger = Logger(className: 'GattRingReader');

  static Future<BleDeviceInfoModel> readInfo({
    required Map<String, BluetoothCharacteristic> characteristics,
    required VulcanDeviceType scannedType,
  }) async {
    final nameBytes = await BleGattReader.read(
      characteristics,
      BleAdapterKey.nameChar,
    );
    final versionBytes = await BleGattReader.read(
      characteristics,
      BleAdapterKey.ota,
    );
    final hardwareBytes = await BleGattReader.read(
      characteristics,
      BleAdapterKey.hardwareChar,
    );
    final batteryBytes = await BleGattReader.read(
      characteristics,
      BleAdapterKey.battery,
    );

    final name = BleValueDecoders.decodeUtf8(nameBytes);
    final firmwareVersion = BleValueDecoders.decodeUtf8(versionBytes);
    final hardwareId = BleValueDecoders.decodeHardwareId(hardwareBytes);
    final batteryPercent = BleValueDecoders.decodeBatteryPercent(batteryBytes);
    final resolvedType = VulcanDeviceType.fromHardwareId(hardwareId);

    // Hardware ID đáng tin hơn advertisement; fallback loại từ scan.
    final effectiveType = resolvedType == VulcanDeviceType.none
        ? scannedType
        : resolvedType;

    final threshold = await readThreshold(characteristics);

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
