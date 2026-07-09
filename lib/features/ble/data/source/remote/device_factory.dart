import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'device_impl.dart';
import 'device/vulcan_myo_band_device.dart';
import 'abstract/ble_device_remote_data_source.dart';

/// Tạo [BleDeviceRemoteDataSource] phù hợp theo [VulcanDeviceType].
///
/// Thêm loại thiết bị mới: tạo subclass và map tại đây (xem TODO bên dưới).
class BleDeviceDataSourceFactory {
  BleDeviceRemoteDataSource create(
    BluetoothDevice device, {
    required VulcanDeviceType deviceType,
  }) {
    switch (deviceType) {
      // TODO:[Add New Device] Step 4: map deviceType mới sang implementation cụ thể
      default:
        if (deviceType.isMyoBandFamily) {
          return VulcanMyoBandDevice(device: device, deviceType: deviceType);
        }

        return BleDeviceRemoteDataSourceImpl(
          device: device,
          deviceType: deviceType,
        );
    }
  }
}
