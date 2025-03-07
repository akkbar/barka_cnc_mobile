import 'package:flutter/material.dart';
import 'info_widget/machine_chart.dart';
import 'info_widget/resolved_alarm.dart';
import 'info_widget/unresolved_alarm.dart';

class MachineInfoScreen extends StatelessWidget {
  final int machineId;
  final String machineName;

  const MachineInfoScreen({super.key, required this.machineId, required this.machineName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(machineName)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              ChartSection(machineId: machineId),
              const SizedBox(height: 16),
              const Text("Alarm History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              UnresolvedAlarmTable(machineId: machineId),
              const SizedBox(height: 10),
              ResolvedAlarmTable(machineId: machineId),
            ],
          ),
        ),
      ),
    );
  }
}