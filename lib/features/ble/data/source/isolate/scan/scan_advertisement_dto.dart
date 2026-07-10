import 'dart:typed_data';

/// Serializable BLE advertisement snapshot for isolate communication.
final class ScanAdvertisementDto {
  const ScanAdvertisementDto({
    required this.deviceId,
    required this.advName,
    required this.rssi,
    required this.connectable,
    required this.serviceUuids,
    required this.serviceData,
  });

  final String deviceId;
  final String advName;
  final int rssi;
  final bool connectable;
  final List<String> serviceUuids;

  /// Service data keyed by lowercase UUID string (e.g. `0100`).
  final Map<String, Uint8List> serviceData;
}
