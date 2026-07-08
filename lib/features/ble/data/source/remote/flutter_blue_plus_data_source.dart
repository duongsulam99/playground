import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_vulcan_profiles.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../../model/ble_device_info_model.dart';
import '../../model/ble_device_stream_snapshot_model.dart';
import '../../model/ble_discovered_device_model.dart';
import '../isolate/stream_decode/ble_stream_decode_isolate.dart';
import 'ble_device_data_source_factory.dart';
import 'ble_device_remote_data_source.dart';
import 'ble_remote_data_source.dart';

class FlutterBluePlusDataSource implements BleRemoteDataSource {
  FlutterBluePlusDataSource({
    required this._deviceFactory,
    required this._decodeIsolate,
  });

  final BleDeviceDataSourceFactory _deviceFactory;
  final BleStreamDecodeIsolate _decodeIsolate;

  // SAVED DEVICES
  final Map<String, BleDeviceRemoteDataSource> _connectedDevices = {};
  final Map<String, BleDiscoveredDeviceModel> _discoveredDevices = {};
  final Map<String, BluetoothDevice> _bluetoothDevices = {};

  final _logger = const Logger(className: 'FlutterBluePlusDataSource');

  // STREAMS
  @override
  Stream<BleAdapterStatus> watchAdapterStatus() {
    return FlutterBluePlus.adapterState.map(_mapAdapterState);
  }

  @override
  Stream<Map<String, BleDiscoveredDeviceModel>> watchScanResults() {
    return FlutterBluePlus.scanResults.map(_processScanResults);
  }

  // ACTIONS
  Map<String, BleDiscoveredDeviceModel> _processScanResults(
    List<ScanResult> results,
  ) {
    if (results.isEmpty) return const {};

    /// Process every scan result
    for (final result in results) {
      /// Filter out non-connectable devices
      final ableToConnect = result.advertisementData.connectable;
      if (!ableToConnect) continue;

      /// Extract device info [id]
      final id = result.device.remoteId.str;

      /// Convert scan result to BleDiscoveredDeviceModel
      final model = BleDiscoveredDeviceModel.fromScanResult(result);

      /// Cache discovered device
      _discoveredDevices[id] = model;

      /// Cache bluetooth device
      _bluetoothDevices[id] = result.device;
    }

    return Map<String, BleDiscoveredDeviceModel>.from(_discoveredDevices);
  }

  @override
  Future<void> startScan({List<VulcanDeviceType>? filterTypes}) async {
    /// Check if adapter is ready
    await _checkAdapterState();
    if (FlutterBluePlus.isScanningNow) return;

    /// Clear discovered devices before new scan
    _discoveredDevices.clear();
    _bluetoothDevices.clear();

    /// Get scan GUIDs based on filter types
    final guids = _getScanGuids(filterTypes);

    /// Configure and start scan
    await _configScan(guids);
  }

  @override
  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  @override
  Future<BleConnectionStatus> connect(String deviceId) async {
    final existing = _connectedDevices[deviceId];
    if (existing != null) return BleConnectionStatus.connected;

    final discovered = _discoveredDevices[deviceId];
    final bluetoothDevice = _resolveBluetoothDevice(deviceId);
    final deviceType = discovered?.deviceType ?? VulcanDeviceType.none;

    if (deviceType == VulcanDeviceType.none) {
      throw BleException(
        'Unknown device type for $deviceId',
        deviceId: deviceId,
      );
    }

    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    final deviceSource = _deviceFactory.create(
      bluetoothDevice,
      deviceType: deviceType,
    );

    try {
      final status = await deviceSource.connect();
      _connectedDevices[deviceId] = deviceSource;
      _logger.debug(
        'connect',
        'Device $deviceId added to connected devices map',
      );
      return status;
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to connect: $e', deviceId: deviceId);
    }
  }

  @override
  Stream<BleDeviceStreamSnapshotModel>? watchDeviceData(String deviceId) {
    final deviceSource = _findDeviceConnected(deviceId);

    /// RETURN NULL IF DEVICE DOESN'T SUPPORT STREAM
    final raw = deviceSource.notifyDataStream;
    if (raw == null) return null;

    return _decodeIsolate.decodeStream(source: raw, deviceId: deviceId);
  }

  @override
  Stream<BleConnectionStatus>? watchConnectionStatus(String deviceId) {
    final deviceSource = _findDeviceConnected(deviceId);

    return deviceSource.watchConnectionStatus().map((status) {
      if (status == BleConnectionStatus.disconnected) {
        _connectedDevices.remove(deviceId);
      }
      return status;
    });
  }

  @override
  Future<BleDeviceInfoModel> readDeviceInfo(String deviceId) async {
    final deviceSource = _findDeviceConnected(deviceId);

    try {
      return await deviceSource.readDeviceInfo();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to read device info: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> disconnect(String deviceId) async {
    final deviceSource = _findDeviceConnected(deviceId);

    /// REMOVE DEVICE FROM CONNECTED MAP
    _connectedDevices.remove(deviceId);

    try {
      await deviceSource.disconnect();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to disconnect: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> startDeviceStream(String deviceId) async {
    final deviceSource = _findDeviceConnected(deviceId);

    try {
      await deviceSource.startDeviceStream();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to start device stream: $e',
        deviceId: deviceId,
      );
    }
  }

  @override
  Future<void> stopDeviceStream(String deviceId) async {
    final deviceSource = _findDeviceConnected(deviceId);

    try {
      await deviceSource.stopDeviceStream();
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to stop device stream: $e',
        deviceId: deviceId,
      );
    }
  }

  @override
  Future<List<int>> readOtaCharacteristic(String deviceId) {
    return _findDeviceConnected(deviceId).readOtaCharacteristic();
  }

  @override
  Future<void> writeOtaCharacteristic(
    String deviceId,
    List<int> data, {
    int timeout = 15,
  }) {
    return _findDeviceConnected(deviceId).writeOtaCharacteristic(
      data,
      timeout: timeout,
    );
  }

  @override
  Future<void> setOtaNotifyEnabled(String deviceId, bool enabled) {
    return _findDeviceConnected(deviceId).setOtaNotifyEnabled(enabled);
  }

  @override
  Stream<List<int>> watchOtaNotifications(String deviceId) {
    return _findDeviceConnected(deviceId).watchOtaNotifications();
  }

  @override
  int getNegotiatedMtu(String deviceId) {
    return _findDeviceConnected(deviceId).getNegotiatedMtu();
  }

  BleDeviceRemoteDataSource _findDeviceConnected(String deviceId) {
    /// FIND DEVICE IN LINKED MAP O(1) WITH ID
    final deviceSource = _connectedDevices[deviceId];

    /// THROW EXCEPTION
    if (deviceSource == null) {
      throw BleNotConnectedException(
        'Device $deviceId is not connected',
        deviceId: deviceId,
      );
    }

    /// RETURN DEVICE
    return deviceSource;
  }

  BluetoothDevice _resolveBluetoothDevice(String deviceId) {
    final cached = _bluetoothDevices[deviceId];
    if (cached != null) return cached;

    if (_connectedDevices.containsKey(deviceId)) {
      return BluetoothDevice.fromId(deviceId);
    }

    throw BleDeviceNotFoundException(
      'Device $deviceId not found in scan cache',
      deviceId: deviceId,
    );
  }

  Future<void> _configScan(
    List<Guid> guids, {
    Duration? timeout,
    Duration removeIfGone = const Duration(seconds: 10),
    bool continuousUpdates = true,
    int continuousDivisor = 10,
  }) {
    return FlutterBluePlus.startScan(
      /// Stop scan after [timeout]
      /// Default is null ( no timeout )
      timeout: timeout,

      /// Remove devices after [removeIfGone]
      removeIfGone: removeIfGone,

      /// Update 'lastSeen' & 'rssi'
      continuousUpdates: continuousUpdates,

      /// Update 'lastSeen' every 10 scans
      continuousDivisor: continuousDivisor,

      /// Optional filters
      withServices: guids,
    );
  }

  Future<void> _checkAdapterState() async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (_mapAdapterState(adapterState) != BleAdapterStatus.on) {
      throw const BleAdapterException('Bluetooth adapter is not ready');
    }
  }

  List<Guid> _getScanGuids(List<VulcanDeviceType>? filterTypes) {
    /// If no filter types are provided, return all scan GUIDs
    if (filterTypes == null) return BleVulcanProfiles.allVulcanScanGuids();

    /// Map filter types to native scan service UUIDs
    return BleVulcanProfiles.scanGuidsForDeviceTypes(filterTypes);
  }

  BleAdapterStatus _mapAdapterState(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unavailable:
        return BleAdapterStatus.unavailable;
      case BluetoothAdapterState.unauthorized:
        return BleAdapterStatus.unauthorized;
      case BluetoothAdapterState.turningOn:
        return BleAdapterStatus.turningOn;
      case BluetoothAdapterState.on:
        return BleAdapterStatus.on;
      case BluetoothAdapterState.turningOff:
        return BleAdapterStatus.turningOff;
      case BluetoothAdapterState.off:
        return BleAdapterStatus.off;
      default:
        return BleAdapterStatus.unknown;
    }
  }
}
