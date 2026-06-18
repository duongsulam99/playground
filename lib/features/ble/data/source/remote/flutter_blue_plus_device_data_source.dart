import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

import 'ble_device_remote_data_source.dart';

class FlutterBluePlusDeviceDataSource implements BleDeviceRemoteDataSource {
  FlutterBluePlusDeviceDataSource({required this._device});

  final BluetoothDevice _device;
  final _logger = const Logger(className: 'FlutterBluePlusDeviceDataSource');

  @override
  String get deviceId => _device.remoteId.str;

  @override
  Future<BleConnectionStatus> connect() async {
    try {
      await _device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 20),
      );

      _logger.debug("connect", 'Connected to $deviceId');
      return BleConnectionStatus.connected;
    } catch (e) {
      throw BleException('Failed to connect: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _device.disconnect();
      _logger.debug("disconnect", 'Disconnected from $deviceId');
    } catch (e) {
      throw BleException('Failed to disconnect: $e', deviceId: deviceId);
    }
  }
}
