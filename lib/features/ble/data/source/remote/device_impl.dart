import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'base_ble_device_remote_data_source.dart';
import 'ble_device_runtime.dart';

/// Implementation mặc định cho mọi thiết bị Vulcan (GATT + connect + OTA).
///
/// Stream/info cụ thể do implementation riêng compose [BleDeviceRuntime]
/// (vd. [VulcanMyoBandDevice]).
final class BleDeviceRemoteDataSourceImpl extends BaseBleDeviceRemoteDataSource {
  BleDeviceRemoteDataSourceImpl({required BleDeviceRuntime runtime})
      : super(runtime);

  BleDeviceRemoteDataSourceImpl.fromDevice({
    required BluetoothDevice device,
    required VulcanDeviceType deviceType,
  }) : super(BleDeviceRuntime(device: device, deviceType: deviceType));
}
