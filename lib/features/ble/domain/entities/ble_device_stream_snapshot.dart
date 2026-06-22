import 'package:equatable/equatable.dart';

class BleDeviceStreamSnapshot extends Equatable {
  const BleDeviceStreamSnapshot({
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

  @override
  List<Object?> get props => [
    deviceId,
    frameCount,
    totalBytes,
    framesPerSecond,
    lastFrameLength,
    hexPreview,
    updatedAt,
  ];
}
