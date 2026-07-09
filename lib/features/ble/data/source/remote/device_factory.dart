import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'device_impl.dart';
import 'device/vulcan_myo_band_device.dart';
import 'abstract/ble_device_remote_data_source.dart';

/// Factory class to create [BleDeviceRemoteDataSource] instances based on the [VulcanDeviceType].
/// This allows for different implementations of [BleDeviceRemoteDataSource] for different device types, enabling support for various BLE devices with specific behaviors and characteristics.
class BleDeviceDataSourceFactory {
  /// Create a [BleDeviceRemoteDataSource] based on the [deviceType].
  BleDeviceRemoteDataSource create(
    BluetoothDevice device, {
    required VulcanDeviceType deviceType,
  }) {
    switch (deviceType) {
      // (nếu có lệnh truyền/nhận riêng).
      //TODO:[Add New Device] Step 4: Map kiểu thiết bị mới sang BleDeviceRemoteDataSource cụ thể

      /// Mặc định dùng [FlutterBluePlusPrivateDevice]
      default:

        /// FOR ALL MYO BAND FAMILY
        if (deviceType.isMyoBandFamily) {
          return VulcanMyoBandDevice(device: device, deviceType: deviceType);
        }

        /// FOR UNKNOW DEVICES
        return BleDeviceRemoteDataSourceImpl(
          device: device,
          deviceType: deviceType,
        );
    }
  }
}
