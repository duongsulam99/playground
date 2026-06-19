import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/usecase/usecase.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/myo_band_device_info.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

class ReadMyoBandDeviceInfoParams {
  const ReadMyoBandDeviceInfoParams({required this.deviceId});

  final String deviceId;
}

class ReadMyoBandDeviceInfo
    implements Usecase<MyoBandDeviceInfo, ReadMyoBandDeviceInfoParams> {
  ReadMyoBandDeviceInfo({required this.repository});

  final BleRepository repository;

  @override
  Future<Either<Failure, MyoBandDeviceInfo>> call(
    ReadMyoBandDeviceInfoParams params,
  ) {
    return repository.readMyoBandDeviceInfo(params.deviceId);
  }
}
