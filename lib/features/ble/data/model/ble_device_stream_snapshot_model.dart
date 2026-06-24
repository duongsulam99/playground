import '../../domain/entities/ble_device_stream_snapshot.dart';

class BleDeviceStreamSnapshotModel {
  const BleDeviceStreamSnapshotModel({
    required this.deviceId,
    required this.frameCount,
    required this.totalBytes,
    required this.framesPerSecond,
    required this.lastFrameLength,
    required this.hexPreview,
    required this.updatedAt,
  });

  final String deviceId;
  final int frameCount;
  final int totalBytes;
  final int framesPerSecond;
  final int lastFrameLength;
  final String hexPreview;
  final DateTime updatedAt;

  BleDeviceStreamSnapshot toEntity() => BleDeviceStreamSnapshot(
    deviceId: deviceId,
    frameCount: frameCount,
    totalBytes: totalBytes,
    framesPerSecond: framesPerSecond,
    lastFrameLength: lastFrameLength,
    hexPreview: hexPreview,
    updatedAt: updatedAt,
  );
}
