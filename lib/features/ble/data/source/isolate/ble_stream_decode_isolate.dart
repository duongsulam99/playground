import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../model/ble_device_stream_snapshot_model.dart';
import 'ble_stream_decode_messages.dart';
import 'ble_stream_decode_worker.dart';

/// Long-lived isolate bridge: forwards raw BLE bytes to a worker for EMG decode.
class BleStreamDecodeIsolate {
  BleStreamDecodeIsolate._({
    required this._isolate,
    required this._workerSendPort,
    required this._responsePort,
    required this._responseSubscription,
  });

  final Isolate _isolate;
  final SendPort _workerSendPort;
  final ReceivePort _responsePort;
  final StreamSubscription<Object?> _responseSubscription;

  final Map<int, Completer<List<double>>> _pending = {};
  int _nextRequestId = 0;
  int droppedFramesCount = 0;

  static const _logger = Logger(className: 'BleStreamDecodeIsolate');

  /// Spawns the worker isolate and waits for the SendPort handshake.
  static Future<BleStreamDecodeIsolate> create() async {
    final responsePort = ReceivePort();
    final readyCompleter = Completer<BleStreamDecodeWorkerReady>();
    late final BleStreamDecodeIsolate instance;

    final responseSubscription = responsePort.listen((message) {
      if (_isWorkerReadyHandshake(message, readyCompleter)) return;
      instance._handleWorkerMessage(message);
    });

    final isolate = await Isolate.spawn(
      bleStreamDecodeWorkerMain,
      responsePort.sendPort,
    );

    final readyMessage = await readyCompleter.future;
    instance = BleStreamDecodeIsolate._(
      isolate: isolate,
      workerSendPort: readyMessage.sendPort,
      responsePort: responsePort,
      responseSubscription: responseSubscription,
    );

    return instance;
  }

  /// Bridges a raw byte stream to decoded [BleDeviceStreamSnapshotModel] events.
  ///
  /// Drop-oldest (depth = 1): while a decode is in-flight, only the latest
  /// pending frame is kept.
  Stream<BleDeviceStreamSnapshotModel> decodeStream({
    required Stream<List<int>> source,
    required String deviceId,
  }) {
    late final StreamController<BleDeviceStreamSnapshotModel> controller;
    StreamSubscription<List<int>>? sourceSubscription;

    // Per-subscription backpressure + lifecycle flags.
    var inFlight = false;
    Uint8List? latestPending;
    var sourceDone = false;
    final activeRequestIds = <int>{};

    void maybeCloseController() {
      final canClose =
          sourceDone &&
          !inFlight &&
          latestPending == null &&
          !controller.isClosed;
      if (canClose) unawaited(controller.close());
    }

    void cleanupRequest(int requestId) {
      activeRequestIds.remove(requestId);
      _pending.remove(requestId);
    }

    void cancelActiveRequests() {
      for (final requestId in activeRequestIds.toList()) {
        final completer = _pending[requestId];
        if (completer != null && !completer.isCompleted) {
          completer.completeError(StateError('Decode stream cancelled'));
        }
        cleanupRequest(requestId);
      }
      activeRequestIds.clear();
    }

    EmgStreamSnapshotModel buildSnapshot(
      Uint8List rawBytes,
      List<double> voltages,
    ) {
      return EmgStreamSnapshotModel(
        deviceId: deviceId,
        timestamp: DateTime.now(),
        voltages: voltages,
        rawBytes: rawBytes,
      );
    }

    void emitSnapshot(Uint8List rawBytes, List<double> voltages) {
      if (controller.isClosed) return;
      controller.add(buildSnapshot(rawBytes, voltages));
    }

    void emitDecodeError(Object error, [StackTrace? stackTrace]) {
      if (controller.isClosed) return;

      final failure = error is BleException
          ? BleException(error.message, deviceId: deviceId)
          : BleException(error.toString(), deviceId: deviceId);

      controller.addError(failure, stackTrace);
    }

    int registerDecodeRequest(Completer<List<double>> completer) {
      final requestId = _nextRequestId++;
      activeRequestIds.add(requestId);
      _pending[requestId] = completer;
      return requestId;
    }

    void dispatchToWorker(int requestId, Uint8List rawBytes) {
      _workerSendPort.send(
        BleStreamDecodeRequest(requestId: requestId, rawBytes: rawBytes),
      );
    }

    Future<void> sendDecode(Uint8List rawBytes) async {
      final completer = Completer<List<double>>();
      final requestId = registerDecodeRequest(completer);

      dispatchToWorker(requestId, rawBytes);

      try {
        final voltages = await completer.future;
        emitSnapshot(rawBytes, voltages);
      } on BleException catch (error) {
        emitDecodeError(error);
      } catch (error, stackTrace) {
        emitDecodeError(error, stackTrace);
      } finally {
        /// [sendDecode] is called in a loop - [Dart] don't let local function forward reference
        /// so [Drop-oldest chain] have to declare here
        cleanupRequest(requestId);

        // Drop-oldest chain: process the single buffered frame, or release inFlight.
        if (latestPending == null) {
          inFlight = false;
          maybeCloseController();
        } else {
          final next = latestPending!;
          latestPending = null;
          await sendDecode(next);
        }
      }
    }

    void onRawChunk(List<int> rawBytes) {
      final bytes = rawBytes.toUint8List();

      if (inFlight) {
        if (latestPending != null) {
          _onFramePending(bytes);
        }

        // Always override the latest pending frame, dropping the previous one.
        latestPending = bytes;
        return;
      }

      inFlight = true;
      unawaited(sendDecode(bytes));
    }

    void onSourceDone() {
      sourceDone = true;
      maybeCloseController();
    }

    Future<void> onStreamCancel() async {
      latestPending = null;
      inFlight = false;
      cancelActiveRequests();
      await sourceSubscription?.cancel();
    }

    controller = StreamController<BleDeviceStreamSnapshotModel>(
      onListen: () {
        sourceSubscription = source.listen(
          onRawChunk,
          onError: controller.addError,
          onDone: onSourceDone,
        );
      },
      onCancel: onStreamCancel,
    );

    return controller.stream;
  }

  /// Resolves an RPC response from the worker into the matching completer.
  void _handleWorkerMessage(Object? message) {
    if (message is BleStreamDecodeSuccess) {
      _completePendingSuccess(message);
      return;
    }

    if (message is BleStreamDecodeFailure) {
      _completePendingFailure(message);
    }
  }

  void _completePendingSuccess(BleStreamDecodeSuccess message) {
    final completer = _pending[message.requestId];
    if (completer == null || completer.isCompleted) return;
    completer.complete(message.voltages);
  }

  void _completePendingFailure(BleStreamDecodeFailure message) {
    final completer = _pending[message.requestId];
    if (completer == null || completer.isCompleted) return;
    completer.completeError(BleException(message.errorMessage));
  }

  Future<void> dispose() async {
    await _responseSubscription.cancel();
    _responsePort.close();
    _isolate.kill(priority: Isolate.immediate);
    _pending.clear();
  }

  static bool _isWorkerReadyHandshake(
    Object? message,
    Completer<BleStreamDecodeWorkerReady> readyCompleter,
  ) {
    if (message is! BleStreamDecodeWorkerReady || readyCompleter.isCompleted) {
      return false;
    }

    readyCompleter.complete(message);
    return true;
  }

  void _onFramePending(Uint8List rawBytes) {
    if (_pending.isEmpty) return;

    droppedFramesCount++;
    _logger.debug("droppedFrames", "Dropped frame count: $droppedFramesCount");
    // _logger.debug('_onFramePending', rawBytes);
  }
}
