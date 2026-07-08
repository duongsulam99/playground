import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';

import '../../model/ble_device_info_model.dart';

abstract class BleDeviceRemoteDataSource {
  String get deviceId;

  VulcanDeviceType get deviceType;

  Future<BleConnectionStatus> connect();

  Future<void> disconnect();

  Future<BleDeviceInfoModel> readDeviceInfo();

  Future<RingThresholdConfig?> readThreshold();

  Future<void> writeThreshold(RingThresholdConfig config);

  Stream<BleConnectionStatus> watchConnectionStatus();

  Stream<List<int>>? get notifyDataStream;

  Future<void> startDeviceStream();

  Future<void> stopDeviceStream();

  Future<void> Function()? get onNotifyStopListening;

  Future<List<int>> readOtaCharacteristic();

  Future<void> writeOtaCharacteristic(List<int> data, {int timeout});

  Future<void> setOtaNotifyEnabled(bool enabled);

  Stream<List<int>> watchOtaNotifications();

  Future<int> requestDeviceMtu(int preferredMtu);
}
