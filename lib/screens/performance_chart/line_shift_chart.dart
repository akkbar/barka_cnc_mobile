import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineShiftChart extends StatelessWidget {
  final List<LineChartBarData> lineBarsData;
  final List<String> xLabels;

  const LineShiftChart({required this.lineBarsData, required this.xLabels, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  return index >= 0 && index < xLabels.length
                      ? Text(xLabels[index], style: const TextStyle(fontSize: 10))
                      : const Text("");
                },
              ),
            ),
          ),
          lineBarsData: lineBarsData,
        ),
      ),
    );
  }
}