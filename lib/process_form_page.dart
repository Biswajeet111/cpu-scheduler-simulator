// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'results_page.dart'; // Results UI (already added)

class ProcessFormPage extends StatefulWidget {
  const ProcessFormPage({
    super.key,
    required this.algoName,
    required this.processCount,
  });

  final String algoName; // 'FCFS', 'SJF', 'RR', 'PS'
  final int processCount;

  @override
  State<ProcessFormPage> createState() => _ProcessFormPageState();
}

class _ProcessFormPageState extends State<ProcessFormPage> {
  static const Color primaryBlue = Color(0xFF0A63C9);
  static const Color bgLight = Color(0xFFF3F6FB);

  static const Map<String, String> _algoFullNames = {
    'FCFS': 'First Come First Serve',
    'SJF': 'Shortest Job First',
    'RR': 'Round Robin',
    'PS': 'Priority Scheduling',
    'SRTF': 'Shortest Remaining Time First',
    'MLQ': 'Multi-Level Queue Scheduling',
  };

  late final List<TextEditingController> pidCtrls;
  late final List<TextEditingController> atCtrls;
  late final List<TextEditingController> btCtrls;
  late final List<TextEditingController>? prCtrls; // only for PS
  final TextEditingController _quantumCtrl = TextEditingController(); // only for RR

  bool get isPriority => () {
    final a = widget.algoName.toUpperCase();
    return a == 'PS' || a == 'MLQ';
  }();
  bool get isRR => widget.algoName.toUpperCase() == 'RR';

  @override
  void initState() {
    super.initState();
    pidCtrls = List.generate(widget.processCount, (i) => TextEditingController(text: 'P${i + 1}'));
    atCtrls  = List.generate(widget.processCount, (i) => TextEditingController());
    btCtrls  = List.generate(widget.processCount, (i) => TextEditingController());
    prCtrls  = isPriority ? List.generate(widget.processCount, (i) => TextEditingController()) : null;
  }

  @override
  void dispose() {
    for (final c in [...pidCtrls, ...atCtrls, ...btCtrls, if (prCtrls != null) ...prCtrls!]) {
      c.dispose();
    }
    _quantumCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final short = widget.algoName.toUpperCase();
    final algo = '${_algoFullNames[short] ?? short} ($short)';

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: Text(algo, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Enter the process details\nbelow to start the simulation.',
              style: TextStyle(color: primaryBlue, fontSize: 22, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 20),

            // Algo chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Expanded(
                  child: Text(algo,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              ]),
            ),

            if (isRR) ...[
              const SizedBox(height: 16),
              const Text('Time Quantum', style: TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _blueInput(_quantumCtrl, hint: 'e.g. 2'),
            ],

            const SizedBox(height: 18),

            // Headers
            Row(
              children: [
                _header('PID'),
                _header('Arrival Time'),
                _header('Burst Time'),
                if (isPriority) _header('Priority'),
              ],
            ),
            const SizedBox(height: 8),

            // Columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _blueColumn(pidCtrls, hint: 'P1', isNumber: false)),
                const SizedBox(width: 12),
                Expanded(child: _blueColumn(atCtrls, hint: '0')),
                const SizedBox(width: 12),
                Expanded(child: _blueColumn(btCtrls, hint: '5')),
                if (isPriority) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _blueColumn(prCtrls!, hint: '1')), // lower number = higher priority
                ]
              ],
            ),

            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _onSubmit,
                child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _header(String text) => Expanded(
        child: Text(text,
            style: const TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.w700)),
      );

  Widget _blueInput(TextEditingController c, {String? hint, bool isNumber = true}) {
    return Container(
      decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _blueColumn(List<TextEditingController> ctrls, {String? hint, bool isNumber = true}) {
    return Column(
      children: List.generate(ctrls.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: ctrls[i],
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ===================  SUBMIT: parse -> compute -> navigate  ===================

  void _onSubmit() {
    final algo = widget.algoName.toUpperCase();
    final n = widget.processCount;

    // Parse & validate
    final ids = <String>[];
    final at  = <int>[];
    final bt  = <int>[];
    final pr  = <int>[];

    for (int i = 0; i < n; i++) {
      final id = (pidCtrls[i].text.trim().isEmpty) ? 'P${i + 1}' : pidCtrls[i].text.trim();
      final a = int.tryParse(atCtrls[i].text.trim());
      final b = int.tryParse(btCtrls[i].text.trim());
      if (a == null || b == null) { _toast('Row ${i + 1}: Enter valid Arrival/Burst'); return; }
      if (b <= 0) { _toast('Row ${i + 1}: Burst must be > 0'); return; }
      ids.add(id); at.add(a); bt.add(b);
    }

    int? quantum;
    if (isRR) {
      quantum = int.tryParse(_quantumCtrl.text.trim());
      if (quantum == null || quantum <= 0) { _toast('Enter a valid Time Quantum (>0)'); return; }
    }

    if (isPriority) {
      for (int i = 0; i < n; i++) {
        final p = int.tryParse(prCtrls![i].text.trim());
        if (p == null) { _toast('Row ${i + 1}: Enter valid Priority'); return; }
        pr.add(p);
      }
    }

    // Build table rows for Results
    final rows = <ResultRow>[
      for (int i = 0; i < n; i++) ResultRow(pid: ids[i], arrival: at[i], burst: bt[i]),
    ];

    // Run selected algorithm
    _AlgoOutput out;
    switch (algo) {
      case 'FCFS':
        out = _fcfs(ids, at, bt);
        break;
      case 'SJF':
        out = _sjfNonPreemptive(ids, at, bt);
        break;
      case 'SRTF':
        out = _srtf(ids, at, bt);
        break;
      case 'PS':
        out = _priorityNonPreemptive(ids, at, bt, pr);
        break;
      case 'MLQ':
        out = _multiLevelQueue(ids, at, bt, pr);
        break;
      case 'RR':
        out = _roundRobin(ids, at, bt, quantum!);
        break;
      default:
        _toast('Unknown algorithm: $algo'); return;
    }

    // Navigate to Results page (UI only)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsPage(
          algoName: algo,
          rows: rows,
          avgWaiting: out.avgWaiting,
          avgTurnaround: out.avgTurnaround,
          timeline: out.timeline,
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ----------------- Helper models (top-level) -----------------
class _Proc {
  final String id;
  final int arrival;
  final int burst;
  final int? priority;
  _Proc(this.id, this.arrival, this.burst, {this.priority});
}

class _AlgoOutput {
  final List<GanttSegment> timeline; // ordered segments
  final double avgWaiting;
  final double avgTurnaround;
  _AlgoOutput(this.timeline, this.avgWaiting, this.avgTurnaround);
}

// ----------------- Algorithms -----------------

// FCFS
_AlgoOutput _fcfs(List<String> id, List<int> at, List<int> bt) {
  final procs = <_Proc>[
    for (int i = 0; i < id.length; i++) _Proc(id[i], at[i], bt[i]),
  ]..sort((a, b) => a.arrival.compareTo(b.arrival));

  final timeline = <GanttSegment>[];
  final finish = <String, int>{};
  int time = 0;

  for (final p in procs) {
    if (time < p.arrival) {
      timeline.add(GanttSegment(pid: 'IDLE', start: time, end: p.arrival, color: const Color(0xFFB0B8C1)));
      time = p.arrival;
    }
    timeline.add(GanttSegment(pid: p.id, start: time, end: time + p.burst));
    time += p.burst;
    finish[p.id] = time;
  }

  final (avgW, avgT) = _averages(procs, finish);
  return _AlgoOutput(timeline, avgW, avgT);
}

// SJF (Non-preemptive)
_AlgoOutput _sjfNonPreemptive(List<String> id, List<int> at, List<int> bt) {
  final all = <_Proc>[
    for (int i = 0; i < id.length; i++) _Proc(id[i], at[i], bt[i]),
  ]..sort((a, b) => a.arrival.compareTo(b.arrival));

  final timeline = <GanttSegment>[];
  final finish = <String, int>{};
  int time = 0;
  final ready = <_Proc>[];
  int idx = 0;

  while (idx < all.length || ready.isNotEmpty) {
    while (idx < all.length && all[idx].arrival <= time) {
      ready.add(all[idx++]);
    }
    if (ready.isEmpty) {
      final next = all[idx];
      timeline.add(GanttSegment(pid: 'IDLE', start: time, end: next.arrival, color: const Color(0xFFB0B8C1)));
      time = next.arrival;
      continue;
    }
    // shortest burst
    ready.sort((a, b) => a.burst.compareTo(b.burst));
    final p = ready.removeAt(0);
    timeline.add(GanttSegment(pid: p.id, start: time, end: time + p.burst));
    time += p.burst;
    finish[p.id] = time;
  }

  final (avgW, avgT) = _averages(all, finish);
  return _AlgoOutput(timeline, avgW, avgT);
}

// Priority (Non-preemptive; smaller number = higher priority)
_AlgoOutput _priorityNonPreemptive(List<String> id, List<int> at, List<int> bt, List<int> pr) {
  final all = <_Proc>[
    for (int i = 0; i < id.length; i++) _Proc(id[i], at[i], bt[i], priority: pr[i]),
  ]..sort((a, b) => a.arrival.compareTo(b.arrival));

  final timeline = <GanttSegment>[];
  final finish = <String, int>{};
  int time = 0;
  final ready = <_Proc>[];
  int idx = 0;

  while (idx < all.length || ready.isNotEmpty) {
    while (idx < all.length && all[idx].arrival <= time) {
      ready.add(all[idx++]);
    }
    if (ready.isEmpty) {
      final next = all[idx];
      timeline.add(GanttSegment(pid: 'IDLE', start: time, end: next.arrival, color: const Color(0xFFB0B8C1)));
      time = next.arrival;
      continue;
    }
    // highest priority first
    ready.sort((a, b) {
      final c = (a.priority ?? 0).compareTo(b.priority ?? 0);
      return c != 0 ? c : a.arrival.compareTo(b.arrival);
    });
    final p = ready.removeAt(0);
    timeline.add(GanttSegment(pid: p.id, start: time, end: time + p.burst));
    time += p.burst;
    finish[p.id] = time;
  }

  final (avgW, avgT) = _averages(all, finish);
  return _AlgoOutput(timeline, avgW, avgT);
}

// Round Robin (preemptive)
_AlgoOutput _roundRobin(List<String> id, List<int> at, List<int> bt, int q) {
  final n = id.length;
  final remaining = <String, int>{for (int i = 0; i < n; i++) id[i]: bt[i]};
  final arrival = <String, int>{for (int i = 0; i < n; i++) id[i]: at[i]};

  final order = List<int>.generate(n, (i) => i)..sort((a, b) => at[a].compareTo(at[b]));
  int time = 0;
  int nextIdx = 0;
  final queue = <String>[];
  final finish = <String, int>{};
  final timeline = <GanttSegment>[];

  void addArrivals() {
    while (nextIdx < n && at[order[nextIdx]] <= time) {
      queue.add(id[order[nextIdx]]);
      nextIdx++;
    }
  }

  if (nextIdx < n) {
    time = at[order[nextIdx]];
    addArrivals();
  }

  while (queue.isNotEmpty || nextIdx < n) {
    if (queue.isEmpty) {
      final jump = at[order[nextIdx]];
      if (time < jump) {
        timeline.add(GanttSegment(pid: 'IDLE', start: time, end: jump, color: const Color(0xFFB0B8C1)));
        time = jump;
      }
      addArrivals();
      continue;
    }

    final pid = queue.removeAt(0);
    final rem = remaining[pid]!;
    final slice = rem > q ? q : rem;
    final start = time;
    final end = time + slice;
    timeline.add(GanttSegment(pid: pid, start: start, end: end));
    time = end;
    remaining[pid] = rem - slice;

    addArrivals();

    if (remaining[pid]! > 0) {
      queue.add(pid);
    } else {
      finish[pid] = time;
    }
  }

  final procs = <_Proc>[
    for (int i = 0; i < n; i++) _Proc(id[i], at[i], bt[i]),
  ];
  final (avgW, avgT) = _averages(procs, finish);
  return _AlgoOutput(timeline, avgW, avgT);
}

// Averages helper
(double, double) _averages(List<_Proc> procs, Map<String, int> finish) {
  double totW = 0, totT = 0;
  for (final p in procs) {
    final c = finish[p.id] ?? 0;
    final tat = c - p.arrival;
    final wt = tat - p.burst;
    totT += tat;
    totW += wt;
  }
  final n = procs.length;
  return (totW / n, totT / n);
}
// Shortest Remaining Time First (preemptive)
_AlgoOutput _srtf(List<String> id, List<int> at, List<int> bt) {
  final n = id.length;
  final remaining = <String, int>{for (int i = 0; i < n; i++) id[i]: bt[i]};
  final arrival = <String, int>{for (int i = 0; i < n; i++) id[i]: at[i]};

  final order = List<int>.generate(n, (i) => i)..sort((a, b) => at[a].compareTo(at[b]));
  int nextIdx = 0;
  int time = 0;
  final timeline = <GanttSegment>[];
  final finish = <String, int>{};
  final ready = <String>{};

  void addArrivalsUpTo(int t) {
    while (nextIdx < n && at[order[nextIdx]] <= t) {
      ready.add(id[order[nextIdx]]);
      nextIdx++;
    }
  }

  addArrivalsUpTo(0);

  while (finish.length < n) {
    if (ready.isEmpty) {
      if (nextIdx < n) {
        final jump = at[order[nextIdx]];
        timeline.add(GanttSegment(pid: 'IDLE', start: time, end: jump, color: const Color(0xFFB0B8C1)));
        time = jump;
        addArrivalsUpTo(time);
        continue;
      } else {
        break;
      }
    }

    // pick process with smallest remaining time
    String sel = ready.first;
    for (final r in ready) {
      if (remaining[r]! < remaining[sel]!) sel = r;
    }

    final nextArrivalTime = (nextIdx < n) ? at[order[nextIdx]] : null;
    int slice = remaining[sel]!;
    if (nextArrivalTime != null && time + slice > nextArrivalTime) {
      slice = nextArrivalTime - time;
    }

    final start = time;
    final end = time + slice;
    timeline.add(GanttSegment(pid: sel, start: start, end: end));
    time = end;
    remaining[sel] = remaining[sel]! - slice;

    addArrivalsUpTo(time);

    if (remaining[sel] == 0) {
      finish[sel] = time;
      ready.remove(sel);
    }
  }

  final procs = <_Proc>[for (int i = 0; i < n; i++) _Proc(id[i], at[i], bt[i])];
  final (avgW, avgT) = _averages(procs, finish);
  return _AlgoOutput(timeline, avgW, avgT);
}

// Multi-Level Queue Scheduling (non-preemptive)
 
_AlgoOutput _multiLevelQueue(List<String> id, List<int> at, List<int> bt, List<int> pr) {
  final n = id.length;
  // Build map of priority -> list of indices
  final Map<int, List<int>> queues = {};
  for (int i = 0; i < n; i++) {
    final p = (i < pr.length) ? pr[i] : 0;
    queues.putIfAbsent(p, () => []).add(i);
  }

  final sortedPriorities = queues.keys.toList()..sort();

  final timeline = <GanttSegment>[];
  final finish = <String, int>{};
  int time = 0;

  for (final priority in sortedPriorities) {
    final idxList = queues[priority]!;
    // sort by arrival time
    idxList.sort((a, b) => at[a].compareTo(at[b]));
    for (final i in idxList) {
      final p = _Proc(id[i], at[i], bt[i], priority: priority);
      if (time < p.arrival) {
        timeline.add(GanttSegment(pid: 'IDLE', start: time, end: p.arrival, color: const Color(0xFFB0B8C1)));
        time = p.arrival;
      }
      timeline.add(GanttSegment(pid: p.id, start: time, end: time + p.burst));
      time += p.burst;
      finish[p.id] = time;
    }
  }

  final procs = <_Proc>[for (int i = 0; i < n; i++) _Proc(id[i], at[i], bt[i], priority: (i < pr.length ? pr[i] : 0))];
  final (avgW, avgT) = _averages(procs, finish);
  return _AlgoOutput(timeline, avgW, avgT);
}
