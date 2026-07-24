// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_supper_app_core/core.dart';

import 'package_accumulator.dart';
import 'stream_monitor.dart';

/// Một notify channel gắn với một characteristic (broadcast stream + subscription).
class _NotifyChannel {
  _NotifyChannel({
    required this.channelId,
    required this.reassembleFrames,
  }) : controller = StreamController<List<int>>.broadcast(),
       accumulator = reassembleFrames ? BlePacketAccumulator() : null;

  final String channelId;
  final bool reassembleFrames;
  final StreamController<List<int>> controller;
  final BlePacketAccumulator? accumulator;
  StreamSubscription<List<int>>? subscription;

  bool get isOpen => !controller.isClosed;

  void addChunk(List<int> rawChunk) {
    if (!isOpen) return;

    if (!reassembleFrames) {
      controller.add(List<int>.from(rawChunk));
      return;
    }

    accumulator!.appendChunk(rawChunk, (List<int> frame) {
      if (isOpen) controller.add(List<int>.from(frame));
    });
  }

  Future<void> dispose() async {
    await subscription?.cancel();
    subscription = null;
    accumulator?.clear();
    if (!controller.isClosed) {
      await controller.close();
    }
  }
}

/// Quản lý GATT I/O cho một thiết bị đã connect: MTU, multi-notify, write chunk.
///
/// Một instance gắn với một [BluetoothDevice]; lifecycle theo connect/dispose.
/// Mỗi [channelId] (thường là characteristic key) có stream notify riêng.
class DeviceConnectionHandler {
  DeviceConnectionHandler({required BluetoothDevice device})
    : _bleDevice = device;

  final BluetoothDevice _bleDevice;
  final Map<String, _NotifyChannel> _channels = {};

  static const int DEFAULT_MTU = 23;
  static const int MAX_MTU = 515;

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  final Logger _logger = const Logger(className: 'DeviceConnectionHandler');
  final _streamMonitor = EMGStreamMonitor();

  /// Serialize GATT operations — tránh ghi/notify đồng thời gây race.
  Future<void> _queueLock = Future.value();
  int _currentMtu = DEFAULT_MTU;
  bool _isDisposed = false;

  int get currentMtu => _currentMtu;

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
    });
  }

  /// Trả broadcast stream cho [channelId]. Gọi [subscribeNotify] trước để bật notify.
  Stream<List<int>> watchNotify(String channelId) {
    _ensureNotDisposed();
    final channel = _channels[channelId];
    if (channel == null || !channel.isOpen) {
      throw StateError(
        'Notify channel "$channelId" is not enabled. Call subscribeNotify first.',
      );
    }
    return channel.controller.stream;
  }

  /// Bật notify trên [characteristic] và map vào [channelId].
  ///
  /// Nếu channel đã tồn tại thì hủy subscription cũ rồi subscribe lại.
  Future<Stream<List<int>>> subscribeNotify(
    BluetoothCharacteristic characteristic, {
    required String channelId,
    bool reassembleFrames = false,
  }) async {
    _ensureNotDisposed();

    await unsubscribeNotify(channelId);

    final channel = _NotifyChannel(
      channelId: channelId,
      reassembleFrames: reassembleFrames,
    );
    _channels[channelId] = channel;

    await _enqueueOperation(() => characteristic.setNotifyValue(true));

    // Stream monitor chỉ theo dõi signal-like channels (reassembleFrames).
    if (reassembleFrames) {
      _streamMonitor.start(channel.controller.stream.map((_) => 0.0));
    }

    channel.subscription = characteristic.onValueReceived.listen(
      channel.addChunk,
      onError: (Object error, StackTrace stackTrace) {
        _logger.error(
          'subscribeNotify',
          'Notify error on $channelId: $error',
        );
        if (reassembleFrames) _streamMonitor.stop();
      },
      onDone: () {
        _logger.debug('subscribeNotify', 'Notify done on $channelId');
        if (reassembleFrames) _streamMonitor.stop();
      },
    );

    _logger.debug(
      'subscribeNotify',
      'Listening on $channelId for ${_bleDevice.remoteId.str}',
    );

    return channel.controller.stream;
  }

  /// Tắt notify và đóng channel [channelId].
  Future<void> unsubscribeNotify(String channelId) async {
    final channel = _channels.remove(channelId);
    if (channel == null) return;

    if (channel.reassembleFrames) {
      _streamMonitor.stop();
    }
    await channel.dispose();
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
    _streamMonitor.stop();

    for (final channel in _channels.values) {
      unawaited(channel.dispose());
    }
    _channels.clear();

    _logger.debug('dispose', 'Resources cleaned up for device');
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
