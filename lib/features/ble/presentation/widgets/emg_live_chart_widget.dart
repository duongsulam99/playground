import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_stream_snapshot.dart';

class EmgLiveChartWidget extends StatefulWidget {
  const EmgLiveChartWidget({
    required this.latestSnapshot,
    required this.isStreaming,
    required this.supportsDataStream,
    super.key,
  });

  final EmgStreamSnapshot? latestSnapshot;
  final bool isStreaming;
  final bool supportsDataStream;

  @override
  State<EmgLiveChartWidget> createState() => _EmgLiveChartWidgetState();
}

class _EmgLiveChartWidgetState extends State<EmgLiveChartWidget> {
  static const _dataLiveLim = 300;
  static const _stepCounter = 0.01;

  final _ch0Signal = <FlSpot>[const FlSpot(0, 0)];
  final _ch1Signal = <FlSpot>[const FlSpot(0, 0)];
  final _ch2Signal = <FlSpot>[const FlSpot(0, 0)];

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

    while (_ch0Signal.length > _dataLiveLim) {
      _ch0Signal.removeAt(0);
      _ch1Signal.removeAt(0);
      _ch2Signal.removeAt(0);
    }

    setState(() {
      _ch0Signal.add(FlSpot(_xValue, emg0));
      _ch1Signal.add(FlSpot(_xValue, emg1));
      _ch2Signal.add(FlSpot(_xValue, emg2));
      _xValue += _stepCounter;
    });
  }

  void _resetBuffers() {
    setState(() {
      _xValue = 0;
      _lastProcessedTimestamp = null;
      _ch0Signal
        ..clear()
        ..add(const FlSpot(0, 0));
      _ch1Signal
        ..clear()
        ..add(const FlSpot(0, 0));
      _ch2Signal
        ..clear()
        ..add(const FlSpot(0, 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.supportsDataStream) {
      return _placeholder(
        context,
        'No data stream available for this device.',
      );
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
              minX: _ch0Signal.first.x,
              maxX: _ch0Signal.last.x,
              lineTouchData: const LineTouchData(enabled: false),
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.1),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _lineBar(_ch0Signal, Colors.redAccent),
                _lineBar(_ch1Signal, Colors.blue),
                _lineBar(_ch2Signal, Colors.yellow),
              ],
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

  Widget _placeholder(BuildContext context, String message) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Card(
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  double _resolveMaxY() {
    final maxVal = max(
      _maxSpotY(_ch0Signal),
      max(_maxSpotY(_ch1Signal), _maxSpotY(_ch2Signal)),
    );
    return max(10, ((maxVal ~/ 10) + 1) * 10).toDouble();
  }

  double _maxSpotY(List<FlSpot> points) {
    if (points.isEmpty) return 0;
    return points.map((spot) => spot.y).reduce(max);
  }

  LineChartBarData _lineBar(List<FlSpot> points, Color color) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(show: false),
      color: color,
      barWidth: 3,
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
