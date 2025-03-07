import 'package:flutter/material.dart';
import 'health_widget/alarm_table.dart';
import 'health_widget/machine_widget.dart';

class ViewMachineHealthScreen extends StatelessWidget {
  const ViewMachineHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Machine Health & Alarms')),
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ListView(
          children: const [
            AlarmTable(),
            SizedBox(height: 10),
            MachineWidget(),
          ],
        ),
      ),
    );
  }
}