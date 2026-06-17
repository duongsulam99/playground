import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/features/ble/data/model/ble_discovered_device_model.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/ble_remote_data_source.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';

import '../../../domain/constants/ble_scan_config.dart';

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
          isConnectable: result.advertisementData.connectable,
        ),
      );
    }

    return devices;
  }

  @override
  Future<void> startScan() async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (_mapAdapterState(adapterState) != BleAdapterStatus.on) {
      throw const BleAdapterException('Bluetooth adapter is not ready');
    }

    if (FlutterBluePlus.isScanningNow) return;

    _discoveredDevices.clear();

    await FlutterBluePlus.startScan(
      /// Performance tuning
      // timeout: const Duration(seconds: 10),
      removeIfGone: const Duration(seconds: 2),
      continuousUpdates: true, // Update 'lastSeen' & 'rssi'
      continuousDivisor: 20, // 1/10 of advertisements are processed
      /// Optional filters
      withServices: BleScanConfig.advUUIDsGuid,
    );
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
        timeout: const Duration(seconds: 15),
      );
      _connectedDevice = device;
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
    if (cached != null) {
      return cached;
    }

    if (_connectedDevice?.remoteId.str == deviceId) {
      return _connectedDevice!;
    }

    throw BleDeviceNotFoundException(
      'Device $deviceId not found in scan cache',
    );
  }

  BleAdapterStatus _mapAdapterState(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return BleAdapterStatus.unknown;
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
    }
  }
}
