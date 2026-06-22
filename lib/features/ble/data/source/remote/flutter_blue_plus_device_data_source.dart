import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_gatt_collector.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_characteristics_profile.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ble_services_profile.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/data/gatt/myo_band_device_info_reader.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/helper/device_connection_handler.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/myo_band_device_info.dart';

import 'ble_device_remote_data_source.dart';

class FlutterBluePlusDeviceDataSource implements BleDeviceRemoteDataSource {
  FlutterBluePlusDeviceDataSource({
    required BluetoothDevice device,
    required this._deviceType,
  }) : _device = device,
       _connectionHandler = DeviceConnectionHandler(
         deviceId: device.remoteId.str,
         device: device,
       );

  static const String defaultNotifyCharacteristicKey = 'SIGNAL_UUID';
  static const String defaultWriteCharacteristicKey = 'LOGIC_UUID';

  final BluetoothDevice _device;
  final VulcanDeviceType _deviceType;
  final DeviceConnectionHandler _connectionHandler;
  final Map<String, BluetoothCharacteristic> _characteristics = {};
  StreamSubscription<List<int>>? _signalDataSubscription;
  bool _isStreamingSignal = false;

  final _logger = const Logger(className: 'FlutterBluePlusDeviceDataSource');

  @override
  String get deviceId => _device.remoteId.str;

  @override
  VulcanDeviceType get deviceType => _deviceType;

  int get negotiatedMtu => _connectionHandler.currentMtu;

  Stream<List<int>> watchDeviceData() => _connectionHandler.cleanDataStream;

  @override
  Future<BleConnectionStatus> connect() async {
    try {
      await _device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 20),
        mtu: null,
      );

      // await Future.delayed(const Duration(milliseconds: 250));

      /// Discover and collect characteristics
      await _discoverAndCollectCharacteristics();

      /// Setup MTU ( Request MTU munually )
      await _connectionHandler.setupMtu();

      /// Monitor connection
      _connectionHandler.monitorConnection();

      _logger.debug(
        'connect',
        'Connected to $deviceId (MTU: ${_connectionHandler.currentMtu})',
      );

      if (_deviceType.isMyoBandFamily) {
        await _startMyoBandSignalLogging();
      }

      return BleConnectionStatus.connected;
    } catch (e) {
      _connectionHandler.dispose();
      _characteristics.clear();
      if (e is BleException) rethrow;
      throw BleException('Failed to connect: $e', deviceId: deviceId);
    }
  }

  Future<void> startListening(
    String characteristicKey, {
    bool reassembleFrames = true,
  }) async {
    /// Ensure device is connected
    _ensureConnected();

    /// Ensure characteristic is available
    final characteristic = _requireCharacteristic(characteristicKey);

    /// Call Connection Handler To Start Listening
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
    _ensureConnected();
    final characteristic = _requireCharacteristic(characteristicKey);
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

  void _ensureConnected() {
    if (_characteristics.isEmpty) {
      throw BleException(
        'GATT characteristics not collected. Connect first.',
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

    _ensureConnected();

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

  Future<void> _startMyoBandSignalLogging() async {
    await _signalDataSubscription?.cancel();
    _signalDataSubscription = null;
    _isStreamingSignal = false;

    try {
      await writeData(defaultNotifyCharacteristicKey, utf8.encode('255'));

      await startListening(
        defaultNotifyCharacteristicKey,
        reassembleFrames: false,
      );

      _signalDataSubscription = watchDeviceData().listen(
        (frame) {
          _logger.debug(
            'myoBandSignal',
            '${frame.length} bytes: ${_formatBytes(frame)}',
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.error('myoBandSignal', 'Stream error: $error');
        },
      );

      _isStreamingSignal = true;
      _logger.debug(
        'startMyoBandSignalLogging',
        'Listening and logging MyoBand signal for $deviceId',
      );
    } catch (e, st) {
      await _signalDataSubscription?.cancel();
      _signalDataSubscription = null;
      _isStreamingSignal = false;
      _logger.error(
        'startMyoBandSignalLogging',
        'Failed to start MyoBand signal logging: $e\n$st',
      );
    }
  }

  Future<void> _stopMyoBandSignalLogging() async {
    await _signalDataSubscription?.cancel();
    _signalDataSubscription = null;

    if (!_isStreamingSignal || _characteristics.isEmpty) return;

    try {
      await writeData(defaultNotifyCharacteristicKey, utf8.encode('000'));
    } catch (e) {
      _logger.warning(
        'stopMyoBandSignalLogging',
        'Failed to stop MyoBand signal for $deviceId: $e',
      );
    } finally {
      _isStreamingSignal = false;
    }
  }

  String _formatBytes(List<int> bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ');
  }

  @override
  Future<void> disconnect() async {
    try {
      if (_deviceType.isMyoBandFamily) {
        await _stopMyoBandSignalLogging();
      }
      _connectionHandler.dispose();
      _characteristics.clear();
      await _device.disconnect();
      _logger.debug('disconnect', 'Disconnected from $deviceId');
    } catch (e) {
      throw BleException('Failed to disconnect: $e', deviceId: deviceId);
    }
  }
}
