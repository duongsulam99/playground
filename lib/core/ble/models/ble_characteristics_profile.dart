import '../gatt/keys/adapter/key.dart';
import '../gatt/keys/hand/key.dart';
import '../gatt/keys/ring/key.dart';

typedef KeyMap = Map<String, String>;

/// Typed BLE GATT characteristic UUID profile.
/// See: https://www.bluetooth.com/specifications/gatt/characteristics
sealed class BleCharacteristicsProfile {
  const BleCharacteristicsProfile();

  /// Weak side-table cache keyed by each profile instance.
  ///
  /// Expando stores data outside the object itself, so const profile instances
  /// can keep their const constructors while still getting a lazily-built cache.
  /// When a profile instance is garbage-collected, its Expando entry can be
  /// collected too.
  ///
  /// The cached [KeyMap] is one bidirectional lookup table:
  /// - `uuid:<normalized characteristic uuid>` -> characteristic key
  /// - `key:<characteristic key>` -> original characteristic uuid
  /// - `uuid:<normalized uuid>` -> [_containsOnlyMarker] for UUIDs that only
  ///   need membership lookup via [contains].
  static final Expando<KeyMap> _lookupCache = Expando();

  static const String _uuidPrefix = 'uuid:';
  static const String _keyPrefix = 'key:';
  static const String _containsOnlyMarker = '<contains-only>';

  List<String> get uuids;

  bool contains(String uuid) {
    return _lookup.containsKey(_uuidLookupKey(uuid));
  }

  /// Get [key] from [characteristic].
  String? keyForm(String uuid) {
    final key = _lookup[_uuidLookupKey(uuid)];
    return key == _containsOnlyMarker ? null : key;
  }

  /// Get [characteristic] from [key].
  String? characteristicForKey(String key) => _lookup[_keyLookupKey(key)];

  Iterable<MapEntry<String, String>> get entries;

  KeyMap get _lookup {
    final cached = _lookupCache[this];
    if (cached != null) return cached;

    final lookup = <String, String>{};
    for (final entry in entries) {
      lookup.putIfAbsent(_uuidLookupKey(entry.value), () => entry.key);
      lookup.putIfAbsent(_keyLookupKey(entry.key), () => entry.value);
    }

    for (final uuid in uuids) {
      lookup.putIfAbsent(_uuidLookupKey(uuid), () => _containsOnlyMarker);
    }

    _lookupCache[this] = lookup;
    return lookup;
  }

  String _normalize(String uuid) => uuid.toLowerCase();

  String _uuidLookupKey(String uuid) => '$_uuidPrefix${_normalize(uuid)}';

  String _keyLookupKey(String key) => '$_keyPrefix$key';
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
    MapEntry(BleHandKey.ota, otaUuid),
    MapEntry(BleHandKey.nameChar, nameCharUuid),
    MapEntry(BleHandKey.hardwareChar, hardwareCharUuid),
    MapEntry(BleHandKey.connect, connectUuid),
    MapEntry(BleHandKey.setting, settingUuid),
    MapEntry(BleHandKey.technical, technicalUuid),
    MapEntry(BleHandKey.addr, addrUuid),
    MapEntry(BleHandKey.angle, angleUuid),
    MapEntry(BleHandKey.control, controlUuid),
    MapEntry(BleHandKey.battery, batteryUuid),
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
    MapEntry(BleHandKey.ota, otaUuid),
    MapEntry(BleHandKey.nameChar, nameCharUuid),
    MapEntry(BleHandKey.hardwareChar, hardwareCharUuid),
    MapEntry(BleHandKey.connect, connectUuid),
    MapEntry(BleHandKey.addr, addrUuid),
    MapEntry(BleHandKey.control, controlUuid),
    MapEntry(BleHandKey.battery, batteryUuid),
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
    required this.vibrationCharUuid,
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
  final String vibrationCharUuid;
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
    vibrationCharUuid,
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
    MapEntry(BleRingKey.ota, otaUuid),
    MapEntry(BleRingKey.nameChar, nameCharUuid),
    MapEntry(BleRingKey.hardwareChar, hardwareCharUuid),
    MapEntry(BleRingKey.modeChar, modeCharUuid),
    MapEntry(BleRingKey.vibrationChar, vibrationCharUuid),
    MapEntry(BleRingKey.actionButton, actionButtonUuid),
    MapEntry(BleRingKey.signal, signalUuid),
    MapEntry(BleRingKey.medical, medicalUuid),
    MapEntry(BleRingKey.threshold, thresholdUuid),
    MapEntry(BleRingKey.logic, logicUuid),
    MapEntry(BleRingKey.stateControl, stateControlUuid),
    MapEntry(BleRingKey.battery, batteryUuid),
    MapEntry(BleRingKey.countControl, countControlUuid),
    MapEntry(BleRingKey.calibHistory, calibHistoryUuid),
    MapEntry(BleRingKey.smpChar, smpCharUuid),
    MapEntry(BleRingKey.setting, settingUuid),
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
    MapEntry(BleAdapterKey.nameChar, nameCharUuid),
    MapEntry(BleAdapterKey.stateControl, stateControlUuid),
    MapEntry(BleAdapterKey.battery, batteryUuid),
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
    MapEntry(BleAdapterKey.ota, otaUuid),
    MapEntry(BleAdapterKey.nameChar, nameCharUuid),
    MapEntry(BleAdapterKey.hardwareChar, hardwareCharUuid),
    MapEntry(BleAdapterKey.signal, signalUuid),
    MapEntry(BleAdapterKey.stateControl, stateControlUuid),
    MapEntry(BleAdapterKey.logic, logicUuid),
    MapEntry(BleAdapterKey.battery, batteryUuid),
  ];
}
