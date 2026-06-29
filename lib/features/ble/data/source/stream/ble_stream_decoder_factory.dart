import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import 'ble_stream_decoder.dart';
import 'emg_stream_decoder.dart';

class BleStreamDecoderFactory {
  BleStreamDecoder? create(VulcanDeviceType deviceType) {
    switch (deviceType) {
      // TODO: [Add New Device] Step 5: Decoder
      // Nếu thiết bị mới hỗ trợ stream dữ liệu thời gian thực,
      // trả về BleStreamDecoder tương ứng tại đây.

      default:
        if (deviceType.isMyoBandFamily) {
          return const EmgStreamDecoder();
        }

        /// FOR UNKNOW DEVICES
        return null;
    }
  }
}
