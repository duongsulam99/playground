import 'dart:async';
import 'dart:developer' as developer;

/// Class chịu trách nhiệm đo đạc tần số lấy mẫu (Sampling Rate) của luồng EMG.
/// Thiết kế theo mô hình độc lập, dễ dàng cắm vào (Plug-and-play) bất kỳ Stream nào.
class EMGStreamMonitor {
  StreamSubscription<double>? _subscription;
  Timer? _timer;
  int _counter = 0;

  /// Callback trả về kết quả Hz mỗi giây để bạn có thể hiển thị lên UI nếu cần
  final void Function(int hz)? onHzMeasured;

  EMGStreamMonitor({this.onHzMeasured});

  /// Bắt đầu lắng nghe Stream và đo tần số
  void start(Stream<double> emgStream) {
    // Đảm bảo dọn dẹp các tiến trình cũ trước khi chạy tiến trình mới
    stop();

    _counter = 0;

    // Khởi tạo Timer chạy định kỳ mỗi 1 giây (1000ms)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final int currentHz = _counter;
      _counter = 0; // Reset bộ đếm cho giây kế tiếp

      // Ghi log vào hệ thống DevTools của Flutter
      developer.log(
        '=== [EMG PERFORMANCE] Actual Sampling Rate: $currentHz Hz ===',
        name: 'hardware.emg',
        level: 800, // Tương đương mức INFO
      );

      // Nếu người dùng cấu hình callback, đẩy dữ liệu về cho họ
      if (onHzMeasured != null) {
        onHzMeasured!(currentHz);
      }
    });

    // Lắng nghe luồng dữ liệu từ cảm biến
    _subscription = emgStream.listen(
      (dataPoint) {
        _counter++; // Tăng biến đếm mỗi khi có 1 điểm dữ liệu đổ về
      },
      onError: (error) {
        developer.log(
          'Lỗi xảy ra trong luồng EMG Stream',
          error: error,
          name: 'hardware.emg',
        );
      },
      onDone: () {
        developer.log(
          'Luồng EMG Stream đã đóng ngắt kết nối',
          name: 'hardware.emg',
        );
        stop();
      },
    );
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
