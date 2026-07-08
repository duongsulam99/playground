import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';

import '../entity/firmware_info.dart';
import '../repository/firmware_repository.dart';

class CheckLatestFirmware implements Usecase<FirmwareCheckResult, CheckFirmwareParams> {
  const CheckLatestFirmware({required this.repository});

  final FirmwareRepository repository;

  @override
  Future<Either<Failure, FirmwareCheckResult>> call(
    CheckFirmwareParams params,
  ) async {
    if (params.deviceType.dfuType == DfuType.none) {
      return const Left(
        FirmwareFailure('Device does not support firmware update'),
      );
    }

    final result = await repository.checkLatestFirmware(params);
    return result.map(
      (info) => FirmwareCheckResult(
        firmwareInfo: info,
        updateAvailable: info.isUpdateAvailable(params.currentVersion),
      ),
    );
  }
}
