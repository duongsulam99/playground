import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_encoders.dart';
import 'package:vulcan_mobile_playground/core/ble/gatt/keys/adapter/key.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/ble/models/ring_threshold_config.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../gatt/ring/reader/ring_reader.dart';
import '../../../model/ble_device_info_model.dart';
import '../device_impl.dart';

/// [MyoBand Device]
/// Implementation of [FlutterBluePlusPrivateDevice] for MyoBand family devices
/// This class provides specific implementations for MyoBand devices, including reading device information, starting and stopping signal streams, and handling threshold configurations.
class VulcanMyoBandDevice extends BleDeviceRemoteDataSourceImpl {
  VulcanMyoBandDevice({required super.device, required super.deviceType});

  bool _isStreamingSignal = false;
  static const String _startSignalCommand = '255';
  static const String _stopSignalCommand = '000';

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
    ensureIsMyoBandFamily();

    ensureConnected();

    try {
      return await GattRingReader.readInfo(
        characteristics: characteristics,
        scannedType: deviceType,
      );
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to read device info: $e', deviceId: deviceId);
    }
  }

  Future<RingThresholdConfig?> readThreshold() async {
    ensureConnected();

    try {
      return await GattRingReader.readThreshold(characteristics);
    } catch (e, st) {
      _logger.warning(
        'readThreshold',
        'Failed to read threshold for $deviceId: $e\n$st',
      );
      return null;
    }
  }

  void ensureIsMyoBandFamily() {
    if (!deviceType.isMyoBandFamily) {
      throw BleException(
        'Device type ${deviceType.name} is not a MyoBand family device',
        deviceId: deviceId,
      );
    }
  }

  Future<void> startSignalStream() async {
    _isStreamingSignal = false;
    ensureConnected();

    try {
      /// SET START SIGNAL STREAM TO DEVICE
      await writeData(
        BleAdapterKey.signal,
        BleValueEncoders.encodeUtf8(_startSignalCommand),
      );

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
      await writeData(
        BleAdapterKey.signal,
        BleValueEncoders.encodeUtf8(_stopSignalCommand),
      );
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
