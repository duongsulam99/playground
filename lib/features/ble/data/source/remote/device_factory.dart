import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vulcan_mobile_playground/core/ble/enums/device_type.dart';

import '../isolate/decode/decode_worker.dart';
import 'abstract/ble_device_remote_data_source.dart';
import 'ble_device_runtime.dart';
import 'device_impl.dart';
import 'device/vulcan_myo_band_device.dart';

/// Tạo [BleDeviceRemoteDataSource] phù hợp theo [VulcanDeviceType].
class BleDeviceDataSourceFactory {
  const BleDeviceDataSourceFactory({required this._decodeWorker});

  final StreamDecodeWorker _decodeWorker;

  BleDeviceRemoteDataSource create(
    BluetoothDevice device, {
    required VulcanDeviceType deviceType,
  }) {
    final runtime = BleDeviceRuntime(device: device, deviceType: deviceType);

    switch (deviceType) {
      // TODO:[Add New Device] Step 4: map deviceType mới sang implementation cụ thể
      default:
        if (deviceType.isMyoBandFamily) {
          return VulcanMyoBandDevice(
            runtime: runtime,
            decodeWorker: _decodeWorker,
          );
        }

        return BleDeviceRemoteDataSourceImpl(runtime: runtime);
    }
  }
}
