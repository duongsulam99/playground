import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_info.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class ReadDeviceInfoParams {
  const ReadDeviceInfoParams({required this.deviceId});

  final String deviceId;
}

class ReadDeviceInfo implements Usecase<BleDeviceInfo, ReadDeviceInfoParams> {
  const ReadDeviceInfo({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, BleDeviceInfo>> call(ReadDeviceInfoParams params) {
    return repository.readDeviceInfo(params.deviceId);
  }
}
