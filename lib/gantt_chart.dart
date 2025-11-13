import 'package:flutter/material.dart';

class GanttChart extends StatelessWidget {
  final List<Map<String, dynamic>> result;

  const GanttChart({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final int startTime = result.first['start'];
    final int endTime = result.last['end'];
    final int totalTime = endTime - startTime;

    // Context switches detection
    List<Map<String, dynamic>> switches = [];
    for (int i = 1; i < result.length; i++) {
      if (result[i]['pid'] != result[i - 1]['pid']) {
        switches.add({
          'time': result[i]['start'],
          'from': result[i - 1]['pid'],
          'to': result[i]['pid'],
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time markers
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalTime + 1, (i) {
              return Container(
                width: 20,
                alignment: Alignment.center,
                child: Text('${startTime + i}', style: const TextStyle(fontSize: 10)),
              );
            }),
          ),
        ),

        const SizedBox(height: 4),

        // Process execution row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: result.map((item) {
              final duration = item['end'] - item['start'];
              return Container(
                width: duration * 20.0,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.primaries[item['pid'].hashCode % Colors.primaries.length],
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Text(item['pid'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Context switch row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
                child: switchHere
                    ? const Icon(Icons.swap_horiz, size: 12, color: Colors.white)
                    : null,
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        const Text('🔄 Context switches shown in red',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
