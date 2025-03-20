import 'package:flutter/material.dart';
import 'track_performance_screen.dart';
import 'track_quality_screen.dart';
import 'manage_active_job_screen.dart';
import 'view_machine_health_screen.dart';
import 'dash_widget/card_widget.dart';
import 'dash_widget/active_jobs_table.dart';
import 'dash_widget/machine_health_widget.dart';
import 'dash_widget/multiple_line_charts_widget.dart';
import 'dash_widget/multiple_line_charts_quality_widget.dart';

class DashScreen extends StatelessWidget {
  const DashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barka CNC Monitor App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Today\'s Dashboard',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageActiveJobScreen()),
                  );
                },
                child: const CardWidget(
                  title: "Manage Active Work Orders",
                  child: ActiveJobsTableWidget(),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewMachineHealthScreen()),
                  );
                },
                child: const CardWidget(
                  title: "View Machine Health & Alarms",
                  child: MachineHealthWidget(),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackPerformanceScreen()),
                  );
                },
                child: const CardWidget(
                  title: "Track Performance",
                  child: MultipleLineChartsWidget(),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackQualityScreen()),
                  );
                },
                child: const CardWidget(
                  title: "Track Quality",
                  child: MultipleLineChartsQualityWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}