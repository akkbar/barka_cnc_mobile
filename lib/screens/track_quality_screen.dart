import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrackQualityScreen extends StatefulWidget {
  const TrackQualityScreen({super.key});

  @override
  _TrackQualityScreenState createState() => _TrackQualityScreenState();
}

class _TrackQualityScreenState extends State<TrackQualityScreen> {
  String viewBy = "Shift";
  String chartType = "Line Chart";
  final TextEditingController _dateRangeController = TextEditingController();

  final List<PerformanceData> performanceDataList = [
    PerformanceData(
      title: "Reject",
      summary: "5.2 parts",
      result: "Normal",
      resultColor: Colors.green,
      chartData: [
        FlSpot(DateTime(2025, 2, 19).millisecondsSinceEpoch.toDouble(), 1),
        FlSpot(DateTime(2025, 2, 20).millisecondsSinceEpoch.toDouble(), 3),
        FlSpot(DateTime(2025, 2, 21).millisecondsSinceEpoch.toDouble(), 2),
        FlSpot(DateTime(2025, 2, 22).millisecondsSinceEpoch.toDouble(), 5),
        FlSpot(DateTime(2025, 2, 23).millisecondsSinceEpoch.toDouble(), 4),
      ],
    ),
    // Add more PerformanceData objects as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quality")),
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
                                      _dateRangeController.text =
                                          "${picked.start.toLocal()} - ${picked.end.toLocal()}".split(' ')[0];
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 12),
          foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.blue),
        ),
        child: Text(label, style: const TextStyle(color: Colors.blue)),
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
}