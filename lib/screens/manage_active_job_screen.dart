import 'package:flutter/material.dart';

class ManageActiveJobScreen extends StatelessWidget {
  
  final List<Map<String, dynamic>> workOrders = [
    {'name': 'Part A', 'machine': 'FANUC no 1', 'progress': 33, 'completed': 50, 'remaining': 50, 'status': 'On-time', 'color': Colors.green},
    {'name': 'Part B', 'machine': 'FANUC no 2', 'progress': 25, 'completed': 50, 'remaining': 50, 'status': 'Late', 'color': Colors.red},
    {'name': 'Part C', 'machine': 'FANUC no 3', 'progress': 50, 'completed': 75, 'remaining': 75, 'status': 'On-time', 'color': Colors.green},
    {'name': 'Part D', 'machine': 'FANUC no 4', 'progress': 33, 'completed': 50, 'remaining': 50, 'status': 'At Risk', 'color': Colors.amber},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Active Work Orders')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: workOrders.length,
          itemBuilder: (context, index) {
            final order = workOrders[index];
            return WorkOrderCard(order: order);
          },
        ),
      ),
    );
  }
}

class WorkOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  WorkOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: order['color'],
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                order['name'],
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("Parts Completed", style: TextStyle(fontSize: 10)),
                          Text("${order['completed']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Parts Remaining", style: TextStyle(fontSize: 10)),
                          Text("${order['remaining']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: order['color'],
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                order['status'],
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}