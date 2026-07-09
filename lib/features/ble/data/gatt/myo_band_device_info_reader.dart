import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/adapter/key.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_reader.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';

import '../../domain/entities/ble_device_info.dart';

class MyoBandDeviceInfoReader {
  static const logger = Logger(className: 'MyoBandDeviceInfoReader');

  static Future<BleDeviceInfo> read({
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
    final effectiveType = resolvedType == VulcanDeviceType.none
        ? scannedType
        : resolvedType;

    return BleDeviceInfo(
      name: name,
      firmwareVersion: firmwareVersion,
      hardwareId: hardwareId,
      resolvedType: effectiveType,
      batteryPercent: batteryPercent,
    );
  }
}
