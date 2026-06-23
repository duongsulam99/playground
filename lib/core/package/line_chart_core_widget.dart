import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartCoreWidget extends StatefulWidget {
  const LineChartCoreWidget({super.key});

  @override
  State<LineChartCoreWidget> createState() => _LineChartCoreWidgetState();
}

class _LineChartCoreWidgetState extends State<LineChartCoreWidget> {
  List<Color> gradientColors = [Colors.yellow, Colors.red];

  @override
  Widget build(BuildContext context) {
    return LineChart(mainData());
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.black, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Colors.black, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    String text = switch (value.toInt()) {
      2 => 'M',
      5 => 'J',
      8 => 'S',
      _ => '',
    };
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text = switch (value.toInt()) {
      1 => '10K',
      3 => '30k',
      5 => '50k',
      _ => '',
    };

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
