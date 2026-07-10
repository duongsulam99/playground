import 'package:vulcan_mobile_playground/core/ble/helper/ble_advertisement_parser.dart';
import 'package:vulcan_mobile_playground/core/ble/helper/ble_device_image_resolver.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../domain/entities/ble_discovered_device.dart';
import '../source/isolate/scan/scan_advertisement_dto.dart';

/// DTO thiết bị phát hiện khi scan — trước khi connect.
class BleDiscoveredDeviceModel {
  const BleDiscoveredDeviceModel({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isConnectable,
    required this.deviceType,
    this.imageAssetPath,
  });

  final String id;
  final String name;
  final int rssi;
  final bool isConnectable;
  final VulcanDeviceType deviceType;
  final String? imageAssetPath;

  factory BleDiscoveredDeviceModel.fromAdvertisementDto(
    ScanAdvertisementDto dto,
  ) {
    final deviceType = BleAdvertisementParser.parseFromDto(dto);

    return BleDiscoveredDeviceModel(
      id: dto.deviceId,
      name: dto.advName,
      rssi: dto.rssi,
      isConnectable: dto.connectable,
      deviceType: deviceType,
      imageAssetPath: BleDeviceImageResolver.assetPathFor(deviceType),
    );
  }

  BleDiscoveredDevice toEntity() => BleDiscoveredDevice(
    id: id,
    name: name,
    rssi: rssi,
    isConnectable: isConnectable,
    deviceType: deviceType,
    imageAssetPath: imageAssetPath,
  );
}
