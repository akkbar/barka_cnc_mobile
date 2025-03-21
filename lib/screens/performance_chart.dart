import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:fl_chart/fl_chart.dart'; // Add this import for FlSpot
import './performance_chart/line_shift_chart.dart';
// import './performance_chart/bar_shift_chart.dart';
import './performance_chart/bar_machine_chart.dart';

class TrackPerformanceScreen extends StatefulWidget {
  const TrackPerformanceScreen({super.key});

  @override
  _TrackPerformanceScreenState createState() => _TrackPerformanceScreenState();
}

class _TrackPerformanceScreenState extends State<TrackPerformanceScreen> {
  String viewBy = "Shift";
  String chartType = "Line Chart";
  final TextEditingController _dateRangeController = TextEditingController();
  List<dynamic> performanceDataList = [];
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
      final response = await http.get(Uri.parse('$apiUrl/api/performance?viewBy=$viewBy&dateRange=$selectedDateRange&chartType=$chartType'));

      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        print(data);
        setState(() {
          if (viewBy == "Machine") {
            performanceDataList = (data as List).map((json) => PerformanceData.fromJson(json)).toList();
          } else {
            performanceDataList = [];
            for (var metric in data['shift1']) {
              performanceDataList.add(ShiftPerformanceData.fromJson({
                'title': metric['title'],
                'summary': metric['summary'],
                'result': metric['result'],
                'resultColor': metric['resultColor'],
                'shift1': metric['chartData'],
                'shift2': data['shift2'].firstWhere((m) => m['title'] == metric['title'])['chartData'],
                'shift3': data['shift3'].firstWhere((m) => m['title'] == metric['title'])['chartData'],
              }));
            }
          }
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
                                  hintText: "Date Range",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTimeRange? picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2025),
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

  Widget _buildCard(dynamic data) {
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

            // **Dynamic Chart Rendering**
            if (viewBy == "Machine")
              BarMachineChart(data: data as PerformanceData) // Cast to PerformanceData
            else if (chartType == "Line Chart" && viewBy == "Shift")
              LineShiftChart(
                lineBarsData: [
                  // Series for Shift 1
                  LineChartBarData(
                    spots: data.shift1.map((e) => FlSpot(e.x.millisecondsSinceEpoch.toDouble(), e.y)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                  ),
                  // Series for Shift 2
                  LineChartBarData(
                    spots: data.shift2.map((e) => FlSpot(e.x.millisecondsSinceEpoch.toDouble(), e.y)).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                  ),
                  // Series for Shift 3
                  LineChartBarData(
                    spots: data.shift3.map((e) => FlSpot(e.x.millisecondsSinceEpoch.toDouble(), e.y)).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 4,
                  ),
                ],
                xLabels: data.shift1.map((e) => DateFormat('MM/dd').format(e.x)).toList(),
              )
            else
              const Text("Invalid selection"),
          ],
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
  final List<ChartDataPoint> chartData;

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
          .map((data) => ChartDataPoint.fromJson(data))
          .toList(),
    );
  }
}

class ChartDataPoint {
  final String x;
  final double y;

  ChartDataPoint({required this.x, required this.y});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      x: json['x'],
      y: json['y'].toDouble(),
    );
  }
}

class ShiftPerformanceData {
  final String title;
  final String summary;
  final String result;
  final Color resultColor;
  final List<ShiftChartDataPoint> shift1;
  final List<ShiftChartDataPoint> shift2;
  final List<ShiftChartDataPoint> shift3;

  ShiftPerformanceData({
    required this.title,
    required this.summary,
    required this.result,
    required this.resultColor,
    required this.shift1,
    required this.shift2,
    required this.shift3,
  });

  factory ShiftPerformanceData.fromJson(Map<String, dynamic> json) {
    return ShiftPerformanceData(
      title: json['title'],
      summary: json['summary'],
      result: json['result'],
      resultColor: Color(int.parse(json['resultColor'].substring(1, 7), radix: 16) + 0xFF000000),
      shift1: (json['shift1'] as List).map((data) => ShiftChartDataPoint.fromJson(data)).toList(),
      shift2: (json['shift2'] as List).map((data) => ShiftChartDataPoint.fromJson(data)).toList(),
      shift3: (json['shift3'] as List).map((data) => ShiftChartDataPoint.fromJson(data)).toList(),
    );
  }
}

class ShiftChartDataPoint {
  final DateTime x;
  final double y;

  ShiftChartDataPoint({required this.x, required this.y});

  factory ShiftChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ShiftChartDataPoint(
      x: DateTime.fromMillisecondsSinceEpoch(json['x']),
      y: json['y'].toDouble(),
    );
  }
}