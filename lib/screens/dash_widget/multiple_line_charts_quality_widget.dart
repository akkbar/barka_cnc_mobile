import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class MultipleLineChartsQualityWidget extends StatefulWidget {
  const MultipleLineChartsQualityWidget({Key? key}) : super(key: key);

  @override
  _MultipleLineChartsQualityWidgetState createState() => _MultipleLineChartsQualityWidgetState();
}

class _MultipleLineChartsQualityWidgetState extends State<MultipleLineChartsQualityWidget> {
  List<ChartData> rejectDataList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchChartData();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchChartData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchChartData() async {
    try {
      await GetStorage.init(); // Ensure GetStorage is initialized
      final box = GetStorage();
      final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
      print('API URL: $apiUrl'); // Log the API URL
      final response = await http.get(Uri.parse('$apiUrl/api/quality'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<ChartData> chartData = data.map((json) => ChartData.fromJson(json)).toList();
        setState(() {
          rejectDataList = chartData;
        });
      } else {
        print('Failed to load chart data: ${response.statusCode}'); // Log the status code
        throw Exception('Failed to load chart data');
      }
    } catch (e) {
      print('Error fetching chart data: $e'); // Log the error
      throw Exception('Failed to load chart data');
    }
  }

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
                interval: 14400000,
                getTitlesWidget: (value, meta) {
                  if (value == chartData.first.x || value == chartData.last.x) {
                    return const SizedBox.shrink(); // Skip the first title
                  }
                  final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  final String formattedHour = date.hour.toString().padLeft(2, '0');
                  final String formattedMinute = date.minute.toString().padLeft(2, '0');
                  return Text('$formattedHour:$formattedMinute', style: const TextStyle(fontSize: 10));
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
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final DateTime date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                  final String formattedHour = date.hour.toString().padLeft(2, '0');
                  final String formattedMinute = date.minute.toString().padLeft(2, '0');
                  final String formattedDate = '$formattedHour:$formattedMinute';
                  return LineTooltipItem(
                    'Time: $formattedDate\nValue: ${touchedSpot.y}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
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

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      title: json['title'],
      summary: json['summary'],
      result: json['result'],
      resultColor: Color(int.parse(json['resultColor'].substring(1, 7), radix: 16) + 0xFF000000),
      chartData: (json['chartData'] as List)
          .map((data) => FlSpot(data['x'].toDouble(), data['y'].toDouble()))
          .toList(),
    );
  }
}