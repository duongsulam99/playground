import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class ConnectDeviceParams {
  const ConnectDeviceParams({required this.deviceId});

  final String deviceId;
}

class ConnectDevice
    implements Usecase<BleConnectionStatus, ConnectDeviceParams> {
  ConnectDevice({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, BleConnectionStatus>> call(
    ConnectDeviceParams params,
  ) {
    return repository.connect(params.deviceId);
  }
}
