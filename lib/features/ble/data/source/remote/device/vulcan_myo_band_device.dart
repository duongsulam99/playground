import '../base_ble_device_remote_data_source.dart';
import '../ble_device_runtime.dart';
import 'ring/myo_band_signal_stream.dart';
import 'ring/ring_device_session.dart';

/// MyoBand family facade: compose [RingDeviceSession] + [MyoBandSignalStream].
final class VulcanMyoBandDevice extends BaseBleDeviceRemoteDataSource {
  VulcanMyoBandDevice({required BleDeviceRuntime runtime})
    : _session = RingDeviceSession(runtime),
      _signal = MyoBandSignalStream(runtime),
      super(runtime);

  final RingDeviceSession _session;
  final MyoBandSignalStream _signal;

  @override
  MyoBandSignalStream? get streaming => _signal;

  @override
  BleRingDeviceSession? get ringSession => _session;

  @override
  BleRingDeviceSession? get info => _session;

  @override
  Future<void> onAfterConnect() => _session.startMonitoring();

  @override
  Future<void> onBeforeDisconnect() async {
    try {
      await _signal.stop();
    } catch (_) {
      // Best-effort: device may already be disconnected.
    }
    await _session.dispose();
  }
}
