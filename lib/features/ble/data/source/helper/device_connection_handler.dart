// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';

import 'package_accumulator.dart';
import 'stream_monitor.dart';

/// Quản lý GATT I/O cho một thiết bị đã connect: MTU, notify stream, write chunk.
///
/// Một instance gắn với một [BluetoothDevice]; lifecycle theo connect/dispose.
class DeviceConnectionHandler {
  DeviceConnectionHandler({required BluetoothDevice device})
    : _bleDevice = device;

  final BluetoothDevice _bleDevice;
  final BlePacketAccumulator _accumulator = BlePacketAccumulator();

  static const int DEFAULT_MTU = 23;
  static const int MAX_MTU = 515;

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  StreamController<List<int>>? _cleanDataStreamController;

  final Logger _logger = const Logger(className: 'DeviceConnectionHandler');
  final _streamMonitor = EMGStreamMonitor();

  /// Serialize GATT operations — tránh ghi/notify đồng thời gây race.
  Future<void> _queueLock = Future.value();
  int _currentMtu = DEFAULT_MTU;
  bool _isDisposed = false;

  int get currentMtu => _currentMtu;

  /// Byte stream sau khi lắng nghe notify (có thể đã gộp frame).
  Stream<List<int>> get cleanDataStream {
    _ensureStreamController();
    return _cleanDataStreamController!.stream;
  }

  Future<void> setupMtu() async {
    _ensureNotDisposed();

    if (Platform.isAndroid) {
      await _requestMtu(MAX_MTU);
    }

    _currentMtu = await _bleDevice.mtu.first;
    _logger.debug(
      'setupMtu',
      'Device ${_bleDevice.remoteId.str} negotiated MTU: $_currentMtu',
    );
  }

  Future<void> _requestMtu(int mtu) async {
    await _bleDevice.requestMtu(mtu).catchError((_) => DEFAULT_MTU);
  }

  void monitorConnection() {
    _ensureNotDisposed();

    _connectionSubscription?.cancel();

    _connectionSubscription = _bleDevice.connectionState.listen((state) {
      // Tự dọn resource khi mất kết nối ngoài ý muốn.
      if (state == BluetoothConnectionState.disconnected) dispose();

      //TODO: Handle connection state
    });
  }

  bool _cleanAndEnsureController(StreamController<List<int>>? controller) {
    if (controller == null) return false;
    if (controller.isClosed) return false;
    return true;
  }

  Future<void> startListeningData(
    BluetoothCharacteristic characteristic, {
    bool reassembleFrames = true,
  }) async {
    _ensureNotDisposed();
    _ensureStreamController();

    await _notificationSubscription?.cancel();
    _accumulator.clear();

    await _enqueueOperation(() => characteristic.setNotifyValue(true));

    _streamMonitor.start(cleanDataStream.map((_) => 0.0));

    _notificationSubscription = characteristic.onValueReceived.listen(
      (rawChunk) {
        if (!_cleanAndEnsureController(_cleanDataStreamController)) return;

        if (!reassembleFrames) {
          _cleanDataStreamController!.add(List<int>.from(rawChunk));
          return;
        }

        _accumulator.appendChunk(rawChunk, (List<int> frame) {
          _cleanDataStreamController!.add(List<int>.from(frame));
        });
      },
      onError: _onErrorListeningData,
      onDone: _onDoneListeningData,
    );
  }

  void _onErrorListeningData(Object error, StackTrace stackTrace) {
    _streamMonitor.stop();
    _logger.error('startListeningData', 'Notify stream error: $error');
  }

  void _onDoneListeningData() {
    _streamMonitor.stop();
    _logger.debug('startListeningData', 'Notify stream done.');
  }

  /// Chia payload theo MTU hiện tại (payload = MTU - 3 byte ATT header).
  Future<void> writeData(
    BluetoothCharacteristic characteristic,
    List<int> fullData,
  ) async {
    _ensureNotDisposed();

    final maxPayloadSize = _currentMtu - 3;
    if (maxPayloadSize <= 0) {
      throw StateError('Invalid MTU $_currentMtu for device');
    }

    for (var i = 0; i < fullData.length; i += maxPayloadSize) {
      final end = i + maxPayloadSize > fullData.length
          ? fullData.length
          : i + maxPayloadSize;
      final chunk = fullData.sublist(i, end);

      await _enqueueOperation(() => characteristic.write(chunk));
    }
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _accumulator.clear();
    _streamMonitor.stop();
    _cleanDataStreamController?.close();
    _cleanDataStreamController = null;

    _logger.debug('dispose', 'Resources cleaned up for device');
  }

  void _ensureStreamController() {
    if (_cleanDataStreamController == null ||
        _cleanDataStreamController!.isClosed) {
      _cleanDataStreamController = StreamController<List<int>>.broadcast();
    }
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('DeviceConnectionHandler is disposed');
    }
  }

  Future<T> _enqueueOperation<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _queueLock = _queueLock.then((_) async {
      try {
        final result = await operation().timeout(const Duration(seconds: 3));
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e, st) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        }
      }
    });
    return completer.future;
  }
}
