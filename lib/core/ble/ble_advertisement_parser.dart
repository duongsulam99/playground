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
        // TODO: [Add New Device] Step 3: Thêm case so khớp UUID quảng cáo của thiết bị mới tại đây.
        // Nếu thiết bị cần định danh động (như Ring/Elbow qua serviceData),
        // gọi hàm phân giải hardwareId từ Adv.

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

  /// Function return Vulcan device type from Advertisement data
  /// NOTE: Chỉ dùng để phân biệt remoteId trong Advertisement data
  static VulcanDeviceType _hardwareIdFromAdv(
    AdvertisementData advertisementData,
  ) {
    /// Parse serviceData from advertisement
    final serviceData = advertisementData.serviceData[Guid(deviceTypeUuid)];
    if (serviceData == null) return VulcanDeviceType.none;

    /// Parse hardwareId from serviceData
    var hardwareId = String.fromCharCodes(serviceData);

    /// Remove null bytes
    hardwareId = hardwareId.replaceAll('\x00', '').trim().toUpperCase();
    if (hardwareId.isEmpty) return VulcanDeviceType.none;

    /// return Vulcan device type from hardwareId
    return VulcanDeviceType.fromHardwareId(hardwareId);
  }
}
