import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_supper_app_core/core.dart';
import 'package:vulcan_mobile_playground/features/ble/presentation/widgets/emg_chart/emg_data_buffer.dart';
import 'package:vulcan_mobile_playground/theme/playground_colors.dart';

class EmgLiveChartWidget extends StatelessWidget {
  const EmgLiveChartWidget({
    required this.buffer,
    required this.isStreaming,
    required this.supportsDataStream,
    required this.emgLower,
    required this.emgUpper,
    super.key,
  });

  final EMGDataBuffer buffer;
  final bool isStreaming;
  final bool supportsDataStream;
  final int emgLower;
  final int emgUpper;

  static const _stepCounter = 0.01;

  double _computeRoundedMaxY({
    required double peakSignalY,
    required double upperThreshold,
  }) {
    final resolvedMaxY = peakSignalY > upperThreshold
        ? peakSignalY
        : upperThreshold;
    return ((resolvedMaxY ~/ 10) + 1) * 10.0;
  }

  List<FlSpot> _spotsFromBuffer(EMGDataBuffer buffer) {
    final count = buffer.displayCount;
    if (count == 0) return const [];

    final startX = (buffer.totalPointsWritten - count) * _stepCounter;

    return List.generate(count, (index) {
      return FlSpot(startX + index * _stepCounter, buffer.valueAt(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!supportsDataStream) {
      return const _EmgChartPlaceholder(
        message: 'No data stream available for this device.',
      );
    }

    if (!isStreaming) {
      return const _EmgChartPlaceholder(message: 'Stream is not active.');
    }

    return ListenableBuilder(
      listenable: buffer,
      builder: (context, _) {
        if (buffer.displayCount == 0) {
          return const _EmgChartPlaceholder(message: 'Waiting for EMG data…');
        }

        final maxY = _computeRoundedMaxY(
          peakSignalY: buffer.peakValue,
          upperThreshold: emgUpper.toDouble(),
        );

        return _EmgLiveLineChartView(
          spots: _spotsFromBuffer(buffer),
          maxY: maxY,
          emgLower: emgLower,
          emgUpper: emgUpper,
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
            style: context.textTheme.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
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
          padding: EdgeInsets.all(context.dimensions.spacing12),
          child: RepaintBoundary(
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
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: PlaygroundColors.chartGrid,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    dotData: const FlDotData(show: false),
                    color: PlaygroundColors.chartSignal,
                    barWidth: 3,
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: emgLower.toDouble(),
                      color: PlaygroundColors.chartLower,
                      dashArray: const [20, 10],
                    ),
                    HorizontalLine(
                      y: emgUpper.toDouble(),
                      color: PlaygroundColors.chartUpper,
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
        style: context.textTheme.caption.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
