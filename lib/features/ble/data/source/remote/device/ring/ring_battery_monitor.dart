import 'package:equatable/equatable.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/ring/key.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_battery_snapshot.dart';

import '../../ble_device_runtime.dart';

/// Snapshot pin từ BATTERY_UUID: byte[0]=%, byte[1]=0x2B nếu đang sạc.
final class BatterySnapshot extends Equatable {
  const BatterySnapshot({
    required this.percent,
    required this.isCharging,
  });

  final int percent;
  final bool isCharging;

  /// '+' = 0x2B = 43 — cùng convention với app chính (ringProcess).
  static const int _chargingMarker = 0x2B;

  factory BatterySnapshot.fromBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      return const BatterySnapshot(percent: 0, isCharging: false);
    }
    return BatterySnapshot(
      percent: bytes[0],
      isCharging: bytes.length > 1 && bytes[1] == _chargingMarker,
    );
  }

  BleBatterySnapshot toEntity() => BleBatterySnapshot(
    percent: percent,
    isCharging: isCharging,
  );

  @override
  List<Object?> get props => [percent, isCharging];
}

/// Passive battery notify trên MyoBand/Ring.
abstract interface class BleRingBatteryMonitor {
  Stream<BatterySnapshot> get batteryStream;

  Future<void> start();

  Future<void> dispose();
}

/// Subscribe BATTERY_UUID notify + one-shot read giá trị ban đầu.
///
/// Fail silently nếu notify không khả dụng (giống ringProcess.subscribeBattery).
///
/// [batteryStream] replay snapshot mới nhất cho listener đăng ký muộn — tránh mất
/// event khi Bloc subscribe sau [start] (broadcast không buffer).
final class RingBatteryMonitor implements BleRingBatteryMonitor {
  RingBatteryMonitor(this._runtime);

  final BleDeviceRuntime _runtime;
  final _logger = const Logger(className: 'RingBatteryMonitor');

  final _controller = StreamController<BatterySnapshot>.broadcast();
  StreamSubscription<List<int>>? _subscription;
  BatterySnapshot? _latest;
  bool _started = false;
  bool _disposed = false;

  @override
  Stream<BatterySnapshot> get batteryStream async* {
    final latest = _latest;
    if (latest != null) yield latest;
    yield* _controller.stream;
  }

  @override
  Future<void> start() async {
    if (_disposed || _started) return;
    _started = true;

    _runtime.ensureGattReady();

    try {
      final notifyStream = await _runtime.enableNotify(BleRingKey.battery);

      _subscription = notifyStream.listen(
        (bytes) {
          if (_disposed || _controller.isClosed) return;
          _emit(BatterySnapshot.fromBytes(bytes));
          _logger.debug(
            'notify',
            'battery=${_latest!.percent}%, charging=${_latest!.isCharging}',
          );
        },
        onError: (Object e) {
          _logger.warning('notify', 'Battery notify error: $e');
        },
      );
    } catch (e) {
      _logger.warning(
        'start',
        'Battery monitoring unavailable '
        '(requires BLUETOOTH_PRIVILEGED on some devices): $e',
      );
      await _subscription?.cancel();
      _subscription = null;
    }

    await _emitInitialRead();
  }

  Future<void> _emitInitialRead() async {
    try {
      final bytes = await _runtime.readCharacteristic(BleRingKey.battery);
      if (_disposed || _controller.isClosed) return;

      _emit(BatterySnapshot.fromBytes(bytes));
      _logger.debug(
        'read',
        'battery=${_latest!.percent}%, charging=${_latest!.isCharging}',
      );

      // Retry sau 1s nếu pin = 0 (giống ringProcess.getBattery).
      if (_latest!.percent == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 1000));
        if (_disposed || _controller.isClosed) return;

        final retry = await _runtime.readCharacteristic(BleRingKey.battery);
        if (_disposed || _controller.isClosed) return;

        _emit(BatterySnapshot.fromBytes(retry));
        _logger.debug(
          'readRetry',
          'battery=${_latest!.percent}%, charging=${_latest!.isCharging}',
        );
      }
    } catch (e) {
      _logger.warning('read', 'Failed to read battery: $e');
      if (e is BleException) {
        // Keep monitoring if notify already started; do not rethrow.
      }
    }
  }

  void _emit(BatterySnapshot snapshot) {
    _latest = snapshot;
    if (!_controller.isClosed) {
      _controller.add(snapshot);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _started = false;
    _latest = null;

    await _subscription?.cancel();
    _subscription = null;

    try {
      await _runtime.disableNotify(BleRingKey.battery);
    } catch (e) {
      _logger.warning('dispose', 'Failed to disable battery notify: $e');
    }

    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
