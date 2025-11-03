import 'package:flutter/material.dart';

class GanttChart extends StatelessWidget {
  final List<Map<String, dynamic>> result;

  const GanttChart({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: result.map((item) {
        final burst = item['end'] - item['start'];
        return Container(
          width: burst * 10.0,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.primaries[item['pid'].hashCode % Colors.primaries.length],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(item['pid'], style: TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }
}