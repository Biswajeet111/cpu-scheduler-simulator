import 'package:flutter/material.dart';
import 'starting_page.dart';

void main() {
  runApp(const CpuSchedulerApp());
}

class CpuSchedulerApp extends StatelessWidget {
  const CpuSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CPU Scheduler Simulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: starting_page(),
    );
  }
}
