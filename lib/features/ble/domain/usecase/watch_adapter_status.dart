import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchAdapterStatus extends StreamUsecase<BleAdapterStatus, NoParams> {
  WatchAdapterStatus({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, BleAdapterStatus>> call(NoParams params) {
    return repository.watchAdapterStatus();
  }
}
