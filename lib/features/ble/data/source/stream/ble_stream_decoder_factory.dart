import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'ble_stream_decoder.dart';
import 'emg_stream_decoder.dart';

class BleStreamDecoderFactory {
  BleStreamDecoder? create(VulcanDeviceType deviceType) {
    if (deviceType.isMyoBandFamily) {
      return const EmgStreamDecoder();
    }

    return null;
  }
}
