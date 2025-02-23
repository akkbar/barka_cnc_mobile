import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'track_performance_screen.dart';
import 'manage_active_job_screen.dart';
import 'view_machine_health_screen.dart';

class UserSettingScreen extends StatelessWidget {
  const UserSettingScreen({super.key});

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
                  'Dashboard',
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
              children:[
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Icon(Icons.chevron_right, color: Colors.black),
              ]),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleLineCharts() {
    return Column(
      children: [
        _buildChartWithTitle("Setup Time"),
        const SizedBox(height: 16),
        _buildChartWithTitle("Utilization"),
        const SizedBox(height: 16),
        _buildChartWithTitle("Cycle Time"),
        const SizedBox(height: 16),
        _buildChartWithTitle("Downtime"),
      ],
    );
  }

  Widget _buildChartWithTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
        ),
        const SizedBox(height: 10),
        _buildLineChart(),
      ],
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
              ]),
            
            const SizedBox(height: 5),
            Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
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

