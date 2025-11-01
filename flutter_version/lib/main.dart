import 'package:flutter/material.dart';

void main() {
  runApp(CpuSchedulerApp());
}

class CpuSchedulerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPU Scheduler Simulator',
      home: SchedulerHome(),
    );
  }
}

class SchedulerHome extends StatefulWidget {
  @override
  _SchedulerHomeState createState() => _SchedulerHomeState();
}

class _SchedulerHomeState extends State<SchedulerHome> {
  String selectedAlgorithm = 'FCFS';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CPU Scheduler Simulator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedAlgorithm,
              items: ['FCFS', 'SJF', 'RR', 'Priority']
                  .map((algo) => DropdownMenuItem(
                        value: algo,
                        child: Text(algo),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedAlgorithm = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate logic here
              },
              child: Text('Simulate'),
            ),
          ],
        ),
      ),
    );
  }
}