import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';

class BleDeviceInfo extends Equatable {
  const BleDeviceInfo({
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
  final VulcanDeviceType resolvedType;
  final int batteryPercent;
  final RingThresholdConfig? thresholdConfig;

  @override
  List<Object?> get props => [
    name,
    firmwareVersion,
    hardwareId,
    resolvedType,
    batteryPercent,
    thresholdConfig,
  ];
}
