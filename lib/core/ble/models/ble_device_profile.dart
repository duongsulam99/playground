import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';

/// Gom GATT services, characteristics và adv UUID của một dòng thiết bị BLE.
class BleDeviceProfile {
  const BleDeviceProfile({
    required this.services,
    required this.characteristics,
    required this.advUuid,
    this.additionalAdvUuids = const [],
  });

  final BleServicesProfile services;
  final BleCharacteristicsProfile characteristics;

  /// UUID quảng bá chính — giá trị lấy từ [BleAdvUuids] static.
  final String advUuid;

  /// UUID phụ cho scan (vd. ring legacy firmware <0.7).
  final List<String> additionalAdvUuids;

  List<String> get allAdvUuids => [advUuid, ...additionalAdvUuids];
}
