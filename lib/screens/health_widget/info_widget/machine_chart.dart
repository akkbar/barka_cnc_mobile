import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class ChartSection extends StatefulWidget {
  final int machineId;

  const ChartSection({super.key, required this.machineId});

  @override
  _ChartSectionState createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  List<ChartData> chartDataList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchChartData();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
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
      final response = await http.get(Uri.parse('$apiUrl/api/machine/${widget.machineId}/realtime'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<ChartData> chartData = data.map((json) => ChartData.fromJson(json)).toList();
        setState(() {
          chartDataList = chartData;
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
      children: chartDataList.map((data) => _buildChartCard(data)).toList(),
    );
  }

  Widget _buildChartCard(ChartData data) {
    return Container(
      margin: const EdgeInsets.all(3), // ✅ Margin outside the card
      child: Card(
        color: Colors.white,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10), // ✅ Padding inside the card
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
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
                          interval: 1800000.0,
                            getTitlesWidget: (value, meta) {
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
                        spots: data.chartData,
                        isCurved: true, // Keep smooth curves (set to false for straight lines)
                        color: Colors.blue,
                        barWidth: 2, // Make the line slightly thicker
                        belowBarData: BarAreaData(show: false), // ❌ Remove area effect
                        dotData: FlDotData(show: false), // ❌ Remove dots
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.blueAccent,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((touchedSpot) {
                            final DateTime date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                            final String formattedDate = '${date.hour}:${date.minute}';
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
              ),
              const SizedBox(height: 10), // ✅ Add space below the chart
              Text(
                data.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String title;
  final List<FlSpot> chartData;

  ChartData({
    required this.title,
    required this.chartData,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    List<FlSpot> chartData = (json['chartData'] as List)
        .map((data) => FlSpot(data['x'].toDouble(), data['y'].toDouble()))
        .toList();
    return ChartData(
      title: json['title'],
      chartData: chartData,
    );
  }
}