import 'package:flutter_supper_app_core/core.dart';

/// Class chịu trách nhiệm đo đạc tần số lấy mẫu (Sampling Rate) của luồng EMG.
/// Thiết kế theo mô hình độc lập, dễ dàng cắm vào (Plug-and-play) bất kỳ Stream nào.
class EMGStreamMonitor {
  StreamSubscription<double>? _subscription;
  Timer? _timer;
  int _counter = 0;

  /// Callback trả về kết quả Hz mỗi giây để bạn có thể hiển thị lên UI nếu cần
  final void Function(int hz)? onHzMeasured;

  EMGStreamMonitor({this.onHzMeasured});

  static const _logger = Logger(className: 'EMGStreamMonitor');

  /// Bắt đầu lắng nghe Stream và đo tần số
  void start(Stream<double> emgStream) {
    // Đảm bảo dọn dẹp các tiến trình cũ trước khi chạy tiến trình mới
    stop();

    _counter = 0;

    // Khởi tạo Timer chạy định kỳ mỗi 1 giây (1000ms)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final int currentHz = _counter;
      _counter = 0; // Reset bộ đếm cho giây kế tiếp

      // Nếu người dùng không cung cấp callback return liền
      if (onHzMeasured == null) return;

      // Nếu người dùng cấu hình callback, đẩy dữ liệu về cho họ
      onHzMeasured!(currentHz);
    });

    // Lắng nghe luồng dữ liệu từ cảm biến
    _subscription = emgStream.listen(
      // Mỗi khi nhận được dữ liệu, tăng bộ đếm lên 1
      (dataPoint) => _counter++,

      // Xử lý lỗi nếu có
      onError: _onError,

      // Xử lý khi luồng dữ liệu kết thúc
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

  /// Hủy bỏ lắng nghe và xóa Timer để tránh Memory Leak (Bắt buộc gọi khi hủy Widget)
  void stop() {
    _timer?.cancel();
    _timer = null;
    _subscription?.cancel();
    _subscription = null;
    _counter = 0;
  }
}
