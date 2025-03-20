import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AlarmTable extends StatefulWidget {
  const AlarmTable({Key? key}) : super(key: key);

  @override
  _AlarmTableState createState() => _AlarmTableState();
}

class _AlarmTableState extends State<AlarmTable> {
  List<ValueNotifier<Map<String, dynamic>>> _alarmNotifiers = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchAlarms();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchAlarms();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var notifier in _alarmNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> fetchAlarms() async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
    final response = await http.get(Uri.parse('$apiUrl/api/alarms'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> alarms = data.map((json) => json as Map<String, dynamic>).toList();
      if (_alarmNotifiers.length != alarms.length) {
        _alarmNotifiers = alarms.map((alarm) => ValueNotifier<Map<String, dynamic>>(alarm)).toList();
      } else {
        for (int i = 0; i < alarms.length; i++) {
          _alarmNotifiers[i].value = alarms[i];
        }
      }
      setState(() {});
    } else {
      throw Exception('Failed to load alarms');
    }
  }

  Future<void> acknowledgeAlarm(int id) async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
    final response = await http.post(
      Uri.parse('$apiUrl/api/acknowledge'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      fetchAlarms();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarm acknowledged successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to acknowledge alarm')),
      );
    }
  }

  Future<void> showAlarmDetails(int id) async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
    final response = await http.get(Uri.parse('$apiUrl/api/alarms/$id'));

    if (response.statusCode == 200) {
      final alarmDetails = json.decode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Alarm Details"),
            content: Text("Details: ${alarmDetails['details']}"),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load alarm details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'New Unacknowledged Alarms',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 7.0, // Adjust the column spacing here
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('Priority')),
                DataColumn(label: Text('Time')),
                DataColumn(label: Text('Machine')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Details'))
              ],
              rows: _alarmNotifiers.map((notifier) {
                return DataRow(cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: notifier.value['id'] > 0
                          ? ElevatedButton(
                              onPressed: () {
                                acknowledgeAlarm(notifier.value['id']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text('ACK'),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  DataCell(Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: notifier,
                      builder: (context, alarm, child) {
                        return Text(alarm['priority']);
                      },
                    ),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: notifier,
                      builder: (context, alarm, child) {
                        return Text(alarm['time']);
                      },
                    ),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: notifier,
                      builder: (context, alarm, child) {
                        return Text(alarm['machine']);
                      },
                    ),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: notifier,
                      builder: (context, alarm, child) {
                        return Text(alarm['description']);
                      },
                    ),
                  )),
                  DataCell(Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: notifier.value['id'] > 0
                          ? IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        showAlarmDetails(notifier.value['id']);
                      },
                    ) : const SizedBox.shrink(),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}