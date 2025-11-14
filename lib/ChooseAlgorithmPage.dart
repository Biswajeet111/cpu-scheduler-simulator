// ignore_for_file: file_names, unnecessary_underscores

import 'package:flutter/material.dart';
import 'info_page.dart';

class ChooseAlgorithmPage extends StatefulWidget {
  const ChooseAlgorithmPage({super.key});

  @override
  State<ChooseAlgorithmPage> createState() => _ChooseAlgorithmPageState();
}

class _ChooseAlgorithmPageState extends State<ChooseAlgorithmPage> {
  static const Color primaryBlue = Color(0xFF0A63C9);
  static const Color bgLight = Color(0xFFF3F6FB);

  // Full + short names
  final List<Map<String, String>> _algos = [
    {'short': 'FCFS', 'full': 'First Come First Serve'},
    {'short': 'SJF',  'full': 'Shortest Job First'},
    {'short': 'RR',   'full': 'Round Robin'},
    {'short': 'PS',   'full': 'Priority Scheduling'},
    {'short': 'SRTF', 'full': 'Shortest Remaining Time First'},
    {'short': 'MLQ',  'full': 'Multi-Level Queue Scheduling'},
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Select Algorithm',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        itemCount: _algos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final algo = _algos[i];
          final sel = _selectedIndex == i;
          final label = '${algo['full']!} (${algo['short']!})';

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() => _selectedIndex = i);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InfoPage(
                    algoName: algo['short']!,
                    fullName: algo['full']!,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryBlue, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: primaryBlue),
                    ),
                  ),
                  _RadioCircle(selected: sel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0A63C9);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryBlue, width: 2),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: selected ? 14 : 0,
        height: selected ? 14 : 0,
        decoration: const BoxDecoration(
          color: primaryBlue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
