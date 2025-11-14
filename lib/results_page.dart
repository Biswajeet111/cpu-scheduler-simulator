// ignore_for_file: unused_element_parameter, unused_element, deprecated_member_use, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart'; // optional, used for conversion helpers
import 'package:open_filex/open_filex.dart';

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
  final int end; // exclusive
  final Color? color;
  const GanttSegment({
    required this.pid,
    required this.start,
    required this.end,
    this.color,
  });
}

/// ---------- RESULTS PAGE (now Stateful to support export) ----------
class ResultsPage extends StatefulWidget {
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

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with SingleTickerProviderStateMixin {
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

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final perProc = _computePerProcessMetrics(widget.rows, widget.timeline);
    final ganttData = widget.timeline
        .map((g) => {'pid': g.pid, 'start': g.start, 'end': g.end})
        .toList();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('RESULTS', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.download),
            onPressed: _saving ? null : () => _onDownloadPressed(perProc, widget.timeline),
            tooltip: 'Download PDF',
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    '${_algoFullNames[widget.algoName.toUpperCase()] ?? widget.algoName} (${widget.algoName.toUpperCase()})',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
              ]),
            ),
            const SizedBox(height: 20),

            // Table header
            Row(children: const [
              _Header('PID'),
              _Header('Arrival Time'),
              _Header('Burst Time'),
              _Header('Waiting Time'),
              _Header('Turnaround Time'),
            ]),
            const SizedBox(height: 6),

            // Table
            _ResultGrid(rows: widget.rows, perProc: perProc),

            const SizedBox(height: 22),

            // Averages
            Center(
              child: Column(children: [
                Text('Average Waiting Time: ${widget.avgWaiting.toStringAsFixed(2)}',
                    style: const TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Average Turnaround Time: ${widget.avgTurnaround.toStringAsFixed(2)}',
                    style: const TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),

            const SizedBox(height: 24),

            if (widget.timeline.isNotEmpty) ...[
              const Text("📊 Gantt Chart",
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 10),
              _PrettyGanttChart(result: ganttData),
            ],
            const SizedBox(height: 20),

            // Big Download button (redundant to AppBar icon)
            SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: Icon(Icons.download, color: const Color.fromARGB(255, 255, 255, 255)), // 🔹 icon color blue
    label: Text(
      _saving ? 'Saving...' : 'Download PDF',
      style: const TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryBlue, // 🔹 background white
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: primaryBlue, width: 1.2), // optional blue border
      ),
      elevation: 2, // soft shadow
    ),
    onPressed: _saving ? null : () => _onDownloadPressed(perProc, widget.timeline),
  ),
),

          ]),
        ),
      ),
    );
  }

  Future<void> _onDownloadPressed(List<_PerProc> perProc, List<GanttSegment> timeline) async {
    setState(() => _saving = true);
    try {
      // Ask for storage permission (Android)
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // On Android 11+, WRITE_EXTERNAL_STORAGE may be restricted; still we try saving to app dir
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage permission not granted. Will try app directory.')));
      }

      final pdfBytes = await _buildPdfBytes(widget.algoName, widget.rows, perProc, widget.avgWaiting, widget.avgTurnaround, timeline);

      final savedPath = await _saveFileBytes(pdfBytes, 'schedsim_results_${DateTime.now().millisecondsSinceEpoch}.pdf');

      if (savedPath != null) {
        _showAnimatedMessage('Saved PDF to: $savedPath');

        // Ask user if they want to open the file now
        final openNow = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Open file?'),
            content: Text('Saved PDF to:\n${storedPathOrShort(savedPath)}\n\nOpen it now?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open')),
            ],
          ),
        );

        if (openNow == true) {
          try {
            await OpenFilex.open(savedPath);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open file: $e')));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save PDF.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

// helper to shorten long paths for dialog text (keeps full path for opening)
String storedPathOrShort(String path) {
  if (path.length <= 80) return path;
  return '...${path.substring(path.length - 77)}';
}

  // Animated overlay message (slides + fades from top)
  void _showAnimatedMessage(String message) async {
    final overlay = Overlay.of(context);

    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    final opacity = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(begin: const Offset(0, -0.18), end: Offset.zero).animate(opacity);

    final entry = OverlayEntry(builder: (ctx) {
      return Positioned(
        top: 24,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: opacity,
            child: SlideTransition(
              position: slide,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        controller.reverse();
                      },
                      child: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    overlay.insert(entry);
    try {
      await controller.forward();
      await Future.delayed(const Duration(seconds: 2));
      await controller.reverse();
    } catch (_) {}
    entry.remove();
    controller.dispose();
  }

  /// Build the PDF file bytes using the `pdf` package.
  Future<List<int>> _buildPdfBytes(
    String algo,
    List<ResultRow> rows,
    List<_PerProc> perProc,
    double avgW,
    double avgT,
    List<GanttSegment> timeline,
  ) async {
    final doc = pw.Document();

    // Convert Flutter Color to PdfColor
    PdfColor _toPdfColor(Color c) => PdfColor.fromInt((c.value & 0xFFFFFFFF));

    // Simple table rows for PDF
    final tableHeaders = ['PID', 'Arrival', 'Burst', 'Waiting', 'Turnaround'];

    final tableData = [
      for (int i = 0; i < rows.length; i++)
        [
          rows[i].pid,
          rows[i].arrival.toString(),
          rows[i].burst.toString(),
          perProc.length > i ? perProc[i].wt.toString() : '',
          perProc.length > i ? perProc[i].tat.toString() : ''
        ]
    ];

    // Build Gantt drawing: normalize times into units for page width
    final int chartStart = timeline.isEmpty ? 0 : timeline.first.start;
    final int chartEnd = timeline.isEmpty ? 0 : timeline.last.end;
    final int chartTotal = (chartEnd - chartStart).clamp(1, 1 << 30);

    // Page
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return [
            pw.Header(level: 0, child: pw.Text('SCHEDSIM Results — $algo', style: pw.TextStyle(fontSize: 20))),
            pw.SizedBox(height: 6),
            pw.Text('Average Waiting Time: ${avgW.toStringAsFixed(2)}'),
            pw.Text('Average Turnaround Time: ${avgT.toStringAsFixed(2)}'),
            pw.SizedBox(height: 12),

            // Table
            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: tableData,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColors.blue100),
              cellHeight: 20,
            ),

            pw.SizedBox(height: 18),

            // Gantt title
            pw.Text('Gantt Chart (timeline)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),

            // Draw a custom Gantt using pw.Container and pw.Positioned inside pw.Stack-like approach
            pw.Container(
              height: 80,
              width: double.infinity,
              child: pw.Stack(
                children: [
                  // vertical ticks
                  for (int t = 0; t <= chartTotal; t++)
                    pw.Positioned(
                      left: (t / chartTotal) * (PdfPageFormat.a4.availableWidth - 40),
                      top: 0,
                      child: pw.Container(width: 1, height: 80, decoration: pw.BoxDecoration(color: t % 5 == 0 ? PdfColors.grey600 : PdfColors.grey300)),
                    ),

                  // bars (single row stacked vertically)
                  for (int i = 0; i < timeline.length; i++)
                    pw.Positioned(
                      left: ((timeline[i].start - chartStart) / chartTotal) * (PdfPageFormat.a4.availableWidth - 40),
                      top: 12,
                      child: pw.Container(
                        width: ((timeline[i].end - timeline[i].start) / chartTotal) * (PdfPageFormat.a4.availableWidth - 40),
                        height: 28,
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                          gradient: pw.LinearGradient(
                            colors: [PdfColors.blue300, PdfColors.blue800],
                            begin: pw.Alignment.centerLeft,
                            end: pw.Alignment.centerRight,
                          ),
                        ),
                        child: pw.Center(child: pw.Text(timeline[i].pid, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      ),
                    ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  /// Save bytes to Downloads (if possible) or app external dir.
  Future<String?> _saveFileBytes(List<int> bytes, String filename) async {
    try {
      // Try Downloads directory (Android)
      if (Platform.isAndroid) {
        try {
          final extDir = await getExternalStorageDirectory();
          // extDir path is like /storage/emulated/0/Android/data/<package>/files
          // Try to save in a "Download" path if possible:
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            final file = File('${downloadsDir.path}/$filename');
            await file.writeAsBytes(bytes);
            return file.path;
          } else if (extDir != null) {
            final file = File('${extDir.path}/$filename');
            await file.writeAsBytes(bytes);
            return file.path;
          }
        } catch (_) {
          // fallback below
        }
      }

      // For iOS or fallback: save in app documents directory
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Compute per-process metrics like WT/TAT using the end time from timeline.
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
            if (isLast) const Divider(height: 1.2, thickness: 1.2, color: primaryBlue),
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
          SizedBox(width: chartWidth, height: 8, child: _GridLineRow(start: start, end: end, unitWidth: unitWidth)),
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
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
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
