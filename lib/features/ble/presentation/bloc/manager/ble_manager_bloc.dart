import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/core/ble/config/constants/vulcan_constant.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';

import '../../../domain/entities/ble_connection_entry.dart';
import '../../../domain/entities/ble_discovered_device.dart';
import '../../../domain/entities/ble_scan_snapshot.dart';
import '../../../domain/usecase/connect_device.dart';
import '../../../domain/usecase/disconnect_device.dart';
import '../../../domain/usecase/start_scan.dart';
import '../../../domain/usecase/stop_scan.dart';
import '../../../domain/usecase/watch_adapter_status.dart';
import '../../../domain/usecase/watch_device_connection.dart';
import '../../../domain/usecase/watch_scan_results.dart';
import '../device/ble_device_bloc.dart';
import '../device/ble_device_bloc_registry.dart';

part 'ble_manager_bloc.freezed.dart';
part 'ble_manager_event.dart';
part 'ble_manager_state.dart';

class BleManagerBloc extends Bloc<BleManagerEvent, BleManagerState> {
  BleManagerBloc({
    required this._watchAdapterStatus,
    required this._watchScanResults,
    required this._watchDeviceConnection,
    required this._startScan,
    required this._stopScan,
    required this._connectDevice,
    required this._disconnectDevice,
    required this._deviceRegistry,
  }) : super(const BleManagerState()) {
    on<BleManagerScanFilterUpdated>(_onScanFilterUpdated);
    on<BleManagerStartScan>(_onStartScan);
    on<BleManagerStopScan>(_onStopScan);
    on<BleManagerAdapterStatusUpdated>(_onAdapterStatusUpdated);
    on<BleManagerScanResultsUpdated>(_onScanResultsUpdated);
    on<BleManagerConnectionLost>(_onConnectionLost);
    on<BleManagerStreamFailed>(_onStreamFailed);
    on<BleManagerConnectRequested>(_onConnectRequested);
    on<BleManagerDisconnectRequested>(_onDisconnectRequested);

    _subscribeAdapterStream();
  }

  final WatchAdapterStatus _watchAdapterStatus;
  final WatchScanResults _watchScanResults;
  final WatchDeviceConnection _watchDeviceConnection;
  final StartScan _startScan;
  final StopScan _stopScan;
  final ConnectDevice _connectDevice;
  final DisconnectDevice _disconnectDevice;
  final BleDeviceBlocRegistry _deviceRegistry;

  StreamSubscription<dynamic>? _adapterSubscription;
  StreamSubscription<dynamic>? _scanResultsSubscription;
  final Map<String, StreamSubscription<dynamic>>
  _deviceConnectionSubscriptions = {};

  BleDeviceBlocRegistry get deviceRegistry => _deviceRegistry;

  void _subscribeAdapterStream() {
    if (_adapterSubscription != null) return;

    _adapterSubscription = _watchAdapterStatus(const NoParams()).listen((
      result,
    ) {
      if (isClosed) return;
      result.fold(
        (err) => add(BleManagerEvent.streamFailed(message: err.message)),
        (status) => add(BleManagerEvent.adapterStatusUpdated(status: status)),
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
        (err) => add(BleManagerEvent.streamFailed(message: err.message)),
        (devices) => add(BleManagerEvent.scanResultsUpdated(savedDevices: devices)),
      );
    });
  }

  Future<void> _unsubscribeScanResultsStream() async {
    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
  }

  Future<void> _stopScanning(Emitter<BleManagerState> emit) async {
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
          status: BleManagerStatus.failure,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isScanning: false,
          status: BleManagerStatus.success,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onScanFilterUpdated(
    BleManagerScanFilterUpdated event,
    Emitter<BleManagerState> emit,
  ) async {
    emit(state.copyWith(scanFilterTypes: event.filterTypes));
  }

  Future<void> _onStartScan(
    BleManagerStartScan event,
    Emitter<BleManagerState> emit,
  ) async {
    if (state.isScanning) return;

    emit(state.copyWith(status: BleManagerStatus.loading, errorMessage: null));

    final result = await _startScan(
      StartScanParams(filterTypes: state.scanFilterTypes),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isScanning: false,
          errorMessage: failure.message,
          status: BleManagerStatus.failure,
        ),
      ),
      (_) {
        _subscribeScanResultsStream();
        emit(
          state.copyWith(isScanning: true, status: BleManagerStatus.success),
        );
      },
    );
  }

  Future<void> _onStopScan(
    BleManagerStopScan event,
    Emitter<BleManagerState> emit,
  ) async {
    await _stopScanning(emit);
  }

  Future<void> _onAdapterStatusUpdated(
    BleManagerAdapterStatusUpdated event,
    Emitter<BleManagerState> emit,
  ) async {
    emit(
      state.copyWith(
        adapterStatus: event.status,
        status: BleManagerStatus.success,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onScanResultsUpdated(
    BleManagerScanResultsUpdated event,
    Emitter<BleManagerState> emit,
  ) async {
    emit(
      state.copyWith(
        savedDevices: event.savedDevices,
        status: BleManagerStatus.success,
      ),
    );
  }

  Future<void> _onStreamFailed(
    BleManagerStreamFailed event,
    Emitter<BleManagerState> emit,
  ) async {
    emit(
      state.copyWith(
        errorMessage: event.message,
        status: BleManagerStatus.failure,
      ),
    );
  }

  Future<void> _onConnectRequested(
    BleManagerConnectRequested event,
    Emitter<BleManagerState> emit,
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
          status: BleManagerStatus.failure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: BleManagerStatus.loading,
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
          ),
          status: BleManagerStatus.failure,
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
        ),
        isScanning: false,
        status: BleManagerStatus.success,
      ),
    );

    _subscribeDeviceConnectionStream(deviceId);

    final scannedType =
        state.savedDevices[deviceId]?.deviceType ?? VulcanDeviceType.none;
    final deviceBloc = _deviceRegistry.getOrCreate(deviceId, scannedType);
    deviceBloc.add(const BleDeviceEvent.sessionStarted());
  }

  Future<void> _onDisconnectRequested(
    BleManagerDisconnectRequested event,
    Emitter<BleManagerState> emit,
  ) async {
    final deviceId = event.deviceId;

    await _endDeviceSession(deviceId, stopHardware: true);

    emit(
      state.copyWith(
        status: BleManagerStatus.loading,
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
          status: BleManagerStatus.failure,
        ),
      );
      return;
    }

    await _unsubscribeDeviceConnectionStream(deviceId);
    await _deviceRegistry.dispose(deviceId);
    _emitDeviceDisconnected(emit, deviceId);
  }

  Future<void> _onConnectionLost(
    BleManagerConnectionLost event,
    Emitter<BleManagerState> emit,
  ) async {
    final deviceId = event.deviceId;
    final connection = state.activeConnections[deviceId];
    if (connection == null) return;
    if (connection.status == BleConnectionStatus.disconnecting) return;

    await _endDeviceSession(deviceId, stopHardware: false);
    await _unsubscribeDeviceConnectionStream(deviceId);
    await _deviceRegistry.dispose(deviceId);
    _emitDeviceDisconnected(emit, deviceId);
  }

  Future<void> _endDeviceSession(
    String deviceId, {
    required bool stopHardware,
  }) async {
    final deviceBloc = _deviceRegistry.get(deviceId);
    if (deviceBloc == null) return;

    if (deviceBloc.state.isStreaming && stopHardware) {
      await deviceBloc.stopHardwareStreamIfNeeded();
    }
  }

  void _subscribeDeviceConnectionStream(String deviceId) {
    if (_deviceConnectionSubscriptions.containsKey(deviceId)) return;

    final stream = _watchDeviceConnection(
      WatchDeviceConnectionParams(deviceId: deviceId),
    );

    _deviceConnectionSubscriptions[deviceId] = stream.listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) =>
            add(BleManagerEvent.streamFailed(message: failure.message)),
        (status) {
          if (status == BleConnectionStatus.disconnected) {
            add(BleManagerEvent.connectionLost(deviceId: deviceId));
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

  void _emitDeviceDisconnected(Emitter<BleManagerState> emit, String deviceId) {
    emit(
      state.copyWith(
        activeConnections: _removeConnection(state.activeConnections, deviceId),
        status: BleManagerStatus.success,
        errorMessage: null,
      ),
    );
  }

  Map<String, BleConnectionEntry> _upsertConnection(
    Map<String, BleConnectionEntry> current, {
    required String deviceId,
    required BleConnectionStatus status,
    String? errorMessage,
  }) {
    return {
      ...current,
      deviceId: BleConnectionEntry(
        deviceId: deviceId,
        status: status,
        errorMessage: errorMessage,
      ),
    };
  }

  Map<String, BleConnectionEntry> _removeConnection(
    Map<String, BleConnectionEntry> current,
    String deviceId,
  ) {
    return Map<String, BleConnectionEntry>.from(current)..remove(deviceId);
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

    for (final deviceId in _deviceRegistry.deviceIds.toList()) {
      final deviceBloc = _deviceRegistry.get(deviceId);
      await deviceBloc?.stopHardwareStreamIfNeeded();
    }

    await _deviceRegistry.disposeAll();

    for (final deviceId in connectedDeviceIds) {
      await _disconnectDevice(DisconnectDeviceParams(deviceId: deviceId));
    }

    return super.close();
  }
}
