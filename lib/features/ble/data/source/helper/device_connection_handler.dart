// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';

import 'package_accumulator.dart';
import 'stream_monitor.dart';

class DeviceConnectionHandler {
  DeviceConnectionHandler({
    required this.deviceId,
    required BluetoothDevice device,
  }) : _bleDevice = device;

  final String deviceId;
  final BluetoothDevice _bleDevice;
  final BlePacketAccumulator _accumulator = BlePacketAccumulator();

  // CONFIGURATION
  static const int DEFAULT_MTU = 23;
  static const int MAX_MTU = 515;

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  StreamController<List<int>>? _cleanDataStreamController;

  final Logger _logger = const Logger(className: 'DeviceConnectionHandler');
  final _streamMonitor = EMGStreamMonitor();

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

  bool _cleanAndEnsureController(StreamController<List<int>>? controller) {
    if (controller == null) return false;

    if (controller.isClosed) return false;

    return true;
  }

  Future<void> startListeningData(
    BluetoothCharacteristic characteristic, {
    bool reassembleFrames = true,
  }) async {
    /// Ensure device is connected
    _ensureNotDisposed();

    /// Ensure Stream Controller Is Available & Open
    _ensureStreamController();

    /// Cancel previous subscription
    await _notificationSubscription?.cancel();
    _accumulator.clear();

    /// Send Notify Value Request To Device
    await _enqueueOperation(() => characteristic.setNotifyValue(true));

    // Start monitoring the EMG stream to measure the sampling rate
    _streamMonitor.start(cleanDataStream.map((_) => 0.0));

    /// Listen to value received from characteristic
    _notificationSubscription = characteristic.onValueReceived.listen(
      (rawChunk) {
        /// IMPORTANT STEP BEFORE ADDING DATA ( SAFETY GUARD)
        /// Clean Stream Controller
        /// and ensure controller is available
        if (!_cleanAndEnsureController(_cleanDataStreamController)) return;

        /// If reassembleFrames is false
        /// add the raw chunk to the stream controller directly
        if (!reassembleFrames) {
          _cleanDataStreamController!.add(List<int>.from(rawChunk));
          return;
        }

        /// If reassembleFrames is true
        /// append the chunk to the accumulator
        /// and add the complete frame to the stream controller
        _accumulator.appendChunk(rawChunk, (List<int> frame) {
          _cleanDataStreamController!.add(List<int>.from(frame));
        });
      },

      /// Handle Errors When Start Listening
      onError: _onErrorListeningData,

      /// Handle Done Listening
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
    _streamMonitor.stop();
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
