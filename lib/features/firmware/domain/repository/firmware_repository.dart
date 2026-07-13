import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';

import '../entity/dfu_progress.dart';
import '../entity/firmware_channel.dart';
import '../entity/firmware_info.dart';

class CheckFirmwareParams {
  const CheckFirmwareParams({
    required this.deviceType,
    required this.currentVersion,
    this.channel = FirmwareChannel.dev,
  });

  final VulcanDeviceType deviceType;
  final String currentVersion;
  final FirmwareChannel channel;
}

class ExecuteFirmwareUpdateParams {
  const ExecuteFirmwareUpdateParams({
    required this.deviceId,
    required this.deviceType,
    this.channel = FirmwareChannel.dev,
    this.firmwareInfo,
  });

  final String deviceId;
  final VulcanDeviceType deviceType;
  final FirmwareChannel channel;
  final FirmwareInfo? firmwareInfo;
}

abstract class FirmwareRepository {
  Future<Either<Failure, FirmwareInfo>> checkLatestFirmware(
    CheckFirmwareParams params,
  );

  Stream<Either<Failure, DfuProgress>> executeFirmwareUpdate(
    ExecuteFirmwareUpdateParams params,
  );
}
