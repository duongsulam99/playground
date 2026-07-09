import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../../model/ble_device_info_model.dart';
import '../../model/ble_device_stream_snapshot_model.dart';
import '../../model/ble_discovered_device_model.dart';

/// [Abstract Class]
/// Interface for BLE remote data source
abstract class BleRemoteDataSource {
  // BLE ADAPTER
  Stream<BleAdapterStatus> watchAdapterStatus();
  Stream<Map<String, BleDiscoveredDeviceModel>> watchScanResults();
  Future<void> startScan({List<VulcanDeviceType>? filterTypes});
  Future<void> stopScan();

  // BLE DEVICE - CONNECTION
  Future<BleConnectionStatus> connect(String deviceId);
  Stream<BleConnectionStatus>? watchConnectionStatus(String deviceId);
  Future<void> disconnect(String deviceId);

  // BLE DEVICE - DATA
  Future<BleDeviceInfoModel> readDeviceInfo(String deviceId);

  // BLE DEVICE - STREAM (EMG / signal)
  Stream<BleDeviceStreamSnapshotModel>? watchDeviceData(String deviceId);
  Future<void> startDeviceStream(String deviceId);
  Future<void> stopDeviceStream(String deviceId);
}
