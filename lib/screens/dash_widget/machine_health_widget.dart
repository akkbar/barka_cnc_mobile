import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineHealthWidget extends StatelessWidget {
  const MachineHealthWidget({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> fetchMachineHealth() async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? '';
    final response = await http.get(Uri.parse('$apiUrl/api/dashMachineHealth'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load machine health data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchMachineHealth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Column(
            children: [
              _buildHealthSummary("New Alarm Summary", [
                _buildInfoBox("High", "X", Colors.red),
                const SizedBox(width: 5),
                _buildInfoBox("Medium", "X", Colors.orange),
                const SizedBox(width: 5),
                _buildInfoBox("Low", "X", Colors.blue),
              ]),
              _buildHealthSummary("Machine Health Summary", [
                _buildInfoBox("Down", "X", Colors.red),
                const SizedBox(width: 5),
                _buildInfoBox("Running", "X", Colors.green),
                const SizedBox(width: 5),
                _buildInfoBox("Idle", "X", Colors.orange),
                const SizedBox(width: 5),
                _buildInfoBox("Setup", "X", Colors.blue),
              ]),
            ],
          );
        } else {
          final data = snapshot.data ?? {};
          final high = data['high']?.toString() ?? '0';
          final medium = data['medium']?.toString() ?? '0';
          final low = data['low']?.toString() ?? '0';
          final down = data['down']?.toString() ?? '0';
          final running = data['running']?.toString() ?? '0';
          final idle = data['idle']?.toString() ?? '0';
          final setup = data['setup']?.toString() ?? '0';

          return Column(
            children: [
              _buildHealthSummary("New Alarm Summary", [
                _buildInfoBox("High", high, Colors.red),
                const SizedBox(width: 5),
                _buildInfoBox("Medium", medium, Colors.orange),
                const SizedBox(width: 5),
                _buildInfoBox("Low", low, Colors.blue),
              ]),
              _buildHealthSummary("Machine Health Summary", [
                _buildInfoBox("Down", down, Colors.red),
                const SizedBox(width: 5),
                _buildInfoBox("Running", running, Colors.green),
                const SizedBox(width: 5),
                _buildInfoBox("Idle", idle, Colors.orange),
                const SizedBox(width: 5),
                _buildInfoBox("Setup", setup, Colors.blue),
              ]),
            ],
          );
        }
      },
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
}