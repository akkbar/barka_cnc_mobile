import 'package:flutter/material.dart';

class Job {
  final String status;
  final String name;
  final String machine;
  final String expected;
  final String actual;
  final Color statusColor;

  Job({
    required this.status,
    required this.name,
    required this.machine,
    required this.expected,
    required this.actual,
    required this.statusColor,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      status: json['status'],
      name: json['name'],
      machine: json['machine'],
      expected: json['expected'],
      actual: json['actual'],
      statusColor: json['status'] == 'On-Time' ? Colors.green : Colors.red,
    );
  }
}