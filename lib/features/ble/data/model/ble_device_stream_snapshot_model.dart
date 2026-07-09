import '../../domain/entities/ble_device_stream_snapshot.dart';

/// Snapshot một điểm dữ liệu stream — sealed để mở rộng loại stream khác EMG.
sealed class BleDeviceStreamSnapshotModel {
  String get deviceId;
  DateTime get timestamp;

  BleDeviceStreamSnapshot toEntity();
}

/// Batch EMG đã decode: điện áp (mV) + raw bytes gốc.
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
