import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_scan_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchScanResults implements StreamUsecase<BleScanSnapshot, NoParams> {
  const WatchScanResults({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, BleScanSnapshot>> call(NoParams params) {
    return repository.watchScanResults();
  }
}
