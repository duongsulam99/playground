import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class StopScan implements Usecase<Unit, NoParams> {
  const StopScan({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.stopScan();
  }
}
