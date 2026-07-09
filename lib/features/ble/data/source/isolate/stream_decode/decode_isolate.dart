import 'dart:typed_data';

import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../model/ble_device_stream_snapshot_model.dart';
import '../../helper/ble_stream_temporal_buffer.dart';
import '../isolate_action.dart';
import 'worker.dart';

/// Minimal request payload sent across the isolate boundary.
final class BleStreamDecodeRequest {
  const BleStreamDecodeRequest({
    required this.requestId,
    required this.rawBytes,
  });

  final int requestId;
  final Uint8List rawBytes;
}

/// Long-lived isolate bridge: forwards raw BLE bytes to a worker for EMG decode.
class BleStreamDecodeIsolate extends BleActionIsolate<List<double>> {
  BleStreamDecodeIsolate({
    required super.isolate,
    required super.workerSendPort,
    required super.responsePort,
    required super.responseSubscription,
  });

  int droppedFramesCount = 0;

  static const _logger = Logger(className: 'BleStreamDecodeIsolate');

  /// Spawns the worker isolate and waits for the SendPort handshake.
  static Future<BleStreamDecodeIsolate> create() => BleActionIsolate.create(
    workerEntryPoint: bleStreamDecodeWorkerMain,
    constructor: BleStreamDecodeIsolate.new,
  );

  /// Bridges a raw byte stream to decoded [BleDeviceStreamSnapshotModel] events.
  ///
  /// Fixed-size frames are accumulated in a [BleStreamTemporalBuffer] and flushed
  /// on a time window. Each flushed batch is then decoded with drop-oldest
  /// (depth = 1): while a decode is in-flight, only the latest pending batch
  /// is kept.
  Stream<BleDeviceStreamSnapshotModel> decodeStream({
    required Stream<List<int>> source,
    required String deviceId,
  }) {
    late final StreamController<BleDeviceStreamSnapshotModel> controller;
    StreamSubscription<List<int>>? sourceSubscription;
    BleStreamTemporalBuffer? temporalBuffer;

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
      removePendingRequest(requestId);
    }

    void cancelActiveRequests() {
      for (final requestId in activeRequestIds.toList()) {
        cancelPendingRequest(requestId, StateError('Decode stream cancelled'));
        activeRequestIds.remove(requestId);
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
      final requestId = registerRequest(completer);
      activeRequestIds.add(requestId);
      return requestId;
    }

    void dispatchDecodeRequest(int requestId, Uint8List rawBytes) {
      sendToWorker(
        BleStreamDecodeRequest(requestId: requestId, rawBytes: rawBytes),
      );
    }

    Future<void> sendDecode(Uint8List rawBytes) async {
      final completer = Completer<List<double>>();
      final requestId = registerDecodeRequest(completer);

      dispatchDecodeRequest(requestId, rawBytes);

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

        // Drop-oldest chain: process the single buffered batch, or release inFlight.
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

    void onBatchReady(Uint8List batch) {
      if (batch.isEmpty) return;

      if (inFlight) {
        if (latestPending != null) {
          _onBatchDropped(batch);
        }

        // Always override the latest pending batch, dropping the previous one.
        latestPending = batch;
        return;
      }

      inFlight = true;
      unawaited(sendDecode(batch));
    }

    void onRawChunk(List<int> rawBytes) {
      temporalBuffer?.add(rawBytes.toUint8List());
    }

    void onSourceDone() {
      temporalBuffer?.flushNow();
      sourceDone = true;
      maybeCloseController();
    }

    Future<void> onStreamCancel() async {
      latestPending = null;
      inFlight = false;
      cancelActiveRequests();
      temporalBuffer?.dispose();
      temporalBuffer = null;
      await sourceSubscription?.cancel();
    }

    controller = StreamController<BleDeviceStreamSnapshotModel>(
      onListen: () {
        temporalBuffer = BleStreamTemporalBuffer(onFlush: onBatchReady);
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

  void _onBatchDropped(Uint8List batch) {
    if (!hasPendingRequests) return;

    droppedFramesCount++;
    _logger.debug('droppedFrames', 'Dropped batch count: $droppedFramesCount');
    // _logger.debug('_onBatchDropped', batch);
  }
}
