import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_adv_uuids.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

/// Parses Vulcan device type from BLE advertisement data.
class BleAdvertisementParser {
  const BleAdvertisementParser._();

  static const String deviceTypeUuid = '0100';

  static VulcanDeviceType parse(AdvertisementData advertisementData) {
    for (final element in advertisementData.serviceUuids) {
      final uuidStr = element.str.toLowerCase();

      switch (uuidStr) {
        case BleAdvUuids.advUUIDHand:
          return VulcanDeviceType.hand;

        case BleAdvUuids.advUUIDCoaxial:
          return VulcanDeviceType.coaxial;

        case BleAdvUuids.advUUIDRing:
        case BleAdvUuids.advUUIDRingOld:
          final hardwareType = _hardwareIdFromAdv(advertisementData);
          if (hardwareType == VulcanDeviceType.none) {
            return VulcanDeviceType.ring;
          }
          return hardwareType;

        case BleAdvUuids.advUUIDSensorbox:
          return VulcanDeviceType.sensorBox;

        case BleAdvUuids.advUUIDElbow:
          final hardwareType = _hardwareIdFromAdv(advertisementData);
          if (hardwareType == VulcanDeviceType.none) {
            return VulcanDeviceType.bleAdapter;
          }
          return hardwareType;
      }
    }

    return VulcanDeviceType.none;
  }

  static VulcanDeviceType _hardwareIdFromAdv(AdvertisementData advertisementData) {
    final serviceData = advertisementData.serviceData[Guid(deviceTypeUuid)];
    if (serviceData == null) return VulcanDeviceType.none;

    var hardwareId = String.fromCharCodes(serviceData);
    hardwareId = hardwareId.replaceAll('\x00', '').trim().toUpperCase();
    if (hardwareId.isEmpty) return VulcanDeviceType.none;

    return VulcanDeviceType.fromHardwareId(hardwareId);
  }
}
