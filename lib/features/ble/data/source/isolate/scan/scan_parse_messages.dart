import 'scan_advertisement_dto.dart';

/// Clears the worker-side discovered-device cache.
final class ScanParseClearCacheRequest {
  const ScanParseClearCacheRequest({required this.requestId});

  final int requestId;
}

/// Processes a scan batch on the worker isolate.
final class ScanParseBatchRequest {
  const ScanParseBatchRequest({
    required this.requestId,
    required this.dtos,
  });

  final int requestId;
  final List<ScanAdvertisementDto> dtos;
}
