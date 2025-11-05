import 'package:flutter/material.dart';

class GanttChart extends StatelessWidget {
  final List<Map<String, dynamic>> result;

  const GanttChart({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Build timeline from start to end
    final int startTime = result.first['start'];
    final int endTime = result.last['end'];
    final int totalTime = endTime - startTime;

    // Detect context switches
    List<Map<String, dynamic>> switches = [];
    for (int i = 1; i < result.length; i++) {
      if (result[i]['pid'] != result[i - 1]['pid']) {
        switches.add({'time': result[i]['start'], 'from': result[i - 1]['pid'], 'to': result[i]['pid']});
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time markers
        Row(
          children: List.generate(totalTime + 1, (i) {
            return Container(
              width: 20,
              alignment: Alignment.center,
              child: Text('${startTime + i}', style: TextStyle(fontSize: 10)),
            );
          }),
        ),

        SizedBox(height: 4),

        // Process execution row
        Row(
          children: result.map((item) {
            final duration = item['end'] - item['start'];
            return Container(
              width: duration * 20.0,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.primaries[item['pid'].hashCode % Colors.primaries.length],
                border: Border.all(color: Colors.black),
              ),
              child: Text(item['pid'], style: TextStyle(color: Colors.white)),
            );
          }).toList(),
        ),

        SizedBox(height: 8),

        // Context switch row
        Row(
          children: List.generate(totalTime, (i) {
            final currentTime = startTime + i;
            final switchHere = switches.any((s) => s['time'] == currentTime);
            return Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: switchHere ? Colors.redAccent : Colors.transparent,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: switchHere ? Icon(Icons.swap_horiz, size: 12, color: Colors.white) : null,
            );
          }),
        ),
        Text('🔄 Context switches shown in red'),
      ],
    );
  }
}