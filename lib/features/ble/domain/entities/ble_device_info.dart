import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

class BleDeviceInfo extends Equatable {
  const BleDeviceInfo({
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

  @override
  List<Object?> get props => [
    name,
    firmwareVersion,
    hardwareId,
    resolvedType,
    batteryPercent,
  ];
}
