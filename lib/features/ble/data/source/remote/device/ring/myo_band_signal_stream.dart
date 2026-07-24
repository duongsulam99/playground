import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_encoders.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../abstract/capabilities/ble_device_streaming.dart';
import '../../ble_device_runtime.dart';

/// Active EMG stream trên MyoBand family (SIGNAL_UUID).
///
/// Implements [BleDeviceStreaming] trực tiếp — facade chỉ expose getter.
final class MyoBandSignalStream implements BleDeviceStreaming {
  MyoBandSignalStream(this._runtime);

  final BleDeviceRuntime _runtime;

  static const String _startSignalCommand = '255';
  static const String _stopSignalCommand = '000';

  final _logger = const Logger(className: 'MyoBandSignalStream');
  bool _isStreaming = false;
  Stream<List<int>>? _notifyStream;

  bool get isStreaming => _isStreaming;

  @override
  Stream<List<int>> get notifyDataStream {
    final stream = _notifyStream;
    if (stream == null) {
      throw BleException(
        'Signal notify is not enabled. Call startDeviceStream first.',
        deviceId: _runtime.deviceId,
      );
    }
    return stream;
  }

  @override
  Future<void> startDeviceStream() => start();

  @override
  Future<void> stopDeviceStream() => stop();

  Future<void> start() async {
    _isStreaming = false;
    _notifyStream = null;
    _runtime.ensureGattReady();

    try {
      await _runtime.writeData(
        BleRingKey.signal,
        BleValueEncoders.encodeUtf8(_startSignalCommand),
      );

      _notifyStream = await _runtime.enableNotify(BleRingKey.signal);

      _isStreaming = true;
      _logger.debug('start', 'Notify stream ready for ${_runtime.deviceId}');
    } catch (e, st) {
      _isStreaming = false;
      _notifyStream = null;
      _logger.error('start', 'Failed to setup MyoBand notify stream: $e\n$st');

      if (e is BleException) rethrow;
      throw BleException(
        'Failed to start MyoBand signal stream: $e',
        deviceId: _runtime.deviceId,
      );
    }
  }

  Future<void> stop() async {
    if (!_isStreaming) return;

    try {
      await _runtime.writeData(
        BleRingKey.signal,
        BleValueEncoders.encodeUtf8(_stopSignalCommand),
      );
    } catch (e) {
      _logger.warning(
        'stop',
        'Failed to stop MyoBand signal for ${_runtime.deviceId}: $e',
      );
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to stop MyoBand signal stream: $e',
        deviceId: _runtime.deviceId,
      );
    } finally {
      try {
        await _runtime.disableNotify(BleRingKey.signal);
      } catch (e) {
        _logger.warning(
          'stop',
          'Failed to disable signal notify for ${_runtime.deviceId}: $e',
        );
      }
      _isStreaming = false;
      _notifyStream = null;
    }
  }
}
