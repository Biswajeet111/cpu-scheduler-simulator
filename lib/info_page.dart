import 'package:flutter/material.dart';
import 'process_form_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({
    super.key,
    required this.algoName, // short: FCFS/SJF/RR/PS/multi-level/srtf
    required this.fullName, // full: First Come First Serve, ...
  });

  final String algoName;
  final String fullName;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  static const Color primaryBlue = Color(0xFF0A63C9);
  static const Color bgLight = Color(0xFFF3F6FB);

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  /// Optional short descriptions keyed by SHORT name
  static const Map<String, String> _descriptions = {
    'FCFS': 'Processes execute in arrival order. Simple & non-preemptive.',
    'SJF':  'Executes the job with the smallest CPU burst next.',
    'RR':   'Each process gets a fixed time quantum in round-robin fashion.',
    'PS':   'Higher priority process runs first (preemptive/non-preemptive).',
    'SRTF': 'Preemptive version of SJF — the job with the smallest remaining time runs.',
    'MLQ':  'Multi-Level Queue: processes placed into priority queues and scheduled per-queue.',
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final short = widget.algoName.toUpperCase().trim();
    final full  = widget.fullName.trim();
    final desc  = _descriptions[short];

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          '$full ($short)',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (desc != null) ...[
                  Text(
                    desc,
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  'You selected: $full ($short)',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Please enter the total number\nof processes:',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // Input field
                Container(
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 4',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Enter a valid number';
                      if (n > 12) return 'Keep ≤ 12 for mobile layout';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      final count = int.parse(_controller.text.trim());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProcessFormPage(
                            // Keep passing SHORT name forward for logic keys
                            algoName: short,
                            processCount: count,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
