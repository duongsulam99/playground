import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

/// Advertisement service UUIDs used for BLE scan filtering (Vulcan devices).
class BleAdvUuids {
  const BleAdvUuids._();

  static const String advUUIDHand = '390950ed-51ff-445f-a6c6-f6a95a6a465f';
  static const String advUUIDElbow = '546afe6a-6299-11ee-8c99-0242ac120002';
  static const String advUUIDCoaxial = 'd0232816-a375-46fa-a4a6-f062bdc1de2a';
  static const String advUUIDRing = 'db1df223-4020-4c5a-930c-1989ea04991f';
  static const String advUUIDSensorbox =
      'ffee1404-bbaa-9988-7766-554433221100';
  static const String advUUIDBleadapter =
      '546afe6a-6299-11ee-8c99-0242ac120002';

  /// Old ring firmware (< 0.7).
  static const String advUUIDRingOld = 'efedd9eb-24a9-492a-b66a-ed8543ee096e';

  static const List<String> allAdvUuids = <String>[
    advUUIDHand,
    advUUIDElbow,
    advUUIDCoaxial,
    advUUIDRing,
    advUUIDRingOld,
    advUUIDSensorbox,
    advUUIDBleadapter,
  ];

  /// All Vulcan advertisement UUIDs for unfiltered scan.
  static List<Guid> allVulcanScanGuids() {
    return allAdvUuids.map(Guid.new).toList();
  }

  /// Maps [types] to native scan service UUIDs (deduplicated).
  static List<Guid> scanGuidsForDeviceTypes(List<VulcanDeviceType> types) {
    final addedUuids = <String>{};
    final guids = <Guid>[];

    void addUuid(String uuid) {
      if (addedUuids.add(uuid)) {
        guids.add(Guid(uuid));
      }
    }

    for (final type in types) {
      switch (type) {
        case VulcanDeviceType.hand:
        case VulcanDeviceType.handOld:
          addUuid(advUUIDHand);
        case VulcanDeviceType.elbow:
          addUuid(advUUIDElbow);
        case VulcanDeviceType.coaxial:
          addUuid(advUUIDCoaxial);
        case VulcanDeviceType.wrist:
          addUuid(advUUIDElbow);
        case VulcanDeviceType.ring:
        case VulcanDeviceType.ringNrf:
        case VulcanDeviceType.ringDev3ch:
        case VulcanDeviceType.ringDev6ch:
        case VulcanDeviceType.ringWrist:
        case VulcanDeviceType.ringMedical:
        case VulcanDeviceType.myoLink:
          addUuid(advUUIDRing);
          addUuid(advUUIDRingOld);
        case VulcanDeviceType.sensorBox:
          addUuid(advUUIDSensorbox);
        case VulcanDeviceType.elbowAdapter:
        case VulcanDeviceType.bleAdapter:
          addUuid(advUUIDBleadapter);
        case VulcanDeviceType.otherHand:
        case VulcanDeviceType.electrode:
        case VulcanDeviceType.none:
          break;
      }
    }

    return guids;
  }
}
