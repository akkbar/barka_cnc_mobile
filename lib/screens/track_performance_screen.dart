import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrackPerformanceScreen extends StatefulWidget {
  const TrackPerformanceScreen({super.key});

  @override
  _TrackPerformanceScreenState createState() => _TrackPerformanceScreenState();
}

class _TrackPerformanceScreenState extends State<TrackPerformanceScreen> {
  String viewBy = "Shift";
  String chartType = "Line Chart";

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
                              (newValue) => setState(() => viewBy = newValue as String),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown(
                              "Chart Type:",
                              ["Line Chart", "Bar Chart"],
                              chartType,
                              (newValue) => setState(() => chartType = newValue as String),
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
                                decoration: const InputDecoration(
                                  hintText: "Start Date",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Utilization Chart
              _buildCard("Utilization", _buildChartSection()),
              const SizedBox(height: 16),
              _buildCard("Cycle Time", _buildChartSection()),
              const SizedBox(height: 16),
              _buildCard("Setup Time", _buildChartSection()),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 12),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child:Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
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
                  return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(DateTime(2025, 2, 19).millisecondsSinceEpoch.toDouble(), 1),
                FlSpot(DateTime(2025, 2, 20).millisecondsSinceEpoch.toDouble(), 3),
                FlSpot(DateTime(2025, 2, 21).millisecondsSinceEpoch.toDouble(), 2),
                FlSpot(DateTime(2025, 2, 22).millisecondsSinceEpoch.toDouble(), 5),
                FlSpot(DateTime(2025, 2, 23).millisecondsSinceEpoch.toDouble(), 4),
              ],
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