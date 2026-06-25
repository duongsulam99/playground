import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_stream_snapshot.dart';

class EmgLiveChartWidget extends StatefulWidget {
  const EmgLiveChartWidget({
    required this.latestSnapshot,
    required this.isStreaming,
    required this.supportsDataStream,
    required this.emgLower,
    required this.emgUpper,
    super.key,
  });

  final EmgStreamSnapshot? latestSnapshot;
  final bool isStreaming;
  final bool supportsDataStream;
  final int emgLower;
  final int emgUpper;

  @override
  State<EmgLiveChartWidget> createState() => _EmgLiveChartWidgetState();
}

class _EmgLiveChartWidgetState extends State<EmgLiveChartWidget> {
  static const _dataLiveLim = 300;
  static const _stepCounter = 0.01;

  final _emgTotalSignal = <FlSpot>[const FlSpot(0, 0)];

  double _xValue = 0;
  DateTime? _lastProcessedTimestamp;

  @override
  void didUpdateWidget(covariant EmgLiveChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final snapshot = widget.latestSnapshot;
    if (snapshot == null) {
      if (oldWidget.latestSnapshot != null) {
        _resetBuffers();
      }
      return;
    }

    if (_lastProcessedTimestamp == snapshot.timestamp) return;
    _lastProcessedTimestamp = snapshot.timestamp;

    final voltages = snapshot.voltages;
    final emg0 = voltages.elementAtOrNull(0) ?? 0;
    final emg1 = voltages.elementAtOrNull(1) ?? 0;
    final emg2 = voltages.elementAtOrNull(2) ?? 0;
    final totaldata = max(0, min(emg0 + emg1 + emg2, 1000)).toDouble();

    while (_emgTotalSignal.length > _dataLiveLim) {
      _emgTotalSignal.removeAt(0);
    }

    setState(() {
      _emgTotalSignal.add(FlSpot(_xValue, totaldata));
      _xValue += _stepCounter;
    });
  }

  void _resetBuffers() {
    setState(() {
      _xValue = 0;
      _lastProcessedTimestamp = null;
      _emgTotalSignal
        ..clear()
        ..add(const FlSpot(0, 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.supportsDataStream) {
      return _placeholder(context, 'No data stream available for this device.');
    }

    if (!widget.isStreaming) {
      return _placeholder(context, 'Stream is not active.');
    }

    if (widget.latestSnapshot == null) {
      return _placeholder(context, 'Waiting for EMG data…');
    }

    final maxY = _resolveMaxY();

    return AspectRatio(
      aspectRatio: 1.70,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LineChart(
            duration: Duration.zero,
            LineChartData(
              minY: 0,
              maxY: maxY,
              minX: _emgTotalSignal.first.x,
              maxX: _emgTotalSignal.last.x,
              lineTouchData: const LineTouchData(enabled: false),
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.1),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _emgTotalSignal,
                  dotData: const FlDotData(show: false),
                  color: Colors.white,
                  barWidth: 3,
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: widget.emgLower.toDouble(),
                    color: Colors.green,
                    dashArray: const [20, 10],
                    strokeWidth: 2,
                  ),
                  HorizontalLine(
                    y: widget.emgUpper.toDouble(),
                    color: Colors.orange,
                    dashArray: const [20, 10],
                    strokeWidth: 2,
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: _leftTitleWidgets,
                  ),
                ),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: const AxisTitles(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Legacy basic mode: scale Y to fit current EMG peak and upper threshold.
  double _resolveMaxY() {
    final maxSignalY = _emgTotalSignal.isEmpty
        ? 0.0
        : _emgTotalSignal.map((spot) => spot.y).reduce(max);
    final peak = max(maxSignalY, widget.emgUpper.toDouble());
    return ((peak ~/ 10) + 1) * 10.0;
  }

  Widget _placeholder(BuildContext context, String message) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Card(
        child: Center(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '${value.toInt()}',
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }
}
