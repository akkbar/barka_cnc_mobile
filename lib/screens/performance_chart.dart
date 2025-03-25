import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart'; // Add this import for date formatting
import './performance_chart/line_shift_chart.dart';
import './performance_chart/bar_shift_chart.dart';
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
            performanceDataList = parseShiftData(data as Map<String, dynamic>);
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
            if (chartType == "Bar Chart" && viewBy == "Machine") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(data.summary, style: const TextStyle(fontSize: 14)),
                  Text(data.result, style: TextStyle(fontSize: 14, color: data.resultColor)),
                ],
              ),
              const SizedBox(height: 10),
              BarMachineChart(data: data as PerformanceData)
            ]
            else if (chartType == "Line Chart" && viewBy == "Shift") ...[
              Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              
              // Summary and Result for Shift 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shift 1:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(data.shift1Summary, style: const TextStyle(fontSize: 14)),
                  Text(data.shift1Result, style: TextStyle(fontSize: 14, color: data.shift1Color)),
                ],
              ),
              const SizedBox(height: 5),

              // Summary and Result for Shift 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shift 2:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(data.shift2Summary, style: const TextStyle(fontSize: 14)),
                  Text(data.shift2Result, style: TextStyle(fontSize: 14, color: data.shift2Color)),
                ],
              ),
              const SizedBox(height: 5),

              // Summary and Result for Shift 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shift 3:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(data.shift3Summary, style: const TextStyle(fontSize: 14)),
                  Text(data.shift3Result, style: TextStyle(fontSize: 14, color: data.shift3Color)),
                ],
              ),
              const SizedBox(height: 10),

              // 3-Series Line Chart
              ShiftLineChart(data: data),
            ]
            else if (chartType == "Bar Chart" && viewBy == "Shift") ...[
              Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              
              // Summary and Result for Shift 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shift 1:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(data.shift1Summary, style: const TextStyle(fontSize: 14)),
                  Text(data.shift1Result, style: TextStyle(fontSize: 14, color: data.shift1Color)),
                ],
              ),
              const SizedBox(height: 5),

              // Summary and Result for Shift 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shift 2:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(data.shift2Summary, style: const TextStyle(fontSize: 14)),
                  Text(data.shift2Result, style: TextStyle(fontSize: 14, color: data.shift2Color)),
                ],
              ),
              const SizedBox(height: 5),

              // Summary and Result for Shift 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shift 3:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(data.shift3Summary, style: const TextStyle(fontSize: 14)),
                  Text(data.shift3Result, style: TextStyle(fontSize: 14, color: data.shift3Color)),
                ],
              ),
              const SizedBox(height: 10),

              // 3-Series Line Chart
              ShiftBarChart(data: data),
            ]
            else 
              const Text("Invalid selection, View by Machine only supported Bar Chart"),
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

class ShiftChartDataPoint {
  final DateTime x;
  final double y;

  ShiftChartDataPoint({required this.x, required this.y});

  factory ShiftChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ShiftChartDataPoint(
      x: DateTime.fromMillisecondsSinceEpoch(json['x']),
      y: (json['y'] as num).toDouble(),
    );
  }
}

class ShiftPerformanceData {
  final String title;
  final String shift1Summary, shift2Summary, shift3Summary;
  final String shift1Result, shift2Result, shift3Result;
  final Color shift1Color, shift2Color, shift3Color;
  final List<ShiftChartDataPoint> shift1, shift2, shift3;

  ShiftPerformanceData({
    required this.title,
    required this.shift1Summary,
    required this.shift2Summary,
    required this.shift3Summary,
    required this.shift1Result,
    required this.shift2Result,
    required this.shift3Result,
    required this.shift1Color,
    required this.shift2Color,
    required this.shift3Color,
    required this.shift1,
    required this.shift2,
    required this.shift3,
  });

  factory ShiftPerformanceData.fromJson(Map<String, dynamic> json) {
    return ShiftPerformanceData(
      title: json['title'],
      shift1Summary: json['shift1']['summary'],
      shift2Summary: json['shift2']['summary'],
      shift3Summary: json['shift3']['summary'],
      shift1Result: json['shift1']['result'],
      shift2Result: json['shift2']['result'],
      shift3Result: json['shift3']['result'],
      shift1Color: Color(int.parse(json['shift1']['resultColor'].substring(1, 7), radix: 16) + 0xFF000000),
      shift2Color: Color(int.parse(json['shift2']['resultColor'].substring(1, 7), radix: 16) + 0xFF000000),
      shift3Color: Color(int.parse(json['shift3']['resultColor'].substring(1, 7), radix: 16) + 0xFF000000),
      shift1: (json['shift1']['chartData'] as List)
          .map((data) => ShiftChartDataPoint.fromJson(data))
          .toList(),
      shift2: (json['shift2']['chartData'] as List)
          .map((data) => ShiftChartDataPoint.fromJson(data))
          .toList(),
      shift3: (json['shift3']['chartData'] as List)
          .map((data) => ShiftChartDataPoint.fromJson(data))
          .toList(),
    );
  }
}


List<ShiftPerformanceData> parseShiftData(Map<String, dynamic> data) {
  List<ShiftPerformanceData> shiftDataList = [];
  try {
    // Use shift1's structure to iterate through categories
    for (var metric in data['shift1']) {
      var shift2Data = data['shift2']
          .firstWhere((m) => m['title'] == metric['title'], orElse: () => null);
      var shift3Data = data['shift3']
          .firstWhere((m) => m['title'] == metric['title'], orElse: () => null);

      shiftDataList.add(ShiftPerformanceData(
        title: metric['title'],
        shift1Summary: metric['summary'],
        shift2Summary: shift2Data?['summary'] ?? '',
        shift3Summary: shift3Data?['summary'] ?? '',
        shift1Result: metric['result'],
        shift2Result: shift2Data?['result'] ?? '',
        shift3Result: shift3Data?['result'] ?? '',
        shift1Color: Color(int.parse(metric['resultColor'].substring(1, 7), radix: 16) + 0xFF000000),
        shift2Color: shift2Data != null
            ? Color(int.parse(shift2Data['resultColor'].substring(1, 7), radix: 16) + 0xFF000000)
            : Colors.grey,
        shift3Color: shift3Data != null
            ? Color(int.parse(shift3Data['resultColor'].substring(1, 7), radix: 16) + 0xFF000000)
            : Colors.grey,
        shift1: (metric['chartData'] as List)
            .map((data) => ShiftChartDataPoint.fromJson(data))
            .toList(),
        shift2: shift2Data != null
            ? (shift2Data['chartData'] as List).map((data) => ShiftChartDataPoint.fromJson(data)).toList()
            : [],
        shift3: shift3Data != null
            ? (shift3Data['chartData'] as List).map((data) => ShiftChartDataPoint.fromJson(data)).toList()
            : [],
      ));
    }
  } catch (e) {
    print("Error parsing shift data: $e");
  }
  return shiftDataList;
}
