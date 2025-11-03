import 'package:flutter/material.dart';
import 'scheduler_home.dart';

void main() {
  runApp(CpuSchedulerApp());
}

class CpuSchedulerApp extends StatelessWidget {
  const CpuSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPU Scheduler Simulator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SchedulerHome(),
    );
  }
}