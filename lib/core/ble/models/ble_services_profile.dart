/// Typed BLE GATT service UUID profile.
/// See: https://www.bluetooth.com/specifications/gatt/services
///
///
sealed class BleServicesProfile {
  const BleServicesProfile();

  List<String> get uuids;

  bool contains(String uuid) =>
      uuids.any((value) => value.toLowerCase() == uuid.toLowerCase());
}

final class HandBleServices extends BleServicesProfile {
  const HandBleServices({
    required this.inforServiceUuid,
    required this.controlServiceUuid,
  });

  final String inforServiceUuid;
  final String controlServiceUuid;

  @override
  List<String> get uuids => [inforServiceUuid, controlServiceUuid];
}

final class ElbowBleServices extends BleServicesProfile {
  const ElbowBleServices({
    required this.inforServiceUuid,
    required this.controlServiceUuid,
  });

  final String inforServiceUuid;
  final String controlServiceUuid;

  @override
  List<String> get uuids => [inforServiceUuid, controlServiceUuid];
}

final class CoaxialBleServices extends BleServicesProfile {
  const CoaxialBleServices({
    required this.inforServiceUuid,
    required this.controlServiceUuid,
    required this.smpServiceUuid,
  });

  final String inforServiceUuid;
  final String controlServiceUuid;
  final String smpServiceUuid;

  @override
  List<String> get uuids => [
    inforServiceUuid,
    controlServiceUuid,
    smpServiceUuid,
  ];
}

final class WristBleServices extends BleServicesProfile {
  const WristBleServices({
    required this.inforServiceUuid,
    required this.controlServiceUuid,
    required this.smpServiceUuid,
  });

  final String inforServiceUuid;
  final String controlServiceUuid;
  final String smpServiceUuid;

  @override
  List<String> get uuids => [
    inforServiceUuid,
    controlServiceUuid,
    smpServiceUuid,
  ];
}

final class RingBleServices extends BleServicesProfile {
  const RingBleServices({
    required this.ringServiceUuid,
    required this.sensorServiceUuid,
    required this.smpServiceUuid,
  });

  final String ringServiceUuid;
  final String sensorServiceUuid;
  final String smpServiceUuid;

  @override
  List<String> get uuids => [
    ringServiceUuid,
    sensorServiceUuid,
    smpServiceUuid,
  ];
}

final class SensorBoxBleServices extends BleServicesProfile {
  const SensorBoxBleServices({
    required this.sensorBoxServiceUuid,
    required this.inforServiceUuid,
  });

  final String sensorBoxServiceUuid;
  final String inforServiceUuid;

  @override
  List<String> get uuids => [sensorBoxServiceUuid, inforServiceUuid];
}

final class BleAdapterBleServices extends BleServicesProfile {
  const BleAdapterBleServices({
    required this.inforServiceUuid,
    required this.controlServiceUuid,
  });

  final String inforServiceUuid;
  final String controlServiceUuid;

  @override
  List<String> get uuids => [inforServiceUuid, controlServiceUuid];
}
