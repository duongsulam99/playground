import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/core/ble/config/constants/vulcan_constant.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

import '../../../domain/entities/ble_discovered_device.dart';
import '../../../domain/entities/ble_active_connection.dart';
import '../../../domain/entities/ble_device_info.dart';
import '../../../domain/entities/ble_device_stream_snapshot.dart';
import '../../../domain/usecase/connect_device.dart';
import '../../../domain/usecase/disconnect_device.dart';
import '../../../domain/usecase/read_device_info.dart';
import '../../../domain/usecase/start_device_stream.dart';
import '../../../domain/usecase/start_scan.dart';
import '../../../domain/usecase/stop_device_stream.dart';
import '../../../domain/usecase/stop_scan.dart';
import '../../../domain/usecase/watch_adapter_status.dart';
import '../../../domain/usecase/watch_device_connection.dart';
import '../../../domain/usecase/watch_device_data.dart';
import '../../../domain/usecase/watch_scan_results.dart';

part 'ble_bloc.freezed.dart';
part 'ble_event.dart';
part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  BleBloc({
    required this._watchAdapterStatus,
    required this._watchScanResults,
    required this._watchDeviceData,
    required this._watchDeviceConnection,
    required this._startScan,
    required this._stopScan,
    required this._connectDevice,
    required this._disconnectDevice,
    required this._readDeviceInfo,
    required this._startDeviceStream,
    required this._stopDeviceStream,
  }) : super(const BleState()) {
    on<BleScanFilterUpdated>(_onScanFilterUpdated);
    on<BleStartScan>(_onStartScan);
    on<BleStopScan>(_onStopScan);
    on<BleAdapterStatusUpdated>(_onAdapterStatusUpdated);
    on<BleScanResultsUpdated>(_onScanResultsUpdated);
    on<BleConnectionLost>(_onConnectionLost);
    on<BleStreamFailed>(_onStreamFailed);
    on<BleConnectRequested>(_onConnectRequested);
    on<BleDisconnectRequested>(_onDisconnectRequested);
    on<BleStartDeviceStream>(_onStartDeviceStream);
    on<BleStopDeviceStream>(_onStopDeviceStream);
    on<BleListenDeviceData>(_onListenDeviceData, transformer: restartable());

    _subscribeAdapterStream();
  }

  final WatchAdapterStatus _watchAdapterStatus;
  final WatchScanResults _watchScanResults;
  final WatchDeviceData _watchDeviceData;
  final WatchDeviceConnection _watchDeviceConnection;
  final StartScan _startScan;
  final StopScan _stopScan;
  final ConnectDevice _connectDevice;
  final DisconnectDevice _disconnectDevice;
  final ReadDeviceInfo _readDeviceInfo;
  final StartDeviceStream _startDeviceStream;
  final StopDeviceStream _stopDeviceStream;

  StreamSubscription<dynamic>? _adapterSubscription;
  StreamSubscription<dynamic>? _scanResultsSubscription;
  final Map<String, StreamSubscription<dynamic>>
  _deviceConnectionSubscriptions = {};

  void _subscribeAdapterStream() {
    if (_adapterSubscription != null) return;

    _adapterSubscription = _watchAdapterStatus(const NoParams()).listen((
      result,
    ) {
      if (isClosed) return;
      result.fold(
        (failure) => add(BleEvent.streamFailed(message: failure.message)),
        (status) => add(BleEvent.adapterStatusUpdated(status: status)),
      );
    });
  }

  void _subscribeScanResultsStream() {
    if (_scanResultsSubscription != null) return;

    _scanResultsSubscription = _watchScanResults(const NoParams()).listen((
      result,
    ) {
      if (isClosed) return;
      result.fold(
        (failure) => add(BleEvent.streamFailed(message: failure.message)),
        (devices) => add(BleEvent.scanResultsUpdated(savedDevices: devices)),
      );
    });
  }

  Future<void> _unsubscribeScanResultsStream() async {
    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
  }

  Future<void> _stopScanning(Emitter<BleState> emit) async {
    if (!state.isScanning) {
      await _unsubscribeScanResultsStream();
      return;
    }

    final result = await _stopScan(const NoParams());
    await _unsubscribeScanResultsStream();

    result.fold(
      (failure) => emit(
        state.copyWith(
          isScanning: false,
          errorMessage: failure.message,
          status: BleStatus.failure,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isScanning: false,
          status: BleStatus.success,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onScanFilterUpdated(
    BleScanFilterUpdated event,
    Emitter<BleState> emit,
  ) async {
    emit(state.copyWith(scanFilterTypes: event.filterTypes));
  }

  Future<void> _onStartScan(BleStartScan event, Emitter<BleState> emit) async {
    if (state.isScanning) return;

    emit(state.copyWith(status: BleStatus.loading, errorMessage: null));

    final result = await _startScan(
      StartScanParams(filterTypes: state.scanFilterTypes),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isScanning: false,
          errorMessage: failure.message,
          status: BleStatus.failure,
        ),
      ),
      (_) {
        _subscribeScanResultsStream();
        emit(state.copyWith(isScanning: true, status: BleStatus.success));
      },
    );
  }

  Future<void> _onStopScan(BleStopScan event, Emitter<BleState> emit) async {
    await _stopScanning(emit);
  }

  Future<void> _onAdapterStatusUpdated(
    BleAdapterStatusUpdated event,
    Emitter<BleState> emit,
  ) async {
    emit(
      state.copyWith(
        adapterStatus: event.status,
        status: BleStatus.success,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onScanResultsUpdated(
    BleScanResultsUpdated event,
    Emitter<BleState> emit,
  ) async {
    emit(
      state.copyWith(
        savedDevices: event.savedDevices,
        status: BleStatus.success,
      ),
    );
  }

  Future<void> _onStreamFailed(
    BleStreamFailed event,
    Emitter<BleState> emit,
  ) async {
    emit(
      state.copyWith(errorMessage: event.message, status: BleStatus.failure),
    );
  }

  Future<void> _onConnectRequested(
    BleConnectRequested event,
    Emitter<BleState> emit,
  ) async {
    final deviceId = event.deviceId;

    if (!state.canConnectDevice(deviceId)) {
      emit(
        state.copyWith(
          activeConnections: _upsertConnection(
            state.activeConnections,
            deviceId: deviceId,
            status: BleConnectionStatus.disconnected,
            errorMessage: 'Device limit reached',
          ),
          status: BleStatus.failure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: BleStatus.loading,
        activeConnections: _upsertConnection(
          state.activeConnections,
          deviceId: deviceId,
          status: BleConnectionStatus.connecting,
        ),
        errorMessage: null,
      ),
    );

    if (state.isScanning) {
      await _stopScanning(emit);
    }

    final connectResult = await _connectDevice(
      ConnectDeviceParams(deviceId: deviceId),
    );

    if (connectResult.isLeft()) {
      final failure = connectResult.fold(
        (left) => left,
        (_) => throw StateError(''),
      );
      emit(
        state.copyWith(
          activeConnections: _upsertConnection(
            state.activeConnections,
            deviceId: deviceId,
            status: BleConnectionStatus.disconnected,
            errorMessage: failure.message,
            clearDeviceInfo: true,
          ),
          status: BleStatus.failure,
          isScanning: false,
        ),
      );
      return;
    }

    final connectionStatus = connectResult.getOrElse(
      () => BleConnectionStatus.disconnected,
    );

    emit(
      state.copyWith(
        activeConnections: _upsertConnection(
          state.activeConnections,
          deviceId: deviceId,
          status: connectionStatus,
          clearDeviceInfo: true,
        ),
        isScanning: false,
        status: BleStatus.success,
      ),
    );

    _subscribeDeviceConnectionStream(deviceId);

    if (!_isMyoBandDevice(deviceId)) return;

    emit(
      state.copyWith(
        activeConnections: _upsertConnection(
          state.activeConnections,
          deviceId: deviceId,
          status: connectionStatus,
          isReadingInfo: true,
        ),
        status: BleStatus.loading,
      ),
    );

    final readResult = await _readDeviceInfo(
      ReadDeviceInfoParams(deviceId: deviceId),
    );

    readResult.fold(
      (failure) => emit(
        state.copyWith(
          activeConnections: _upsertConnection(
            state.activeConnections,
            deviceId: deviceId,
            status: connectionStatus,
            errorMessage: failure.message,
          ),
          status: BleStatus.failure,
        ),
      ),
      (info) => emit(
        state.copyWith(
          status: BleStatus.success,
          activeConnections: _upsertConnection(
            state.activeConnections,
            deviceId: deviceId,
            status: connectionStatus,
            deviceInfo: info,
          ),
        ),
      ),
    );
  }

  Future<void> _onDisconnectRequested(
    BleDisconnectRequested event,
    Emitter<BleState> emit,
  ) async {
    final deviceId = event.deviceId;

    if (state.isDeviceStreaming(deviceId)) {
      await _stopDeviceStreaming(deviceId, emit);
    }

    emit(
      state.copyWith(
        status: BleStatus.loading,
        activeConnections: _upsertConnection(
          state.activeConnections,
          deviceId: deviceId,
          status: BleConnectionStatus.disconnecting,
        ),
      ),
    );

    final result = await _disconnectDevice(
      DisconnectDeviceParams(deviceId: deviceId),
    );

    if (result.isLeft()) {
      final failure = result.fold((left) => left, (_) => throw StateError(''));
      emit(
        state.copyWith(
          activeConnections: _upsertConnection(
            state.activeConnections,
            deviceId: deviceId,
            status: BleConnectionStatus.connected,
            errorMessage: failure.message,
          ),
          status: BleStatus.failure,
        ),
      );
      return;
    }

    await _clearDeviceSubscriptions(deviceId);
    _emitDeviceDisconnected(emit, deviceId);
  }

  Future<void> _onConnectionLost(
    BleConnectionLost event,
    Emitter<BleState> emit,
  ) async {
    final deviceId = event.deviceId;
    final connection = state.activeConnections[deviceId];
    if (connection == null) return;
    if (connection.status == BleConnectionStatus.disconnecting) return;

    if (state.isDeviceStreaming(deviceId)) {
      await _stopDeviceStreaming(deviceId, emit, stopHardware: false);
    }

    await _clearDeviceSubscriptions(deviceId);
    _emitDeviceDisconnected(emit, deviceId);
  }

  Future<void> _onStartDeviceStream(
    BleStartDeviceStream event,
    Emitter<BleState> emit,
  ) async {
    final deviceId = event.deviceId;
    if (!_canStartDeviceStream(deviceId)) return;

    emit(state.copyWith(status: BleStatus.loading, errorMessage: null));

    final result = await _startHardwareStream(deviceId);

    if (result.isLeft()) {
      final failure = result.fold((left) => left, (_) => throw StateError(''));
      emit(
        state.copyWith(
          errorMessage: failure.message,
          status: BleStatus.failure,
        ),
      );
      return;
    }

    /// Add the device to the list of streaming devices
    emit(_stateWithStreamingStarted(deviceId));

    /// Start listening for device data
    add(BleEvent.listenDeviceData(deviceId: deviceId));
  }

  Future<void> _onListenDeviceData(
    BleListenDeviceData event,
    Emitter<BleState> emit,
  ) async {
    final deviceId = event.deviceId;
    if (!state.isDeviceStreaming(deviceId)) return;

    final stream = _resolveDeviceDataStream(deviceId);
    if (stream == null) return;

    await emit.forEach<Either<Failure, BleDeviceStreamSnapshot>>(
      stream,
      onData: (result) {
        // Stop listening if the device is no longer streaming
        if (!state.streamingDeviceIds.contains(deviceId)) return state;

        // Update the snapshot
        return result.fold(
          _stateWithStreamFailure,
          (snapshot) => _stateWithStreamSnapshot(deviceId, snapshot),
        );
      },
      onError: (error, _) => state.copyWith(
        errorMessage: error.toString(),
        status: BleStatus.failure,
      ),
    );

    // If Stream ended unexpectedly
    // While still marked as streaming — cleanup state.
    if (state.streamingDeviceIds.contains(deviceId)) {
      emit(_stateWithStreamingStopped(deviceId));
    }
  }

  Future<void> _onStopDeviceStream(
    BleStopDeviceStream event,
    Emitter<BleState> emit,
  ) async {
    await _stopDeviceStreaming(event.deviceId, emit);
  }

  Future<void> _stopDeviceStreaming(
    String deviceId,
    Emitter<BleState> emit, {
    bool stopHardware = true,
  }) async {
    if (!state.isDeviceStreaming(deviceId)) return;

    emit(_stateWithStreamingStopped(deviceId));

    if (!stopHardware) return;

    final result = await _stopHardwareStream(deviceId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
          status: BleStatus.failure,
        ),
      ),
      (_) =>
          emit(state.copyWith(status: BleStatus.success, errorMessage: null)),
    );
  }

  bool _isMyoBandDevice(String deviceId) {
    return state.savedDevices[deviceId]?.deviceType.isMyoBandFamily ?? false;
  }

  // ---------------------------------------------------------------------------
  // Device stream: guards
  // ---------------------------------------------------------------------------

  bool _canStartDeviceStream(String deviceId) {
    return state.isDeviceConnected(deviceId) &&
        !state.isDeviceStreaming(deviceId);
  }

  // ---------------------------------------------------------------------------
  // Device stream: hardware lifecycle
  // ---------------------------------------------------------------------------

  Future<Either<Failure, Unit>> _startHardwareStream(String deviceId) {
    return _startDeviceStream(StartDeviceStreamParams(deviceId: deviceId));
  }

  Future<Either<Failure, Unit>> _stopHardwareStream(String deviceId) {
    return _stopDeviceStream(StopDeviceStreamParams(deviceId: deviceId));
  }

  // ---------------------------------------------------------------------------
  // Device stream: stream resolution
  // ---------------------------------------------------------------------------

  Stream<Either<Failure, BleDeviceStreamSnapshot>>? _resolveDeviceDataStream(
    String deviceId,
  ) {
    return _watchDeviceData(WatchDeviceDataParams(deviceId: deviceId));
  }

  // ---------------------------------------------------------------------------
  // Device stream: state mapping
  // ---------------------------------------------------------------------------

  BleState _stateWithStreamingStarted(String deviceId) {
    return state.copyWith(
      streamingDeviceIds: {...state.streamingDeviceIds, deviceId},
      status: BleStatus.success,
      errorMessage: null,
    );
  }

  BleState _stateWithStreamingStopped(String deviceId) {
    final updated = Set<String>.from(state.streamingDeviceIds)
      ..remove(deviceId);

    return state.copyWith(
      streamingDeviceIds: updated,
      deviceStreamSnapshots: _removeStreamSnapshot(
        state.deviceStreamSnapshots,
        deviceId,
      ),
    );
  }

  BleState _stateWithStreamSnapshot(
    String deviceId,
    BleDeviceStreamSnapshot snapshot,
  ) {
    return state.copyWith(
      status: BleStatus.success,
      deviceStreamSnapshots: {
        ...state.deviceStreamSnapshots,
        deviceId: snapshot,
      },
    );
  }

  BleState _stateWithStreamFailure(Failure failure) {
    return state.copyWith(
      errorMessage: failure.message,
      status: BleStatus.failure,
    );
  }

  void _subscribeDeviceConnectionStream(String deviceId) {
    if (_deviceConnectionSubscriptions.containsKey(deviceId)) return;

    final stream = _watchDeviceConnection(
      WatchDeviceConnectionParams(deviceId: deviceId),
    );
    if (stream == null) return;

    _deviceConnectionSubscriptions[deviceId] = stream.listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => add(BleEvent.streamFailed(message: failure.message)),
        (status) {
          if (status == BleConnectionStatus.disconnected) {
            add(BleEvent.connectionLost(deviceId: deviceId));
          }
        },
      );
    });
  }

  Future<void> _unsubscribeDeviceConnectionStream(String deviceId) async {
    await _deviceConnectionSubscriptions.remove(deviceId)?.cancel();
  }

  Future<void> _unsubscribeAllDeviceConnectionStreams() async {
    final subscriptions = _deviceConnectionSubscriptions.values.toList();
    _deviceConnectionSubscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  }

  Future<void> _clearDeviceSubscriptions(String deviceId) async {
    await _unsubscribeDeviceConnectionStream(deviceId);
  }

  void _emitDeviceDisconnected(Emitter<BleState> emit, String deviceId) {
    emit(
      state.copyWith(
        activeConnections: _removeConnection(state.activeConnections, deviceId),
        deviceStreamSnapshots: _removeStreamSnapshot(
          state.deviceStreamSnapshots,
          deviceId,
        ),
        streamingDeviceIds: Set<String>.from(state.streamingDeviceIds)
          ..remove(deviceId),
        status: BleStatus.success,
        errorMessage: null,
      ),
    );
  }

  Map<String, BleActiveConnection> _upsertConnection(
    Map<String, BleActiveConnection> current, {
    required String deviceId,
    required BleConnectionStatus status,
    String? errorMessage,
    BleDeviceInfo? deviceInfo,
    bool isReadingInfo = false,
    bool clearDeviceInfo = false,
  }) {
    final existing = current[deviceId];

    return {
      ...current,
      deviceId: BleActiveConnection(
        deviceId: deviceId,
        status: status,
        errorMessage: errorMessage,
        isReadingInfo: isReadingInfo,
        deviceInfo: _getDeviceInfo(
          clearDeviceInfo,
          existingInfo: existing?.deviceInfo,
          newInfo: deviceInfo,
        ),
      ),
    };
  }

  BleDeviceInfo? _getDeviceInfo(
    bool clearDeviceInfo, {
    BleDeviceInfo? existingInfo,
    BleDeviceInfo? newInfo,
  }) {
    /// Clear Everything When clearDeviceInfo Flag is true
    if (clearDeviceInfo) return null;

    /// clearDeviceInfo Flag is false || newInfo is not null
    if (newInfo != null) return newInfo;

    /// clearDeviceInfo Flag is false || existingInfo is not null
    if (existingInfo != null) return existingInfo;

    /// Everything else is null
    return null;
  }

  Map<String, BleActiveConnection> _removeConnection(
    Map<String, BleActiveConnection> current,
    String deviceId,
  ) {
    return Map<String, BleActiveConnection>.from(current)..remove(deviceId);
  }

  Map<String, BleDeviceStreamSnapshot> _removeStreamSnapshot(
    Map<String, BleDeviceStreamSnapshot> current,
    String deviceId,
  ) {
    return Map<String, BleDeviceStreamSnapshot>.from(current)..remove(deviceId);
  }

  @override
  Future<void> close() async {
    await _adapterSubscription?.cancel();
    await _unsubscribeScanResultsStream();
    await _unsubscribeAllDeviceConnectionStreams();
    if (state.isScanning) {
      await _stopScan(const NoParams());
    }

    final connectedDeviceIds = state.activeConnections.values
        .where((connection) => connection.status.isConnected)
        .map((connection) => connection.deviceId)
        .toList();

    for (final deviceId in state.streamingDeviceIds.toList()) {
      await _stopHardwareStream(deviceId);
    }

    for (final deviceId in connectedDeviceIds) {
      await _disconnectDevice(DisconnectDeviceParams(deviceId: deviceId));
    }

    return super.close();
  }
}
