import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_action_button_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchActionButtonPressParams {
  const WatchActionButtonPressParams({required this.deviceId});

  final String deviceId;
}

class WatchActionButtonPress implements StreamUsecase<RingActionButtonType, WatchActionButtonPressParams> {
  const WatchActionButtonPress({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, RingActionButtonType>> call(
    WatchActionButtonPressParams params,
  ) {
    return repository.watchActionButtonPress(params.deviceId);
  }
}
