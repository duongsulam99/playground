import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class DisconnectDeviceParams {
  const DisconnectDeviceParams({required this.deviceId});

  final String deviceId;
}

class DisconnectDevice implements Usecase<Unit, DisconnectDeviceParams> {
  DisconnectDevice({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(DisconnectDeviceParams params) {
    return repository.disconnect(params.deviceId);
  }
}
