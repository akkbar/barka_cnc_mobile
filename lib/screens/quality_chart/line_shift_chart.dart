import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../quality_chart.dart';
import 'package:intl/intl.dart';

class ShiftLineChart extends StatelessWidget {
  final ShiftPerformanceData data;

  const ShiftLineChart({Key? key, required this.data}) : super(key: key);

  String formatTimestamp(double value) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateFormat('MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                getTitlesWidget: (value, meta) {
                  return Text(formatTimestamp(value), style: const TextStyle(fontSize: 10));
                },
                interval: 86400000,
              ),
            ),
          ),
          lineTouchData: LineTouchData(
  enabled: true,
  touchTooltipData: LineTouchTooltipData(
    tooltipBgColor: Colors.blueAccent,
    fitInsideHorizontally: true,
    fitInsideVertically: true,
    getTooltipItems: (List<LineBarSpot> touchedSpots) {
      if (touchedSpots.isEmpty) return [];

      // Get the x-position of the first touched spot
      final double xPosition = touchedSpots.first.x;
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(xPosition.toInt());
      final String formattedDate = DateFormat('dd-MM-yyyy').format(date);

      // Find values for all shifts at this x-position
      final shift1Value = _getValueAtX(xPosition, data.shift1);
      final shift2Value = _getValueAtX(xPosition, data.shift2);
      final shift3Value = _getValueAtX(xPosition, data.shift3);

      // Create a list with the same length as touchedSpots
      return List.generate(touchedSpots.length, (index) {
        // Only show content for the first item
        if (index == 0) {
          return LineTooltipItem(
            'Date: $formattedDate\n'
            'Shift1: ${_formatValue(shift1Value)}\n'
            'Shift2: ${_formatValue(shift2Value)}\n'
            'Shift3: ${_formatValue(shift3Value)}',
            const TextStyle(color: Colors.white),
          );
        }
        // Return empty tooltips for other items
        return const LineTooltipItem('', TextStyle());
      });
    },
  ),
),
          lineBarsData: [
            _buildLineChartBarData(data.shift1, Colors.blue, 0),
            _buildLineChartBarData(data.shift2, Colors.green, 1),
            _buildLineChartBarData(data.shift3, Colors.red, 2),
          ],
        ),
      ),
    );
  }

  double? _getValueAtX(double x, List<ShiftChartDataPoint> shiftData) {
  try {
    return shiftData.firstWhere(
      (point) => point.x.millisecondsSinceEpoch.toDouble() == x,
    ).y;
  } catch (e) {
    return null;
  }
}

String _formatValue(double? value) {
  if (value == null || value.isNaN) return "--";
  return value.toStringAsFixed(2);
}

  LineChartBarData _buildLineChartBarData(
    List<ShiftChartDataPoint> shiftData, Color color, int index) {
    if (shiftData.isEmpty) {
      return LineChartBarData(
        spots: [FlSpot(0, 0)],
        isCurved: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }

    return LineChartBarData(
      spots: shiftData
          .map((point) => FlSpot(
              point.x.millisecondsSinceEpoch.toDouble(),
              point.y.isFinite ? point.y : 0))
          .toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}
