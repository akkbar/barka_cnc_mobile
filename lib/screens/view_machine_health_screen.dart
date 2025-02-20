import 'package:flutter/material.dart';
import 'machine_info_screen.dart';

class ViewMachineHealthScreen extends StatelessWidget {
  const ViewMachineHealthScreen({super.key});

  final List<Map<String, dynamic>> alarms = const [
    {'priority': 'High', 'time': '00:00:00', 'machine': 'FANUC no 1', 'description': 'Misaligned Spindle'},
    {'priority': 'Medium', 'time': '00:00:00', 'machine': 'FANUC no 2', 'description': 'Misaligned Spindle'},
    {'priority': 'Low', 'time': '00:00:00', 'machine': 'FANUC no 3', 'description': 'Misaligned Spindle'},
  ];

  final List<Machine> machines = const [
    Machine(number: 1, status: "Running", color: Colors.green, icon: Icons.check),
    Machine(number: 2, status: "Running", color: Colors.green, icon: Icons.check),
    Machine(number: 3, status: "Alarm", color: Colors.red, icon: Icons.warning),
    Machine(number: 4, status: "Offline", color: Colors.red, icon: Icons.warning),
    Machine(number: 5, status: "Setup", color: Colors.amber, icon: Icons.build),
    Machine(number: 6, status: "Running", color: Colors.green, icon: Icons.check),
    Machine(number: 7, status: "Idle", color: Colors.grey, icon: Icons.info),
    Machine(number: 8, status: "Emergency", color: Colors.red, icon: Icons.warning),
    Machine(number: 9, status: "Running", color: Colors.green, icon: Icons.check),
    Machine(number: 10, status: "Running", color: Colors.green, icon: Icons.check),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Machine Health & Alarms')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
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
                      columns: const [
                        DataColumn(label: Text('Priority')),
                        DataColumn(label: Text('Time')),
                        DataColumn(label: Text('Machine')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('')),
                      ],
                      rows: alarms.map((alarm) {
                        return DataRow(cells: [
                          DataCell(Text(alarm['priority'])),
                          DataCell(Text(alarm['time'])),
                          DataCell(Text(alarm['machine'])),
                          DataCell(Text(alarm['description'])),
                          DataCell(ElevatedButton(onPressed: () {}, child: const Text('Acknowledge'))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Machine Health',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5, // Adjust ratio for better spacing
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: machines.length,
                      itemBuilder: (context, index) {
                        return MachineBox(machine: machines[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MachineBox extends StatelessWidget {
  final Machine machine;

  const MachineBox({Key? key, required this.machine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: 
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MachineInfoScreen()),
            );
          },
          child: Column(
            children: [
              // Top section with machine number
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: machine.color,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                ),
                child: Text(
                  "FANUC no ${machine.number}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // Middle section (White background with icon)
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: Icon(machine.icon, color: machine.color, size: 40),
                  ),
                ),
              ),

              // Bottom section with status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: machine.color,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                child: Text(
                  machine.status,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      
      
    );
  }
}

class Machine {
  final int number;
  final String status;
  final Color color;
  final IconData icon;

  const Machine({required this.number, required this.status, required this.color, required this.icon});
}