import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_encoders.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../ble_device_runtime.dart';

/// Điều khiển stream tín hiệu EMG trên MyoBand family.
class MyoBandSignalStream {
  MyoBandSignalStream(this._runtime);

  final BleDeviceRuntime _runtime;

  static const String _startSignalCommand = '255';
  static const String _stopSignalCommand = '000';

  final _logger = const Logger(className: 'MyoBandSignalStream');
  bool _isStreaming = false;

  bool get isStreaming => _isStreaming;

  Stream<List<int>> get rawStream => _runtime.watchNotifyData();

  Future<void> start() async {
    _isStreaming = false;
    _runtime.ensureGattReady();

    try {
      await _runtime.writeData(
        BleRingKey.signal,
        BleValueEncoders.encodeUtf8(_startSignalCommand),
      );

      await _runtime.startListening(
        BleRingKey.signal,
        reassembleFrames: false,
      );

      _isStreaming = true;
      _logger.debug('start', 'Notify stream ready for ${_runtime.deviceId}');
    } catch (e, st) {
      _isStreaming = false;
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
      _isStreaming = false;
    }
  }
}
