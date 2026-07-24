import '../../../../model/ble_device_stream_snapshot_model.dart';

/// Decoded notify stream capability (e.g. EMG after isolate decode).
///
/// Optional per device type — implement when the device emits a structured
/// [BleDeviceStreamSnapshotModel] rather than raw bytes alone.
abstract interface class DecodedStreaming {
  Stream<BleDeviceStreamSnapshotModel> watchDecodedDeviceData();
}
