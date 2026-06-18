import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_adv_uuids.dart';
import 'package:vulcan_mobile_playground/core/ble/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/features/ble/data/model/ble_discovered_device_model.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/ble_remote_data_source.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';

class FlutterBluePlusDataSource implements BleRemoteDataSource {
  FlutterBluePlusDataSource();

  BluetoothDevice? _connectedDevice;
  final Map<String, BluetoothDevice> _discoveredDevices = {};

  final _logger = const Logger(className: 'FlutterBluePlusDataSource');

  @override
  Stream<BleAdapterStatus> watchAdapterStatus() {
    return FlutterBluePlus.adapterState.map(_mapAdapterState);
  }

  @override
  Stream<List<BleDiscoveredDeviceModel>> watchScanResults() {
    return FlutterBluePlus.scanResults.map(_processScanResults);
  }

  List<BleDiscoveredDeviceModel> _processScanResults(List<ScanResult> results) {
    if (results.isEmpty) return const [];

    final devices = <BleDiscoveredDeviceModel>[];

    for (final result in results) {
      /// Filter out non-connectable devices
      final ableToConnect = result.advertisementData.connectable;
      if (!ableToConnect) continue;

      final id = result.device.remoteId.str;
      _discoveredDevices[id] = result.device;

      _logger.debug(
        "Advertisement Data: ${result.advertisementData.manufacturerData.toString()}",
      );

      devices.add(
        BleDiscoveredDeviceModel.fromScanResult(
          id: id,
          name: result.advertisementData.advName,
          rssi: result.rssi,
          isConnectable: ableToConnect,
        ),
      );
    }

    return devices;
  }

  @override
  Future<void> startScan({List<VulcanDeviceType>? filterTypes}) async {
    /// Check if adapter is ready
    await _checkAdapterState();
    if (FlutterBluePlus.isScanningNow) return;

    /// Clear discovered devices before new scan
    _discoveredDevices.clear();

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
    final device = _resolveDevice(deviceId);

    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    try {
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 20),
      );

      _connectedDevice = device;

      _logger.debug('Connected to ${_connectedDevice?.remoteId.str}');
      return BleConnectionStatus.connected;
    } catch (e) {
      throw BleException('Failed to connect: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    final device = _connectedDevice;
    if (device == null) {
      throw const BleNotConnectedException();
    }

    try {
      await device.disconnect();
    } finally {
      _connectedDevice = null;
    }
  }

  BluetoothDevice _resolveDevice(String deviceId) {
    final cached = _discoveredDevices[deviceId];
    if (cached != null) return cached;

    if (_connectedDevice?.remoteId.str == deviceId) {
      return _connectedDevice!;
    }

    throw BleDeviceNotFoundException(
      'Device $deviceId not found in scan cache',
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
    if (filterTypes == null) return BleAdvUuids.allVulcanScanGuids();

    /// Map filter types to native scan service UUIDs
    return BleAdvUuids.scanGuidsForDeviceTypes(filterTypes);
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
