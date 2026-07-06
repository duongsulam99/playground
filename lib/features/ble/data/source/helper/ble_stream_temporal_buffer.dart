import 'dart:typed_data';

import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/config/ble_stream_frame_config.dart';

/// Accumulates fixed-size BLE frames and flushes them on a time window.
class BleStreamTemporalBuffer {
  BleStreamTemporalBuffer({
    this.frameSizeBytes = BleStreamFrameConfig.emgFrameSizeBytes,
    this.flushInterval = BleStreamFrameConfig.defaultBatchInterval,
    required this._onFlush,
  }) {
    _timer = Timer.periodic(flushInterval, (_) => flushNow());
  }

  final int frameSizeBytes;
  final Duration flushInterval;
  final void Function(Uint8List batch) _onFlush;

  final List<Uint8List> _frames = [];
  Timer? _timer;
  bool _isDisposed = false;

  static const _logger = Logger(className: 'BleStreamTemporalBuffer');

  void add(Uint8List frame) {
    if (_isDisposed) return;

    if (frame.length != frameSizeBytes) {
      _logger.warning(
        'add',
        'Skipped frame with invalid size ${frame.length} (expected $frameSizeBytes)',
      );
      return;
    }

    _frames.add(Uint8List.fromList(frame));
  }

  void flushNow() {
    if (_isDisposed || _frames.isEmpty) return;

    final batch = Uint8List(_frames.length * frameSizeBytes);
    var offset = 0;
    for (final frame in _frames) {
      batch.setRange(offset, offset + frameSizeBytes, frame);
      offset += frameSizeBytes;
    }
    _frames.clear();
    _onFlush(batch);
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    _frames.clear();
  }
}
