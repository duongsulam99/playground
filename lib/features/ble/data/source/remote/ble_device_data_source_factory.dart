import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_device_remote_data_source.dart';
import 'flutter_blue_plus_device_data_source.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

class BleDeviceDataSourceFactory {
  BleDeviceRemoteDataSource create(
    BluetoothDevice device, {
    required VulcanDeviceType deviceType,
  }) {
    return FlutterBluePlusDeviceDataSource(
      device: device,
      deviceType: deviceType,
    );
  }
}
