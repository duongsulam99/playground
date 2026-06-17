/// Typed BLE GATT characteristic UUID profile.
/// See: https://www.bluetooth.com/specifications/gatt/characteristics
///
///
sealed class BleCharacteristicsProfile {
  const BleCharacteristicsProfile();

  List<String> get uuids;

  bool contains(String uuid) => uuids.contains(uuid);

  String? keyFor(String uuid) {
    for (final entry in entries) {
      if (entry.value == uuid) {
        return entry.key;
      }
    }
    return null;
  }

  Iterable<MapEntry<String, String>> get entries;
}

final class HandBleCharacteristics extends BleCharacteristicsProfile {
  const HandBleCharacteristics({
    required this.otaUuid,
    required this.nameCharUuid,
    required this.hardwareCharUuid,
    required this.connectUuid,
    required this.settingUuid,
    required this.technicalUuid,
    required this.addrUuid,
    required this.angleUuid,
    required this.controlUuid,
    required this.batteryUuid,
  });

  final String otaUuid;
  final String nameCharUuid;
  final String hardwareCharUuid;
  final String connectUuid;
  final String settingUuid;
  final String technicalUuid;
  final String addrUuid;
  final String angleUuid;
  final String controlUuid;
  final String batteryUuid;

  @override
  List<String> get uuids => [
    otaUuid,
    nameCharUuid,
    hardwareCharUuid,
    connectUuid,
    settingUuid,
    technicalUuid,
    addrUuid,
    angleUuid,
    controlUuid,
    batteryUuid,
  ];

  @override
  Iterable<MapEntry<String, String>> get entries => [
    MapEntry('OTA_UUID', otaUuid),
    MapEntry('NAME_CHAR_UUID', nameCharUuid),
    MapEntry('HARDWARE_CHAR_UUID', hardwareCharUuid),
    MapEntry('CONNECT_UUID', connectUuid),
    MapEntry('SETTING_UUID', settingUuid),
    MapEntry('TECHNICAL_UUID', technicalUuid),
    MapEntry('ADDR_UUID', addrUuid),
    MapEntry('ANGLE_UUID', angleUuid),
    MapEntry('CONTROL_UUID', controlUuid),
    MapEntry('BATTERY_UUID', batteryUuid),
  ];
}

final class ElbowBleCharacteristics extends BleCharacteristicsProfile {
  const ElbowBleCharacteristics({
    required this.otaUuid,
    required this.nameUuid,
    required this.hardwareUuid,
    required this.addrUuid,
    required this.controlUuid,
    required this.speedUuid,
    required this.batteryUuid,
    required this.stateElbowUuid,
    required this.connectUuid,
  });

  final String otaUuid;
  final String nameUuid;
  final String hardwareUuid;
  final String addrUuid;
  final String controlUuid;
  final String speedUuid;
  final String batteryUuid;
  final String stateElbowUuid;
  final String connectUuid;

  @override
  List<String> get uuids => [
    otaUuid,
    nameUuid,
    hardwareUuid,
    addrUuid,
    controlUuid,
    speedUuid,
    batteryUuid,
    stateElbowUuid,
    connectUuid,
  ];

  @override
  Iterable<MapEntry<String, String>> get entries => [
    MapEntry('OTA_UUID', otaUuid),
    MapEntry('NAME_UUID', nameUuid),
    MapEntry('HARDWARE_UUID', hardwareUuid),
    MapEntry('ADDR_UUID', addrUuid),
    MapEntry('CONTROL_UUID', controlUuid),
    MapEntry('SPEED_UUID', speedUuid),
    MapEntry('BATTERY_UUID', batteryUuid),
    MapEntry('STATE_ELBOW_UUID', stateElbowUuid),
    MapEntry('CONNECT_UUID', connectUuid),
  ];
}

final class CoaxialBleCharacteristics extends BleCharacteristicsProfile {
  const CoaxialBleCharacteristics({
    required this.otaUuid,
    required this.nameCharUuid,
    required this.hardwareCharUuid,
    required this.connectUuid,
    required this.addrUuid,
    required this.controlUuid,
    required this.batteryUuid,
  });

  final String otaUuid;
  final String nameCharUuid;
  final String hardwareCharUuid;
  final String connectUuid;
  final String addrUuid;
  final String controlUuid;
  final String batteryUuid;

  @override
  List<String> get uuids => [
    otaUuid,
    nameCharUuid,
    hardwareCharUuid,
    connectUuid,
    addrUuid,
    controlUuid,
    batteryUuid,
  ];

  @override
  Iterable<MapEntry<String, String>> get entries => [
    MapEntry('OTA_UUID', otaUuid),
    MapEntry('NAME_CHAR_UUID', nameCharUuid),
    MapEntry('HARDWARE_CHAR_UUID', hardwareCharUuid),
    MapEntry('CONNECT_UUID', connectUuid),
    MapEntry('ADDR_UUID', addrUuid),
    MapEntry('CONTROL_UUID', controlUuid),
    MapEntry('BATTERY_UUID', batteryUuid),
  ];
}

final class WristBleCharacteristics extends BleCharacteristicsProfile {
  const WristBleCharacteristics({
    required this.otaUuid,
    required this.nameUuid,
    required this.hardwareUuid,
    required this.addrUuid,
    required this.controlUuid,
    required this.speedUuid,
    required this.batteryUuid,
    required this.stateWristUuid,
    required this.connectUuid,
  });

  final String otaUuid;
  final String nameUuid;
  final String hardwareUuid;
  final String addrUuid;
  final String controlUuid;
  final String speedUuid;
  final String batteryUuid;
  final String stateWristUuid;
  final String connectUuid;

  @override
  List<String> get uuids => [
    otaUuid,
    nameUuid,
    hardwareUuid,
    addrUuid,
    controlUuid,
    speedUuid,
    batteryUuid,
    stateWristUuid,
    connectUuid,
  ];

  @override
  Iterable<MapEntry<String, String>> get entries => [
    MapEntry('OTA_UUID', otaUuid),
    MapEntry('NAME_UUID', nameUuid),
    MapEntry('HARDWARE_UUID', hardwareUuid),
    MapEntry('ADDR_UUID', addrUuid),
    MapEntry('CONTROL_UUID', controlUuid),
    MapEntry('SPEED_UUID', speedUuid),
    MapEntry('BATTERY_UUID', batteryUuid),
    MapEntry('STATE_WRIST_UUID', stateWristUuid),
    MapEntry('CONNECT_UUID', connectUuid),
  ];
}

final class RingBleCharacteristics extends BleCharacteristicsProfile {
  const RingBleCharacteristics({
    required this.otaUuid,
    required this.nameCharUuid,
    required this.hardwareCharUuid,
    required this.modeCharUuid,
    required this.actionButtonUuid,
    required this.signalUuid,
    required this.medicalUuid,
    required this.thresholdUuid,
    required this.logicUuid,
    required this.stateControlUuid,
    required this.batteryUuid,
    required this.countControlUuid,
    required this.calibHistoryUuid,
    required this.smpCharUuid,
    required this.settingUuid,
  });

  final String otaUuid;
  final String nameCharUuid;
  final String hardwareCharUuid;
  final String modeCharUuid;
  final String actionButtonUuid;
  final String signalUuid;
  final String medicalUuid;
  final String thresholdUuid;
  final String logicUuid;
  final String stateControlUuid;
  final String batteryUuid;
  final String countControlUuid;
  final String calibHistoryUuid;
  final String smpCharUuid;
  final String settingUuid;

  @override
  List<String> get uuids => [
    otaUuid,
    nameCharUuid,
    hardwareCharUuid,
    modeCharUuid,
    actionButtonUuid,
    signalUuid,
    medicalUuid,
    thresholdUuid,
    logicUuid,
    stateControlUuid,
    batteryUuid,
    countControlUuid,
    calibHistoryUuid,
    smpCharUuid,
    settingUuid,
  ];

  @override
  Iterable<MapEntry<String, String>> get entries => [
    MapEntry('OTA_UUID', otaUuid),
    MapEntry('NAME_CHAR_UUID', nameCharUuid),
    MapEntry('HARDWARE_CHAR_UUID', hardwareCharUuid),
    MapEntry('MODE_CHAR_UUID', modeCharUuid),
    MapEntry('ACTION_BUTTON_UUID', actionButtonUuid),
    MapEntry('SIGNAL_UUID', signalUuid),
    MapEntry('MEDICAL_UUID', medicalUuid),
    MapEntry('THRESHOLD_UUID', thresholdUuid),
    MapEntry('LOGIC_UUID', logicUuid),
    MapEntry('STATE_CONTROL_UUID', stateControlUuid),
    MapEntry('BATTERY_UUID', batteryUuid),
    MapEntry('COUNT_CONTROL_UUID', countControlUuid),
    MapEntry('CALIB_HISTORY_UUID', calibHistoryUuid),
    MapEntry('SMP_CHAR_UUID', smpCharUuid),
    MapEntry('SETTING_UUID', settingUuid),
  ];
}

final class SensorBoxBleCharacteristics extends BleCharacteristicsProfile {
  const SensorBoxBleCharacteristics({
    required this.nameCharUuid,
    required this.stateControlUuid,
    required this.batteryUuid,
  });

  final String nameCharUuid;
  final String stateControlUuid;
  final String batteryUuid;

  @override
  List<String> get uuids => [nameCharUuid, stateControlUuid, batteryUuid];

  @override
  Iterable<MapEntry<String, String>> get entries => [
    MapEntry('NAME_CHAR_UUID', nameCharUuid),
    MapEntry('STATE_CONTROL_UUID', stateControlUuid),
    MapEntry('BATTERY_UUID', batteryUuid),
  ];
}

final class BleAdapterBleCharacteristics extends BleCharacteristicsProfile {
  const BleAdapterBleCharacteristics({
    required this.otaUuid,
    required this.nameCharUuid,
    required this.hardwareCharUuid,
    required this.signalUuid,
    required this.stateControlUuid,
    required this.logicUuid,
    required this.batteryUuid,
  });

  final String otaUuid;
  final String nameCharUuid;
  final String hardwareCharUuid;
  final String signalUuid;
  final String stateControlUuid;
  final String logicUuid;
  final String batteryUuid;

  @override
  List<String> get uuids => [
    otaUuid,
    nameCharUuid,
    hardwareCharUuid,
    signalUuid,
    stateControlUuid,
    logicUuid,
    batteryUuid,
  ];

  @override
  Iterable<MapEntry<String, String>> get entries => [
    MapEntry('OTA_UUID', otaUuid),
    MapEntry('NAME_CHAR_UUID', nameCharUuid),
    MapEntry('HARDWARE_CHAR_UUID', hardwareCharUuid),
    MapEntry('SIGNAL_UUID', signalUuid),
    MapEntry('STATE_CONTROL_UUID', stateControlUuid),
    MapEntry('LOGIC_UUID', logicUuid),
    MapEntry('BATTERY_UUID', batteryUuid),
  ];
}
