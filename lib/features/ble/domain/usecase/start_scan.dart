import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class StartScanParams {
  const StartScanParams({this.filterTypes});

  final List<VulcanDeviceType>? filterTypes;
}

class StartScan implements Usecase<Unit, StartScanParams> {
  StartScan({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(StartScanParams params) {
    return repository.startScan(filterTypes: params.filterTypes);
  }
}
