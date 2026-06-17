import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';
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
  })  : super(const BleState()) {
    on<BleAdapterStatusUpdated>(_onAdapterStatusUpdated);
    on<BleScanResultsUpdated>(_onScanResultsUpdated);
    on<BleStreamFailed>(_onStreamFailed);
    on<BleScanToggled>(_onScanToggled);
    on<BleDeviceSelected>(_onDeviceSelected);
    on<BleDisconnectRequested>(_onDisconnectRequested);

    _subscribeToStreams();
  }

  final WatchAdapterStatus _watchAdapterStatus;
  final WatchScanResults _watchScanResults;
  final StartScan _startScan;
  final StopScan _stopScan;
  final ConnectDevice _connectDevice;
  final DisconnectDevice _disconnectDevice;

  StreamSubscription<dynamic>? _adapterSubscription;
  StreamSubscription<dynamic>? _scanResultsSubscription;

  void _subscribeToStreams() {
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
        devices: event.devices,
        status: BleStatus.success,
      ),
    );
  }

  Future<void> _onStreamFailed(
    BleStreamFailed event,
    Emitter<BleState> emit,
  ) async {
    emit(
      state.copyWith(
        errorMessage: event.message,
        status: BleStatus.failure,
      ),
    );
  }

  Future<void> _onScanToggled(
    BleScanToggled event,
    Emitter<BleState> emit,
  ) async {
    if (state.isScanning) {
      final result = await _stopScan(const NoParams());
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
      return;
    }

    emit(
      state.copyWith(
        status: BleStatus.loading,
        errorMessage: null,
      ),
    );

    final result = await _startScan(const NoParams());
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
          isScanning: true,
          status: BleStatus.success,
        ),
      ),
    );
  }

  Future<void> _onDeviceSelected(
    BleDeviceSelected event,
    Emitter<BleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BleStatus.loading,
        connectionStatus: BleConnectionStatus.connecting,
        errorMessage: null,
      ),
    );

    if (state.isScanning) {
      await _stopScan(const NoParams());
    }

    final connectResult =
        await _connectDevice(ConnectDeviceParams(deviceId: event.deviceId));

    connectResult.fold(
      (failure) => emit(
        state.copyWith(
          connectionStatus: BleConnectionStatus.disconnected,
          errorMessage: failure.message,
          status: BleStatus.failure,
          isScanning: false,
        ),
      ),
      (connectionStatus) => emit(
        state.copyWith(
          connectionStatus: connectionStatus,
          connectedDeviceId: event.deviceId,
          isScanning: false,
          status: BleStatus.success,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onDisconnectRequested(
    BleDisconnectRequested event,
    Emitter<BleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BleStatus.loading,
        connectionStatus: BleConnectionStatus.disconnecting,
      ),
    );

    final result = await _disconnectDevice(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
          status: BleStatus.failure,
        ),
      ),
      (_) => emit(
        state.copyWith(
          connectionStatus: BleConnectionStatus.disconnected,
          status: BleStatus.success,
          connectedDeviceId: null,
          errorMessage: null,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _adapterSubscription?.cancel();
    await _scanResultsSubscription?.cancel();
    if (state.isScanning) {
      await _stopScan(const NoParams());
    }
    return super.close();
  }
}
