import '../../../../model/ble_device_info_model.dart';

/// Structured device info read. Optional per device type.
abstract interface class BleDeviceInfoSource {
  Future<BleDeviceInfoModel> readDeviceInfo();
}
