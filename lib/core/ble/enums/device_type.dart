import 'package:vulcan_mobile_playground/core/ble/ble_vulcan_uuids.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';

/// Vulcan device types (playground).
///
/// `services` and `characteristics` are optional because not every product line
/// shares the same BLE profile.
enum VulcanDeviceType {
  hand(
    name: 'Vulcan Hand',
    hardwareId: 'H09 99',
    hardwareIdOld: 'HAND 9.9',
    genName: 'Vulcan Hand 9.9',
    services: BleVulcanProfiles.handServices,
    characteristics: BleVulcanProfiles.handCharacteristics,
  ),
  handOld(
    name: 'Vulcan Hand',
    hardwareId: 'HAND 9.7',
    hardwareIdOld: 'Vulcan Hand 9.7',
    genName: 'Vulcan Hand 9.7',
    services: BleVulcanProfiles.handServices,
    characteristics: BleVulcanProfiles.handCharacteristics,
  ),
  coaxial(
    name: 'Partner Hand (BLE)',
    hardwareId: 'COAXIAL',
    genName: null,
    services: BleVulcanProfiles.coaxialServices,
    characteristics: BleVulcanProfiles.coaxialCharacteristics,
  ),
  wrist(
    name: 'Wrist (BLE)',
    hardwareId: 'WR02',
    genName: 'Wrist Gen 2',
    services: BleVulcanProfiles.wristServices,
    characteristics: BleVulcanProfiles.wristCharacteristics,
  ),
  bleAdapter(
    name: 'Electrode (BLE)',
    hardwareId: 'BLE ADAPTER V2.0',
    genName: 'BLE ADAPTER V2.0',
    services: BleVulcanProfiles.bleAdapterServices,
    characteristics: BleVulcanProfiles.bleAdapterCharacteristics,
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
    services: BleVulcanProfiles.elbowServices,
    characteristics: BleVulcanProfiles.elbowCharacteristics,
  ),
  sensorBox(
    name: 'Sensorbox',
    hardwareId: 'SB',
    genName: null,
    services: BleVulcanProfiles.sensorBoxServices,
    characteristics: BleVulcanProfiles.sensorBoxCharacteristics,
  ),
  ring(
    name: 'Myoband',
    hardwareId: 'E02',
    hardwareIdOld: 'RING V2',
    genName: 'MyoBand gen 2',
    services: BleVulcanProfiles.ringServices,
    characteristics: BleVulcanProfiles.ringCharacteristics,
  ),
  ringNrf(
    name: 'Myoband',
    hardwareId: 'E03',
    hardwareIdOld: 'RING NRF',
    genName: 'MyoBand gen 3',
    services: BleVulcanProfiles.ringServices,
    characteristics: BleVulcanProfiles.ringCharacteristics,
  ),
  ringDev3ch(
    name: 'Myoband',
    hardwareId: 'MYO3CH',
    genName: 'MyoBand Advanced 3CH',
    services: BleVulcanProfiles.ringServices,
    characteristics: BleVulcanProfiles.ringCharacteristics,
  ),
  ringDev6ch(
    name: 'Myoband',
    hardwareId: 'MYO6CH',
    genName: 'MyoBand Advanced 6CH',
    services: BleVulcanProfiles.ringServices,
    characteristics: BleVulcanProfiles.ringCharacteristics,
  ),
  ringWrist(
    name: 'Myoband',
    hardwareId: 'MYOWRIST',
    genName: 'MyoBand Wrist',
    services: BleVulcanProfiles.ringServices,
    characteristics: BleVulcanProfiles.ringCharacteristics,
  ),
  ringMedical(
    name: 'Myoband Medical',
    hardwareId: 'MYOMED',
    genName: 'MyoBand Medical',
    services: BleVulcanProfiles.ringServices,
    characteristics: BleVulcanProfiles.ringCharacteristics,
  ),
  myoLink(
    name: 'Myolink',
    hardwareId: 'E09',
    hardwareIdOld: 'MYOLINK',
    genName: 'Myolink gen 1',
    services: BleVulcanProfiles.ringServices,
    characteristics: BleVulcanProfiles.ringCharacteristics,
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
  none(name: 'None', hardwareId: 'NONE', genName: null, isHasBle: false);

  const VulcanDeviceType({
    required this.name,
    required this.hardwareId,
    this.hardwareIdOld,
    required this.genName,
    this.isHasBle = true,
    this.services,
    this.characteristics,
  });

  final String name;
  final String hardwareId;
  final String? hardwareIdOld;
  final String? genName;
  final bool isHasBle;

  final BleServicesProfile? services;
  final BleCharacteristicsProfile? characteristics;

  static VulcanDeviceType fromHardwareId(String id) {
    return VulcanDeviceType.values.firstWhere(
      (device) => device.hardwareId == id || device.hardwareIdOld == id,
      orElse: () => VulcanDeviceType.none,
    );
  }
}
