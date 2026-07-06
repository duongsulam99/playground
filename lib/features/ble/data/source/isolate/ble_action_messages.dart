import 'dart:isolate';

/// Worker isolate handshake message sent to the main isolate.
final class BleWorkerReady {
  const BleWorkerReady(this.sendPort);

  final SendPort sendPort;
}

/// Successful RPC payload returned from a worker isolate.
final class BleActionSuccess {
  const BleActionSuccess({required this.requestId, required this.result});

  final int requestId;
  final Object? result;
}

/// Failed RPC payload returned from a worker isolate.
final class BleActionFailure {
  const BleActionFailure({required this.requestId, required this.errorMessage});

  final int requestId;
  final String errorMessage;
}
