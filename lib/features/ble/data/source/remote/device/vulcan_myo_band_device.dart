import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../../gatt/ring/reader/ring_reader.dart';
import '../../../model/ble_device_info_model.dart';
import '../abstract/ble_device_capabilities.dart';
import '../base_ble_device_remote_data_source.dart';
import '../ble_device_runtime.dart';
import 'myo_band_signal_stream.dart';

/// MyoBand family: đọc metadata qua GATT, stream EMG qua characteristic signal.
final class VulcanMyoBandDevice extends BaseBleDeviceRemoteDataSource
    implements BleDeviceStreaming, BleDeviceInfoSource {
  VulcanMyoBandDevice({
    required BleDeviceRuntime runtime,
    MyoBandSignalStream? signalStream,
  }) : _signalStream = signalStream ?? MyoBandSignalStream(runtime),
       super(runtime);

  final MyoBandSignalStream _signalStream;

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
    runtime.ensureGattReady();

    try {
      return await GattRingReader.readInfo(
        gatt: runtime,
        scannedType: deviceType,
      );
    } catch (e) {
      if (e is BleException) rethrow;
      throw BleException('Failed to read device info: $e', deviceId: deviceId);
    }
  }

  @override
  Future<void> onBeforeDisconnect() => stopDeviceStream();

  void _ensureIsMyoBandFamily() {
    if (!deviceType.isMyoBandFamily) {
      throw BleException(
        'Device type ${deviceType.name} is not a MyoBand family device',
        deviceId: deviceId,
      );
    }
  }
}
