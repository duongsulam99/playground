import '../../domain/entities/ble_device_info.dart';

class BleDeviceInfoModel extends BleDeviceInfo {
  const BleDeviceInfoModel({
    required super.name,
    required super.firmwareVersion,
    required super.hardwareId,
    required super.resolvedType,
    required super.batteryPercent,
  });
}
