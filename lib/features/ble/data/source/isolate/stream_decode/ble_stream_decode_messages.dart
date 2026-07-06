import 'dart:typed_data';

/// Minimal request payload sent across the isolate boundary.
final class BleStreamDecodeRequest {
  const BleStreamDecodeRequest({
    required this.requestId,
    required this.rawBytes,
  });

  final int requestId;
  final Uint8List rawBytes;
}
