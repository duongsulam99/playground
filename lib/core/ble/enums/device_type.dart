import 'package:vulcan_mobile_playground/core/ble/ble_vulcan_profiles.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_device_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';

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
  ),
  handOld(
    name: 'Vulcan Hand',
    hardwareId: 'HAND 9.7',
    hardwareIdOld: 'Vulcan Hand 9.7',
    genName: 'Vulcan Hand 9.7',
    profile: BleVulcanProfiles.hand,
  ),
  coaxial(
    name: 'Partner Hand (BLE)',
    hardwareId: 'COAXIAL',
    genName: null,
    profile: BleVulcanProfiles.coaxial,
  ),
  wrist(
    name: 'Wrist (BLE)',
    hardwareId: 'WR02',
    genName: 'Wrist Gen 2',
    profile: BleVulcanProfiles.wrist,
  ),
  bleAdapter(
    name: 'Electrode (BLE)',
    hardwareId: 'BLE ADAPTER V2.0',
    genName: 'BLE ADAPTER V2.0',
    profile: BleVulcanProfiles.bleAdapter,
  ),
  elbowAdapter(
    name: 'Elbow (Electrode)',
    hardwareId: 'ADAPTER ELBOW',
    genName: 'ADAPTER ELBOW',
  ),
  elbow(
    name: 'Elbow (BLE)',
    hardwareId: 'ELB',
    genName: 'Elbow Gen 1',
    profile: BleVulcanProfiles.elbow,
  ),
  sensorBox(
    name: 'Sensorbox',
    hardwareId: 'SB',
    genName: null,
    profile: BleVulcanProfiles.sensorBox,
  ),
  ring(
    name: 'Myoband',
    hardwareId: 'E02',
    hardwareIdOld: 'RING V2',
    genName: 'MyoBand gen 2',
    profile: BleVulcanProfiles.ring,
  ),
  ringNrf(
    name: 'Myoband',
    hardwareId: 'E03',
    hardwareIdOld: 'RING NRF',
    genName: 'MyoBand gen 3',
    profile: BleVulcanProfiles.ring,
  ),
  ringDev3ch(
    name: 'Myoband',
    hardwareId: 'MYO3CH',
    genName: 'MyoBand Advanced 3CH',
    profile: BleVulcanProfiles.ring,
  ),
  ringDev6ch(
    name: 'Myoband',
    hardwareId: 'MYO6CH',
    genName: 'MyoBand Advanced 6CH',
    profile: BleVulcanProfiles.ring,
  ),
  ringWrist(
    name: 'Myoband',
    hardwareId: 'MYOWRIST',
    genName: 'MyoBand Wrist',
    profile: BleVulcanProfiles.ring,
  ),
  ringMedical(
    name: 'Myoband Medical',
    hardwareId: 'MYOMED',
    genName: 'MyoBand Medical',
    profile: BleVulcanProfiles.ring,
  ),
  myoLink(
    name: 'Myolink',
    hardwareId: 'E09',
    hardwareIdOld: 'MYOLINK',
    genName: 'Myolink gen 1',
    profile: BleVulcanProfiles.ring,
  ),
  otherHand(
    name: 'Other Hand',
    hardwareId: 'OTHER HAND',
    genName: 'Other Hand',
    isHasBle: false,
  ),
  electrode(
    name: 'Electrode',
    hardwareId: 'EMG ELECTRODE',
    genName: null,
    isHasBle: false,
  ),
  // TODO: [Add New Device] Step 2: Thêm giá trị enum cho thiết bị mới tại đây

  // (profile định nghĩa ở Step 1, hardwareId, isHasBle, ...).
  none(name: 'None', hardwareId: 'NONE', genName: null, isHasBle: false);

  const VulcanDeviceType({
    required this.name,
    required this.hardwareId,
    this.hardwareIdOld,
    required this.genName,
    this.isHasBle = true,
    this.profile,
  });

  final String name;
  final String hardwareId;
  final String? hardwareIdOld;
  final String? genName;
  final bool isHasBle;

  final BleDeviceProfile? profile;

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
      VulcanDeviceType.ringDev3ch ||
      VulcanDeviceType.ringDev6ch ||
      VulcanDeviceType.ringWrist ||
      VulcanDeviceType.ringMedical ||
      VulcanDeviceType.myoLink => true,
      // TODO: [Add New Device] Step 2b: Nếu thiết bị mới thuộc nhóm MyoBand,
      // bổ sung case return true tại đây để kích hoạt luồng xử lý EMG.
      _ => false,
    };
  }
}
