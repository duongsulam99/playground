import 'package:equatable/equatable.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

class BleDiscoveredDevice extends Equatable {
  const BleDiscoveredDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isConnectable,
    required this.deviceType,
  });

  final String id;
  final String name;
  final int rssi;
  final bool isConnectable;
  final VulcanDeviceType deviceType;

  String get displayName => name.isEmpty ? 'Unknown device' : name;

  @override
  List<Object?> get props => [id, name, rssi, isConnectable, deviceType];
}
