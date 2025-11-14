// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'ChooseAlgorithmPage.dart';

void main() => runApp(const starting_page());

class starting_page extends StatelessWidget {
  const starting_page({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0A63C9);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCHEDSIM',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 44,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFFD6E4FF),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: Colors.white,
          ),
        ),
      ),
      home: const SchedSimWelcomePage(),
    );
  }
}

class SchedSimWelcomePage extends StatelessWidget {
  const SchedSimWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0A63C9);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.08),

                // Welcome text
                Align(
                  alignment: Alignment.center,
                  child: Text('Welcome to',
                      style: Theme.of(context).textTheme.displayLarge),
                ),
                const SizedBox(height: 25),

                // 🔹 Logo image
                Image.asset(
                  'assets/logo.png',
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 18),

                // App name
                // Text(
                //   'SCHEDSIM',
                //   style: Theme.of(context).textTheme.headlineMedium,
                // ),

                const SizedBox(height: 18),

                // Description
              Flexible(
  child: Text(
    'Explore and understand classic CPU scheduling algorithms like '
    'FCFS, SJF, Round Robin, and Priority Scheduling. Visualize process '
    'execution, Gantt charts, waiting time, turnaround time — all in one app!',
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 15,
          height: 1.4,
        ),
  ),
),

                const Spacer(),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ChooseAlgorithmPage(),
    ),
  );
},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'GET STARTED',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
