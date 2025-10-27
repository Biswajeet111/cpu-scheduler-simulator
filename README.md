# 🧠 Intelligent CPU Scheduler Simulator

## 📌 Overview
This project simulates four classic CPU scheduling algorithms:
- First-Come, First-Served (FCFS)
- Shortest Job First (SJF)
- Round Robin (RR)
- Priority Scheduling

It provides a GUI for entering process data and visualizes execution using Gantt charts and performance metrics like average waiting time and turnaround time.

## 🚀 Features
- Input process details: PID, arrival time, burst time, priority
- Select scheduling algorithm from dropdown
- Visualize execution order with Gantt chart
- Display average waiting and turnaround times
- Modular codebase for easy extension

## 🛠️ Technologies Used
- Python 3.10+
- Tkinter (GUI)
- Matplotlib (Gantt chart)
- Pandas (optional for data handling)
- VS Code (IDE)

## 📦 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Biswajeet111/cpu-scheduler-simulator.git
   cd cpu-scheduler-simulator
  
   ##Install dependencies
   pip install -r requirements.txt
   ##TO Run
   python main.py

##Folder Structure
   Cpu_Simulator/
│
├── main.py                  # Entry point
├── requirements.txt         # Dependencies
├── README.md                # Project overview
│
├── scheduler/               # Scheduling algorithms
│   ├── fcfs.py
│   ├── sjf.py
│   ├── rr.py
│   └── priority.py
│
├── gui/                     # GUI components
│   └── interface.py
│
├── visualization/           # Gantt chart rendering
│   └── gantt_chart.py
│
└── utils/                   # Process class and helpers
    └── process.py
