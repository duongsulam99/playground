import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/core/ble/config/constants/vulcan_constant.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

import '../../../domain/entities/ble_discovered_device.dart';
import '../../../domain/entities/ble_active_connection.dart';
import '../../../domain/entities/ble_device_info.dart';
import '../../../domain/usecase/connect_device.dart';
import '../../../domain/usecase/disconnect_device.dart';
import '../../../domain/usecase/read_device_info.dart';
import '../../../domain/usecase/start_scan.dart';
import '../../../domain/usecase/stop_scan.dart';
import '../../../domain/usecase/watch_adapter_status.dart';
import '../../../domain/usecase/watch_scan_results.dart';

part 'ble_bloc.freezed.dart';
part 'ble_event.dart';
part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  BleBloc({
    required this._watchAdapterStatus,
    required this._watchScanResults,
    required this._startScan,
    required this._stopScan,
    required this._connectDevice,
    required this._disconnectDevice,
    required this._readDeviceInfo,
  }) : super(const BleState()) {
    on<BleScanFilterUpdated>(_onScanFilterUpdated);
    on<BleStartScan>(_onStartScan);
    on<BleStopScan>(_onStopScan);
    on<BleAdapterStatusUpdated>(_onAdapterStatusUpdated);
    on<BleScanResultsUpdated>(_onScanResultsUpdated);
    on<BleStreamFailed>(_onStreamFailed);
    on<BleConnectRequested>(_onConnectRequested);
    on<BleDisconnectRequested>(_onDisconnectRequested);

    _subscribeAdapterStream();
  }

  final WatchAdapterStatus _watchAdapterStatus;
  final WatchScanResults _watchScanResults;
  final StartScan _startScan;
  final StopScan _stopScan;
  final ConnectDevice _connectDevice;
  final DisconnectDevice _disconnectDevice;
  final ReadDeviceInfo _readDeviceInfo;

  StreamSubscription<dynamic>? _adapterSubscription;
  StreamSubscription<dynamic>? _scanResultsSubscription;

  void _subscribeAdapterStream() {
    if (_adapterSubscription != null) return;

    _adapterSubscription = _watchAdapterStatus(const NoParams()).listen(
      (result) {
        if (isClosed) return;
        result.fold(
          (failure) => add(BleEvent.streamFailed(message: failure.message)),
          (status) => add(BleEvent.adapterStatusUpdated(status: status)),
        );
      },
      onError: (Object error) {
        if (isClosed) return;
        add(BleEvent.streamFailed(message: error.toString()));
      },
    );
  }

  void _subscribeScanResultsStream() {
    if (_scanResultsSubscription != null) return;

    _scanResultsSubscription = _watchScanResults(const NoParams()).listen(
      (result) {
        if (isClosed) return;
        result.fold(
          (failure) => add(BleEvent.streamFailed(message: failure.message)),
          (devices) => add(BleEvent.scanResultsUpdated(savedDevices: devices)),
        );
      },
      onError: (Object error) {
        if (isClosed) return;
        add(BleEvent.streamFailed(message: error.toString()));
      },
    );
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

    result.fold(
      (failure) => emit(
        state.copyWith(
          activeConnections: _upsertConnection(
            state.activeConnections,
            deviceId: deviceId,
            status: BleConnectionStatus.connected,
            errorMessage: failure.message,
          ),
          status: BleStatus.failure,
        ),
      ),
      (_) => emit(
        state.copyWith(
          activeConnections: _removeConnection(
            state.activeConnections,
            deviceId,
          ),
          status: BleStatus.success,
          errorMessage: null,
        ),
      ),
    );
  }

  bool _isMyoBandDevice(String deviceId) {
    return state.savedDevices[deviceId]?.deviceType.isMyoBandFamily ?? false;
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
    if (clearDeviceInfo) return null;
    if (newInfo != null) return newInfo;
    if (existingInfo == null) return null;

    /// Keep existing info
    return existingInfo;
  }

  Map<String, BleActiveConnection> _removeConnection(
    Map<String, BleActiveConnection> current,
    String deviceId,
  ) {
    return Map<String, BleActiveConnection>.from(current)..remove(deviceId);
  }

  @override
  Future<void> close() async {
    await _adapterSubscription?.cancel();
    await _unsubscribeScanResultsStream();
    if (state.isScanning) {
      await _stopScan(const NoParams());
    }

    final connectedDeviceIds = state.activeConnections.values
        .where((connection) => connection.status.isConnected)
        .map((connection) => connection.deviceId)
        .toList();

    for (final deviceId in connectedDeviceIds) {
      await _disconnectDevice(DisconnectDeviceParams(deviceId: deviceId));
    }

    return super.close();
  }
}
