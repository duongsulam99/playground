import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_action_button_mapping.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class UpdateActionButtonMappingParams {
  const UpdateActionButtonMappingParams({
    required this.deviceId,
    required this.mapping,
  });

  final String deviceId;
  final BleActionButtonMapping mapping;
}

class UpdateActionButtonMapping implements Usecase<Unit, UpdateActionButtonMappingParams> {
  const UpdateActionButtonMapping({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(
    UpdateActionButtonMappingParams params,
  ) {
    return repository.updateActionButtonMapping(
      params.deviceId,
      params.mapping,
    );
  }
}
