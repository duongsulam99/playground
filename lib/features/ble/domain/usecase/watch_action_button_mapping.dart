import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_action_button_mapping.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchActionButtonMappingParams {
  const WatchActionButtonMappingParams({required this.deviceId});

  final String deviceId;
}

class WatchActionButtonMapping implements StreamUsecase<BleActionButtonMapping, WatchActionButtonMappingParams> {
  const WatchActionButtonMapping({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, BleActionButtonMapping>> call(
    WatchActionButtonMappingParams params,
  ) {
    return repository.watchActionButtonMapping(params.deviceId);
  }
}
