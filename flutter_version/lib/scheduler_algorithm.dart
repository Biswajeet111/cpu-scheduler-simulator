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