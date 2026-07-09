import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_collector.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../model/ble_device_info_model.dart';
import '../../helper/device_connection_handler.dart';
import '../ble_device_remote_data_source.dart';

/// [Default]
/// Implementation of [BleDeviceRemoteDataSource]
/// This class is used to represent a BLE device that is connected
/// If the device type is not recognized, this class will be used as a default implementation.
class FlutterBluePlusPrivateDevice implements BleDeviceRemoteDataSource {
  FlutterBluePlusPrivateDevice({
    required BluetoothDevice device,
    required this._deviceType,
  }) : _device = device,
       _connectionHandler = DeviceConnectionHandler(
         deviceId: device.remoteId.str,
         device: device,
       );

  final BluetoothDevice _device;
  final VulcanDeviceType _deviceType;
  final DeviceConnectionHandler _connectionHandler;
  final Map<String, BluetoothCharacteristic> _characteristics = {};

  final _logger = const Logger(className: 'FlutterBluePlusPrivateDevice');

  @override
  String get deviceId => _device.remoteId.str;

  @override
  VulcanDeviceType get deviceType => _deviceType;

  @override
  Stream<List<int>>? get notifyDataStream => null;

  @override
  Future<void> Function()? get onNotifyStopListening => null;

  int get negotiatedMtu => _connectionHandler.currentMtu;

  Map<String, BluetoothCharacteristic> get characteristics => _characteristics;

  DeviceConnectionHandler get connectionHandler => _connectionHandler;

  Stream<List<int>> watchDeviceData() => _connectionHandler.cleanDataStream;

  @override
  Stream<BleConnectionStatus> watchConnectionStatus() {
    return _device.connectionState.map(_mapConnectionState);
  }

  BleConnectionStatus _mapConnectionState(BluetoothConnectionState state) {
    if (state == BluetoothConnectionState.connected) {
      return BleConnectionStatus.connected;
    }
    return BleConnectionStatus.disconnected;
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
        'Device connect',
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
  Future<BleDeviceInfoModel> readDeviceInfo() {
    throw BleException(
      'readDeviceInfo is not supported for ${deviceType.name}',
      deviceId: deviceId,
    );
  }

  @override
  Future<RingThresholdConfig?> readThreshold() async => null;

  @override
  Future<void> writeThreshold(RingThresholdConfig config) {
    throw UnimplementedError('writeThreshold is not implemented yet');
  }

  Future<void> startListening(
    String characteristicKey, {
    bool reassembleFrames = true,
  }) async {
    ensureConnected();
    final characteristic = requireCharacteristic(characteristicKey);
    await _connectionHandler.startListeningData(
      characteristic,
      reassembleFrames: reassembleFrames,
    );
    _logger.debug(
      'startListening',
      'Listening on $characteristicKey for $deviceId',
    );
  }

  Future<void> writeData(String characteristicKey, List<int> data) async {
    ensureConnected();
    final characteristic = requireCharacteristic(characteristicKey);
    await _connectionHandler.writeData(characteristic, data);
    _logger.debug(
      'writeData',
      'Wrote ${data.length} bytes to $characteristicKey for $deviceId',
    );
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

    final services = await _discoverServices();

    _collectCharacteristics(
      services: services,
      servicesProfile: servicesProfile,
      characteristicsProfile: characteristicsProfile,
    );
  }

  Future<List<BluetoothService>> _discoverServices() async {
    final services = await _device.discoverServices();

    _logger.debug(
      'discoverServices',
      'Discovered ${services.length} services for $deviceId',
    );

    for (final service in services) {
      _logger.debug('availableService', 'Discovered service ${service.uuid}');
    }

    return services;
  }

  void _collectCharacteristics({
    required List<BluetoothService> services,
    required BleServicesProfile servicesProfile,
    required BleCharacteristicsProfile characteristicsProfile,
  }) {
    _characteristics
      ..clear()
      ..addAll(
        BleGattCollector.collect(
          services: services,
          servicesProfile: servicesProfile,
          characteristicsProfile: characteristicsProfile,
        ),
      );

    _logger.debug('COLLECTED', '${_characteristics.length} characteristics');

    if (_characteristics.isEmpty) {
      throw BleException(
        'No matching characteristics found after service discovery',
        deviceId: deviceId,
      );
    }
  }

  BluetoothCharacteristic requireCharacteristic(String key) {
    final characteristic = _characteristics[key];
    if (characteristic == null) {
      throw BleCharacteristicNotFoundException(
        'Characteristic $key not found',
        deviceId: deviceId,
      );
    }
    return characteristic;
  }

  void ensureConnected() {
    if (_characteristics.isEmpty) {
      throw BleException(
        'GATT characteristics not collected. Connect first.',
        deviceId: deviceId,
      );
    }
  }

  @override
  Future<void> startDeviceStream() {
    throw BleException(
      'Device stream is not supported for ${deviceType.name}',
      deviceId: deviceId,
    );
  }

  @override
  Future<void> stopDeviceStream() async {}

  // Firmware: OTA characteristic key
  static const String _otaKey = 'OTA_UUID';

  @override
  Future<List<int>> readCharacteristic(String characteristicKey) async {
    ensureConnected();
    final characteristic = requireCharacteristic(characteristicKey);
    return characteristic.read();
  }

  @override
  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  }) async {
    ensureConnected();
    final characteristic = requireCharacteristic(characteristicKey);
    await characteristic.write(data, timeout: timeout);
  }

  @override
  Future<void> setUpdateFirmware(bool enabled) async {
    ensureConnected();
    final characteristic = requireCharacteristic(_otaKey);
    await characteristic.setNotifyValue(enabled);
  }

  @override
  Stream<List<int>> watchUpdateNotifications() {
    ensureConnected();
    final characteristic = requireCharacteristic(_otaKey);
    return characteristic.onValueReceived;
  }

  @override
  int getNegotiatedMtu() => negotiatedMtu;

  @override
  Future<void> disconnect() async {
    try {
      await onNotifyStopListening?.call();
      _connectionHandler.dispose();
      _characteristics.clear();
      await _device.disconnect();
      _logger.debug('disconnect', 'Disconnected from $deviceId');
    } catch (e) {
      throw BleException('Failed to disconnect: $e', deviceId: deviceId);
    }
  }
}
