import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MultipleLineChartsQualityWidget extends StatelessWidget {
  const MultipleLineChartsQualityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rejectDataList.map((data) => _buildChartWithTitle(data)).toList(),
    );
  }

  Widget _buildChartWithTitle(ChartData data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(data.summary, style: const TextStyle(fontSize: 14)),
                Text(data.result, style: TextStyle(fontSize: 14, color: data.resultColor)),
              ],
            ),
            const SizedBox(height: 10),
            _buildLineChart(data.chartData),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> chartData) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
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
                getTitlesWidget: (value, meta) {
                  final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text('${date.hour}:00', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String title;
  final String summary;
  final String result;
  final Color resultColor;
  final List<FlSpot> chartData;

  ChartData({
    required this.title,
    required this.summary,
    required this.result,
    required this.resultColor,
    required this.chartData,
  });
}

final List<ChartData> rejectDataList = [
  ChartData(
    title: "Rejected Parts",
    summary: "3 parts",
    result: "Above Normal",
    resultColor: Colors.red,
    chartData: [
      FlSpot(DateTime(2025, 2, 25, 0).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 1).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 2).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 3).millisecondsSinceEpoch.toDouble(), 5),
      FlSpot(DateTime(2025, 2, 25, 4).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 5).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 6).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 7).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 8).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 9).millisecondsSinceEpoch.toDouble(), 2),
    ],
  ),
  // Add more ChartData objects as needed
];