import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_logic_control.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class UpdateLogicControlParams {
  const UpdateLogicControlParams({
    required this.deviceId,
    required this.logic,
  });

  final String deviceId;
  final RingLogicControl logic;
}

class UpdateLogicControl implements Usecase<Unit, UpdateLogicControlParams> {
  const UpdateLogicControl({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateLogicControlParams params) {
    return repository.updateLogicControl(params.deviceId, params.logic);
  }
}
