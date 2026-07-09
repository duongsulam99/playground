import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';

import '../../domain/entities/ble_device_info.dart';

/// DTO metadata thiết bị đọc từ GATT (name, firmware, hardware, pin, …).
class BleDeviceInfoModel {
  const BleDeviceInfoModel({
    required this.name,
    required this.firmwareVersion,
    required this.hardwareId,
    required this.resolvedType,
    required this.batteryPercent,
    this.thresholdConfig,
  });

  final String name;
  final String firmwareVersion;
  final String hardwareId;

  /// Loại thiết bị sau khi resolve từ hardware ID (có thể khác loại lúc scan).
  final VulcanDeviceType resolvedType;

  final int batteryPercent;
  final RingThresholdConfig? thresholdConfig;

  BleDeviceInfo toEntity() => BleDeviceInfo(
    name: name,
    firmwareVersion: firmwareVersion,
    hardwareId: hardwareId,
    resolvedType: resolvedType,
    batteryPercent: batteryPercent,
    thresholdConfig: thresholdConfig,
  );
}
