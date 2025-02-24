import 'package:flutter/material.dart';

class MachineInfoScreen extends StatelessWidget {
  const MachineInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FANUC no 1")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              _buildChartSection("Feedrate"),
              _buildChartSection("Spindle Temp"),
              _buildChartSection("Spindle Speed"),
              _buildChartSection("Spindle Load"),
              _buildChartSection("X Temp"),
              _buildChartSection("Y Temp"),
              _buildChartSection("Z Temp"),
              const SizedBox(height: 16),
              const Text("Alarm History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildAlarmTable(context, "Unresolved Alarms"),
              const SizedBox(height: 10),
              _buildAlarmTable(context, "Resolved Alarms"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(String title) {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            child: Center(
              child: Text("$title Chart Placeholder", style: const TextStyle(color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmTable(BuildContext context, String title) {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 10.0,
              columns: const [
                DataColumn(label: Text("Priority")),
                DataColumn(label: Text("Trigger")),
                DataColumn(label: Text("Program")),
                DataColumn(label: Text("Acknowledged")),
                DataColumn(label: Text("Machine")),
                DataColumn(label: Text("Code")),
                DataColumn(label: Text("Summary")),
                DataColumn(label: Text("Details")),
              ],
              rows: List.generate(2, (index) => _buildAlarmRow(context)),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildAlarmRow(BuildContext context) {
    return DataRow(cells: [
      const DataCell(Text("High")),
      const DataCell(Text("2/13/25 9:00:00")),
      const DataCell(Text("Part A")),
      const DataCell(Text("2/13/25 9:10:00")),
      const DataCell(Text("FANUC no 1")),
      const DataCell(Text("PS011")),
      const DataCell(Text("Misaligned Spindle")),
      DataCell(
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Alarm Details"),
                  content: const Text("Details about the alarm..."),
                  actions: [
                    TextButton(
                      child: const Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ]);
  }
}
