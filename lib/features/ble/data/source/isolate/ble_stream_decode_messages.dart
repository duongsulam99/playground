import 'dart:isolate';
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

/// Minimal successful decode payload returned from the worker isolate.
final class BleStreamDecodeSuccess {
  const BleStreamDecodeSuccess({
    required this.requestId,
    required this.voltages,
  });

  final int requestId;
  final List<double> voltages;
}

/// Minimal failure payload returned from the worker isolate.
final class BleStreamDecodeFailure {
  const BleStreamDecodeFailure({
    required this.requestId,
    required this.errorMessage,
  });

  final int requestId;
  final String errorMessage;
}

/// Worker isolate handshake message sent to the main isolate.
final class BleStreamDecodeWorkerReady {
  const BleStreamDecodeWorkerReady(this.sendPort);

  final SendPort sendPort;
}
