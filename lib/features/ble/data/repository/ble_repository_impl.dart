import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/features/ble/data/source/remote/ble_remote_data_source.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_discovered_device.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/repository/ble_repository.dart';

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
  Future<Either<Failure, Unit>> startScan() async {
    try {
      await _remoteDataSource.startScan();
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
  Future<Either<Failure, Unit>> disconnect() async {
    try {
      await _remoteDataSource.disconnect();
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  Failure _mapException(Object error) {
    if (error is BleException) {
      return BleFailure(error.message);
    }
    return UnknownFailure(error.toString());
  }
}
