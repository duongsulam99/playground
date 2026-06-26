import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/features/ble/domain/entities/ble_device_stream_snapshot.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/emg_chart/emg_data_buffer.dart';

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
  static const _emgSignalCeiling = 1000;

  late final EMGDataBuffer _buffer;
  DateTime? _lastProcessedTimestamp;

  @override
  void initState() {
    super.initState();
    _buffer = EMGDataBuffer(maxDisplayPoints: _dataLiveLim);
    _buffer.startUiFlush();
  }

  @override
  void dispose() {
    _buffer.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Snapshot ingestion — push vào buffer, không setState
  // ---------------------------------------------------------------------------

  @override
  void didUpdateWidget(covariant EmgLiveChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isStreaming || widget.latestSnapshot == null) {
      if (oldWidget.isStreaming && oldWidget.latestSnapshot != null) {
        _resetBuffers();
      }
      return;
    }

    final snapshot = widget.latestSnapshot!;
    if (_isDuplicateSnapshot(snapshot)) return;

    _lastProcessedTimestamp = snapshot.timestamp;
    _buffer.push(_computeTotalEmg(snapshot));
  }

  bool _isDuplicateSnapshot(EmgStreamSnapshot snapshot) {
    return _lastProcessedTimestamp == snapshot.timestamp;
  }

  double _computeTotalEmg(EmgStreamSnapshot snapshot) {
    final voltages = snapshot.voltages;
    final channelSum =
        (voltages.elementAtOrNull(0) ?? 0) +
        (voltages.elementAtOrNull(1) ?? 0) +
        (voltages.elementAtOrNull(2) ?? 0);

    return max(0, min(channelSum, _emgSignalCeiling)).toDouble();
  }

  void _resetBuffers() {
    _buffer.stopProcessing();
    _lastProcessedTimestamp = null;
    _buffer.startUiFlush();
  }

  // ---------------------------------------------------------------------------
  // Trục Y
  // ---------------------------------------------------------------------------

  double _computeRoundedMaxY({
    required double peakSignalY,
    required double upperThreshold,
  }) {
    final resolvedMaxY = max(peakSignalY, upperThreshold);
    return ((resolvedMaxY ~/ 10) + 1) * 10.0;
  }

  List<FlSpot> _spotsFromBuffer(List<double> values) {
    return List.generate(
      values.length,
      (index) => FlSpot(index * _stepCounter, values[index]),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!widget.supportsDataStream) {
      return const _EmgChartPlaceholder(
        message: 'No data stream available for this device.',
      );
    }

    if (!widget.isStreaming) {
      return const _EmgChartPlaceholder(message: 'Stream is not active.');
    }

    if (widget.latestSnapshot == null) {
      return const _EmgChartPlaceholder(message: 'Waiting for EMG data…');
    }

    return ListenableBuilder(
      listenable: _buffer,
      builder: (context, _) {
        final values = _buffer.points;

        if (values.isEmpty) {
          return const _EmgChartPlaceholder(message: 'Waiting for EMG data…');
        }

        final maxY = _computeRoundedMaxY(
          peakSignalY: values.reduce(max),
          upperThreshold: widget.emgUpper.toDouble(),
        );

        return _EmgLiveLineChartView(
          spots: _spotsFromBuffer(values),
          maxY: maxY,
          emgLower: widget.emgLower,
          emgUpper: widget.emgUpper,
        );
      },
    );
  }
}

class _EmgChartPlaceholder extends StatelessWidget {
  const _EmgChartPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
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
}

class _EmgLiveLineChartView extends StatelessWidget {
  const _EmgLiveLineChartView({
    required this.spots,
    required this.maxY,
    required this.emgLower,
    required this.emgUpper,
  });

  final List<FlSpot> spots;
  final double maxY;
  final int emgLower;
  final int emgUpper;

  @override
  Widget build(BuildContext context) {
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
              minX: spots.first.x,
              maxX: spots.last.x,
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
                  spots: spots,
                  dotData: const FlDotData(show: false),
                  color: Colors.red,
                  barWidth: 3,
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: emgLower.toDouble(),
                    color: Colors.green,
                    dashArray: const [20, 10],
                  ),
                  HorizontalLine(
                    y: emgUpper.toDouble(),
                    color: Colors.orange,
                    dashArray: const [20, 10],
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) =>
                        _EmgChartLeftTitle(value: value, meta: meta),
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
}

class _EmgChartLeftTitle extends StatelessWidget {
  const _EmgChartLeftTitle({required this.value, required this.meta});

  final double value;
  final TitleMeta meta;

  @override
  Widget build(BuildContext context) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        '${value.toInt()}',
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }
}
