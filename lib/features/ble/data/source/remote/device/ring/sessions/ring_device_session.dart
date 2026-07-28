import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_action_button_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_logic_control.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../../../gatt/ring/reader/ring_reader.dart';
import '../../../../../model/ble_device_info_model.dart';
import '../../../abstract/capabilities/info_source.dart';
import '../../../device_runtime.dart';
import 'ring_action_button_monitor.dart';
import 'ring_battery_monitor.dart';
import 'ring_logic_control_service.dart';

export 'ring_action_button_monitor.dart' show ActionButtonMappingSnapshot;
export 'ring_battery_monitor.dart' show BatterySnapshot;

/// Passive session sau connect: battery, action button, logic control.
///
/// Cũng là [InfoSource] — đọc metadata GATT qua [GattRingReader].
abstract interface class BleRingDeviceSession implements InfoSource {
  Stream<BatterySnapshot> get batteryStream;

  Stream<ActionButtonMappingSnapshot> get actionButtonMappingStream;

  Stream<RingActionButtonType> get actionButtonPressStream;

  Stream<RingLogicControl> get logicControlStream;

  Future<void> updateActionButtonMapping(ActionButtonMappingSnapshot mapping);

  Future<void> updateLogicControl(RingLogicControl logic);

  /// Bật các passive notify (battery, action button, …). Gọi sau connect.
  Future<void> startMonitoring();

  /// Hủy mọi subscription / controller của session.
  Future<void> dispose();
}

/// Session MyoBand/Ring — battery + action button + logic control.
final class RingDeviceSession implements BleRingDeviceSession {
  RingDeviceSession(this._runtime)
    : _battery = RingBatteryMonitor(_runtime),
      _logic = RingLogicControlService(_runtime),
      _actionButton = RingActionButtonMonitor(_runtime);

  final DeviceRuntime _runtime;
  final BleRingBatteryMonitor _battery;
  final BleRingLogicControlService _logic;
  final BleRingActionButtonMonitor _actionButton;
  final _logger = const Logger(className: 'RingDeviceSession');

  bool _monitoring = false;
  bool _disposed = false;

  @override
  Stream<BatterySnapshot> get batteryStream => _battery.batteryStream;

  @override
  Stream<ActionButtonMappingSnapshot> get actionButtonMappingStream =>
      _actionButton.mappingStream;

  @override
  Stream<RingActionButtonType> get actionButtonPressStream =>
      _actionButton.pressStream;

  @override
  Stream<RingLogicControl> get logicControlStream => _logic.logicStream;

  @override
  Future<void> updateActionButtonMapping(ActionButtonMappingSnapshot mapping) =>
      _actionButton.updateMapping(mapping);

  @override
  Future<void> updateLogicControl(RingLogicControl logic) =>
      _logic.update(logic);

  @override
  Future<void> startMonitoring() async {
    if (_disposed || _monitoring) return;
    _monitoring = true;

    _logger.debug(
      'startMonitoring',
      'Starting passive monitors for ${_runtime.deviceId}',
    );

    await _logic.start();
    await _battery.start();
    await _actionButton.start(logic: _logic);
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

    await _actionButton.dispose();
    await _battery.dispose();
    await _logic.dispose();
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
