import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import 'action_message.dart';

/// Base class for long-lived BLE worker isolates with RPC-style messaging.
abstract class BleActionIsolate<TResult> {
  @protected
  BleActionIsolate({
    required this._isolate,
    required this.workerSendPort,
    required this._responsePort,
    required this._responseSubscription,
  });

  final Isolate _isolate;
  @protected
  final SendPort workerSendPort;
  final ReceivePort _responsePort;
  final StreamSubscription<Object?> _responseSubscription;

  final Map<int, Completer<TResult>> _pending = {};
  int _nextRequestId = 0;

  /// Spawns the worker isolate and waits for the [BleWorkerReady] handshake.
  static Future<T> create<T extends BleActionIsolate<TResult>, TResult>({
    required void Function(SendPort) workerEntryPoint,
    required T Function({
      required Isolate isolate,
      required SendPort workerSendPort,
      required ReceivePort responsePort,
      required StreamSubscription<Object?> responseSubscription,
    })
    constructor,
  }) async {
    final responsePort = ReceivePort();
    final readyCompleter = Completer<BleWorkerReady>();
    late final T instance;

    final responseSubscription = responsePort.listen((message) {
      if (_isWorkerReadyHandshake(message, readyCompleter)) return;
      instance.handleWorkerMessage(message);
    });

    final isolate = await Isolate.spawn(
      workerEntryPoint,
      responsePort.sendPort,
    );

    final readyMessage = await readyCompleter.future;
    instance = constructor(
      isolate: isolate,
      workerSendPort: readyMessage.sendPort,
      responsePort: responsePort,
      responseSubscription: responseSubscription,
    );

    return instance;
  }

  @protected
  int registerRequest(Completer<TResult> completer) {
    final requestId = _nextRequestId++;
    _pending[requestId] = completer;
    return requestId;
  }

  @protected
  void sendToWorker(Object message) => workerSendPort.send(message);

  @protected
  void removePendingRequest(int requestId) => _pending.remove(requestId);

  @protected
  void cancelPendingRequest(int requestId, Object error) {
    final completer = _pending.remove(requestId);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error);
    }
  }

  @protected
  void cancelAllPendingRequests(Object error) {
    for (final requestId in _pending.keys.toList()) {
      cancelPendingRequest(requestId, error);
    }
  }

  @protected
  bool get hasPendingRequests => _pending.isNotEmpty;

  /// Resolves an RPC response from the worker into the matching completer.
  void handleWorkerMessage(Object? message) {
    switch (message) {
      case BleActionSuccess(:final requestId, :final result):
        _completeSuccess(requestId, result as TResult);
      case BleActionFailure(:final requestId, :final errorMessage):
        _completeFailure(requestId, BleException(errorMessage));
      default:
        break;
    }
  }

  Future<void> dispose() async {
    await _responseSubscription.cancel();
    _responsePort.close();
    _isolate.kill(priority: Isolate.immediate);
    _pending.clear();
  }

  void _completeSuccess(int requestId, TResult result) {
    final completer = _pending[requestId];
    if (completer == null || completer.isCompleted) return;
    completer.complete(result);
  }

  void _completeFailure(int requestId, BleException error) {
    final completer = _pending[requestId];
    if (completer == null || completer.isCompleted) return;
    completer.completeError(error);
  }

  static bool _isWorkerReadyHandshake(
    Object? message,
    Completer<BleWorkerReady> readyCompleter,
  ) {
    if (message is! BleWorkerReady || readyCompleter.isCompleted) {
      return false;
    }

    readyCompleter.complete(message);
    return true;
  }
}
