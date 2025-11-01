import 'package:flutter/material.dart';
import 'scheduler_algorithm.dart';
import 'gantt_chart_widget.dart';
import 'dart:io';
import 'dart:convert';

class SchedulerHome extends StatefulWidget {
  const SchedulerHome({super.key});

  @override
  _SchedulerHomeState createState() => _SchedulerHomeState();
}

class _SchedulerHomeState extends State<SchedulerHome> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> pidControllers = [];
  final List<TextEditingController> arrivalControllers = [];
  final List<TextEditingController> burstControllers = [];
  final List<TextEditingController> priorityControllers = [];

  String selectedAlgorithm = 'FCFS';
  String output = '';
  List<Map<String, dynamic>> result = [];
  List<Map<String, dynamic>> inputData = [];

  void simulate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    inputData.clear();
    for (int i = 0; i < pidControllers.length; i++) {
      final pid = pidControllers[i].text;
      final arrival = int.tryParse(arrivalControllers[i].text) ?? 0;
      final burst = int.tryParse(burstControllers[i].text) ?? 0;
      final priority = int.tryParse(priorityControllers[i].text) ?? 0;
      inputData.add({
        'pid': pid,
        'arrival': arrival,
        'burst': burst,
        'priority': priority,
      });
    }

    result.clear();
    switch (selectedAlgorithm) {
      case 'FCFS':
        result = fcfs(inputData);
        break;
      case 'SJF':
        result = sjf(inputData);
        break;
      case 'RR':
        result = rr(inputData, 2);
        break;
      case 'Priority':
        result = priorityScheduling(inputData);
        break;
    }

    double totalWaiting = 0;
    double totalTurnaround = 0;

    for (var item in result) {
     final arrival = inputData.firstWhere((p) => p['pid'] == item['pid'],orElse: () => {'arrival': 0}, )['arrival'] as int;
      final waiting = item['start'] - arrival;
      final turnaround = item['end'] - arrival;
      totalWaiting += waiting;
      totalTurnaround += turnaround;
    }

    final avgWaiting = (totalWaiting / result.length).toStringAsFixed(2);
    final avgTurnaround = (totalTurnaround / result.length).toStringAsFixed(2);

    setState(() {
      output = '';
      output += 'Average Waiting Time: $avgWaiting\n';
      output += 'Average Turnaround Time: $avgTurnaround';
    });
  }
  void saveProcessList() async {
  List<Map<String, dynamic>> data = [];
  for (int i = 0; i < pidControllers.length; i++) {
    data.add({
      'pid': pidControllers[i].text,
      'arrival': arrivalControllers[i].text,
      'burst': burstControllers[i].text,
      'priority': priorityControllers[i].text,
    });
  }

  final file = File('process_list.json');
  await file.writeAsString(jsonEncode(data));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Process list saved!')),
  );
}

void loadProcessList() async {
  final file = File('process_list.json');
  if (!await file.exists()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No saved process list found.')),
    );
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> data = jsonDecode(content);

  for (int i = 0; i < data.length && i < 5; i++) {
    pidControllers[i].text = data[i]['pid'] ?? '';
    arrivalControllers[i].text = data[i]['arrival'] ?? '';
    burstControllers[i].text = data[i]['burst'] ?? '';
    priorityControllers[i].text = data[i]['priority'] ?? '';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Process list loaded!')),
  );
}

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      pidControllers.add(TextEditingController());
      arrivalControllers.add(TextEditingController());
      burstControllers.add(TextEditingController());
      priorityControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var c in [...pidControllers, ...arrivalControllers, ...burstControllers, ...priorityControllers]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CPU Scheduler Simulator')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedAlgorithm,
              items: ['FCFS', 'SJF', 'RR', 'Priority']
                  .map((algo) => DropdownMenuItem(value: algo, child: Text(algo)))
                  .toList(),
              onChanged: (value) => setState(() => selectedAlgorithm = value!),
            ),
            SizedBox(height: 20),
            Text('Enter Process Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  for (int i = 0; i < 5; i++)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: pidControllers[i],
                            decoration: InputDecoration(labelText: 'PID'),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: arrivalControllers[i],
                            decoration: InputDecoration(labelText: 'Arrival'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              final num = int.tryParse(value);
                              if (num == null || num < 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: burstControllers[i],
                            decoration: InputDecoration(labelText: 'Burst'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              final num = int.tryParse(value);
                              if (num == null || num <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: priorityControllers[i],
                            decoration: InputDecoration(labelText: 'Priority'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              final num = int.tryParse(value);
                              if (num == null || num < 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
  children: [
    ElevatedButton(
      onPressed: simulate,
      child: Text('Simulate'),
    ),
    SizedBox(width: 10),
    ElevatedButton(
      onPressed: saveProcessList,
      child: Text('Save Process List'),
    ),
    SizedBox(width: 10),
    ElevatedButton(
      onPressed: loadProcessList,
      child: Text('Load Process List'),
    ),
  ],
),
            
            SizedBox(height: 20),
            if (result.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('PID')),
                    DataColumn(label: Text('Start')),
                    DataColumn(label: Text('End')),
                    DataColumn(label: Text('Waiting')),
                    DataColumn(label: Text('Turnaround')),
                  ],
                  rows: result.map((item) {
                    final arrival = inputData.firstWhere((p) => p['pid'] == item['pid'],orElse: () => {'arrival': 0},)['arrival'] as int;
                    final waiting = item['start'] - arrival;
                    final turnaround = item['end'] - arrival;
                    return DataRow(cells: [
                      DataCell(Text(item['pid'])),
                      DataCell(Text('${item['start']}')),
                      DataCell(Text('${item['end']}')),
                      DataCell(Text('$waiting')),
                      DataCell(Text('$turnaround')),
                    ]);
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text(output, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              GanttChart(result: result),
            ]
          ],
        ),
      ),
    );
  }
}