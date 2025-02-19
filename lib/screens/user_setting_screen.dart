import 'package:flutter/material.dart';

class UserSettingScreen extends StatelessWidget {
  const UserSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard("Track Performance", _buildActiveJobsTable()),
              const SizedBox(height: 16),
              _buildCard("View Machine Health & Alarms", _buildMachineHealth()),
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
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
        _buildTableRow(["Status", "Program Name", "Machine", "Expected", "Actual"], isHeader: true),
        _buildTableRow(["On-Time", "Part A", "FANUC no 1", "2025-02-20\n00:00:00", "2025-02-20\n00:00:00"], status: Colors.green),
        _buildTableRow(["Late", "Part B", "FANUC no 3", "2025-02-20\n00:00:00", "2025-02-20\n00:00:00"], status: Colors.red),
      ],
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, Color? status}) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 13 : 12,
              color: status ?? Colors.black,
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
          const SizedBox(width: 10),
          _buildInfoBox("Medium", "1", Colors.orange),
          const SizedBox(width: 10),
          _buildInfoBox("Low", "3", Colors.blue),
        ]),
        _buildHealthSummary("Machine Health Summary", [
          _buildInfoBox("Down", "1", Colors.red),
          const SizedBox(width: 10),
          _buildInfoBox("Running", "1", Colors.green),
          const SizedBox(width: 10),
          _buildInfoBox("Idle", "1", Colors.orange),
          const SizedBox(width: 10),
          _buildInfoBox("Setup", "3", Colors.blue),
        ]),
      ],
    );
  }

  Widget _buildHealthSummary(String title, List<Widget> boxes) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}