import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../../../domain/entity/firmware_info.dart';
import '../../../domain/repository/firmware_repository.dart';
import '../../../domain/usecase/check_latest_firmware.dart';

part 'firmware_update_event.dart';
part 'firmware_update_state.dart';
part 'firmware_update_bloc.freezed.dart';

class FirmwareUpdateBloc extends Bloc<FirmwareUpdateEvent, FirmwareUpdateState> {
  FirmwareUpdateBloc({required this._checkLatestFirmware})
    : super(const FirmwareUpdateState()) {
    on<FirmwareUpdateStarted>(_onStarted);
    on<FirmwareUpdateRetryRequested>(_onRetryRequested);
  }

  final CheckLatestFirmware _checkLatestFirmware;

  Future<void> _onStarted(
    FirmwareUpdateStarted event,
    Emitter<FirmwareUpdateState> emit,
  ) async {
    await _checkFirmware(
      emit,
      deviceId: event.deviceId,
      deviceType: event.deviceType,
      currentVersion: event.currentVersion,
    );
  }

  Future<void> _onRetryRequested(
    FirmwareUpdateRetryRequested event,
    Emitter<FirmwareUpdateState> emit,
  ) async {
    await _checkFirmware(
      emit,
      deviceId: state.deviceId,
      deviceType: state.deviceType,
      currentVersion: state.currentVersion,
    );
  }

  Future<void> _checkFirmware(
    Emitter<FirmwareUpdateState> emit, {
    required String deviceId,
    required VulcanDeviceType deviceType,
    required String currentVersion,
  }) async {
    emit(
      state.copyWith(
        deviceId: deviceId,
        deviceType: deviceType,
        currentVersion: currentVersion,
        checkStatus: FirmwareCheckStatus.loading,
        errorMessage: null,
        checkResult: null,
      ),
    );

    final result = await _checkLatestFirmware(
      CheckFirmwareParams(
        deviceType: deviceType,
        currentVersion: currentVersion,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          checkStatus: FirmwareCheckStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (checkResult) => emit(
        state.copyWith(
          checkStatus: FirmwareCheckStatus.success,
          checkResult: checkResult,
        ),
      ),
    );
  }
}
