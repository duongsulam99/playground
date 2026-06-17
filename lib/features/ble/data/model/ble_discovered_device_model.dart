import '../../domain/entities/ble_discovered_device.dart';

class BleDiscoveredDeviceModel extends BleDiscoveredDevice {
  const BleDiscoveredDeviceModel({
    required super.id,
    required super.name,
    required super.rssi,
    required super.isConnectable,
  });

  factory BleDiscoveredDeviceModel.fromScanResult({
    required String id,
    required String name,
    required int rssi,
    required bool isConnectable,
  }) {
    return BleDiscoveredDeviceModel(
      id: id,
      name: name,
      rssi: rssi,
      isConnectable: isConnectable,
    );
  }
}
