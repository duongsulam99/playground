import 'dart:async';

import 'device_stream_metrics.dart';

class DeviceStreamAggregator {
  DeviceStreamAggregator({
    required this.deviceId,
    required this.source,
    this.throttleInterval = const Duration(milliseconds: 200),
    this.hexPreviewMaxBytes = 32,
  });

  static const _fpsWindow = Duration(seconds: 1);

  final String deviceId;
  final Stream<List<int>> source;
  final Duration throttleInterval;
  final int hexPreviewMaxBytes;

  Stream<DeviceStreamMetrics> get stream {
    late final StreamController<DeviceStreamMetrics> controller;
    StreamSubscription<List<int>>? subscription;
    Timer? throttleTimer;

    var frameCount = 0;
    var totalBytes = 0;
    var lastFrameLength = 0;
    var hexPreview = '';
    final frameTimestamps = <DateTime>[];
    DateTime? lastEmit;

    void emitSnapshot() {
      final now = DateTime.now();
      frameTimestamps.removeWhere(
        (timestamp) => now.difference(timestamp) > _fpsWindow,
      );

      controller.add(
        DeviceStreamMetrics(
          deviceId: deviceId,
          frameCount: frameCount,
          totalBytes: totalBytes,
          framesPerSecond: frameTimestamps.length,
          lastFrameLength: lastFrameLength,
          hexPreview: hexPreview,
          updatedAt: now,
        ),
      );
      lastEmit = now;
    }

    void scheduleEmit() {
      final now = DateTime.now();
      if (lastEmit == null || now.difference(lastEmit!) >= throttleInterval) {
        emitSnapshot();
        throttleTimer?.cancel();
        throttleTimer = null;
        return;
      }

      throttleTimer ??= Timer(throttleInterval - now.difference(lastEmit!), () {
        throttleTimer = null;
        emitSnapshot();
      });
    }

    controller = StreamController<DeviceStreamMetrics>(
      onListen: () {
        subscription = source.listen(
          (frame) {
            frameCount++;
            totalBytes += frame.length;
            lastFrameLength = frame.length;
            hexPreview = _formatHexPreview(frame);
            frameTimestamps.add(DateTime.now());
            scheduleEmit();
          },
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () async {
        throttleTimer?.cancel();
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  String _formatHexPreview(List<int> bytes) {
    final limit = bytes.length < hexPreviewMaxBytes
        ? bytes.length
        : hexPreviewMaxBytes;
    final preview = bytes
        .take(limit)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ');

    if (bytes.length > hexPreviewMaxBytes) {
      return '$preview …';
    }

    return preview;
  }
}
