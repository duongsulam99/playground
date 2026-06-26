import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

class EMGDataBuffer extends ChangeNotifier {
  EMGDataBuffer({this.maxDisplayPoints = 200});

  final int maxDisplayPoints;

  final Queue<double> _displayPoints = Queue<double>();

  StreamSubscription<double>? _streamSubscription;
  Timer? _uiFlushTimer;
  bool _hasPendingData = false;

  static const _flushInterval = Duration(milliseconds: 66);

  List<double> get points => _displayPoints.toList();

  /// Thêm 1 điểm Y — O(1), không kích hoạt UI.
  void push(double dataPoint) {
    _displayPoints.addLast(dataPoint);

    if (_displayPoints.length > maxDisplayPoints) {
      _displayPoints.removeFirst();
    }

    _hasPendingData = true;
  }

  /// Bật timer flush UI ~30 FPS.
  void startUiFlush() {
    _uiFlushTimer?.cancel();
    _uiFlushTimer = Timer.periodic(_flushInterval, (_) {
      if (!_hasPendingData || _displayPoints.isEmpty) return;

      _hasPendingData = false;
      notifyListeners();
    });
  }

  /// Hứng [Stream] + bật flush UI.
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
    _displayPoints.clear();
    _hasPendingData = false;
  }

  @override
  void dispose() {
    stopProcessing();
    super.dispose();
  }
}
