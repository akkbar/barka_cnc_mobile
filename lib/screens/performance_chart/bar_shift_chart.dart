import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../performance_chart.dart';

class BarShiftChart extends StatelessWidget {
  final PerformanceData data;

  const BarShiftChart({required this.data, Key? key}) : super(key: key);

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

    

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
              ),
            ),
            
          ),
          barGroups: barChartData,
        ),
      ),
    );
  }
}
