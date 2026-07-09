/// Gộp BLE notify chunks thành frame hoàn chỉnh.
///
/// Format: 2 byte header (big-endian payload length) + payload.
class BlePacketAccumulator {
  final List<int> _buffer = [];
  int _expectedLength = -1;

  void appendChunk(List<int> chunk, void Function(List<int>) onFrameComplete) {
    _buffer.addAll(chunk);

    if (_expectedLength == -1 && _buffer.length >= 2) {
      _expectedLength = (_buffer[0] << 8) | _buffer[1];
    }

    while (_expectedLength != -1 && _buffer.length >= (_expectedLength + 2)) {
      final completeFrame = _buffer.sublist(2, _expectedLength + 2);
      onFrameComplete(completeFrame);

      _buffer.removeRange(0, _expectedLength + 2);

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
