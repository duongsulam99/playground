import 'package:equatable/equatable.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_action_button_mapping.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_action_button_type.dart';

import '../../../device_runtime.dart';
import 'ring_logic_control_service.dart';

/// GATT mapping for single/double tap (ACTION_BUTTON_UUID read).
final class ActionButtonMappingSnapshot extends Equatable {
  const ActionButtonMappingSnapshot({
    required this.single,
    required this.doubleTap,
  });

  factory ActionButtonMappingSnapshot.fromCore(
    RingActionButtonMapping mapping,
  ) {
    return ActionButtonMappingSnapshot(
      single: mapping.single,
      doubleTap: mapping.doubleTap,
    );
  }

  final RingActionButtonType single;
  final RingActionButtonType doubleTap;

  RingActionButtonMapping toCore() =>
      RingActionButtonMapping(single: single, doubleTap: doubleTap);

  @override
  List<Object?> get props => [single, doubleTap];
}

abstract interface class BleRingActionButtonMonitor {
  Stream<ActionButtonMappingSnapshot> get mappingStream;

  Stream<RingActionButtonType> get pressStream;

  Future<void> start({required BleRingLogicControlService logic});

  Future<void> updateMapping(ActionButtonMappingSnapshot mapping);

  Future<void> dispose();
}

/// Read/write/notify ACTION_BUTTON_UUID (parity ringProcess).
final class RingActionButtonMonitor implements BleRingActionButtonMonitor {
  RingActionButtonMonitor(this._runtime);

  final DeviceRuntime _runtime;
  final _logger = const Logger(className: 'RingActionButtonMonitor');

  final _mappingController =
      StreamController<ActionButtonMappingSnapshot>.broadcast();
  final _pressController = StreamController<RingActionButtonType>.broadcast();

  StreamSubscription<List<int>>? _subscription;
  ActionButtonMappingSnapshot? _latestMapping;
  bool _started = false;
  bool _disposed = false;

  @override
  Stream<ActionButtonMappingSnapshot> get mappingStream async* {
    final latest = _latestMapping;
    if (latest != null) yield latest;
    yield* _mappingController.stream;
  }

  @override
  Stream<RingActionButtonType> get pressStream => _pressController.stream;

  @override
  Future<void> start({required BleRingLogicControlService logic}) async {
    if (_disposed || _started) return;
    _started = true;
    _runtime.ensureGattReady();

    await _readAndEmitMapping();

    try {
      final notifyStream = await _runtime.enableNotify(BleRingKey.actionButton);

      _subscription = notifyStream.listen(
        (bytes) {
          if (_disposed || bytes.isEmpty) return;
          final pressed = RingActionButtonType.fromBleIndex(bytes[0]);
          _logger.debug(
            'notify',
            'ActionButton pressed: $pressed (raw: ${bytes[0]})',
          );
          if (!_pressController.isClosed) {
            _pressController.add(pressed);
          }
          if (pressed == RingActionButtonType.logic) {
            unawaited(logic.read());
          }
        },
        onError: (Object e) {
          _logger.warning('notify', 'Action button notify error: $e');
        },
      );
    } catch (e) {
      _logger.warning(
        'start',
        'Action button notifications unavailable '
            '(requires BLUETOOTH_PRIVILEGED on some devices): $e',
      );
      await _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  Future<void> updateMapping(ActionButtonMappingSnapshot mapping) async {
    _runtime.ensureGattReady();
    final data = BleValueDecoders.encodeActionButtonMappingWrite(
      mapping.toCore(),
    );
    await _runtime.writeCharacteristic(BleRingKey.actionButton, data);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _readAndEmitMapping();
  }

  Future<void> _readAndEmitMapping() async {
    try {
      final bytes = await _runtime.readCharacteristic(BleRingKey.actionButton);
      if (bytes.isEmpty) return;
      final decoded = BleValueDecoders.decodeActionButtonMapping(bytes);
      _emitMapping(ActionButtonMappingSnapshot.fromCore(decoded));
      _logger.debug(
        'read',
        'mapping: single=${decoded.single}, double=${decoded.doubleTap}',
      );
    } catch (e) {
      _logger.warning('read', 'Failed to read action button mapping: $e');
    }
  }

  void _emitMapping(ActionButtonMappingSnapshot snapshot) {
    _latestMapping = snapshot;
    if (!_mappingController.isClosed) {
      _mappingController.add(snapshot);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _started = false;
    _latestMapping = null;

    await _subscription?.cancel();
    _subscription = null;

    try {
      await _runtime.disableNotify(BleRingKey.actionButton);
    } catch (e) {
      _logger.warning('dispose', 'Failed to disable action button notify: $e');
    }

    if (!_mappingController.isClosed) {
      await _mappingController.close();
    }
    if (!_pressController.isClosed) {
      await _pressController.close();
    }
  }
}
