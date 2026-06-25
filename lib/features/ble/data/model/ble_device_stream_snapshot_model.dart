import '../../domain/entities/ble_device_stream_snapshot.dart';

sealed class BleDeviceStreamSnapshotModel {
  String get deviceId;
  DateTime get timestamp;

  BleDeviceStreamSnapshot toEntity();
}

final class EmgStreamSnapshotModel extends BleDeviceStreamSnapshotModel {
  EmgStreamSnapshotModel({
    required this.deviceId,
    required this.timestamp,
    required this.voltages,
    required this.rawBytes,
  });

  @override
  final String deviceId;

  @override
  final DateTime timestamp;

  final List<double> voltages;
  final List<int> rawBytes;

  @override
  EmgStreamSnapshot toEntity() => EmgStreamSnapshot(
    deviceId: deviceId,
    timestamp: timestamp,
    voltages: voltages,
    rawBytes: rawBytes,
  );
}
