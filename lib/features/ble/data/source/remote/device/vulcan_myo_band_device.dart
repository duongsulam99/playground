import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/config/keys/adapter/key.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../gatt/myo_band_device_info_reader.dart';
import '../../../model/ble_device_info_model.dart';
import 'flutter_blue_plus_private_device.dart';

class VulcanMyoBandDevice extends FlutterBluePlusPrivateDevice {
  VulcanMyoBandDevice({required super.device, required super.deviceType});

  bool _isStreamingSignal = false;

  final _logger = const Logger(className: 'VulcanMyoBandDevice');

  @override
  Stream<List<int>>? get notifyDataStream => watchDeviceData();

  @override
  Future<void> Function()? get onNotifyStopListening => stopSignalStream;

  @override
  Future<void> startDeviceStream() => startSignalStream();

  @override
  Future<void> stopDeviceStream() => stopSignalStream();

  @override
  Future<BleDeviceInfoModel> readDeviceInfo() async {
    if (!deviceType.isMyoBandFamily) {
      throw BleException(
        'Device type ${deviceType.name} is not a MyoBand family device',
        deviceId: deviceId,
      );
    }

    ensureConnected();

    try {
      final info = await MyoBandDeviceInfoReader.read(
        characteristics: characteristics,
        scannedType: deviceType,
      );

      return BleDeviceInfoModel(
        name: info.name,
        firmwareVersion: info.firmwareVersion,
        hardwareId: info.hardwareId,
        resolvedType: info.resolvedType,
        batteryPercent: info.batteryPercent,
      );
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to read device info: $e', deviceId: deviceId);
    }
  }

  Future<void> startSignalStream() async {
    _isStreamingSignal = false;
    ensureConnected();

    try {
      /// SET START SIGNAL STREAM TO DEVICE
      await writeData(BleAdapterKey.signal, utf8.encode('255'));

      /// START LISTENING STREAM DATA FROM DEVICE
      await startListening(BleAdapterKey.signal, reassembleFrames: false);

      _isStreamingSignal = true;
      _logger.debug('startSignalStream', 'Notify stream ready for $deviceId');
    } catch (e, st) {
      _isStreamingSignal = false;
      _logger.error(
        'startSignalStream',
        'Failed to setup MyoBand notify stream: $e\n$st',
      );

      /// THROW EXCEPTION
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to start MyoBand signal stream: $e',
        deviceId: deviceId,
      );
    }
  }

  Future<void> stopSignalStream() async {
    if (!_isStreamingSignal || characteristics.isEmpty) return;

    try {
      await writeData(BleAdapterKey.signal, utf8.encode('000'));
    } catch (e) {
      _logger.warning(
        'stopSignalStream',
        'Failed to stop MyoBand signal for $deviceId: $e',
      );
      if (e is BleException) rethrow;
      throw BleException(
        'Failed to stop MyoBand signal stream: $e',
        deviceId: deviceId,
      );
    } finally {
      _isStreamingSignal = false;
    }
  }
}
