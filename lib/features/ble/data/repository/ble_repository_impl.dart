import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_action_button_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_logic_control.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_adapter_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';

import '../../domain/entities/ble_action_button_mapping.dart';
import '../../domain/entities/ble_battery_snapshot.dart';
import '../../domain/entities/ble_device_info.dart';
import '../../domain/entities/ble_device_stream_snapshot.dart';
import '../../domain/entities/ble_scan_snapshot.dart';
import '../../domain/repository/ble_repository.dart';
import '../source/remote/abstract/ble_remote_data_source.dart';
import '../source/remote/abstract/capabilities/decoded_streaming.dart';
import '../source/remote/abstract/capabilities/info_source.dart';
import '../source/remote/abstract/capabilities/data_streaming.dart';
import '../source/remote/abstract/device_remote_datasrc.dart';
import '../source/remote/device/ring/sessions/ring_device_session.dart';

/// Biên giới domain ↔ data: map Model → Entity, Exception → [Failure].
///
/// Global BLE (adapter / scan / connect) delegate xuống [BleRemoteDataSource].
/// Per-device ops resolve qua [BleRemoteDataSource.findConnectedDevice] rồi
/// gọi capabilities trên [BleDeviceRemoteDataSource].
class BleRepositoryImpl implements BleRepository {
  const BleRepositoryImpl({required this._remoteDataSource});

  final BleRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<Failure, BleAdapterStatus>> watchAdapterStatus() {
    return _mapStreamToEither(_remoteDataSource.watchAdapterStatus());
  }

  @override
  Stream<Either<Failure, BleScanSnapshot>> watchScanResults() {
    return _mapStreamToEither(
      _remoteDataSource.watchScanResults().map(
        (devices) => BleScanSnapshot(
          devices.map((key, model) => MapEntry(key, model.toEntity())),
        ),
      ),
    );
  }

  @override
  Stream<Either<Failure, BleDeviceStreamSnapshot>> watchDeviceData(
    String deviceId,
  ) {
    try {
      final decoded = _requireDecodedStreaming(_connectedDevice(deviceId));
      return _mapStreamToEither(
        decoded.watchDecodedDeviceData().map((snapshot) => snapshot.toEntity()),
      );
    } catch (error) {
      return Stream.value(Left(_mapException(error)));
    }
  }

  @override
  Stream<Either<Failure, BleBatterySnapshot>> watchBattery(String deviceId) {
    try {
      final session = _requireRingSession(_connectedDevice(deviceId));
      return _mapStreamToEither(
        session.batteryStream.map((snapshot) => snapshot.toEntity()),
      );
    } catch (error) {
      return Stream.value(Left(_mapException(error)));
    }
  }

  @override
  Stream<Either<Failure, BleActionButtonMapping>> watchActionButtonMapping(
    String deviceId,
  ) {
    try {
      final session = _requireRingSession(_connectedDevice(deviceId));
      return _mapStreamToEither(
        session.actionButtonMappingStream.map(_mapActionButtonMapping),
      );
    } catch (error) {
      return Stream.value(Left(_mapException(error)));
    }
  }

  @override
  Stream<Either<Failure, RingActionButtonType>> watchActionButtonPress(
    String deviceId,
  ) {
    try {
      final session = _requireRingSession(_connectedDevice(deviceId));
      return _mapStreamToEither(session.actionButtonPressStream);
    } catch (error) {
      return Stream.value(Left(_mapException(error)));
    }
  }

  @override
  Stream<Either<Failure, RingLogicControl>> watchLogicControl(String deviceId) {
    try {
      final session = _requireRingSession(_connectedDevice(deviceId));
      return _mapStreamToEither(session.logicControlStream);
    } catch (error) {
      return Stream.value(Left(_mapException(error)));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateActionButtonMapping(
    String deviceId,
    BleActionButtonMapping mapping,
  ) async {
    try {
      final session = _requireRingSession(_connectedDevice(deviceId));
      await session.updateActionButtonMapping(
        ActionButtonMappingSnapshot(
          single: mapping.single,
          doubleTap: mapping.doubleTap,
        ),
      );
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLogicControl(
    String deviceId,
    RingLogicControl logic,
  ) async {
    try {
      final session = _requireRingSession(_connectedDevice(deviceId));
      await session.updateLogicControl(logic);
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  BleActionButtonMapping _mapActionButtonMapping(
    ActionButtonMappingSnapshot snapshot,
  ) {
    return BleActionButtonMapping(
      single: snapshot.single,
      doubleTap: snapshot.doubleTap,
    );
  }

  @override
  Stream<Either<Failure, BleConnectionStatus>> watchConnectionStatus(
    String deviceId,
  ) {
    try {
      final stream = _remoteDataSource.watchConnectionStatus(deviceId);
      return _mapStreamToEither(stream);
    } catch (error) {
      return Stream.value(Left(_mapException(error)));
    }
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
      final info = _requireInfo(_connectedDevice(deviceId));
      try {
        final model = await info.readDeviceInfo();
        return Right(model.toEntity());
      } catch (e) {
        if (e is BleException) rethrow;
        throw BleException(
          'Failed to read device info: $e',
          deviceId: deviceId,
        );
      }
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> startDeviceStream(String deviceId) async {
    try {
      final streaming = _requireStreaming(_connectedDevice(deviceId));
      try {
        await streaming.startDeviceStream();
      } catch (e) {
        if (e is BleException) rethrow;
        throw BleException(
          'Failed to start device stream: $e',
          deviceId: deviceId,
        );
      }
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> stopDeviceStream(String deviceId) async {
    try {
      final device = _connectedDevice(deviceId);
      final streaming = device.streaming;
      if (streaming == null) return const Right(unit);

      try {
        await streaming.stopDeviceStream();
      } catch (e) {
        if (e is BleException) rethrow;
        throw BleException(
          'Failed to stop device stream: $e',
          deviceId: deviceId,
        );
      }
      return const Right(unit);
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  DeviceRemoteDS _connectedDevice(String deviceId) {
    return _remoteDataSource.findConnectedDevice(deviceId);
  }

  InfoSource _requireInfo(DeviceRemoteDS device) {
    final info = device.info;
    if (info == null) {
      throw BleException(
        'Device info is not supported for ${device.deviceType.name}',
        deviceId: device.deviceId,
      );
    }
    return info;
  }

  BleRingDeviceSession _requireRingSession(DeviceRemoteDS device) {
    final session = device.ringSession;
    if (session == null) {
      throw BleException(
        'Battery stream is not supported for ${device.deviceType.name}',
        deviceId: device.deviceId,
      );
    }
    return session;
  }

  DataStreaming _requireStreaming(DeviceRemoteDS device) {
    final streaming = device.streaming;
    if (streaming == null) {
      throw BleException(
        'Device stream is not supported for ${device.deviceType.name}',
        deviceId: device.deviceId,
      );
    }
    return streaming;
  }

  DecodedStreaming _requireDecodedStreaming(DeviceRemoteDS device) {
    final streaming = device.streaming;
    if (streaming is DecodedStreaming) {
      return streaming as DecodedStreaming;
    }
    throw BleException(
      'Device stream is not supported for ${device.deviceType.name}',
      deviceId: device.deviceId,
    );
  }

  /// Bọc stream: data → `Right`, error → `Left` (không để exception trôi ra ngoài).
  Stream<Either<Failure, T>> _mapStreamToEither<T>(Stream<T> source) {
    return source.transform(
      StreamTransformer<T, Either<Failure, T>>.fromHandlers(
        handleData: (data, sink) => sink.add(Right(data)),
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
