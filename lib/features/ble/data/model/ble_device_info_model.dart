import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../domain/entities/ble_device_info.dart';

class BleDeviceInfoModel {
  const BleDeviceInfoModel({
    required this.name,
    required this.firmwareVersion,
    required this.hardwareId,
    required this.resolvedType,
    required this.batteryPercent,
  });

  final String name;
  final String firmwareVersion;
  final String hardwareId;
  final VulcanDeviceType resolvedType;
  final int batteryPercent;

  BleDeviceInfo toEntity() => BleDeviceInfo(
    name: name,
    firmwareVersion: firmwareVersion,
    hardwareId: hardwareId,
    resolvedType: resolvedType,
    batteryPercent: batteryPercent,
  );
}
