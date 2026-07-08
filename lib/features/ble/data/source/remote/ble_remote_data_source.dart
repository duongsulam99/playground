import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../../model/ble_device_info_model.dart';
import '../../model/ble_device_stream_snapshot_model.dart';
import '../../model/ble_discovered_device_model.dart';

abstract class BleRemoteDataSource {
  Stream<BleAdapterStatus> watchAdapterStatus();

  Stream<Map<String, BleDiscoveredDeviceModel>> watchScanResults();

  Future<void> startScan({List<VulcanDeviceType>? filterTypes});

  Future<void> stopScan();

  Future<BleConnectionStatus> connect(String deviceId);

  Stream<BleConnectionStatus>? watchConnectionStatus(String deviceId);

  Future<void> disconnect(String deviceId);

  Future<BleDeviceInfoModel> readDeviceInfo(String deviceId);

  Stream<BleDeviceStreamSnapshotModel>? watchDeviceData(String deviceId);

  Future<void> startDeviceStream(String deviceId);

  Future<void> stopDeviceStream(String deviceId);

  Future<List<int>> readOtaCharacteristic(String deviceId);

  Future<void> writeOtaCharacteristic(
    String deviceId,
    List<int> data, {
    int timeout = 15,
  });

  Future<void> setOtaNotifyEnabled(String deviceId, bool enabled);

  Stream<List<int>> watchOtaNotifications(String deviceId);

  Future<int> requestDeviceMtu(String deviceId, int preferredMtu);
}
