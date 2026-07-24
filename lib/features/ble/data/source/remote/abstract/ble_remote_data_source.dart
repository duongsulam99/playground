import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../../../model/ble_discovered_device_model.dart';
import 'ble_device_remote_data_source.dart';

/// Contract cho thao tác BLE global ở data layer.
///
/// Một implementation ([BleRemoteDataSourceImpl]) quản lý adapter, scan,
/// và registry các [BleDeviceRemoteDataSource] đã kết nối.
///
/// Thao tác per-device (info, battery, stream) đi qua [findConnectedDevice]
/// và capabilities trên device source — không expose trên contract này.
abstract class BleRemoteDataSource {
  // --- Adapter & scan ---
  Stream<BleAdapterStatus> watchAdapterStatus();

  /// Map keyed by `deviceId`; mỗi lần emit là snapshot đầy đủ thiết bị đã thấy.
  Stream<Map<String, BleDiscoveredDeviceModel>> watchScanResults();
  Future<void> startScan({List<VulcanDeviceType>? filterTypes});
  Future<void> stopScan();

  // --- Connection ---
  Future<BleConnectionStatus> connect(String deviceId);

  /// Throw [BleNotConnectedException] nếu thiết bị chưa connect.
  Stream<BleConnectionStatus> watchConnectionStatus(String deviceId);
  Future<void> disconnect(String deviceId);

  /// Trả về device source đã connect; throw nếu chưa connect.
  BleDeviceRemoteDataSource findConnectedDevice(String deviceId);
}
