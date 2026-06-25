import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import '../../model/ble_device_stream_snapshot_model.dart';
import 'ble_stream_decoder.dart';

class EmgStreamDecoder implements BleStreamDecoder {
  const EmgStreamDecoder();

  @override
  EmgStreamSnapshotModel decode({
    required String deviceId,
    required List<int> rawBytes,
  }) {
    try {
      final voltages = BleValueDecoders.decodeEmgVoltages(rawBytes);

      return EmgStreamSnapshotModel(
        deviceId: deviceId,
        timestamp: DateTime.now(),
        voltages: voltages,
        rawBytes: rawBytes,
        // rawBytes: List<int>.from(rawBytes),
      );
    } catch (error) {
      if (error is BleException) rethrow;
      throw BleException(
        'Failed to decode EMG packet: $error',
        deviceId: deviceId,
      );
    }
  }
}
