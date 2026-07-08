import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';

import '../../domain/entity/firmware_channel.dart';
import '../../domain/entity/dfu_progress.dart';
import '../../domain/entity/firmware_info.dart';
import '../../domain/repository/firmware_repository.dart';
import '../firmware_ble_transport.dart';
import '../remote/firmware_firebase_remote.dart';
import '../remote/firmware_remote_api.dart';
import '../strategy/dfu_strategy_factory.dart';
import '../helper/firmware_hardware_resolver.dart';
import '../helper/firmware_metadata_source.dart';
import '../model/firmware_model.dart';

class FirmwareRepositoryImpl implements FirmwareRepository {
  FirmwareRepositoryImpl({
    required this._firebaseRemote,
    required this._restRemote,
    required this._bleTransport,
    this.metadataSource = FirmwareMetadataSource.firebase,
  });

  final FirmwareFirebaseRemote _firebaseRemote;
  final FirmwareRemoteApi _restRemote;
  final FirmwareBleTransport _bleTransport;
  final FirmwareMetadataSource metadataSource;

  @override
  Future<Either<Failure, FirmwareInfo>> checkLatestFirmware(
    CheckFirmwareParams params,
  ) async {
    try {
      final model = await _fetchMetadata(
        deviceType: params.deviceType,
        channel: params.channel,
      );
      return Right(model.toEntity());
    } catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Stream<Either<Failure, DfuProgress>> executeFirmwareUpdate(
    ExecuteFirmwareUpdateParams params,
  ) async* {
    try {
      yield const Right(
        DfuProgress(
          status: DfuStatus.downloading,
          percent: 0,
          message: 'Downloading firmware',
        ),
      );

      final firmwareInfo = params.firmwareInfo ??
          (await _fetchMetadata(
            deviceType: params.deviceType,
            channel: params.channel,
          )).toEntity();

      final firmwareBytes = await _downloadFirmware(firmwareInfo.downloadUrl);

      yield const Right(
        DfuProgress(
          status: DfuStatus.downloading,
          percent: 100,
          message: 'Firmware downloaded',
        ),
      );

      final strategy = DfuStrategyFactory().resolve(params.deviceType.dfuType);
      yield* strategy
          .execute(
            transport: _bleTransport,
            firmwareBytes: firmwareBytes,
            deviceId: params.deviceId,
          )
          .map(Right.new);
    } catch (error) {
      yield Left(_mapException(error));
    }
  }

  Future<FirmwareModel> _fetchMetadata({
    required VulcanDeviceType deviceType,
    required FirmwareChannel channel,
  }) {
    if (metadataSource == FirmwareMetadataSource.rest) {
      return _restRemote.fetchFirmwareMetadata(
        deviceType: deviceType,
        channel: channel,
      );
    }

    return _firebaseRemote.fetchFirmwareMetadata(
      deviceType: deviceType,
      channel: channel,
    );
  }

  Future<Uint8List> _downloadFirmware(String downloadUrl) async {
    if (metadataSource == FirmwareMetadataSource.firebase ||
        isFirebaseStorageUrl(downloadUrl)) {
      return _firebaseRemote.downloadFirmwareBytes(downloadUrl);
    }

    return _restRemote.downloadFirmwareBytes(downloadUrl);
  }

  Failure _mapException(Object error) {
    if (error is FirmwareException) {
      return FirmwareFailure(error.message);
    }
    return UnknownFailure(error.toString());
  }
}
