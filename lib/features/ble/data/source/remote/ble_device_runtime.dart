import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_collector.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_reader.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../helper/device_connection_handler.dart';
import 'abstract/capabilities/ble_device_connection.dart';
import 'abstract/capabilities/ble_device_firmware_transport.dart';
import 'abstract/capabilities/ble_device_gatt_access.dart';

/// Runtime nội bộ: connect, GATT discovery, notify/write, OTA cho một thiết bị.
///
/// Không expose ra public contract — device implementations compose qua class này.
class BleDeviceRuntime
    implements
        BleDeviceConnection,
        BleDeviceGattAccess,
        BleDeviceFirmwareTransport {
  BleDeviceRuntime({required BluetoothDevice device, required this._deviceType})
    : _device = device,
      _connectionHandler = DeviceConnectionHandler(device: device);

  final BluetoothDevice _device;
  final VulcanDeviceType _deviceType;
  final DeviceConnectionHandler _connectionHandler;
  final Map<String, BluetoothCharacteristic> _characteristics = {};
  final _logger = const Logger(className: 'BleDeviceRuntime');

  @override
  String get deviceId => _device.remoteId.str;

  @override
  VulcanDeviceType get deviceType => _deviceType;

  @override
  Stream<BleConnectionStatus> watchConnectionStatus() {
    return _device.connectionState.map(_mapConnectionState);
  }

  @override
  Future<BleConnectionStatus> connect() async {
    try {
      await _device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 20),
        mtu: null,
      );

      await _discoverAndCollectCharacteristics();
      await _connectionHandler.setupMtu();
      _connectionHandler.monitorConnection();

      _logger.debug(
        'connect',
        'Connected to $deviceId (MTU: ${_connectionHandler.currentMtu})',
      );

      return BleConnectionStatus.connected;
    } catch (e) {
      _connectionHandler.dispose();
      _characteristics.clear();
      if (e is BleException) rethrow;
      throw BleException('Failed to connect: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _connectionHandler.dispose();
      _characteristics.clear();
      await _device.disconnect();
      _logger.debug('disconnect', 'Disconnected from $deviceId');
    } catch (e) {
      throw BleException('Failed to disconnect: $e', deviceId: deviceId);
    }
  }

  @override
  Future<List<int>> readCharacteristic(String characteristicKey) async {
    ensureGattReady();
    return BleGattReader.read(_characteristics, characteristicKey);
  }

  @override
  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  }) async {
    ensureGattReady();
    final characteristic = _requireCharacteristic(characteristicKey);
    await characteristic.write(data, timeout: timeout);
  }

  @override
  Future<void> writeOta(List<int> data, {int timeout = 15}) =>
      writeCharacteristic(
        _requireOtaCharacteristicKey(),
        data,
        timeout: timeout,
      );

  @override
  Future<void> setUpdateFirmware(bool enabled) async {
    ensureGattReady();
    final characteristic = _requireCharacteristic(
      _requireOtaCharacteristicKey(),
    );
    await characteristic.setNotifyValue(enabled);
  }

  @override
  Stream<List<int>> watchUpdateNotifications() {
    ensureGattReady();
    final characteristic = _requireCharacteristic(
      _requireOtaCharacteristicKey(),
    );
    return characteristic.onValueReceived;
  }

  @override
  int getNegotiatedMtu() => _connectionHandler.currentMtu;

  /// Raw notify stream (chưa decode).
  Stream<List<int>> watchNotifyData() => _connectionHandler.cleanDataStream;

  /// Bật notify. [reassembleFrames] = false khi mỗi notify là một frame hoàn chỉnh.
  Future<void> startListening(
    String characteristicKey, {
    bool reassembleFrames = true,
  }) async {
    ensureGattReady();
    final characteristic = _requireCharacteristic(characteristicKey);
    await _connectionHandler.startListeningData(
      characteristic,
      reassembleFrames: reassembleFrames,
    );
    _logger.debug(
      'startListening',
      'Listening on $characteristicKey for $deviceId',
    );
  }

  /// Ghi payload có thể lớn hơn MTU (chunked qua [DeviceConnectionHandler]).
  Future<void> writeData(String characteristicKey, List<int> data) async {
    ensureGattReady();
    final characteristic = _requireCharacteristic(characteristicKey);
    await _connectionHandler.writeData(characteristic, data);
    _logger.debug(
      'writeData',
      'Wrote ${data.length} bytes to $characteristicKey for $deviceId',
    );
  }

  void ensureGattReady() {
    if (_characteristics.isEmpty) {
      throw BleException(
        'GATT characteristics not collected. Connect first.',
        deviceId: deviceId,
      );
    }
  }

  Future<void> _discoverAndCollectCharacteristics() async {
    final servicesProfile = _deviceType.services;
    final characteristicsProfile = _deviceType.characteristics;

    if (servicesProfile == null || characteristicsProfile == null) {
      throw BleException(
        'Device type ${_deviceType.name} has no BLE GATT profile',
        deviceId: deviceId,
      );
    }

    final services = await _device.discoverServices();

    _logger.debug(
      'discoverServices',
      'Discovered ${services.length} services for $deviceId',
    );

    _characteristics
      ..clear()
      ..addAll(
        BleGattCollector.collect(
          services: services,
          servicesProfile: servicesProfile,
          characteristicsProfile: characteristicsProfile,
        ),
      );

    if (_characteristics.isEmpty) {
      throw BleException(
        'No matching characteristics found after service discovery',
        deviceId: deviceId,
      );
    }
  }

  BluetoothCharacteristic _requireCharacteristic(String key) {
    final characteristic = _characteristics[key];
    if (characteristic == null) {
      throw BleCharacteristicNotFoundException(
        'Characteristic $key not found',
        deviceId: deviceId,
      );
    }
    return characteristic;
  }

  String _requireOtaCharacteristicKey() {
    final key = _deviceType.characteristics?.otaCharacteristicKey;
    if (key == null) {
      throw BleException(
        'Device type ${_deviceType.name} does not support OTA',
        deviceId: deviceId,
      );
    }
    return key;
  }

  BleConnectionStatus _mapConnectionState(BluetoothConnectionState state) {
    if (state == BluetoothConnectionState.connected) {
      return BleConnectionStatus.connected;
    }
    return BleConnectionStatus.disconnected;
  }
}
