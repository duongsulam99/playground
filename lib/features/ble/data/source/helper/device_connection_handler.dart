// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';

import 'ble_package_accumulator.dart';

class DeviceConnectionHandler {
  DeviceConnectionHandler({
    required this.deviceId,
    required BluetoothDevice device,
  }) : _bleDevice = device;

  final String deviceId;
  final BluetoothDevice _bleDevice;
  final BlePacketAccumulator _accumulator = BlePacketAccumulator();
  final Logger _logger = const Logger(className: 'DeviceConnectionHandler');

  // CONFIGURATION
  static const int DEFAULT_MTU = 23;
  static const int MAX_MTU = 515;

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  StreamController<List<int>>? _cleanDataStreamController;

  Future<void> _queueLock = Future.value();
  int _currentMtu = DEFAULT_MTU;
  bool _isDisposed = false;

  int get currentMtu => _currentMtu;

  Stream<List<int>> get cleanDataStream {
    _ensureStreamController();
    return _cleanDataStreamController!.stream;
  }

  Future<void> setupMtu() async {
    _ensureNotDisposed();

    /// Request MTU MAX_MTU on Android
    if (Platform.isAndroid) {
      await _requestMtu(MAX_MTU);
    }

    _currentMtu = await _bleDevice.mtu.first;
    _logger.debug('setupMtu', 'Device $deviceId negotiated MTU: $_currentMtu');
  }

  Future<void> _requestMtu(int mtu) async {
    await _bleDevice.requestMtu(mtu).catchError((_) => DEFAULT_MTU);
  }

  void monitorConnection() {
    _ensureNotDisposed();

    /// Cancel previous subscription
    _connectionSubscription?.cancel();

    /// Monitor & handle 2 connection states
    _connectionSubscription = _bleDevice.connectionState.listen((state) {
      /// Disconnect if device is disconnected
      if (state == BluetoothConnectionState.disconnected) dispose();

      //TODO: Handle connection state
    });
  }

  Future<void> startListeningData(
    BluetoothCharacteristic characteristic,
  ) async {
    _ensureNotDisposed();
    _ensureStreamController();

    await _notificationSubscription?.cancel();
    _accumulator.clear();

    await _enqueueOperation(() => characteristic.setNotifyValue(true));

    _notificationSubscription = characteristic.onValueReceived.listen(
      (rawChunk) {
        _accumulator.appendChunk(rawChunk, (completeFrame) {
          final controller = _cleanDataStreamController;
          if (controller != null && !controller.isClosed) {
            controller.add(completeFrame);
          }
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.error('startListeningData', 'Notify stream error: $error');
      },
    );
  }

  Future<void> writeData(
    BluetoothCharacteristic characteristic,
    List<int> fullData,
  ) async {
    _ensureNotDisposed();

    final maxPayloadSize = _currentMtu - 3;
    if (maxPayloadSize <= 0) {
      throw StateError('Invalid MTU $_currentMtu for device $deviceId');
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
    _cleanDataStreamController?.close();
    _cleanDataStreamController = null;

    _logger.debug('dispose', 'Resources cleaned up for device $deviceId');
  }

  void _ensureStreamController() {
    if (_cleanDataStreamController == null ||
        _cleanDataStreamController!.isClosed) {
      _cleanDataStreamController = StreamController<List<int>>.broadcast();
    }
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('DeviceConnectionHandler for $deviceId is disposed');
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
