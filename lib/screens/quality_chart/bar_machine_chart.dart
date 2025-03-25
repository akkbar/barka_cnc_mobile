import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../quality_chart.dart';

class BarMachineChart extends StatelessWidget {
  final PerformanceData data;

  const BarMachineChart({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barChartData = data.chartData
        .asMap()
        .entries
        .map((entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.y,
                  color: Colors.blue,
                  width: 16,
                ),
              ],
            ))
        .toList();

    List<String> xLabels = data.chartData.map((entry) => entry.x.toString()).toList();
    double maxY = data.chartData.map((entry) => entry.y).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == maxY) {
                    return const SizedBox.shrink(); // Hide the highest title
                  }
                  return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  return index >= 0 && index < xLabels.length
                      ? Text(xLabels[index], style: const TextStyle(fontSize: 10))
                      : const Text("");
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final String machine = xLabels[group.x.toInt()];
                return BarTooltipItem(
                  '$machine\nValue: ${rod.toY}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          barGroups: barChartData,
        ),
      ),
    );
  }
}
