import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class UnresolvedAlarmTable extends StatefulWidget {
  final int machineId;

  const UnresolvedAlarmTable({super.key, required this.machineId});

  @override
  _UnresolvedAlarmTableState createState() => _UnresolvedAlarmTableState();
}

class _UnresolvedAlarmTableState extends State<UnresolvedAlarmTable> {
  List<AlarmData> alarmDataList = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchAlarmData();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchAlarmData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAlarmData() async {
    try {
      await GetStorage.init(); // Ensure GetStorage is initialized
      final box = GetStorage();
      final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
      print('API URL: $apiUrl/api/unresolved?machineId=${widget.machineId}'); // Log the API URL
      final response = await http.get(Uri.parse('$apiUrl/api/unresolved?machineId=${widget.machineId}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<AlarmData> alarmData = data.map((json) => AlarmData.fromJson(json)).toList();
        setState(() {
          alarmDataList = alarmData;
        });
      } else {
        print('Failed to load 1alarm data: ${response.statusCode}'); // Log the status code
        throw Exception('Failed to load alarm data');
      }
    } catch (e) {
      print('Error fetching alarm data: $e'); // Log the error
      throw Exception('Failed to load alarm data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Unresolved Alarms", style: TextStyle(fontWeight: FontWeight.bold)),
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
              rows: alarmDataList.map((data) => _buildAlarmRow(context, data)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildAlarmRow(BuildContext context, AlarmData data) {
    return DataRow(cells: [
      DataCell(Text(data.priority)),
      DataCell(Text(data.trigger)),
      DataCell(Text(data.program)),
      DataCell(Text(data.acknowledged)),
      DataCell(Text(data.machine)),
      DataCell(Text(data.code)),
      DataCell(Text(data.summary)),
      DataCell(
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Alarm Details"),
                  content: Text(data.details),
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

class AlarmData {
  final String priority;
  final String trigger;
  final String program;
  final String acknowledged;
  final String machine;
  final String code;
  final String summary;
  final String details;

  AlarmData({
    required this.priority,
    required this.trigger,
    required this.program,
    required this.acknowledged,
    required this.machine,
    required this.code,
    required this.summary,
    required this.details,
  });

  factory AlarmData.fromJson(Map<String, dynamic> json) {
    return AlarmData(
      priority: json['priority'],
      trigger: json['trigger'],
      program: json['program'],
      acknowledged: json['acknowledged'],
      machine: json['machine'],
      code: json['code'],
      summary: json['summary'],
      details: json['details'],
    );
  }
}