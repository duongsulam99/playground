import 'package:vulcan_mobile_playground/core/ble/gatt/ble_value_decoders.dart';
import 'package:vulcan_mobile_playground/core/error/exceptions.dart';

import 'ble_stream_decoder.dart';

/// Decode batch raw bytes EMG thành danh sách điện áp (mV).
class EmgStreamDecoder implements BleStreamDecoder {
  const EmgStreamDecoder();

  @override
  List<double> decode(List<int> rawBytes) {
    try {
      return BleValueDecoders.decodeEmgVoltages(rawBytes);
    } catch (error) {
      if (error is BleException) rethrow;
      throw BleException('Failed to decode EMG packet: $error');
    }
  }
}
