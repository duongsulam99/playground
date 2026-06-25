import 'package:flutter/foundation.dart';

@immutable
sealed class BleDeviceStreamSnapshot {
  final String deviceId;
  final DateTime timestamp;

  const BleDeviceStreamSnapshot({
    required this.deviceId,
    required this.timestamp,
  });
}

@immutable
final class EmgStreamSnapshot extends BleDeviceStreamSnapshot {
  final List<double> voltages;
  final List<int> rawBytes;

  const EmgStreamSnapshot({
    required super.deviceId,
    required super.timestamp,
    required this.voltages,
    required this.rawBytes,
  });
}
