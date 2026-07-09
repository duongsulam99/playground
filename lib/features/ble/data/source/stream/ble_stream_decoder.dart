import '../../model/ble_device_stream_snapshot_model.dart';

/// Strategy decode raw BLE bytes → [BleDeviceStreamSnapshotModel].
abstract class BleStreamDecoder {
  BleDeviceStreamSnapshotModel decode({
    required String deviceId,
    required List<int> rawBytes,
  });
}
