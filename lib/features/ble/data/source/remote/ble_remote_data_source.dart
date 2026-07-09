import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../../model/ble_device_info_model.dart';
import '../../model/ble_device_stream_snapshot_model.dart';
import '../../model/ble_discovered_device_model.dart';

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

  // GATT — generic read/write by characteristic key
  Future<List<int>> readCharacteristic(
    String deviceId,
    String characteristicKey,
  );

  Future<void> writeCharacteristic(
    String deviceId,
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  });

  // Firmware update — OTA notify stream & MTU
  /// Bật/tắt notify trên OTA_UUID để nhận ACK khi ESP32 OTA.
  Future<void> setUpdateFirmware(String deviceId, bool enabled);

  /// Stream raw bytes từ OTA_UUID (packet counter ACK, không phải EMG stream).
  Stream<List<int>> watchUpdateNotifications(String deviceId);

  /// MTU đã negotiate lúc connect — dùng tính bytePacket cho ESP32 OTA.
  int getNegotiatedMtu(String deviceId);
}
