import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'track_performance_screen.dart';
import 'track_quality_screen.dart';
import 'manage_active_job_screen.dart';
import 'view_machine_health_screen.dart';

class DashScreen extends StatelessWidget {
  const DashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barka Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Today\'s Dashboard',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageActiveJobScreen()),
                  );
                },
                child: _buildCard("Manage Active Work Orders", _buildActiveJobsTable()),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewMachineHealthScreen()),
                  );
                },
                child: _buildCard("View Machine Health & Alarms", _buildMachineHealth()),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackPerformanceScreen()),
                  );
                },
                child: _buildCard("Track Performance", _buildMultipleLineCharts()),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackQualityScreen()),
                  );
                },
                child: _buildCard("Track Quality", _buildMultipleLineChartsQuality()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Icon(Icons.chevron_right, color: Colors.black),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleLineCharts() {
    return Column(
      children: chartDataList.map((data) => _buildChartWithTitle(data)).toList(),
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

  Widget _buildMultipleLineChartsQuality() {
    return Column(
      children: rejectDataList.map((data) => _buildChartWithTitleQuality(data)).toList(),
    );
  }

  Widget _buildChartWithTitleQuality(ChartData data) {
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

  Widget _buildActiveJobsTable() {
    return Table(
      border: const TableBorder(
        horizontalInside: BorderSide(width: 1, color: Colors.grey),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(3),
        4: FlexColumnWidth(3),
      },
      children: [
        _buildTableRow(["Status", "Name", "Machine", "Expected", "Actual"], isHeader: true),
        _buildTableRow(["On-Time", "Part A", "FANUC no 1", "00:00:00", "00:00:00"], status: Colors.green),
        _buildTableRow(["Late", "Part B", "FANUC no 3", "00:00:00", "00:00:00"], status: Colors.red),
      ],
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, Color? status}) {
    return TableRow(
      children: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String cell = entry.value;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 13 : 12,
              color: (index == 0 && status != null) ? status : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMachineHealth() {
    return Column(
      children: [
        _buildHealthSummary("New Alarm Summary", [
          _buildInfoBox("High", "1", Colors.red),
          const SizedBox(width: 5),
          _buildInfoBox("Medium", "1", Colors.orange),
          const SizedBox(width: 5),
          _buildInfoBox("Low", "3", Colors.blue),
        ]),
        _buildHealthSummary("Machine Health Summary", [
          _buildInfoBox("Down", "1", Colors.red),
          const SizedBox(width: 5),
          _buildInfoBox("Running", "1", Colors.green),
          const SizedBox(width: 5),
          _buildInfoBox("Idle", "1", Colors.orange),
          const SizedBox(width: 5),
          _buildInfoBox("Setup", "3", Colors.blue),
        ]),
      ],
    );
  }

  Widget _buildHealthSummary(String title, List<Widget> boxes) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: boxes,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoBox(String label, String number, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            const SizedBox(height: 5),
            Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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

final List<ChartData> chartDataList = [
  ChartData(
    title: "Setup Time",
    summary: "5.2 hrs",
    result: "Normal",
    resultColor: Colors.green,
    chartData: [
      FlSpot(DateTime(2025, 2, 25, 0).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 1).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 2).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 3).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 4).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 5).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 6).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 7).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 8).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 9).millisecondsSinceEpoch.toDouble(), 3),
    ],
  ),
  ChartData(
    title: "Utilization",
    summary: "75%",
    result: "Below Normal",
    resultColor: Colors.red,
    chartData: [
      FlSpot(DateTime(2025, 2, 25, 0).millisecondsSinceEpoch.toDouble(), 80),
      FlSpot(DateTime(2025, 2, 25, 1).millisecondsSinceEpoch.toDouble(), 74),
      FlSpot(DateTime(2025, 2, 25, 2).millisecondsSinceEpoch.toDouble(), 50),
      FlSpot(DateTime(2025, 2, 25, 3).millisecondsSinceEpoch.toDouble(), 60),
      FlSpot(DateTime(2025, 2, 25, 4).millisecondsSinceEpoch.toDouble(), 77),
      FlSpot(DateTime(2025, 2, 25, 5).millisecondsSinceEpoch.toDouble(), 49),
      FlSpot(DateTime(2025, 2, 25, 6).millisecondsSinceEpoch.toDouble(), 40),
      FlSpot(DateTime(2025, 2, 25, 7).millisecondsSinceEpoch.toDouble(), 82),
      FlSpot(DateTime(2025, 2, 25, 8).millisecondsSinceEpoch.toDouble(), 55),
      FlSpot(DateTime(2025, 2, 25, 9).millisecondsSinceEpoch.toDouble(), 57),
    ],
  ),
  ChartData(
    title: "Cycle Time",
    summary: "2.1 hrs",
    result: "Normal",
    resultColor: Colors.green,
    chartData: [
      FlSpot(DateTime(2025, 2, 25, 0).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 1).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 2).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 3).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 4).millisecondsSinceEpoch.toDouble(), 3),
      FlSpot(DateTime(2025, 2, 25, 5).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 6).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 7).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 8).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 9).millisecondsSinceEpoch.toDouble(), 3),
    ],
  ),
  ChartData(
    title: "Downtime",
    summary: "1.2 hrs",
    result: "Normal",
    resultColor: Colors.green,
    chartData: [
      FlSpot(DateTime(2025, 2, 25, 0).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 1).millisecondsSinceEpoch.toDouble(), 1.1),
      FlSpot(DateTime(2025, 2, 25, 2).millisecondsSinceEpoch.toDouble(), 2),
      FlSpot(DateTime(2025, 2, 25, 3).millisecondsSinceEpoch.toDouble(), 1.2),
      FlSpot(DateTime(2025, 2, 25, 4).millisecondsSinceEpoch.toDouble(), 1.3),
      FlSpot(DateTime(2025, 2, 25, 5).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 6).millisecondsSinceEpoch.toDouble(), 0),
      FlSpot(DateTime(2025, 2, 25, 7).millisecondsSinceEpoch.toDouble(), 0),
      FlSpot(DateTime(2025, 2, 25, 8).millisecondsSinceEpoch.toDouble(), 1),
      FlSpot(DateTime(2025, 2, 25, 9).millisecondsSinceEpoch.toDouble(), 0.5),
    ],
  ),
  // Add more ChartData objects as needed
];

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

