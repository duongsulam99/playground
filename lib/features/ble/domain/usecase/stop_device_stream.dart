import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class StopDeviceStreamParams {
  const StopDeviceStreamParams({required this.deviceId});

  final String deviceId;
}

class StopDeviceStream implements Usecase<Unit, StopDeviceStreamParams> {
  const StopDeviceStream({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(StopDeviceStreamParams params) {
    return repository.stopDeviceStream(params.deviceId);
  }
}
