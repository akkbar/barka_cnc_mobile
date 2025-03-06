import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/work_order.dart';

class ActiveJobsTableWidget extends StatelessWidget {
  const ActiveJobsTableWidget({Key? key}) : super(key: key);

  Future<List<Job>> fetchJobs() async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? '';
    final response = await http.get(Uri.parse('$apiUrl/api/dashActiveJobs'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Job.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Job>>(
      future: fetchJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Job> jobs = snapshot.data ?? [];
          return Table(
            border: const TableBorder(
              horizontalInside: BorderSide(width: 1, color: Colors.grey),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(3),
              4: FlexColumnWidth(3),
            },
            children: [
              _buildTableRow(["Status", "Name", "Machine", "Expected", "Actual"], isHeader: true),
              if (jobs.isEmpty)
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        '0 data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                )
              else
                ...jobs.map((job) => _buildTableRow(
                  [job.status, job.name, job.machine, job.expected, job.actual],
                  status: job.statusColor,
                )).toList(),
            ],
          );
        }
      },
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, Color? status}) {
    return TableRow(
      children: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String cell = entry.value;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 13 : 12,
              color: (index == 0 && status != null) ? status : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }
}