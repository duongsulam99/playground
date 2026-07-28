import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_logic_control.dart';

import '../../../device_runtime.dart';

abstract interface class BleRingLogicControlService {
  Stream<RingLogicControl> get logicStream;

  Future<void> start();

  Future<RingLogicControl> read();

  Future<void> update(RingLogicControl logic);

  Future<void> dispose();
}

/// Read/write LOGIC_UUID; replay latest on [logicStream].
final class RingLogicControlService implements BleRingLogicControlService {
  RingLogicControlService(this._runtime);

  final DeviceRuntime _runtime;
  final _logger = const Logger(className: 'RingLogicControlService');

  final _controller = StreamController<RingLogicControl>.broadcast();
  RingLogicControl? _latest;
  bool _started = false;
  bool _disposed = false;

  @override
  Stream<RingLogicControl> get logicStream async* {
    final latest = _latest;
    if (latest != null) yield latest;
    yield* _controller.stream;
  }

  @override
  Future<void> start() async {
    if (_disposed || _started) return;
    _started = true;
    _runtime.ensureGattReady();
    await read();
  }

  @override
  Future<RingLogicControl> read() async {
    _runtime.ensureGattReady();
    try {
      final bytes = await _runtime.readCharacteristic(BleRingKey.logic);
      final logic = BleValueDecoders.decodeLogicControl(bytes);
      _emit(logic);
      _logger.debug('read', 'logicControl: $logic');
      return logic;
    } catch (e) {
      _logger.warning(
        'read',
        'Failed to read logic control, using default: $e',
      );
      const fallback = RingLogicControl.defaultOpen;
      _emit(fallback);
      return fallback;
    }
  }

  @override
  Future<void> update(RingLogicControl logic) async {
    _runtime.ensureGattReady();
    await _runtime.writeCharacteristic(
      BleRingKey.logic,
      utf8.encode(logic.bleValue.toString()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await read();
  }

  void _emit(RingLogicControl logic) {
    _latest = logic;
    if (!_controller.isClosed) {
      _controller.add(logic);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _started = false;
    _latest = null;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
