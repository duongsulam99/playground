import '../../domain/entities/ble_device_stream_snapshot.dart';

class BleDeviceStreamSnapshotModel extends BleDeviceStreamSnapshot {
  const BleDeviceStreamSnapshotModel({
    required super.deviceId,
    required super.frameCount,
    required super.totalBytes,
    required super.framesPerSecond,
    required super.lastFrameLength,
    required super.hexPreview,
    required super.updatedAt,
  });
}
