part of 'firmware_update_bloc.dart';

enum FirmwareCheckStatus { initial, loading, success, failure }

enum FirmwareUpdateStatus {
  idle,
  downloading,
  unpacking,
  uploading,
  confirming,
  completed,
  failed;

  static FirmwareUpdateStatus fromDfuStatus(DfuStatus status) {
    return switch (status) {
      DfuStatus.idle => FirmwareUpdateStatus.idle,
      DfuStatus.downloading => FirmwareUpdateStatus.downloading,
      DfuStatus.unpacking => FirmwareUpdateStatus.unpacking,
      DfuStatus.uploading => FirmwareUpdateStatus.uploading,
      DfuStatus.confirming => FirmwareUpdateStatus.confirming,
      DfuStatus.completed => FirmwareUpdateStatus.completed,
      DfuStatus.failed => FirmwareUpdateStatus.failed,
    };
  }
}

@freezed
abstract class FirmwareUpdateState with _$FirmwareUpdateState {
  const factory FirmwareUpdateState({
    @Default('') String deviceId,
    @Default(VulcanDeviceType.none) VulcanDeviceType deviceType,
    @Default('') String currentVersion,
    @Default(FirmwareCheckStatus.initial) FirmwareCheckStatus checkStatus,
    @Default(FirmwareUpdateStatus.idle) FirmwareUpdateStatus updateStatus,
    FirmwareCheckResult? checkResult,
    DfuProgress? dfuProgress,
    String? errorMessage,
  }) = _FirmwareUpdateState;
}
