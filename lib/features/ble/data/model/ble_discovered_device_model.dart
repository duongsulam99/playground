import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/ble_advertisement_parser.dart';

import '../../domain/entities/ble_discovered_device.dart';

class BleDiscoveredDeviceModel extends BleDiscoveredDevice {
  const BleDiscoveredDeviceModel({
    required super.id,
    required super.name,
    required super.rssi,
    required super.isConnectable,
    required super.deviceType,
  });

  factory BleDiscoveredDeviceModel.fromScanResult(ScanResult result) {
    final advertisementData = result.advertisementData;

    return BleDiscoveredDeviceModel(
      id: result.device.remoteId.str,
      name: advertisementData.advName,
      rssi: result.rssi,
      isConnectable: advertisementData.connectable,

      /// Specific device type [VulcanDeviceType]
      deviceType: BleAdvertisementParser.parse(advertisementData),
    );
  }
}
