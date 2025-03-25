import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../quality_chart.dart';
import 'package:intl/intl.dart';

class ShiftBarChart extends StatelessWidget {
  final ShiftPerformanceData data;

  const ShiftBarChart({Key? key, required this.data}) : super(key: key);

  String formatTimestamp(double value) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateFormat('MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
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
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final xPosition = group.x.toDouble();
                final DateTime date = DateTime.fromMillisecondsSinceEpoch(xPosition.toInt());
                final String formattedDate = DateFormat('dd-MM-yyyy').format(date);

                final shift1Value = _getValueAtX(xPosition, data.shift1);
                final shift2Value = _getValueAtX(xPosition, data.shift2);
                final shift3Value = _getValueAtX(xPosition, data.shift3);

                return BarTooltipItem(
                  'Date: $formattedDate\n'
                  'Shift1: ${_formatValue(shift1Value)}\n'
                  'Shift2: ${_formatValue(shift2Value)}\n'
                  'Shift3: ${_formatValue(shift3Value)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          barGroups: _generateBarGroups(),
          // Adjust spacing between bar groups
          groupsSpace: 12,
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    // Combine all x positions from all shifts
    final allXValues = {
      ...data.shift1.map((e) => e.x.millisecondsSinceEpoch.toDouble()),
      ...data.shift2.map((e) => e.x.millisecondsSinceEpoch.toDouble()),
      ...data.shift3.map((e) => e.x.millisecondsSinceEpoch.toDouble()),
    }.toList()..sort();

    return allXValues.map((x) {
      return BarChartGroupData(
        x: x.toInt(),
        barRods: [
          BarChartRodData(
            toY: _getValueAtX(x, data.shift1) ?? 0,
            color: Colors.blue,
            width: 8,
          ),
          BarChartRodData(
            toY: _getValueAtX(x, data.shift2) ?? 0,
            color: Colors.green,
            width: 8,
          ),
          BarChartRodData(
            toY: _getValueAtX(x, data.shift3) ?? 0,
            color: Colors.red,
            width: 8,
          ),
        ],
        // Space between rods in the same group
        barsSpace: 4,
      );
    }).toList();
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
}