import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_device_remote_data_source.dart';
import 'flutter_blue_plus_device_data_source.dart';

class BleDeviceDataSourceFactory {
  BleDeviceRemoteDataSource create(BluetoothDevice device) {
    return FlutterBluePlusDeviceDataSource(device: device);
  }
}
