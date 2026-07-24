import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_battery_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchBatteryParams {
  const WatchBatteryParams({required this.deviceId});

  final String deviceId;
}

class WatchBattery
    implements StreamUsecase<BleBatterySnapshot, WatchBatteryParams> {
  const WatchBattery({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, BleBatterySnapshot>> call(WatchBatteryParams params) {
    return repository.watchBattery(params.deviceId);
  }
}
