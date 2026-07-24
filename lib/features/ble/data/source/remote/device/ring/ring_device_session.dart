import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../../gatt/ring/reader/ring_reader.dart';
import '../../../../model/ble_device_info_model.dart';
import '../../abstract/capabilities/ble_device_info_source.dart';
import '../../ble_device_runtime.dart';
import 'ring_battery_monitor.dart';

export 'ring_battery_monitor.dart' show BatterySnapshot;

/// Passive session sau connect: battery notify (+ action button / control sau này).
///
/// Cũng là [BleDeviceInfoSource] — đọc metadata GATT qua [GattRingReader].
abstract interface class BleRingDeviceSession implements BleDeviceInfoSource {
  Stream<BatterySnapshot> get batteryStream;

  /// Bật các passive notify (battery, …). Gọi sau connect.
  Future<void> startMonitoring();

  /// Hủy mọi subscription / controller của session.
  Future<void> dispose();
}

/// Session MyoBand/Ring — phase này chỉ compose [RingBatteryMonitor].
final class RingDeviceSession implements BleRingDeviceSession {
  RingDeviceSession(this._runtime) : _battery = RingBatteryMonitor(_runtime);

  final BleDeviceRuntime _runtime;
  final BleRingBatteryMonitor _battery;
  final _logger = const Logger(className: 'RingDeviceSession');

  bool _monitoring = false;
  bool _disposed = false;

  @override
  Stream<BatterySnapshot> get batteryStream => _battery.batteryStream;

  @override
  Future<void> startMonitoring() async {
    if (_disposed || _monitoring) return;
    _monitoring = true;

    _logger.debug(
      'startMonitoring',
      'Starting passive monitors for ${_runtime.deviceId}',
    );

    // Battery only — action button / control / logic notify thêm sau.
    await _battery.start();
  }

  @override
  Future<BleDeviceInfoModel> readDeviceInfo() async {
    _ensureIsMyoBandFamily();
    _runtime.ensureGattReady();

    try {
      return await GattRingReader.readInfo(
        gatt: _runtime,
        scannedType: _runtime.deviceType,
      );
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to read device info: $e',
        deviceId: _runtime.deviceId,
      );
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _monitoring = false;

    await _battery.dispose();
    _logger.debug('dispose', 'Session disposed for ${_runtime.deviceId}');
  }

  void _ensureIsMyoBandFamily() {
    if (!_runtime.deviceType.isMyoBandFamily) {
      throw BleException(
        'Device type ${_runtime.deviceType.name} is not a MyoBand family device',
        deviceId: _runtime.deviceId,
      );
    }
  }
}
