import 'package:flutter_supper_app_core/core.dart';

/// Đo sampling rate (Hz) của stream EMG — dùng debug/monitoring,
/// không ảnh hưởng pipeline chính.
class EMGStreamMonitor {
  StreamSubscription<double>? _subscription;
  Timer? _timer;
  int _counter = 0;

  final void Function(int hz)? onHzMeasured;

  EMGStreamMonitor({this.onHzMeasured});

  static const _logger = Logger(className: 'EMGStreamMonitor');

  void start(Stream<double> emgStream) {
    stop();
    _counter = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentHz = _counter;
      _counter = 0;

      if (onHzMeasured == null) return;
      onHzMeasured!(currentHz);
    });

    _subscription = emgStream.listen(
      (_) => _counter++,
      onError: _onError,
      onDone: _onDone,
    );
  }

  void _onError(Object error) {
    _logger.error('EMGStreamMonitor', 'Error in EMG stream: $error');
  }

  void _onDone() {
    _logger.debug('EMGStreamMonitor', 'EMG stream has been closed.');
    stop();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _subscription?.cancel();
    _subscription = null;
    _counter = 0;
  }
}
