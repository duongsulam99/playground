import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'scan_advertisement_dto.dart';

/// Maps native [ScanResult] to [ScanAdvertisementDto] on the main isolate.
class ScanAdvertisementMapper {
  const ScanAdvertisementMapper._();

  static ScanAdvertisementDto fromScanResult(ScanResult result) {
    final advertisementData = result.advertisementData;
    final serviceData = <String, Uint8List>{};

    for (final entry in advertisementData.serviceData.entries) {
      serviceData[entry.key.str.toLowerCase()] = Uint8List.fromList(
        entry.value,
      );
    }

    return ScanAdvertisementDto(
      deviceId: result.device.remoteId.str,
      advName: advertisementData.advName,
      rssi: result.rssi,
      connectable: advertisementData.connectable,
      serviceUuids: advertisementData.serviceUuids.map((e) => e.str).toList(),
      serviceData: serviceData,
    );
  }
}
