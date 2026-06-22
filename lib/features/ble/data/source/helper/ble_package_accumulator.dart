/// Chịu trách nhiệm tích lũy các chunk byte từ BLE
/// và gộp thành gói tin hoàn chỉnh.
class BlePacketAccumulator {
  final List<int> _buffer = [];
  int _expectedLength = -1;

  /// Nhận các mảng byte thô (Chunks) từ BLE Stream và kiểm tra tính trọn vẹn.
  void appendChunk(List<int> chunk, void Function(List<int>) onFrameComplete) {
    _buffer.addAll(chunk);

    // Bước 1: Đọc Header để xác định tổng độ dài Payload (2 byte đầu)
    if (_expectedLength == -1 && _buffer.length >= 2) {
      // Công thức dịch bit chuyển 2 bytes thành số nguyên 16-bit (Big-Endian)
      _expectedLength = (_buffer[0] << 8) | _buffer[1];
    }

    // Bước 2: Kiểm tra xem bộ đệm đã tích lũy đủ số bytes mong muốn chưa
    // Tổng gói = Số byte Payload (_expectedLength) + 2 bytes Header
    while (_expectedLength != -1 && _buffer.length >= (_expectedLength + 2)) {
      // Trích xuất gói tin hoàn chỉnh (bỏ qua 2 byte header)
      final completeFrame = _buffer.sublist(2, _expectedLength + 2);

      // Phát tín hiệu gói tin đã hoàn chỉnh ra ngoài
      onFrameComplete(completeFrame);

      // Xóa phần dữ liệu đã xử lý khỏi bộ đệm của thiết bị
      _buffer.removeRange(0, _expectedLength + 2);

      // Gối đầu kiểm tra gói tin tiếp theo nếu còn dư byte trong bộ đệm
      if (_buffer.length >= 2) {
        _expectedLength = (_buffer[0] << 8) | _buffer[1];
      } else {
        _expectedLength = -1;
      }
    }
  }

  void clear() {
    _buffer.clear();
    _expectedLength = -1;
  }
}
