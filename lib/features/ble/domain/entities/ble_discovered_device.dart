import 'package:equatable/equatable.dart';

class BleDiscoveredDevice extends Equatable {
  const BleDiscoveredDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isConnectable,
  });

  final String id;
  final String name;
  final int rssi;
  final bool isConnectable;

  String get displayName => name.isEmpty ? 'Unknown device' : name;

  @override
  List<Object?> get props => [id, name, rssi, isConnectable];
}
