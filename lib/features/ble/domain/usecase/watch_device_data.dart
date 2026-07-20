import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_stream_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class WatchDeviceDataParams {
  const WatchDeviceDataParams({required this.deviceId});

  final String deviceId;
}

class WatchDeviceData implements StreamUsecase<BleDeviceStreamSnapshot, WatchDeviceDataParams> {
  const WatchDeviceData({required this.repository});

  final BleRepository repository;

  @override
  Stream<Either<Failure, BleDeviceStreamSnapshot>> call(
    WatchDeviceDataParams params,
  ) {
    return repository.watchDeviceData(params.deviceId);
  }
}
