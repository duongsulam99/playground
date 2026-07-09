import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../../model/ble_device_info_model.dart';

/// Contract cho **một** thiết bị BLE đã được tạo instance (thường sau connect).
///
/// Mỗi loại thiết bị có thể override hành vi stream/info; base class cung cấp
/// GATT read/write và OTA dùng chung.
abstract class BleDeviceRemoteDataSource {
  String get deviceId;

  VulcanDeviceType get deviceType;

  // --- Connection ---
  Stream<BleConnectionStatus> watchConnectionStatus();
  Future<BleConnectionStatus> connect();
  Future<void> disconnect();

  // --- Device info ---
  Future<BleDeviceInfoModel> readDeviceInfo();

  // --- Notify stream (EMG / signal) ---
  /// Raw byte stream sau khi bật notify. `null` nếu thiết bị không stream.
  Stream<List<int>>? get notifyDataStream;
  Future<void> startDeviceStream();
  Future<void> stopDeviceStream();

  /// Callback gọi trước disconnect để gửi lệnh dừng stream trên thiết bị.
  Future<void> Function()? get onNotifyStopListening;

  // --- GATT generic (key từ core/ble/gatt/keys) ---
  Future<List<int>> readCharacteristic(String characteristicKey);
  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  });

  // --- Firmware OTA ---
  Future<void> setUpdateFirmware(bool enabled);
  Stream<List<int>> watchUpdateNotifications();
  int getNegotiatedMtu();
}
