List<Map<String, dynamic>> fcfs(List<Map<String, dynamic>> processes) {
    processes.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));
    int time = 0;
    List<Map<String, dynamic>> gantt = [];
    for (var p in processes) {
      int start = time < p['arrival'] ? p['arrival'] : time;
      int end = start + (p['burst'] as int);
      gantt.add({'pid': p['pid'], 'start': start, 'end': end});
      time = end;
    }
    return gantt;
  }

  List<Map<String, dynamic>> sjf(List<Map<String, dynamic>> processes) {
    processes.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));
    int time = 0;
    List<Map<String, dynamic>> ready = [];
    List<Map<String, dynamic>> gantt = [];
    while (processes.isNotEmpty || ready.isNotEmpty) {
      while (processes.isNotEmpty && processes.first['arrival'] <= time) {
        ready.add(processes.removeAt(0));
      }
      if (ready.isNotEmpty) {
        ready.sort((a, b) => a['burst'].compareTo(b['burst']));
        var p = ready.removeAt(0);
        int start = time;
        int end = start + (p['burst'] as int);
        gantt.add({'pid': p['pid'], 'start': start, 'end': end});
        time = end;
      } else {
        time++;
      }
    }
    return gantt;
  }

  List<Map<String, dynamic>> rr(List<Map<String, dynamic>> processes, int quantum) {
    processes.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));
    int time = 0;
    List<Map<String, dynamic>> ready = [];
    List<Map<String, dynamic>> gantt = [];
    while (processes.isNotEmpty || ready.isNotEmpty) {
      while (processes.isNotEmpty && processes.first['arrival'] <= time) {
        ready.add(processes.removeAt(0));
      }
      if (ready.isNotEmpty) {
        var p = ready.removeAt(0);
        int runTime = p['burst'] > quantum ? quantum : p['burst'];
        int start = time;
        int end = start + runTime;
        gantt.add({'pid': p['pid'], 'start': start, 'end': end});
        time = end;
        p['burst'] -= runTime;
        if (p['burst'] > 0) {
          p['arrival'] = time;
          processes.add(p);
          processes.sort((a, b) => a['arrival'].compareTo(b['arrival']));
        }
      } else {
        time++;
      }
    }
    return gantt;
  }

  List<Map<String, dynamic>> priorityScheduling(List<Map<String, dynamic>> processes) {
   processes.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));
    int time = 0;
    List<Map<String, dynamic>> ready = [];
    List<Map<String, dynamic>> gantt = [];
    while (processes.isNotEmpty || ready.isNotEmpty) {
      while (processes.isNotEmpty && processes.first['arrival'] <= time) {
        ready.add(processes.removeAt(0));
      }
      if (ready.isNotEmpty) {
        ready.sort((a, b) => a['priority'].compareTo(b['priority']));
        var p = ready.removeAt(0);
        int start = time;
        int end = start + (p['burst'] as int);
        gantt.add({'pid': p['pid'], 'start': start, 'end': end});
        time = end;
      } else {
        time++;
      }
    }
    return gantt;
  }

  List<Map<String, dynamic>> srtf(List<Map<String, dynamic>> processes) {
  processes.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));
  int time = 0;
  List<Map<String, dynamic>> gantt = [];
  List<Map<String, dynamic>> ready = [];

  for (var p in processes) {
    p['remaining'] = p['burst'];
  }

  while (processes.isNotEmpty || ready.isNotEmpty) {
    while (processes.isNotEmpty && processes.first['arrival'] <= time) {
      ready.add(processes.removeAt(0));
    }

    if (ready.isNotEmpty) {
      ready.sort((a, b) => a['remaining'].compareTo(b['remaining']));
      var p = ready.first;
      int start = time;
      p['remaining'] -= 1;
      time += 1;
      gantt.add({'pid': p['pid'], 'start': start, 'end': time});

      if (p['remaining'] == 0) {
        ready.remove(p);
      }
    } else {
      time++;
    }
  }

  return gantt;
}

List<Map<String, dynamic>> multilevelQueue(
  List<Map<String, dynamic>> foreground,
  List<Map<String, dynamic>> background,
  int quantum,
) {
  // Sort both queues by arrival time
  foreground.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));
  background.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));

  int time = 0;
  List<Map<String, dynamic>> readyFG = [];
  List<Map<String, dynamic>> gantt = [];

  // Clone foreground to avoid modifying original list
  List<Map<String, dynamic>> fgQueue = List.from(foreground);

  while (fgQueue.isNotEmpty || readyFG.isNotEmpty) {
    // Move arrived processes to ready queue
    while (fgQueue.isNotEmpty && fgQueue.first['arrival'] <= time) {
      readyFG.add(fgQueue.removeAt(0));
    }

    if (readyFG.isNotEmpty) {
      var p = readyFG.removeAt(0);
      int runTime = p['burst'] > quantum ? quantum : p['burst'];
      int start = time;
      int end = start + runTime;
      gantt.add({'pid': p['pid'], 'start': start, 'end': end});
      time = end;
      p['burst'] -= runTime;

      if (p['burst'] > 0) {
        p['arrival'] = time;
        fgQueue.add(p);
        fgQueue.sort((a, b) => (a['arrival'] as int).compareTo(b['arrival'] as int));
      }
    } else {
      time++;
    }
  }

  // Background queue: FCFS
  for (var p in background) {
    time = time < p['arrival'] ? p['arrival'] : time;
    int start = time;
    int end = start + (p['burst'] as int);
    gantt.add({'pid': p['pid'], 'start': start, 'end': end});
    time = end;
  }

  return gantt;
}