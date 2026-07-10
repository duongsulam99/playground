import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_adv_uuids.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../../features/ble/data/source/isolate/scan/scan_advertisement_dto.dart';

/// Parses Vulcan device type from BLE advertisement data (isolate-safe).
class BleAdvertisementParser {
  const BleAdvertisementParser._();

  static const String deviceTypeUuid = '0100';
  static const _logger = Logger(className: 'BleAdvertisementParser');

  static VulcanDeviceType parseFromDto(ScanAdvertisementDto dto) {
    for (final uuidStr in dto.serviceUuids) {
      _logger.debug('parseFromDto', uuidStr);
      switch (uuidStr) {
        //TODO:[Add New Device] Step 3: Thêm case so khớp Adv UUID của thiết bị mới

        case BleAdvUuids.advUUIDHand:
          return VulcanDeviceType.hand;

        case BleAdvUuids.advUUIDCoaxial:
          return VulcanDeviceType.coaxial;

        case BleAdvUuids.advUUIDRing:
        case BleAdvUuids.advUUIDRingOld:
          final hardwareType = _hardwareIdFromDto(dto);
          if (hardwareType == VulcanDeviceType.none) {
            return VulcanDeviceType.ring;
          }
          return hardwareType;

        case BleAdvUuids.advUUIDSensorbox:
          return VulcanDeviceType.sensorBox;

        case BleAdvUuids.advUUIDElbow:
          final hardwareType = _hardwareIdFromDto(dto);
          if (hardwareType == VulcanDeviceType.none) {
            return VulcanDeviceType.bleAdapter;
          }
          return hardwareType;
      }
    }

    return VulcanDeviceType.none;
  }

  static VulcanDeviceType _hardwareIdFromDto(ScanAdvertisementDto dto) {
    final serviceData = dto.serviceData[deviceTypeUuid];
    if (serviceData == null) return VulcanDeviceType.none;

    // Parse hardwareId from serviceData
    var hardwareId = String.fromCharCodes(serviceData);

    // Remove null bytes
    hardwareId = hardwareId.replaceAll('\x00', '').trim().toUpperCase();
    if (hardwareId.isEmpty) return VulcanDeviceType.none;

    // Return Vulcan device type from hardwareId
    return VulcanDeviceType.fromHardwareId(hardwareId);
  }
}
