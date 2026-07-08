import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchAdapterStatus implements StreamUsecase<BleAdapterStatus, NoParams> {
  const WatchAdapterStatus({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, BleAdapterStatus>> call(NoParams params) {
    return repository.watchAdapterStatus();
  }
}
