import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchDeviceConnectionParams {
  const WatchDeviceConnectionParams({required this.deviceId});

  final String deviceId;
}

class WatchDeviceConnection implements StreamUsecase<BleConnectionStatus, WatchDeviceConnectionParams> {
  const WatchDeviceConnection({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, BleConnectionStatus>> call(
    WatchDeviceConnectionParams params,
  ) {
    return repository.watchConnectionStatus(params.deviceId);
  }
}
