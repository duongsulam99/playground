import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'ble_discovered_device.dart';

/// Snapshot kết quả scan tại một thời điểm — keyed by `deviceId`.
@immutable
class BleScanSnapshot extends Equatable {
  const BleScanSnapshot([this.devicesById = const {}]);

  static const empty = BleScanSnapshot();

  final Map<String, BleDiscoveredDevice> devicesById;

  BleDiscoveredDevice? operator [](String deviceId) => devicesById[deviceId];

  Iterable<BleDiscoveredDevice> get devices => devicesById.values;

  int get length => devicesById.length;

  bool get isEmpty => devicesById.isEmpty;

  bool get isNotEmpty => devicesById.isNotEmpty;

  bool contains(String deviceId) => devicesById.containsKey(deviceId);

  @override
  List<Object?> get props => [devicesById];
}
