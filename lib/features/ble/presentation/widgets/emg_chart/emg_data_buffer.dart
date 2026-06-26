import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

// This Buffer is used to store EMG data from the BLE Stream.
// It is a circular buffer with a fixed size.
// It is used to display EMG data in a chart.
// Improve performance by using Float64List instead of List<double> about 1.5x faster.
class EMGDataBuffer extends ChangeNotifier {
  EMGDataBuffer({this.maxDisplayPoints = 200}) {
    _ringBuffer = Float64List(maxDisplayPoints);
  }

  final int maxDisplayPoints;
  late final Float64List _ringBuffer;

  int _writeIndex = 0;
  int _totalPointsWritten = 0;

  StreamSubscription<double>? _streamSubscription;
  Timer? _uiFlushTimer;
  bool _hasPendingData = false;

  static const _flushInterval = Duration(milliseconds: 16);

  Float64List get rawBuffer => _ringBuffer;

  /// Số điểm đang hiển thị (chưa đầy ring thì < maxDisplayPoints).
  int get displayCount => min(_totalPointsWritten, maxDisplayPoints);

  /// Tổng số điểm đã ghi từ đầu stream — dùng cho trục X cuộn liên tục.
  int get totalPointsWritten => _totalPointsWritten;

  /// Đọc giá trị theo thứ tự thời gian: 0 = cũ nhất, displayCount-1 = mới nhất.
  double valueAt(int chronologicalIndex) {
    assert(chronologicalIndex >= 0 && chronologicalIndex < displayCount);
    return _ringBuffer[_physicalIndex(chronologicalIndex)];
  }

  double get peakValue {
    if (displayCount == 0) return 0;

    var peak = 0.0;
    for (var i = 0; i < displayCount; i++) {
      peak = max(peak, valueAt(i));
    }
    return peak;
  }

  /// Thêm 1 điểm Y — O(1) trên mảng cố định.
  void push(double dataPoint) {
    _ringBuffer[_writeIndex] = dataPoint;
    _writeIndex = (_writeIndex + 1) % maxDisplayPoints;
    _totalPointsWritten++;
    _hasPendingData = true;
  }

  void startUiFlush() {
    _uiFlushTimer?.cancel();
    _uiFlushTimer = Timer.periodic(_flushInterval, (_) {
      if (!_hasPendingData) return;

      _hasPendingData = false;
      notifyListeners();
    });
  }

  void startProcessing(Stream<double> rawEMGStream) {
    stopProcessing();
    _streamSubscription = rawEMGStream.listen(push);
    startUiFlush();
  }

  void stopProcessing() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _uiFlushTimer?.cancel();
    _uiFlushTimer = null;
    _writeIndex = 0;
    _totalPointsWritten = 0;
    _ringBuffer.fillRange(0, maxDisplayPoints, 0.0);
    _hasPendingData = false;
  }

  @override
  void dispose() {
    stopProcessing();
    super.dispose();
  }

  /// Map chỉ số thời gian (0 = cũ nhất) → vị trí vật lý trong ring.
  int _physicalIndex(int chronologicalIndex) {
    if (_totalPointsWritten <= maxDisplayPoints) {
      return chronologicalIndex;
    }
    // Ring đã đầy: điểm cũ nhất nằm tại _writeIndex.
    return (_writeIndex + chronologicalIndex) % maxDisplayPoints;
  }
}
