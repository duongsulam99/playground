import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchDeviceConnectionParams {
  const WatchDeviceConnectionParams({required this.deviceId});

  final String deviceId;
}

class WatchDeviceConnection {
  WatchDeviceConnection({required this.repository});

  final BleRepository repository;

  Stream<Either<Failure, BleConnectionStatus>>? call(
    WatchDeviceConnectionParams params,
  ) {
    return repository.watchConnectionStatus(params.deviceId);
  }
}
