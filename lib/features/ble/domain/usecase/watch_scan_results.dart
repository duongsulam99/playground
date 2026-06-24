import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchScanResults implements StreamUsecase<Map<String, BleDiscoveredDevice>, NoParams>{
  const WatchScanResults({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, Map<String, BleDiscoveredDevice>>> call(
    NoParams params,
  ) {
    return repository.watchScanResults();
  }
}
