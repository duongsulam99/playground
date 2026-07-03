import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'ble_stream_decoder.dart';
import 'emg_stream_decoder.dart';

class BleStreamDecoderFactory {
  BleStreamDecoder? create(VulcanDeviceType deviceType) {
    switch (deviceType) {
      // Nếu thiết bị mới hỗ trợ stream dữ liệu thời gian thực,
      // trả về BleStreamDecoder tương ứng tại đây.
      //TODO:[Add New Device] Step 5: Decoder

      // Mặc định không dùng decoder (trả về null)
      default:
        if (deviceType.isMyoBandFamily) return const EmgStreamDecoder();

        // Cho những thiết bị không hỗ trợ stream
        return null;
    }
  }
}
