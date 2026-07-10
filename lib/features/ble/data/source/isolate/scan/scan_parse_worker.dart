import 'dart:async';
import 'dart:isolate';

import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../model/ble_discovered_device_model.dart';
import '../action_message.dart';
import '../isolate_action.dart';
import 'scan_advertisement_dto.dart';
import 'scan_parse_messages.dart';

/// Pure scan-batch merge logic — testable without isolate.
Map<String, BleDiscoveredDeviceModel> processScanBatch(
  Map<String, BleDiscoveredDeviceModel> cache,
  List<ScanAdvertisementDto> dtos,
) {
  for (final dto in dtos) {
    if (!dto.connectable) continue;

    cache[dto.deviceId] = BleDiscoveredDeviceModel.fromAdvertisementDto(dto);
  }

  return Map<String, BleDiscoveredDeviceModel>.from(cache);
}

@pragma('vm:entry-point')
void scanParseWorkerMain(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(BleWorkerReady(receivePort.sendPort));

  final cache = <String, BleDiscoveredDeviceModel>{};

  receivePort.listen((message) {
    switch (message) {
      case ScanParseClearCacheRequest(:final requestId):
        cache.clear();
        mainSendPort.send(
          BleActionSuccess(
            requestId: requestId,
            result: <String, BleDiscoveredDeviceModel>{},
          ),
        );
      case ScanParseBatchRequest(:final requestId, :final dtos):
        try {
          final result = processScanBatch(cache, dtos);
          mainSendPort.send(BleActionSuccess(requestId: requestId, result: result));
        } on BleException catch (error) {
          mainSendPort.send(
            BleActionFailure(
              requestId: requestId,
              errorMessage: error.message,
            ),
          );
        } catch (error) {
          mainSendPort.send(
            BleActionFailure(
              requestId: requestId,
              errorMessage: error.toString(),
            ),
          );
        }
      default:
        break;
    }
  });
}


/// Main-isolate bridge for scan parse worker.
class ScanParseWorker extends BleActionIsolate<Map<String, BleDiscoveredDeviceModel>> {
  ScanParseWorker({
    required super.isolate,
    required super.workerSendPort,
    required super.responsePort,
    required super.responseSubscription,
  });

  List<ScanAdvertisementDto>? _coalescedBatch;
  Completer<Map<String, BleDiscoveredDeviceModel>>? _activeCompleter;
  bool _isDraining = false;
  Map<String, BleDiscoveredDeviceModel> _lastResult = {};

  static Future<ScanParseWorker> create() => BleActionIsolate.create(
    workerEntryPoint: scanParseWorkerMain,
    constructor: ScanParseWorker.new,
  );

  Future<void> clearCache() async {
    final completer = Completer<Map<String, BleDiscoveredDeviceModel>>();
    final requestId = registerRequest(completer);

    sendToWorker(ScanParseClearCacheRequest(requestId: requestId));

    try {
      await completer.future;
      _lastResult = {};
    } finally {
      removePendingRequest(requestId);
    }
  }

  Future<Map<String, BleDiscoveredDeviceModel>> processBatch(
    List<ScanAdvertisementDto> dtos,
  ) {
    _coalescedBatch = dtos;

    if (_activeCompleter != null) {
      return _activeCompleter!.future;
    }

    _activeCompleter = Completer<Map<String, BleDiscoveredDeviceModel>>();
    unawaited(_drainCoalescedBatches());
    return _activeCompleter!.future;
  }

  Future<void> _drainCoalescedBatches() async {
    if (_isDraining) return;
    _isDraining = true;

    try {
      while (_coalescedBatch != null) {
        final batch = _coalescedBatch!;
        _coalescedBatch = null;
        _lastResult = await _sendBatch(batch);
      }

      _activeCompleter?.complete(_lastResult);
    } catch (error, stackTrace) {
      _activeCompleter?.completeError(error, stackTrace);
    } finally {
      _activeCompleter = null;
      _isDraining = false;

      if (_coalescedBatch != null) {
        _activeCompleter = Completer<Map<String, BleDiscoveredDeviceModel>>();
        unawaited(_drainCoalescedBatches());
      }
    }
  }

  Future<Map<String, BleDiscoveredDeviceModel>> _sendBatch(
    List<ScanAdvertisementDto> dtos,
  ) async {
    final completer = Completer<Map<String, BleDiscoveredDeviceModel>>();
    final requestId = registerRequest(completer);

    sendToWorker(ScanParseBatchRequest(requestId: requestId, dtos: dtos));

    try {
      return await completer.future;
    } finally {
      removePendingRequest(requestId);
    }
  }
}
