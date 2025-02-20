import 'package:flutter/material.dart';

class MachineInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FANUC no 1")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              _buildChartSection("Data 1"),
              _buildChartSection("Data 2"),
              _buildChartSection("Data 3"),
              SizedBox(height: 10),
              Text("Alarm History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildAlarmTable("Unresolved Alarms"),
              SizedBox(height: 10),
              _buildAlarmTable("Resolved Alarms"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(String title) {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            child: Center(
              child: Text("$title Chart Placeholder", style: TextStyle(color: Colors.grey)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmTable(String title) {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text("Priority")),
                DataColumn(label: Text("Trigger")),
                DataColumn(label: Text(title == "Unresolved Alarms" ? "Acknowledged" : "Resolved")),
                DataColumn(label: Text("Machine")),
                DataColumn(label: Text("Code")),
                DataColumn(label: Text("Summary")),
                DataColumn(label: Text("Details")),
              ],
              rows: List.generate(2, (index) => _buildAlarmRow()),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildAlarmRow() {
    return DataRow(cells: [
      DataCell(Text("High")),
      DataCell(Text("2/13/25 9:00:00")),
      DataCell(Text("2/13/25 9:10:00")),
      DataCell(Text("FANUC no 1")),
      DataCell(Text("PS011")),
      DataCell(Text("Misaligned Spindle")),
      DataCell(IconButton(icon: Icon(Icons.arrow_forward), onPressed: () {})),
    ]);
  }
}
