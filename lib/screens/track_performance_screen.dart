import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart'; // Add this import for date formatting

class TrackPerformanceScreen extends StatefulWidget {
  const TrackPerformanceScreen({super.key});

  @override
  _TrackPerformanceScreenState createState() => _TrackPerformanceScreenState();
}

class _TrackPerformanceScreenState extends State<TrackPerformanceScreen> {
  String viewBy = "Shift";
  String chartType = "Line Chart";
  final TextEditingController _dateRangeController = TextEditingController();
  List<PerformanceData> performanceDataList = [];
  String selectedDateRange = "Today";

  @override
  void initState() {
    super.initState();
    fetchPerformanceData();
  }

  Future<void> fetchPerformanceData() async {
    try {
      await GetStorage.init(); // Ensure GetStorage is initialized
      final box = GetStorage();
      final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
      print('API URL: $apiUrl'); // Log the API URL
      final response = await http.get(Uri.parse('$apiUrl/api/performance?viewBy=$viewBy&dateRange=$selectedDateRange'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<PerformanceData> performanceData = data.map((json) => PerformanceData.fromJson(json)).toList();
        setState(() {
          performanceDataList = performanceData;
        });
      } else {
        print('Failed to load performance data: ${response.statusCode}'); // Log the status code
        throw Exception('Failed to load performance data');
      }
    } catch (e) {
      print('Error fetching performance data: $e'); // Log the error
      throw Exception('Failed to load performance data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Performance")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // View Selector & Chart Type Dropdowns
              Card(
                color: Colors.white,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              "View by:",
                              ["Shift", "Machine"],
                              viewBy,
                              (newValue) {
                                setState(() {
                                  viewBy = newValue as String;
                                  fetchPerformanceData();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown(
                              "Chart Type:",
                              ["Line Chart", "Bar Chart"],
                              chartType,
                              (newValue) {
                                setState(() {
                                  chartType = newValue as String;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildDateButton("Today"),
                          _buildDateButton("Week"),
                          _buildDateButton("Month"),
                          _buildDateButton("YTD"),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                controller: _dateRangeController,
                                decoration: const InputDecoration(
                                  hintText: "Start Date",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTimeRange? picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      final DateFormat formatter = DateFormat('yyyy-MM-dd');
                                      _dateRangeController.text =
                                          "${formatter.format(picked.start)} - ${formatter.format(picked.end)}";
                                      selectedDateRange = "${formatter.format(picked.start)} - ${formatter.format(picked.end)}";
                                      fetchPerformanceData();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Selected Date Range: $selectedDateRange"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Utilization Chart
              ...performanceDataList.map((data) => _buildCard(data)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateButton(String label) {
    final bool isSelected = selectedDateRange == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedDateRange = label;
            fetchPerformanceData();
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 12),
          foregroundColor: isSelected ? Colors.white : Colors.blue,
          side: const BorderSide(color: Colors.blue),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.blue)),
      ),
    );
  }

  Widget _buildCard(PerformanceData data) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            _buildChartSection(data.chartData),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(List<FlSpot> chartData) {
    return SizedBox(
      height: 200,
      child: chartType == "Line Chart"
          ? LineChart(
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
                        return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10));
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
            )
          : BarChart(
              BarChartData(
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
                        return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                barGroups: chartData
                    .map((data) => BarChartGroupData(
                          x: data.x.toInt(),
                          barRods: [
                            BarChartRodData(
                              toY: data.y,
                              color: Colors.blue,
                              width: 4,
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ),
    );
  }
}

class PerformanceData {
  final String title;
  final String summary;
  final String result;
  final Color resultColor;
  final List<FlSpot> chartData;

  PerformanceData({
    required this.title,
    required this.summary,
    required this.result,
    required this.resultColor,
    required this.chartData,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
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