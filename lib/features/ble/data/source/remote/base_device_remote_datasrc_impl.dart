import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'base_device_remote_datasrc.dart';
import 'device_runtime.dart';

/// Implementation mặc định cho mọi thiết bị Vulcan (GATT + connect + OTA).
///
/// Stream/info cụ thể do implementation riêng compose [BleDeviceRuntime]
/// (vd. [VulcanMyoBandDevice]).
final class BaseDeviceRemoteDSImpl extends BaseDeviceRemoteDS {
  BaseDeviceRemoteDSImpl({required DeviceRuntime runtime}) : super(runtime);

  BaseDeviceRemoteDSImpl.fromDevice({
    required BluetoothDevice device,
    required VulcanDeviceType deviceType,
  }) : super(DeviceRuntime(device: device, deviceType: deviceType));
}
