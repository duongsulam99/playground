import 'dart:async';

/// Throttler - Chống spam và giới hạn tần suất thực thi.
class Throttler {
  final Duration delay;
  bool _isFree = true;
  Timer? _timer;

  Throttler({required this.delay});

  /// Thực thi [action] ngay lập tức nếu đang trong trạng thái tự do.
  /// Mọi lần gọi tiếp theo trong khoảng [delay] sẽ bị bỏ qua.
  void run(void Function() action) {
    if (!_isFree) return;

    // 1. Chuyển trạng thái sang bận và thực thi ngay (Leading Edge)
    _isFree = false;
    action();

    // 2. Thiết lập bộ đếm để giải phóng khóa sau khoảng delay
    _timer?.cancel();
    _timer = Timer(delay, () {
      _isFree = true;
    });
  }

  /// Giải phóng tài nguyên để tránh Memory Leak.
  /// Luôn gọi trong dispose() của Widget hoặc Controller.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
