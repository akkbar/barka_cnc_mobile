import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'machine_info_screen.dart';

class MachineWidget extends StatefulWidget {
  const MachineWidget({Key? key}) : super(key: key);

  @override
  _MachineWidgetState createState() => _MachineWidgetState();
}

class _MachineWidgetState extends State<MachineWidget> {
  List<ValueNotifier<Machine>> _machineNotifiers = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchMachines();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchMachines();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var notifier in _machineNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> fetchMachines() async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
    final response = await http.get(Uri.parse('$apiUrl/api/machines'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Machine> machines = data.map((json) => Machine.fromJson(json)).toList();
      if (_machineNotifiers.length != machines.length) {
        _machineNotifiers = machines.map((machine) => ValueNotifier<Machine>(machine)).toList();
      } else {
        for (int i = 0; i < machines.length; i++) {
          _machineNotifiers[i].value = machines[i];
        }
      }
      setState(() {});
    } else {
      throw Exception('Failed to load machines');
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
              'Machine Health',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.5, // Adjust ratio for better spacing
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _machineNotifiers.length,
              itemBuilder: (context, index) {
                return MachineBox(machineNotifier: _machineNotifiers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MachineBox extends StatelessWidget {
  final ValueNotifier<Machine> machineNotifier;

  const MachineBox({Key? key, required this.machineNotifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Machine>(
      valueListenable: machineNotifier,
      builder: (context, machine, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MachineInfoScreen(machineId: machine.id, machineName: machine.name)),
              );
            },
            child: Column(
              children: [
                // Top section with machine number
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(int.parse(machine.color.substring(1, 7), radix: 16) + 0xFF000000),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        machine.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),

                // Middle section (White background with icon)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Center(
                      child: machine.status == "Running"
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Left big column
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Aligns vertically (if inside an Expanded)
                                    crossAxisAlignment: CrossAxisAlignment.center, // Aligns horizontally
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center, // Aligns vertically (if inside an Expanded)
                                            crossAxisAlignment: CrossAxisAlignment.center, // Aligns horizontally
                                            children: [
                                              const Text(
                                                "Spindle Load",
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              ),
                                              Text(machine.spindleLoad, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              const Text(
                                                "Spindle Speed",
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              ),
                                              Text(machine.spindleSpeed, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 50),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Aligns vertically (if inside an Expanded)
                                    crossAxisAlignment: CrossAxisAlignment.center, // Aligns horizontally
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "X",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          Text(machine.x, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Y",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          Text(machine.y, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Z",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          Text(machine.z, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "B",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          Text(machine.b, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Icon(_getIconData(machine.icon), color: Color(int.parse(machine.color.substring(1, 7), radix: 16) + 0xFF000000), size: 40),
                    ),
                  ),
                ),

                // Bottom section with status and ">" icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(int.parse(machine.color.substring(1, 7), radix: 16) + 0xFF000000),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        machine.status,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'check':
      return Icons.check;
    case 'warning':
      return Icons.warning;
    case 'build':
      return Icons.build;
    case 'info':
      return Icons.info;
    // Add more cases as needed
    default:
      return Icons.help;
  }
}

class Machine {
  final int id;
  final String name;
  final String status;
  final String color;
  final String icon;
  final String spindleLoad;
  final String spindleSpeed;
  final String x;
  final String y;
  final String z;
  final String b;

  const Machine({
    required this.id,
    required this.name,
    required this.status,
    required this.color,
    required this.icon,
    required this.spindleLoad,
    required this.spindleSpeed,
    required this.x,
    required this.y,
    required this.z,
    required this.b,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      color: json['color'],
      icon: json['icon'],
      spindleLoad: json['spindleLoad'],
      spindleSpeed: json['spindleSpeed'],
      x: json['x'],
      y: json['y'],
      z: json['z'],
      b: json['b'],
    );
  }
}