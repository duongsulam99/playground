import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_collector.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/data/gatt/myo_band_device_info_reader.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/myo_band_device_info.dart';

import 'ble_device_remote_data_source.dart';

class FlutterBluePlusDeviceDataSource implements BleDeviceRemoteDataSource {
  FlutterBluePlusDeviceDataSource({
    required this._device,
    required this._deviceType,
  });

  final BluetoothDevice _device;
  final VulcanDeviceType _deviceType;
  final Map<String, BluetoothCharacteristic> _characteristics = {};
  final _logger = const Logger(className: 'FlutterBluePlusDeviceDataSource');

  @override
  String get deviceId => _device.remoteId.str;

  @override
  VulcanDeviceType get deviceType => _deviceType;

  @override
  Future<BleConnectionStatus> connect() async {
    try {
      await _device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 20),
      );

      // await Future.delayed(const Duration(milliseconds: 250));
      await _discoverAndCollectCharacteristics();

      _logger.debug('connect', 'Connected to $deviceId');
      return BleConnectionStatus.connected;
    } catch (e) {
      _characteristics.clear();
      if (e is BleException) rethrow;
      throw BleException('Failed to connect: $e', deviceId: deviceId);
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

    /// Find/Discover available services
    final services = await _discoverServices();

    /// Collect available characteristics
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

    _logger.debug(
      'collectCharacteristics',
      'Collected ${_characteristics.length} characteristics',
    );

    if (_characteristics.isEmpty) {
      throw BleException(
        'No matching characteristics found after service discovery',
        deviceId: deviceId,
      );
    }
  }

  @override
  Future<MyoBandDeviceInfo> readMyoBandDeviceInfo() async {
    if (!_deviceType.isMyoBandFamily) {
      throw BleException(
        'Device type ${_deviceType.name} is not a MyoBand family device',
        deviceId: deviceId,
      );
    }

    if (_characteristics.isEmpty) {
      throw BleException(
        'GATT characteristics not collected. Connect first.',
        deviceId: deviceId,
      );
    }

    try {
      return MyoBandDeviceInfoReader.read(
        characteristics: _characteristics,
        scannedType: _deviceType,
      );
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to read MyoBand info: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      _characteristics.clear();
      await _device.disconnect();
      _logger.debug('disconnect', 'Disconnected from $deviceId');
    } catch (e) {
      throw BleException('Failed to disconnect: $e', deviceId: deviceId);
    }
  }
}
