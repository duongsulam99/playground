import 'package:vulcan_mobile_playground/core/ble/ble_vulcan_profiles.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_device_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';

import 'DFU/dfu_type.dart';

/// Vulcan device types (playground).
///
/// `profile` is optional because not every product line shares the same BLE GATT
/// profile (e.g. elbowAdapter is scan-only).
enum VulcanDeviceType {
  hand(
    name: 'Vulcan Hand',
    hardwareId: 'H09 99',
    hardwareIdOld: 'HAND 9.9',
    genName: 'Vulcan Hand 9.9',
    profile: BleVulcanProfiles.hand,
    dfuType: DfuType.esp32Custom,
  ),
  handOld(
    name: 'Vulcan Hand',
    hardwareId: 'HAND 9.7',
    hardwareIdOld: 'Vulcan Hand 9.7',
    genName: 'Vulcan Hand 9.7',
    profile: BleVulcanProfiles.hand,
    dfuType: DfuType.esp32Custom,
  ),
  coaxial(
    name: 'Partner Hand (BLE)',
    hardwareId: 'COAXIAL',
    profile: BleVulcanProfiles.coaxial,
    dfuType: DfuType.nordicDfu,
  ),
  wrist(
    name: 'Wrist (BLE)',
    hardwareId: 'WR02',
    genName: 'Wrist Gen 2',
    profile: BleVulcanProfiles.wrist,
    dfuType: DfuType.esp32Custom,
  ),
  bleAdapter(
    name: 'Electrode (BLE)',
    hardwareId: 'BLE ADAPTER V2.0',
    genName: 'BLE ADAPTER V2.0',
    profile: BleVulcanProfiles.bleAdapter,
    dfuType: DfuType.nordicDfu,
  ),
  elbowAdapter(
    name: 'Elbow (Electrode)',
    hardwareId: 'ADAPTER ELBOW',
    genName: 'ADAPTER ELBOW',
    dfuType: DfuType.nordicDfu,
  ),
  elbow(
    name: 'Elbow (BLE)',
    hardwareId: 'ELB',
    genName: 'Elbow Gen 1',
    profile: BleVulcanProfiles.elbow,
    dfuType: DfuType.esp32Custom,
  ),
  sensorBox(
    name: 'Sensorbox',
    hardwareId: 'SB',
    profile: BleVulcanProfiles.sensorBox,
    dfuType: DfuType.nordicDfu,
  ),
  ring(
    name: 'Myoband',
    hardwareId: 'E02',
    hardwareIdOld: 'RING V2',
    genName: 'MyoBand gen 2',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.esp32Custom,
  ),
  ringVibration(
    name: 'Myoband Vibration',
    hardwareId: 'E03-C0',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.nordicDfu,
  ),
  ringNrf(
    name: 'Myoband',
    hardwareId: 'E03',
    hardwareIdOld: 'RING NRF',
    genName: 'MyoBand gen 3',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.nordicDfu,
  ),
  ringDev3ch(
    name: 'Myoband',
    hardwareId: 'MYO3CH',
    genName: 'MyoBand Advanced 3CH',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.nordicDfu,
  ),
  ringDev6ch(
    name: 'Myoband',
    hardwareId: 'MYO6CH',
    genName: 'MyoBand Advanced 6CH',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.nordicDfu,
  ),
  ringWrist(
    name: 'Myoband',
    hardwareId: 'MYOWRIST',
    genName: 'MyoBand Wrist',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.nordicDfu,
  ),
  ringMedical(
    name: 'Myoband Medical',
    hardwareId: 'MYOMED',
    genName: 'MyoBand Medical',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.nordicDfu,
  ),
  myoLink(
    name: 'Myolink',
    hardwareId: 'E09',
    hardwareIdOld: 'MYOLINK',
    genName: 'Myolink gen 1',
    profile: BleVulcanProfiles.ring,
    dfuType: DfuType.nordicDfu,
  ),
  otherHand(
    name: 'Other Hand',
    hardwareId: 'OTHER HAND',
    genName: 'Other Hand',
    isHasBle: false,
    dfuType: DfuType.esp32Custom,
  ),
  electrode(
    name: 'Electrode',
    hardwareId: 'EMG ELECTRODE',
    isHasBle: false,
    dfuType: DfuType.none,
  ),
  // (profile định nghĩa ở Step 1, hardwareId, isHasBle, ...).
  //TODO:[Add New Device] Step 2: Thêm giá trị enum cho thiết bị mới tại đây

  none(
    name: 'None',
    hardwareId: 'NONE',
    isHasBle: false,
    dfuType: DfuType.none,
  );

  const VulcanDeviceType({
    required this.name,
    required this.hardwareId,
    this.hardwareIdOld,
    this.genName,
    this.isHasBle = true,
    this.profile,
    required this.dfuType,
  });

  final String name;
  final String hardwareId;
  final String? hardwareIdOld;
  final String? genName;
  final bool isHasBle;

  final BleDeviceProfile? profile;
  final DfuType dfuType;

  BleServicesProfile? get services => profile?.services;
  BleCharacteristicsProfile? get characteristics => profile?.characteristics;
  String? get advUuid => profile?.advUuid;

  static VulcanDeviceType fromHardwareId(String id) {
    return VulcanDeviceType.values.firstWhere(
      (device) => device.hardwareId == id || device.hardwareIdOld == id,
      orElse: () => VulcanDeviceType.none,
    );
  }
}

extension VulcanDeviceTypeX on VulcanDeviceType {
  bool get isMyoBandFamily {
    return switch (this) {
      VulcanDeviceType.ring ||
      VulcanDeviceType.ringNrf ||
      VulcanDeviceType.ringVibration ||
      VulcanDeviceType.ringDev3ch ||
      VulcanDeviceType.ringDev6ch ||
      VulcanDeviceType.ringWrist ||
      VulcanDeviceType.ringMedical ||
      VulcanDeviceType.myoLink => true,
      // bổ sung case return true tại đây để kế thừa các tính năng của ring.
      //TODO:[Add New Device] Step 2b: Nếu thiết bị mới thuộc nhóm MyoBand,
      _ => false,
    };
  }
}
