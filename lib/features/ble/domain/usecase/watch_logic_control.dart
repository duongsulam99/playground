import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_logic_control.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchLogicControlParams {
  const WatchLogicControlParams({required this.deviceId});

  final String deviceId;
}

class WatchLogicControl implements StreamUsecase<RingLogicControl, WatchLogicControlParams> {
  const WatchLogicControl({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, RingLogicControl>> call(
    WatchLogicControlParams params,
  ) {
    return repository.watchLogicControl(params.deviceId);
  }
}
