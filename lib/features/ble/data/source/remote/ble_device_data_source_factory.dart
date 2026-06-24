import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'device/flutter_blue_plus_private_device.dart';
import 'device/vulcan_myo_band_device.dart';
import 'ble_device_remote_data_source.dart';

class BleDeviceDataSourceFactory {
  BleDeviceRemoteDataSource create(
    BluetoothDevice device, {
    required VulcanDeviceType deviceType,
  }) {
    switch (deviceType) {
      // TODO: Add support for other device types

      default:

        /// FOR ALL MYO BAND FAMILY
        if (deviceType.isMyoBandFamily) {
          return VulcanMyoBandDevice(device: device, deviceType: deviceType);
        }

        /// FOR UNKNOW DEVICES
        return FlutterBluePlusPrivateDevice(
          device: device,
          deviceType: deviceType,
        );
    }
  }
}
