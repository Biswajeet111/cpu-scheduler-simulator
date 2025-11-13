// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';

/// ---------- DATA passed from ProcessFormPage ----------
class ResultRow {
  final String pid;
  final int arrival;
  final int burst;
  const ResultRow({required this.pid, required this.arrival, required this.burst});
}

class GanttSegment {
  final String pid;
  final int start; // inclusive
  final int end;   // exclusive
  final Color? color;
  const GanttSegment({
    required this.pid,
    required this.start,
    required this.end,
    this.color,
  });
}

/// ---------- RESULTS PAGE ----------
class ResultsPage extends StatelessWidget {
  const ResultsPage({
    super.key,
    required this.algoName,
    required this.rows,
    required this.avgWaiting,
    required this.avgTurnaround,
    required this.timeline,
  });

  final String algoName;
  final List<ResultRow> rows;
  final double avgWaiting;
  final double avgTurnaround;
  final List<GanttSegment> timeline;

  static const Color primaryBlue = Color(0xFF0A63C9);
  static const Color bgLight = Color(0xFFF3F6FB);

  @override
  Widget build(BuildContext context) {
    // Per-process WT/TAT (from timeline)
    final perProc = _computePerProcessMetrics(rows, timeline);
    final ganttData = timeline
        .map((g) => {'pid': g.pid, 'start': g.start, 'end': g.end})
        .toList();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('RESULTS', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review the Gantt chart and detailed process metrics below.',
                style: TextStyle(
                  color: primaryBlue, fontSize: 22, fontWeight: FontWeight.w600, height: 1.35),
              ),
              const SizedBox(height: 16),

              // Algorithm chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      algoName.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                ]),
              ),
              const SizedBox(height: 20),

              // -------- First & Only Table: PID / AT / BT / WT / TAT --------
              Row(
                children: const [
                  _Header('PID'),
                  _Header('Arrival Time'),
                  _Header('Burst Time'),
                  _Header('Waiting Time'),
                  _Header('Turnaround Time'),
                ],
              ),
              const SizedBox(height: 6),

              _ResultGrid(rows: rows, perProc: perProc),

              const SizedBox(height: 22),

              // Averages
              Center(
                child: Column(
                  children: [
                    Text(
                      'Average Waiting Time: ${avgWaiting.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: primaryBlue, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Average Turnaround Time: ${avgTurnaround.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: primaryBlue, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (timeline.isNotEmpty) ...[
                const Text(
                  "📊 Gantt Chart",
                  style: TextStyle(
                    color: primaryBlue, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 10),
                _PrettyGanttChart(result: ganttData), // new design
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build WT/TAT per PID using the end of the last segment for that PID.
  List<_PerProc> _computePerProcessMetrics(List<ResultRow> rows, List<GanttSegment> segs) {
    final finish = <String, int>{};
    for (final s in segs) {
      if (s.pid == 'IDLE') continue;
      final prev = finish[s.pid];
      if (prev == null || s.end > prev) finish[s.pid] = s.end;
    }

    final list = <_PerProc>[];
    for (final r in rows) {
      final c = finish[r.pid] ?? 0;
      final tat = c - r.arrival;
      final wt = tat - r.burst;
      list.add(_PerProc(pid: r.pid, wt: wt, tat: tat));
    }
    return list;
  }
}

/// ---------- Table Header ----------
class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  static const Color primaryBlue = Color(0xFF0A63C9);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Text(
      text,
      style: const TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );
}

/// ---------- Table (PID/AT/BT/WT/TAT) ----------
class _ResultGrid extends StatelessWidget {
  const _ResultGrid({required this.rows, required this.perProc});
  final List<ResultRow> rows;
  final List<_PerProc> perProc;

  static const Color primaryBlue = Color(0xFF0A63C9);

  @override
  Widget build(BuildContext context) {
    final map = {for (final m in perProc) m.pid: m};

    final list = rows.isEmpty
        ? List<ResultRow>.filled(5, const ResultRow(pid: '', arrival: 0, burst: 0))
        : rows;

    return Column(
      children: List.generate(list.length, (i) {
        final r = list[i];
        final m = map[r.pid];
        final isLast = i == list.length - 1;

        return Column(
          children: [
            Container(
              height: 44,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: primaryBlue, width: 1.2)),
              ),
              child: Row(
                children: [
                  Expanded(child: _cell(r.pid)),
                  Expanded(child: _cell('${r.arrival}')),
                  Expanded(child: _cell('${r.burst}')),
                  Expanded(child: _cell(m == null ? '' : '${m.wt}')),
                  Expanded(child: _cell(m == null ? '' : '${m.tat}')),
                ],
              ),
            ),
            if (isLast)
              const Divider(height: 1.2, thickness: 1.2, color: primaryBlue),
          ],
        );
      }),
    );
  }

  Widget _cell(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF0A63C9),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _PerProc {
  final String pid;
  final int wt;
  final int tat;
  const _PerProc({required this.pid, required this.wt, required this.tat});
}

/// ---------- Pretty Gantt Chart (single row) ----------
class _PrettyGanttChart extends StatelessWidget {
  const _PrettyGanttChart({
    required this.result,
    this.unitWidth = 32,
    this.barHeight = 30,
    this.showSwitchMarkers = true,
  });

  final List<Map<String, dynamic>> result; // [{pid,start,end}]
  final double unitWidth;
  final double barHeight;
  final bool showSwitchMarkers;

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty) return const SizedBox.shrink();

    final data = [...result]..sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));
    final start = data.first['start'] as int;
    final end = data.last['end'] as int;
    final total = (end - start).clamp(1, 1 << 30);

    // context switch times
    final switches = <int>[];
    for (int i = 1; i < data.length; i++) {
      if (data[i]['pid'] != data[i - 1]['pid']) {
        switches.add(data[i]['start'] as int);
      }
    }

    final chartWidth = unitWidth * total;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GRID lines
          SizedBox(
            width: chartWidth,
            height: 8,
            child: _GridLineRow(start: start, end: end, unitWidth: unitWidth),
          ),
          const SizedBox(height: 2),

          // Gantt bars row (rounded gradient)
          SizedBox(
            width: chartWidth,
            height: barHeight,
            child: Stack(
              children: [
                for (final seg in data)
                  Positioned(
                    left: (seg['start'] - start) * unitWidth,
                    top: 0,
                    child: _CapsuleBar(
                      width: (seg['end'] - seg['start']) * unitWidth,
                      height: barHeight,
                      label: seg['pid'] as String,
                      color: _baseColor(seg['pid'] as String),
                    ),
                  ),

                // Context switch markers as red thin lines + dots
                if (showSwitchMarkers)
                  for (final t in switches)
                    Positioned(
                      left: (t - start) * unitWidth - 0.5,
                      top: 0,
                      child: Column(
                        children: [
                          Container(width: 1.5, height: barHeight, color: Colors.redAccent),
                          const SizedBox(height: 3),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(
                            color: Colors.redAccent, shape: BoxShape.circle)),
                        ],
                      ),
                    ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Time labels grey band
          _BottomBand(start: start, end: end, unitWidth: unitWidth),
        ],
      ),
    );
  }

  static Color _baseColor(String pid) {
    const palette = <Color>[
      Color(0xFF1E88E5), // blue
      Color(0xFF43A047), // green
      Color(0xFFFB8C00), // orange
      Color(0xFF8E24AA), // purple
      Color(0xFFE53935), // red
      Color(0xFF00897B), // teal
      Color(0xFF6D4C41), // brown
      Color(0xFF3949AB), // indigo
    ];
    return palette[pid.hashCode.abs() % palette.length];
  }
}

class _GridLineRow extends StatelessWidget {
  const _GridLineRow({required this.start, required this.end, required this.unitWidth});
  final int start;
  final int end;
  final double unitWidth;

  @override
  Widget build(BuildContext context) {
    final ticks = end - start;
    return Row(
      children: List.generate(ticks, (i) {
        final isMajor = (i + start) % 5 == 0;
        return Container(
          width: unitWidth,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey.withOpacity(isMajor ? 0.45 : 0.22),
                width: isMajor ? 1.2 : 0.8,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CapsuleBar extends StatelessWidget {
  const _CapsuleBar({
    required this.width,
    required this.height,
    required this.label,
    required this.color,
  });

  final double width;
  final double height;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        HSLColor.fromColor(color).withLightness(0.65).toColor(),
        HSLColor.fromColor(color).withLightness(0.50).toColor(),
        HSLColor.fromColor(color).withLightness(0.40).toColor(),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BottomBand extends StatelessWidget {
  const _BottomBand({required this.start, required this.end, required this.unitWidth});
  final int start;
  final int end;
  final double unitWidth;

  @override
  Widget build(BuildContext context) {
    final ticks = end - start + 1;
    return SizedBox(
      height: 26,
      child: Row(
        children: List.generate(ticks, (i) {
          final v = start + i;
          return Container(
            width: unitWidth,
            color: Colors.grey.shade700,
            alignment: Alignment.center,
            child: Text(
              '$v',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          );
        }),
      ),
    );
  }
}
