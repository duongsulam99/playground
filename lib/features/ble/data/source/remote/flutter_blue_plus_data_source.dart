import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/features/ble/data/model/ble_discovered_device_model.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/ble_remote_data_source.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';

class FlutterBluePlusDataSource implements BleRemoteDataSource {
  FlutterBluePlusDataSource();

  BluetoothDevice? _connectedDevice;
  final Map<String, BluetoothDevice> _discoveredDevices = {};

  @override
  Stream<BleAdapterStatus> watchAdapterStatus() {
    return FlutterBluePlus.adapterState.map(_mapAdapterState);
  }

  @override
  Stream<List<BleDiscoveredDeviceModel>> watchScanResults() {
    return FlutterBluePlus.scanResults.map((results) {
      for (final result in results) {
        _discoveredDevices[result.device.remoteId.str] = result.device;
      }

      return results
          .map(
            (result) => BleDiscoveredDeviceModel.fromScanResult(
              id: result.device.remoteId.str,
              name: result.advertisementData.advName,
              rssi: result.rssi,
              isConnectable: result.advertisementData.connectable,
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> startScan() async {
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (_mapAdapterState(adapterState) != BleAdapterStatus.on) {
      throw const BleAdapterException('Bluetooth adapter is not ready');
    }

    if (FlutterBluePlus.isScanningNow) return;

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
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
