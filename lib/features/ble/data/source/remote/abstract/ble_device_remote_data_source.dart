import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../../model/ble_device_info_model.dart';

/// [Abstract Class]
/// Interface for (each) BLE device remote data source
/// (e.g. FlutterBluePlusPrivateDevice, VulcanMyoBandDevice)
abstract class BleDeviceRemoteDataSource {
  String get deviceId;

  VulcanDeviceType get deviceType;

  // Device - Connection
  Stream<BleConnectionStatus> watchConnectionStatus();
  Future<BleConnectionStatus> connect();
  Future<void> disconnect();

  // Device - Data Info
  Future<BleDeviceInfoModel> readDeviceInfo();

  // Device - Stream (EMG / signal)
  Stream<List<int>>? get notifyDataStream;
  Future<void> startDeviceStream();
  Future<void> stopDeviceStream();
  Future<void> Function()? get onNotifyStopListening;

  // GATT — generic read/write by characteristic key
  Future<List<int>> readCharacteristic(String characteristicKey);
  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  });

  // Firmware update — OTA notify stream & MTU
  Future<void> setUpdateFirmware(bool enabled);
  Stream<List<int>> watchUpdateNotifications();

  // Lấy MTU hiện tại đã negotiate lúc connect
  int getNegotiatedMtu();
}
