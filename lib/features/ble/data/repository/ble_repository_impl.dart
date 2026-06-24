import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';

import 'package:vulcan_mobile_playground/core/ble/enums/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/ble_connection_status.dart';

import '../../domain/entities/ble_device_info.dart';
import '../../domain/entities/ble_discovered_device.dart';
import '../../domain/entities/ble_device_stream_snapshot.dart';
import '../../domain/repository/ble_repository.dart';
import '../source/remote/ble_remote_data_source.dart';

class BleRepositoryImpl implements BleRepository {
  const BleRepositoryImpl({required this._remoteDataSource});

  final BleRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<Failure, BleAdapterStatus>> watchAdapterStatus() {
    return _mapStreamToEither(_remoteDataSource.watchAdapterStatus());
  }

  @override
  Stream<Either<Failure, Map<String, BleDiscoveredDevice>>> watchScanResults() {
    return _mapStreamToEither(
      _remoteDataSource.watchScanResults().map(
        (devices) => devices.map((key, model) => MapEntry(key, model.toEntity())),
      ),
    );
  }

  @override
  Stream<Either<Failure, BleDeviceStreamSnapshot>>? watchDeviceData(
    String deviceId,
  ) {
    final stream = _remoteDataSource.watchDeviceData(deviceId);
    if (stream == null) return null;

    return _mapStreamToEither(stream.map((snapshot) => snapshot.toEntity()));
  }

  @override
  Stream<Either<Failure, BleConnectionStatus>>? watchConnectionStatus(
    String deviceId,
  ) {
    final stream = _remoteDataSource.watchConnectionStatus(deviceId);
    if (stream == null) return null;

    return _mapStreamToEither(stream);
  }

  @override
  Future<Either<Failure, Unit>> startScan({
    List<VulcanDeviceType>? filterTypes,
  }) async {
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

  @override
  Future<Either<Failure, BleDeviceInfo>> readDeviceInfo(String deviceId) async {
    try {
      final info = await _remoteDataSource.readDeviceInfo(deviceId);
      return Right(info.toEntity());
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  Stream<Either<Failure, T>> _mapStreamToEither<T>(Stream<T> source) {
    return source.transform(
      StreamTransformer<T, Either<Failure, T>>.fromHandlers(
        /// Handle success data
        handleData: (data, sink) => sink.add(Right(data)),

        /// Handle errors
        handleError: (error, stackTrace, sink) {
          sink.add(Left(_mapException(error)));
        },
      ),
    );
  }

  Failure _mapException(Object error) {
    if (error is BleException) {
      return BleFailure(error.message, deviceId: error.deviceId);
    }
    return UnknownFailure(error.toString());
  }
}
