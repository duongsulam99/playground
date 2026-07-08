part of 'firmware_update_bloc.dart';

@freezed
sealed class FirmwareUpdateEvent with _$FirmwareUpdateEvent {
  const factory FirmwareUpdateEvent.started({
    required String deviceId,
    required VulcanDeviceType deviceType,
    required String currentVersion,
  }) = FirmwareUpdateStarted;

  const factory FirmwareUpdateEvent.retryRequested() =
      FirmwareUpdateRetryRequested;
}
