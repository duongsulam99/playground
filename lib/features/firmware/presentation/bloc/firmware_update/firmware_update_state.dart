part of 'firmware_update_bloc.dart';

enum FirmwareCheckStatus { initial, loading, success, failure }

@freezed
abstract class FirmwareUpdateState with _$FirmwareUpdateState {
  const factory FirmwareUpdateState({
    @Default('') String deviceId,
    @Default(VulcanDeviceType.none) VulcanDeviceType deviceType,
    @Default('') String currentVersion,
    @Default(FirmwareCheckStatus.initial) FirmwareCheckStatus checkStatus,
    FirmwareCheckResult? checkResult,
    String? errorMessage,
  }) = _FirmwareUpdateState;
}
