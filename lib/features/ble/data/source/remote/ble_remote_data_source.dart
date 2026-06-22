import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

import '../../model/ble_device_info.dart';
import '../../model/ble_discovered_device_model.dart';

abstract class BleRemoteDataSource {
  Stream<BleAdapterStatus> watchAdapterStatus();

  Stream<List<BleDiscoveredDeviceModel>> watchScanResults();

  Future<void> startScan({List<VulcanDeviceType>? filterTypes});

  Future<void> stopScan();

  Future<BleConnectionStatus> connect(String deviceId);

  Future<void> disconnect(String deviceId);

  Future<BleDeviceInfoModel> readDeviceInfo(String deviceId);
}
