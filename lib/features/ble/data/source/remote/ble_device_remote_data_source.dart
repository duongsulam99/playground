import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../model/ble_device_info_model.dart';

abstract class BleDeviceRemoteDataSource {
  String get deviceId;

  VulcanDeviceType get deviceType;

  Future<BleConnectionStatus> connect();

  Future<void> disconnect();

  Future<BleDeviceInfoModel> readDeviceInfo();

  Stream<BleConnectionStatus> watchConnectionStatus();

  Stream<List<int>>? get notifyDataStream;

  Future<void> startDeviceStream();

  Future<void> stopDeviceStream();

  Future<void> Function()? get onNotifyStopListening;
}
