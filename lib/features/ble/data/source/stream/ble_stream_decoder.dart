import '../../model/ble_device_stream_snapshot_model.dart';

abstract class BleStreamDecoder {
  BleDeviceStreamSnapshotModel decode({
    required String deviceId,
    required List<int> rawBytes,
  });
}
