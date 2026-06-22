import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/config/adapter/key.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../gatt/myo_band_device_info_reader.dart';
import '../../model/ble_device_info.dart';
import 'flutter_blue_plus_private_device.dart';

class VulcanMyoBandDevice extends FlutterBluePlusPrivateDevice {
  VulcanMyoBandDevice({required super.device, required super.deviceType});

  StreamSubscription<List<int>>? _signalDataSubscription;
  bool _isStreamingSignal = false;

  final _logger = const Logger(className: 'VulcanMyoBandDevice');

  @override
  Future<void> Function()? get onNotifyListening => _startSignalListening;

  @override
  Future<void> Function()? get onNotifyStopListening => _stopSignalListening;

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

  Future<void> _startSignalListening() async {
    await _signalDataSubscription?.cancel();
    _signalDataSubscription = null;
    _isStreamingSignal = false;

    try {
      await writeData(BleAdapterKey.signal, utf8.encode('255'));
      await startListening(BleAdapterKey.signal, reassembleFrames: false);

      _signalDataSubscription = watchDeviceData().listen(
        (frame) {
          _logger.debug(
            'myoBandSignal',
            '${frame.length} bytes: ${_formatBytes(frame)}',
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.error('myoBandSignal', 'Stream error: $error');
        },
      );

      _isStreamingSignal = true;
      _logger.debug(
        'startSignalListening',
        'Listening and logging MyoBand signal for $deviceId',
      );
    } catch (e, st) {
      await _signalDataSubscription?.cancel();
      _signalDataSubscription = null;
      _isStreamingSignal = false;
      _logger.error(
        'startSignalListening',
        'Failed to start MyoBand signal logging: $e\n$st',
      );
    }
  }

  Future<void> _stopSignalListening() async {
    await _signalDataSubscription?.cancel();
    _signalDataSubscription = null;

    if (!_isStreamingSignal || characteristics.isEmpty) return;

    try {
      await writeData(BleAdapterKey.signal, utf8.encode('000'));
    } catch (e) {
      _logger.warning(
        'stopSignalListening',
        'Failed to stop MyoBand signal for $deviceId: $e',
      );
    } finally {
      _isStreamingSignal = false;
    }
  }

  String _formatBytes(List<int> bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ');
  }
}
