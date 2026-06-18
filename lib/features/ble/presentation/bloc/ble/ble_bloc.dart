import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/connect_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/disconnect_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/start_scan.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/stop_scan.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/watch_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/usecase/watch_scan_results.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_event.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/bloc/ble/ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  BleBloc({
    required this._watchAdapterStatus,
    required this._watchScanResults,
    required this._startScan,
    required this._stopScan,
    required this._connectDevice,
    required this._disconnectDevice,
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
          (devices) => add(BleEvent.scanResultsUpdated(devices: devices)),
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
    emit(state.copyWith(devices: event.devices, status: BleStatus.success));
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
    final updatedConnections = Map<String, BleConnectionStatus>.from(
      state.deviceConnections,
    )..[deviceId] = BleConnectionStatus.connecting;

    emit(
      state.copyWith(
        status: BleStatus.loading,
        deviceConnections: updatedConnections,
        deviceErrors: _clearDeviceError(deviceId),
        errorMessage: null,
      ),
    );

    if (state.isScanning) {
      await _stopScanning(emit);
    }

    final connectResult = await _connectDevice(
      ConnectDeviceParams(deviceId: deviceId),
    );

    connectResult.fold(
      (failure) {
        final connections = Map<String, BleConnectionStatus>.from(
          state.deviceConnections,
        )..[deviceId] = BleConnectionStatus.disconnected;

        final errors = Map<String, String>.from(state.deviceErrors)
          ..[deviceId] = failure.message;

        emit(
          state.copyWith(
            deviceConnections: connections,
            deviceErrors: errors,
            status: BleStatus.failure,
            isScanning: false,
          ),
        );
      },
      (connectionStatus) {
        final connections = Map<String, BleConnectionStatus>.from(
          state.deviceConnections,
        )..[deviceId] = connectionStatus;

        emit(
          state.copyWith(
            deviceConnections: connections,
            isScanning: false,
            status: BleStatus.success,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> _onDisconnectRequested(
    BleDisconnectRequested event,
    Emitter<BleState> emit,
  ) async {
    final deviceId = event.deviceId;
    final updatedConnections = Map<String, BleConnectionStatus>.from(
      state.deviceConnections,
    )..[deviceId] = BleConnectionStatus.disconnecting;

    emit(
      state.copyWith(
        status: BleStatus.loading,
        deviceConnections: updatedConnections,
      ),
    );

    final result = await _disconnectDevice(
      DisconnectDeviceParams(deviceId: deviceId),
    );

    result.fold(
      (failure) {
        final errors = Map<String, String>.from(state.deviceErrors)
          ..[deviceId] = failure.message;

        emit(
          state.copyWith(
            deviceErrors: errors,
            status: BleStatus.failure,
          ),
        );
      },
      (_) {
        final connections = Map<String, BleConnectionStatus>.from(
          state.deviceConnections,
        )..remove(deviceId);

        emit(
          state.copyWith(
            deviceConnections: connections,
            deviceErrors: _clearDeviceError(deviceId),
            status: BleStatus.success,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Map<String, String> _clearDeviceError(String deviceId) {
    final errors = Map<String, String>.from(state.deviceErrors);
    errors.remove(deviceId);
    return errors;
  }

  @override
  Future<void> close() async {
    await _adapterSubscription?.cancel();
    await _unsubscribeScanResultsStream();
    if (state.isScanning) {
      await _stopScan(const NoParams());
    }

    final connectedDeviceIds = state.deviceConnections.entries
        .where((entry) => entry.value.isConnected)
        .map((entry) => entry.key)
        .toList();

    for (final deviceId in connectedDeviceIds) {
      await _disconnectDevice(DisconnectDeviceParams(deviceId: deviceId));
    }

    return super.close();
  }
}
