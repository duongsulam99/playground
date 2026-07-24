import '../../isolate/decode/decode_worker.dart';
import '../base_device_remote_datasrc.dart';
import '../device_runtime.dart';
import 'ring/signal_stream/myo_band_signal_stream.dart';
import 'ring/sessions/ring_device_session.dart';

/// MyoBand family facade: compose [RingDeviceSession] + [MyoBandSignalStream].
final class RingDevice extends BaseDeviceRemoteDS {
  RingDevice({
    required DeviceRuntime runtime,
    required StreamDecodeWorker decodeWorker,
  }) : _session = RingDeviceSession(runtime),
       _signal = MyoBandSignalStream(runtime, decodeWorker: decodeWorker),
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
