import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_advertisement_parser.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../domain/entities/ble_discovered_device.dart';

/// DTO thiết bị phát hiện khi scan — trước khi connect.
class BleDiscoveredDeviceModel {
  const BleDiscoveredDeviceModel({
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

  factory BleDiscoveredDeviceModel.fromScanResult(ScanResult result) {
    final advertisementData = result.advertisementData;

    return BleDiscoveredDeviceModel(
      id: result.device.remoteId.str,
      name: advertisementData.advName,
      rssi: result.rssi,
      isConnectable: advertisementData.connectable,
      deviceType: BleAdvertisementParser.parse(advertisementData),
    );
  }

  BleDiscoveredDevice toEntity() => BleDiscoveredDevice(
    id: id,
    name: name,
    rssi: rssi,
    isConnectable: isConnectable,
    deviceType: deviceType,
  );
}
