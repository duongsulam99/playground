import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';

import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';
import '../../domain/entities/ble_discovered_device.dart';
import '../../domain/repository/ble_repository.dart';
import '../source/remote/ble_remote_data_source.dart';

class BleRepositoryImpl implements BleRepository {
  BleRepositoryImpl({required this._remoteDataSource});

  final BleRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<Failure, BleAdapterStatus>> watchAdapterStatus() {
    return _remoteDataSource.watchAdapterStatus().map(
      (status) => Right<Failure, BleAdapterStatus>(status),
    ).handleError(
      (Object error, StackTrace stackTrace) {
        throw _mapException(error);
      },
    );
  }

  @override
  Stream<Either<Failure, List<BleDiscoveredDevice>>> watchScanResults() {
    return _remoteDataSource.watchScanResults().map(
      (devices) => Right<Failure, List<BleDiscoveredDevice>>(devices),
    ).handleError(
      (Object error, StackTrace stackTrace) {
        throw _mapException(error);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> startScan({List<VulcanDeviceType>? filterTypes}) async {
    try {
      await _remoteDataSource.startScan(filterTypes: filterTypes);
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> stopScan() async {
    try {
      await _remoteDataSource.stopScan();
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, BleConnectionStatus>> connect(String deviceId) async {
    try {
      final status = await _remoteDataSource.connect(deviceId);
      return Right(status);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> disconnect(String deviceId) async {
    try {
      await _remoteDataSource.disconnect(deviceId);
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  Failure _mapException(Object error) {
    if (error is BleException) {
      return BleFailure(error.message, deviceId: error.deviceId);
    }
    return UnknownFailure(error.toString());
  }
}
