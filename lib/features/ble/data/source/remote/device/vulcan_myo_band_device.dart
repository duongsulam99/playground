import 'package:vulcan_mobile_playground/core/ble/enums/BLE/ble_connection_status.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../gatt/ring/reader/ring_reader.dart';
import '../../../model/ble_device_info_model.dart';
import '../abstract/ble_device_capabilities.dart';
import '../ble_device_runtime.dart';
import 'myo_band_signal_stream.dart';

/// MyoBand family: đọc metadata qua GATT, stream EMG qua characteristic signal.
class VulcanMyoBandDevice implements BleDeviceRemoteDataSource, BleDeviceStreaming, BleDeviceInfoSource {
   VulcanMyoBandDevice({
    required BleDeviceRuntime runtime,
    MyoBandSignalStream? signalStream,
  }) : _runtime = runtime,
       _signalStream = signalStream ?? MyoBandSignalStream(runtime);

  final BleDeviceRuntime _runtime;
  final MyoBandSignalStream _signalStream;

  @override
  String get deviceId => _runtime.deviceId;

  @override
  VulcanDeviceType get deviceType => _runtime.deviceType;

  @override
  BleDeviceStreaming? get streaming => this;

  @override
  BleDeviceInfoSource? get info => this;

  @override
  Stream<List<int>> get notifyDataStream => _signalStream.rawStream;

  @override
  Future<void> startDeviceStream() => _signalStream.start();

  @override
  Future<void> stopDeviceStream() => _signalStream.stop();

  @override
  Future<BleDeviceInfoModel> readDeviceInfo() async {
    _ensureIsMyoBandFamily();
    _runtime.ensureGattReady();

    try {
      return await GattRingReader.readInfo(
        gatt: _runtime,
        scannedType: deviceType,
      );
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to read device info: $e', deviceId: deviceId);
    }
  }

  @override
  Stream<BleConnectionStatus> watchConnectionStatus() =>
      _runtime.watchConnectionStatus();

  @override
  Future<BleConnectionStatus> connect() => _runtime.connect();

  @override
  Future<void> disconnect() async {
    await stopDeviceStream();
    await _runtime.disconnect();
  }

  @override
  Future<List<int>> readCharacteristic(String characteristicKey) =>
      _runtime.readCharacteristic(characteristicKey);

  @override
  Future<void> writeCharacteristic(
    String characteristicKey,
    List<int> data, {
    int timeout = 15,
  }) =>
      _runtime.writeCharacteristic(
        characteristicKey,
        data,
        timeout: timeout,
      );

  @override
  Future<void> setUpdateFirmware(bool enabled) =>
      _runtime.setUpdateFirmware(enabled);

  @override
  Stream<List<int>> watchUpdateNotifications() =>
      _runtime.watchUpdateNotifications();

  @override
  int getNegotiatedMtu() => _runtime.getNegotiatedMtu();

  void _ensureIsMyoBandFamily() {
    if (!deviceType.isMyoBandFamily) {
      throw BleException(
        'Device type ${deviceType.name} is not a MyoBand family device',
        deviceId: deviceId,
      );
    }
  }
}
