import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ManageActiveJobScreen extends StatefulWidget {
  const ManageActiveJobScreen({Key? key}) : super(key: key);

  @override
  _ManageActiveJobScreenState createState() => _ManageActiveJobScreenState();
}

class _ManageActiveJobScreenState extends State<ManageActiveJobScreen> {
  List<ValueNotifier<Map<String, dynamic>>> _workOrderNotifiers = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchWorkOrders();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchWorkOrders();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var notifier in _workOrderNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> fetchWorkOrders() async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? 'http://localhost:3000';
    final response = await http.get(Uri.parse('$apiUrl/api/workOrders'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> workOrders = data.map((json) => json as Map<String, dynamic>).toList();
      if (_workOrderNotifiers.length != workOrders.length) {
        _workOrderNotifiers = workOrders.map((order) => ValueNotifier<Map<String, dynamic>>(order)).toList();
      } else {
        for (int i = 0; i < workOrders.length; i++) {
          _workOrderNotifiers[i].value = workOrders[i];
        }
      }
      setState(() {});
    } else {
      throw Exception('Failed to load work orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Work Orders')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _workOrderNotifiers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _workOrderNotifiers.length,
                itemBuilder: (context, index) {
                  return WorkOrderCard(orderNotifier: _workOrderNotifiers[index]);
                },
              ),
      ),
    );
  }
}

class WorkOrderCard extends StatelessWidget {
  final ValueNotifier<Map<String, dynamic>> orderNotifier;

  WorkOrderCard({required this.orderNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: orderNotifier,
      builder: (context, order, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(int.parse(order['color'].substring(1, 7), radix: 16) + 0xFF000000),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    order['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${order['machine']}"),
                      Text(
                        "${order['progress']}%",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("Parts Completed", style: TextStyle(fontSize: 10)),
                              Text("${order['completed']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Parts Remaining", style: TextStyle(fontSize: 10)),
                              Text("${order['remaining']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(int.parse(order['color'].substring(1, 7), radix: 16) + 0xFF000000),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    order['status'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}