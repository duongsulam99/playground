import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';

import '../entity/dfu_progress.dart';
import '../repository/firmware_repository.dart';

class ExecuteFirmwareUpdate implements StreamUsecase<DfuProgress, ExecuteFirmwareUpdateParams> {
  const ExecuteFirmwareUpdate({required this.repository});

  final FirmwareRepository repository;

  @override
  Stream<Either<Failure, DfuProgress>> call(
    ExecuteFirmwareUpdateParams params,
  ) {
    if (params.deviceType.dfuType == DfuType.none) {
      return Stream.value(
        const Left(
          FirmwareFailure('Device does not support firmware update'),
        ),
      );
    }

    return repository.executeFirmwareUpdate(params);
  }
}
