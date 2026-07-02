import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../model/ble_device_stream_snapshot_model.dart';
import 'ble_stream_decode_messages.dart';
import 'ble_stream_decode_worker.dart';

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

  static Future<BleStreamDecodeIsolate> create() async {
    final responsePort = ReceivePort();
    final readyCompleter = Completer<BleStreamDecodeWorkerReady>();
    late final BleStreamDecodeIsolate instance;

    final responseSubscription = responsePort.listen((message) {
      if (message is BleStreamDecodeWorkerReady &&
          !readyCompleter.isCompleted) {
        readyCompleter.complete(message);
        return;
      }

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

  Stream<BleDeviceStreamSnapshotModel> decodeStream({
    required Stream<List<int>> source,
    required String deviceId,
  }) {
    late final StreamController<BleDeviceStreamSnapshotModel> controller;
    StreamSubscription<List<int>>? sourceSubscription;

    var inFlight = false;
    Uint8List? latestPending;
    var sourceDone = false;
    final activeRequestIds = <int>{};

    void maybeCloseController() {
      if (sourceDone &&
          !inFlight &&
          latestPending == null &&
          !controller.isClosed) {
        unawaited(controller.close());
      }
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

    Future<void> sendDecode(Uint8List rawBytes) async {
      final requestId = _nextRequestId++;
      final completer = Completer<List<double>>();

      activeRequestIds.add(requestId);
      _pending[requestId] = completer;

      _workerSendPort.send(
        BleStreamDecodeRequest(requestId: requestId, rawBytes: rawBytes),
      );

      try {
        final voltages = await completer.future;
        if (!controller.isClosed) {
          controller.add(
            EmgStreamSnapshotModel(
              deviceId: deviceId,
              timestamp: DateTime.now(),
              voltages: voltages,
              rawBytes: rawBytes,
            ),
          );
        }
      } on BleException catch (error) {
        if (!controller.isClosed) {
          controller.addError(BleException(error.message, deviceId: deviceId));
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(
            BleException(error.toString(), deviceId: deviceId),
            stackTrace,
          );
        }
      } finally {
        cleanupRequest(requestId);

        if (latestPending != null) {
          final next = latestPending!;
          latestPending = null;
          await sendDecode(next);
        } else {
          inFlight = false;
          maybeCloseController();
        }
      }
    }

    controller = StreamController<BleDeviceStreamSnapshotModel>(
      onListen: () {
        sourceSubscription = source.listen(
          (rawBytes) {
            final bytes = rawBytes.toUint8List();

            if (inFlight) {
              latestPending = bytes;
              return;
            }

            inFlight = true;
            unawaited(sendDecode(bytes));
          },
          onError: controller.addError,
          onDone: () {
            sourceDone = true;
            maybeCloseController();
          },
        );
      },
      onCancel: () async {
        latestPending = null;
        inFlight = false;
        cancelActiveRequests();
        await sourceSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  void _handleWorkerMessage(Object? message) {
    if (message is BleStreamDecodeSuccess) {
      final completer = _pending[message.requestId];
      if (completer == null || completer.isCompleted) return;

      completer.complete(message.voltages);
      return;
    }

    if (message is BleStreamDecodeFailure) {
      final completer = _pending[message.requestId];
      if (completer == null || completer.isCompleted) return;

      completer.completeError(BleException(message.errorMessage));
    }
  }

  Future<void> dispose() async {
    await _responseSubscription.cancel();
    _responsePort.close();
    _isolate.kill(priority: Isolate.immediate);
    _pending.clear();
  }
}
