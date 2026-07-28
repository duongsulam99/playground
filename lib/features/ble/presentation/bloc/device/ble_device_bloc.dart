import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import '../../../domain/entities/ble_action_button_mapping.dart';
import '../../../domain/entities/ble_battery_snapshot.dart';
import '../../../domain/entities/ble_device_capabilities.dart';
import '../../../domain/entities/ble_device_info.dart';
import '../../../domain/entities/ble_device_stream_snapshot.dart';
import '../../../domain/usecase/read_device_info.dart';
import '../../../domain/usecase/start_device_stream.dart';
import '../../../domain/usecase/stop_device_stream.dart';
import '../../../domain/usecase/watch_action_button_mapping.dart';
import '../../../domain/usecase/watch_battery.dart';
import '../../../domain/usecase/watch_device_data.dart';

part 'ble_device_bloc.freezed.dart';
part 'ble_device_event.dart';
part 'ble_device_state.dart';

class BleDeviceBlocArgs {
  const BleDeviceBlocArgs({required this.deviceId, required this.scannedType});

  final String deviceId;
  final VulcanDeviceType scannedType;
}

class BleDeviceBloc extends Bloc<BleDeviceEvent, BleDeviceState> {
  BleDeviceBloc({
    required String deviceId,
    required VulcanDeviceType scannedType,
    required this._watchDeviceData,
    required this._watchBattery,
    required this._watchActionButtonMapping,
    required this._readDeviceInfo,
    required this._startDeviceStream,
    required this._stopDeviceStream,
  }) : super(
         BleDeviceState(
           deviceId: deviceId,
           scannedType: scannedType,
           capabilities: BleDeviceCapabilities.fromDeviceTypes(
             scannedType: scannedType,
           ),
         ),
       ) {
    on<BleDeviceSessionStarted>(_onSessionStarted);
    on<BleDeviceReadInfoRequested>(_onReadInfoRequested);
    on<BleDeviceStartStream>(_onStartStream);
    on<BleDeviceStopStream>(_onStopStream);
    on<BleDeviceListenData>(_onListenData, transformer: restartable());
    on<BleDeviceBatteryUpdated>(_onBatteryUpdated, transformer: concurrent());
    on<BleDeviceActionButtonMappingUpdated>(
      _onActionButtonMappingUpdated,
      transformer: concurrent(),
    );
    on<BleDeviceSessionEnded>(_onSessionEnded);
  }

  final WatchDeviceData _watchDeviceData;
  final WatchBattery _watchBattery;
  final WatchActionButtonMapping _watchActionButtonMapping;
  final ReadDeviceInfo _readDeviceInfo;
  final StartDeviceStream _startDeviceStream;
  final StopDeviceStream _stopDeviceStream;

  StreamSubscription<dynamic>? _batterySubscription;
  StreamSubscription<dynamic>? _actionButtonMappingSubscription;

  Future<void> _onSessionStarted(
    BleDeviceSessionStarted event,
    Emitter<BleDeviceState> emit,
  ) async {
    _subscribeBatteryStream();
    _subscribeActionButtonMappingStream();
    await _readInfo(emit);
  }

  Future<void> _onReadInfoRequested(
    BleDeviceReadInfoRequested event,
    Emitter<BleDeviceState> emit,
  ) async {
    if (!state.capabilities.supportsDeviceInfo &&
        state.scannedType != VulcanDeviceType.none) {
      return;
    }
    await _readInfo(emit);
  }

  Future<void> _readInfo(Emitter<BleDeviceState> emit) async {
    emit(
      state.copyWith(
        isReadingInfo: true,
        status: BleDeviceStatus.loading,
        errorMessage: null,
      ),
    );

    final result = await _readDeviceInfo(
      ReadDeviceInfoParams(deviceId: state.deviceId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isReadingInfo: false,
          errorMessage: failure.message,
          status: BleDeviceStatus.failure,
        ),
      ),
      (info) {
        final resolvedType = info.resolvedType;
        final capabilities = BleDeviceCapabilities.fromDeviceTypes(
          scannedType: state.scannedType,
          resolvedType: resolvedType,
        );

        emit(
          state.copyWith(
            isReadingInfo: false,
            deviceInfo: info,
            resolvedType: resolvedType,
            capabilities: capabilities,
            status: BleDeviceStatus.success,
            errorMessage: null,
          ),
        );

        if (capabilities.supportsBattery && _batterySubscription == null) {
          _subscribeBatteryStream();
        }
        if (capabilities.supportsActionButton &&
            _actionButtonMappingSubscription == null) {
          _subscribeActionButtonMappingStream();
        }
      },
    );
  }

  Future<void> _onStartStream(
    BleDeviceStartStream event,
    Emitter<BleDeviceState> emit,
  ) async {
    if (!state.capabilities.supportsDecodedStream) return;
    if (state.isStreaming) return;

    emit(state.copyWith(status: BleDeviceStatus.loading, errorMessage: null));

    final result = await _startDeviceStream(
      StartDeviceStreamParams(deviceId: state.deviceId),
    );

    if (result.isLeft()) {
      final failure = result.fold((left) => left, (_) => throw StateError(''));
      emit(
        state.copyWith(
          errorMessage: failure.message,
          status: BleDeviceStatus.failure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isStreaming: true,
        status: BleDeviceStatus.success,
        errorMessage: null,
      ),
    );

    add(const BleDeviceEvent.listenData());
  }

  Future<void> _onListenData(
    BleDeviceListenData event,
    Emitter<BleDeviceState> emit,
  ) async {
    if (!state.isStreaming) return;
    if (!state.capabilities.supportsDecodedStream) return;

    final stream = _watchDeviceData(
      WatchDeviceDataParams(deviceId: state.deviceId),
    );

    await emit.forEach<Either<Failure, BleDeviceStreamSnapshot>>(
      stream,
      onData: (result) {
        if (!state.isStreaming) return state;

        return result.fold(
          (failure) => state.copyWith(
            errorMessage: failure.message,
            status: BleDeviceStatus.failure,
          ),
          (snapshot) => state.copyWith(
            streamSnapshot: snapshot,
            status: BleDeviceStatus.success,
            errorMessage: null,
          ),
        );
      },
      onError: (error, _) => state.copyWith(
        errorMessage: error.toString(),
        status: BleDeviceStatus.failure,
      ),
    );

    if (state.isStreaming) {
      emit(state.copyWith(isStreaming: false, streamSnapshot: null));
    }
  }

  Future<void> _onStopStream(
    BleDeviceStopStream event,
    Emitter<BleDeviceState> emit,
  ) async {
    await _stopStreaming(emit, stopHardware: event.stopHardware);
  }

  Future<void> _stopStreaming(
    Emitter<BleDeviceState> emit, {
    required bool stopHardware,
  }) async {
    if (!state.isStreaming) return;

    emit(state.copyWith(isStreaming: false, streamSnapshot: null));

    if (!stopHardware) return;
    if (!state.capabilities.supportsDecodedStream) return;

    final result = await _stopDeviceStream(
      StopDeviceStreamParams(deviceId: state.deviceId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
          status: BleDeviceStatus.failure,
        ),
      ),
      (_) => emit(
        state.copyWith(status: BleDeviceStatus.success, errorMessage: null),
      ),
    );
  }

  Future<void> _onBatteryUpdated(
    BleDeviceBatteryUpdated event,
    Emitter<BleDeviceState> emit,
  ) async {
    emit(state.copyWith(battery: event.battery));
  }

  Future<void> _onActionButtonMappingUpdated(
    BleDeviceActionButtonMappingUpdated event,
    Emitter<BleDeviceState> emit,
  ) async {
    emit(state.copyWith(actionButtonMapping: event.mapping));
  }

  Future<void> _onSessionEnded(
    BleDeviceSessionEnded event,
    Emitter<BleDeviceState> emit,
  ) async {
    await _stopStreaming(emit, stopHardware: event.stopHardware);
    await _unsubscribeBatteryStream();
    await _unsubscribeActionButtonMappingStream();

    emit(
      state.copyWith(
        isReadingInfo: false,
        deviceInfo: null,
        battery: null,
        actionButtonMapping: null,
        streamSnapshot: null,
        isStreaming: false,
        status: BleDeviceStatus.success,
        errorMessage: null,
      ),
    );
  }

  void _subscribeBatteryStream() {
    if (_batterySubscription != null) return;

    final stream = _watchBattery(WatchBatteryParams(deviceId: state.deviceId));

    _batterySubscription = stream.listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => _onBatteryStreamError,
        (battery) => add(BleDeviceEvent.batteryUpdated(battery: battery)),
      );
    });
  }

  void _onBatteryStreamError(Failure err) {
    // One-shot stream failures usually mean device family doesn't support
    // battery notify. Stop listening to avoid repeated no-op callbacks.
    log('Battery stream error: $err');
  }

  Future<void> _unsubscribeBatteryStream() async {
    await _batterySubscription?.cancel();
    _batterySubscription = null;
  }

  void _subscribeActionButtonMappingStream() {
    if (_actionButtonMappingSubscription != null) return;
    if (!state.capabilities.supportsActionButton) return;

    final stream = _watchActionButtonMapping(
      WatchActionButtonMappingParams(deviceId: state.deviceId),
    );

    _actionButtonMappingSubscription = stream.listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => log('Action button mapping stream error: $failure'),
        (mapping) => add(
          BleDeviceEvent.actionButtonMappingUpdated(mapping: mapping),
        ),
      );
    });
  }

  Future<void> _unsubscribeActionButtonMappingStream() async {
    await _actionButtonMappingSubscription?.cancel();
    _actionButtonMappingSubscription = null;
  }

  /// Stops hardware stream if still active (used by Manager close / disconnect).
  Future<void> stopHardwareStreamIfNeeded() async {
    if (!state.isStreaming) return;
    await _stopDeviceStream(StopDeviceStreamParams(deviceId: state.deviceId));
  }

  @override
  Future<void> close() async {
    await _unsubscribeBatteryStream();
    await _unsubscribeActionButtonMappingStream();
    // Hardware stop is owned by BleManagerBloc (disconnect vs connectionLost).
    return super.close();
  }
}
