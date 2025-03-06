import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '/models/work_order.dart';

class ActiveJobsTableWidget extends StatefulWidget {
  const ActiveJobsTableWidget({Key? key}) : super(key: key);

  @override
  _ActiveJobsTableWidgetState createState() => _ActiveJobsTableWidgetState();
}

class _ActiveJobsTableWidgetState extends State<ActiveJobsTableWidget> {
  List<ValueNotifier<Job>> _jobNotifiers = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchJobs();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchJobs();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var notifier in _jobNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> fetchJobs() async {
    final box = GetStorage();
    final apiUrl = box.read('apiUrl') ?? '';
    final response = await http.get(Uri.parse('$apiUrl/api/dashActiveJobs'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Job> jobs = data.map((json) => Job.fromJson(json)).toList();
      if (_jobNotifiers.length != jobs.length) {
        _jobNotifiers = jobs.map((job) => ValueNotifier<Job>(job)).toList();
      } else {
        for (int i = 0; i < jobs.length; i++) {
          _jobNotifiers[i].value = jobs[i];
        }
      }
      setState(() {});
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _jobNotifiers.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Table(
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
              if (_jobNotifiers.isEmpty)
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
                ..._jobNotifiers.map((notifier) => _buildJobRow(notifier)).toList(),
            ],
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

  TableRow _buildJobRow(ValueNotifier<Job> jobNotifier) {
    return TableRow(
      children: [
        _buildJobCell(jobNotifier, (job) => job.status, jobNotifier.value.statusColor),
        _buildJobCell(jobNotifier, (job) => job.name),
        _buildJobCell(jobNotifier, (job) => job.machine),
        _buildJobCell(jobNotifier, (job) => job.expected),
        _buildJobCell(jobNotifier, (job) => job.actual),
      ],
    );
  }

  Widget _buildJobCell(ValueNotifier<Job> jobNotifier, String Function(Job) getValue, [Color? color]) {
    return ValueListenableBuilder<Job>(
      valueListenable: jobNotifier,
      builder: (context, job, child) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            getValue(job),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.black,
            ),
          ),
        );
      },
    );
  }
}