import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:mcumgr_flutter/mcumgr_flutter.dart' as dfu;
import 'package:vulcan_mobile_playground/core/ble/enums/DFU/dfu_type.dart';

import '../../domain/entity/dfu_progress.dart';
import '../model/manifest_model.dart';
import '../firmware_ble_transport.dart';
import 'dfu_strategy.dart';

class NordicMcumgrStrategy implements DfuStrategy {
  NordicMcumgrStrategy({dfu.UpdateManagerFactory? updateManagerFactory})
    : _updateManagerFactory = updateManagerFactory ?? dfu.FirmwareUpdateManagerFactory();

  final dfu.UpdateManagerFactory _updateManagerFactory;

  static const int _progressTimeoutSeconds = 600;

  @override
  DfuType get type => DfuType.nordicDfu;

  @override
  Stream<DfuProgress> execute({
    required FirmwareBleTransport transport,
    required Uint8List firmwareBytes,
    required String deviceId,
  }) async* {
    dfu.FirmwareUpdateManager? updateManager;
    StreamSubscription<dfu.FirmwareUpgradeState>? stateSubscription;
    StreamSubscription<dfu.ProgressUpdate>? progressSubscription;
    Timer? progressTimeoutTimer;
    var imageCount = 0;
    final progressController = StreamController<DfuProgress>();

    Future<void> closeAll() async {
      progressTimeoutTimer?.cancel();
      await stateSubscription?.cancel();
      await progressSubscription?.cancel();
      updateManager?.kill();
    }

    try {
      yield const DfuProgress(
        status: DfuStatus.unpacking,
        percent: 0,
        message: 'Unpacking firmware',
      );

      final images = _buildImagesFromZip(firmwareBytes);

      yield const DfuProgress(
        status: DfuStatus.uploading,
        percent: 0,
        message: 'Entering bootloader',
      );

      await transport.writeOta(deviceId, utf8.encode('1'));
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      final bleDeviceId = transport.getDeviceId(deviceId);
      updateManager = await _updateManagerFactory.getUpdateManager(bleDeviceId);
      updateManager.setup();

      stateSubscription = updateManager.updateStateStream?.listen(
        (event) {
          switch (event) {
            case dfu.FirmwareUpgradeState.upload:
              imageCount = 0;
              progressController.add(
                const DfuProgress(
                  status: DfuStatus.uploading,
                  percent: 0,
                  message: 'Uploading firmware',
                ),
              );
            case dfu.FirmwareUpgradeState.success:
              progressController.add(
                const DfuProgress(
                  status: DfuStatus.completed,
                  percent: 100,
                  message: 'Firmware update completed',
                ),
              );
              progressController.close();
            case dfu.FirmwareUpgradeState.reset:
            case dfu.FirmwareUpgradeState.confirm:
              progressController.add(
                const DfuProgress(
                  status: DfuStatus.confirming,
                  percent: 100,
                  message: 'Confirming firmware',
                ),
              );
            default:
              progressController.add(
                DfuProgress(
                  status: DfuStatus.uploading,
                  percent: 0,
                  message: event.toString(),
                ),
              );
          }
        },
        onError: (Object error) {
          progressController.add(
            DfuProgress(
              status: DfuStatus.failed,
              percent: 0,
              message: error.toString(),
            ),
          );
          progressController.close();
        },
      );

      progressSubscription = updateManager.progressStream.listen(
        (event) {
          progressTimeoutTimer?.cancel();
          progressTimeoutTimer = Timer(
            const Duration(seconds: _progressTimeoutSeconds),
            () {
              progressController.add(
                const DfuProgress(
                  status: DfuStatus.failed,
                  percent: 0,
                  message: 'Firmware update timed out',
                ),
              );
              progressController.close();
            },
          );

          var percent = (event.bytesSent / event.imageSize + imageCount) * 50;
          if (percent > 100) {
            percent -= 50;
          }

          progressController.add(
            DfuProgress(
              status: DfuStatus.uploading,
              percent: percent.clamp(0, 100),
              message: '${percent.toStringAsFixed(2)}%',
            ),
          );
        },
        onError: (Object error) {
          progressController.add(
            DfuProgress(
              status: DfuStatus.failed,
              percent: 0,
              message: error.toString(),
            ),
          );
          progressController.close();
        },
      );

      unawaited(
        updateManager.update(images).catchError((Object error) {
          if (!progressController.isClosed) {
            progressController.add(
              DfuProgress(
                status: DfuStatus.failed,
                percent: 0,
                message: error.toString(),
              ),
            );
            progressController.close();
          }
        }),
      );

      yield* progressController.stream;
    } catch (error) {
      yield DfuProgress(
        status: DfuStatus.failed,
        percent: 0,
        message: error.toString(),
      );
    } finally {
      await closeAll();
      if (!progressController.isClosed) {
        await progressController.close();
      }
    }
  }

  List<dfu.Image> _buildImagesFromZip(Uint8List zipBytes) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final manifestFile = archive.files.firstWhere(
      (file) => file.name.endsWith('manifest.json'),
      orElse: () => throw const FormatException('manifest.json not found'),
    );

    final manifestJson =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;
    final manifest = ManifestModel.fromJson(manifestJson);

    return manifest.files.map((file) {
      final archiveFile = archive.files.firstWhere(
        (entry) => entry.name.endsWith(file.file),
        orElse: () => throw FormatException('${file.file} not found in zip'),
      );

      return dfu.Image(
        image: file.image,
        data: Uint8List.fromList(archiveFile.content as List<int>),
      );
    }).toList();
  }
}
