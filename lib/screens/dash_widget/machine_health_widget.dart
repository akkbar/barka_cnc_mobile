import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class MachineHealthWidget extends StatefulWidget {
  const MachineHealthWidget({Key? key}) : super(key: key);

  @override
  _MachineHealthWidgetState createState() => _MachineHealthWidgetState();
}

class _MachineHealthWidgetState extends State<MachineHealthWidget> {
  late Timer _timer;
  final ValueNotifier<String> highNotifier = ValueNotifier<String>('...');
  final ValueNotifier<String> mediumNotifier = ValueNotifier<String>('...');
  final ValueNotifier<String> lowNotifier = ValueNotifier<String>('...');
  final ValueNotifier<String> downNotifier = ValueNotifier<String>('...');
  final ValueNotifier<String> runningNotifier = ValueNotifier<String>('...');
  final ValueNotifier<String> idleNotifier = ValueNotifier<String>('...');
  final ValueNotifier<String> setupNotifier = ValueNotifier<String>('...');

  @override
  void initState() {
    super.initState();
    fetchMachineHealth();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchMachineHealth();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    highNotifier.dispose();
    mediumNotifier.dispose();
    lowNotifier.dispose();
    downNotifier.dispose();
    runningNotifier.dispose();
    idleNotifier.dispose();
    setupNotifier.dispose();
    super.dispose();
  }

  Future<void> fetchMachineHealth() async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
    final response = await http.get(Uri.parse('$apiUrl/api/dashMachineHealth'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      highNotifier.value = data['high']?.toString() ?? '0';
      mediumNotifier.value = data['medium']?.toString() ?? '0';
      lowNotifier.value = data['low']?.toString() ?? '0';
      downNotifier.value = data['down']?.toString() ?? '0';
      runningNotifier.value = data['running']?.toString() ?? '0';
      idleNotifier.value = data['idle']?.toString() ?? '0';
      setupNotifier.value = data['setup']?.toString() ?? '0';
    } else {
      highNotifier.value = 'X';
      mediumNotifier.value = 'X';
      lowNotifier.value = 'X';
      downNotifier.value = 'X';
      runningNotifier.value = 'X';
      idleNotifier.value = 'X';
      setupNotifier.value = 'X';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHealthSummary("New Alarm Summary", [
          _buildInfoBox("High", highNotifier, Colors.red),
          const SizedBox(width: 5),
          _buildInfoBox("Medium", mediumNotifier, Colors.orange),
          const SizedBox(width: 5),
          _buildInfoBox("Low", lowNotifier, Colors.blue),
        ]),
        _buildHealthSummary("Machine Health Summary", [
          _buildInfoBox("Down", downNotifier, Colors.red),
          const SizedBox(width: 5),
          _buildInfoBox("Running", runningNotifier, Colors.green),
          const SizedBox(width: 5),
          _buildInfoBox("Idle", idleNotifier, Colors.orange),
          const SizedBox(width: 5),
          _buildInfoBox("Setup", setupNotifier, Colors.blue),
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

  Widget _buildInfoBox(String label, ValueNotifier<String> notifier, Color color) {
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
            ValueListenableBuilder<String>(
              valueListenable: notifier,
              builder: (context, value, child) {
                return Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
              },
            ),
          ],
        ),
      ),
    );
  }
}