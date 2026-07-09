import 'dart:isolate';

/// Handshake: worker gửi SendPort của mình về main isolate sau khi spawn.
final class BleWorkerReady {
  const BleWorkerReady(this.sendPort);

  final SendPort sendPort;
}

/// RPC response thành công từ worker isolate.
final class BleActionSuccess {
  const BleActionSuccess({required this.requestId, required this.result});

  final int requestId;
  final Object? result;
}

/// RPC response lỗi từ worker isolate.
final class BleActionFailure {
  const BleActionFailure({required this.requestId, required this.errorMessage});

  final int requestId;
  final String errorMessage;
}
