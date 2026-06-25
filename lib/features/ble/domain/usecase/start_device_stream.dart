import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class StartDeviceStreamParams {
  const StartDeviceStreamParams({required this.deviceId});

  final String deviceId;
}

class StartDeviceStream implements Usecase<Unit, StartDeviceStreamParams> {
  const StartDeviceStream({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(StartDeviceStreamParams params) {
    return repository.startDeviceStream(params.deviceId);
  }
}
