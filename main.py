import tkinter as tk
from tkinter import ttk, messagebox

# ------------------ Scheduling Algorithms ------------------

def fcfs_scheduling(processes):
    processes.sort(key=lambda x: x['arrival'])
    time = 0
    gantt = []
    for p in processes:
        start = max(time, p['arrival'])
        end = start + p['burst']
        gantt.append((p['pid'], start, end))
        time = end
    return gantt

def sjf_scheduling(processes):
    processes.sort(key=lambda x: (x['arrival'], x['burst']))
    time = 0
    gantt = []
    ready = []
    while processes or ready:
        while processes and processes[0]['arrival'] <= time:
            ready.append(processes.pop(0))
        if ready:
            ready.sort(key=lambda x: x['burst'])
            p = ready.pop(0)
            start = time
            end = start + p['burst']
            gantt.append((p['pid'], start, end))
            time = end
        else:
            time += 1
    return gantt

def rr_scheduling(processes, quantum=2):
    queue = sorted(processes, key=lambda x: x['arrival'])
    time = 0
    gantt = []
    ready = []
    while queue or ready:
        while queue and queue[0]['arrival'] <= time:
            ready.append(queue.pop(0))
        if ready:
            p = ready.pop(0)
            start = time
            run_time = min(p['burst'], quantum)
            end = start + run_time
            gantt.append((p['pid'], start, end))
            time = end
            p['burst'] -= run_time
            if p['burst'] > 0:
                p['arrival'] = time
                queue.append(p)
        else:
            time += 1
    return gantt

def priority_scheduling(processes):
    processes.sort(key=lambda x: (x['arrival'], x['priority']))
    time = 0
    gantt = []
    ready = []
    while processes or ready:
        while processes and processes[0]['arrival'] <= time:
            ready.append(processes.pop(0))
        if ready:
            ready.sort(key=lambda x: x['priority'])
            p = ready.pop(0)
            start = time
            end = start + p['burst']
            gantt.append((p['pid'], start, end))
            time = end
        else:
            time += 1
    return gantt

# ------------------ GUI Setup ------------------

def simulate():
    try:
        processes = []
        for row in entries:
            pid = row[0].get()
            arrival = int(row[1].get())
            burst = int(row[2].get())
            priority = int(row[3].get())
            processes.append({'pid': pid, 'arrival': arrival, 'burst': burst, 'priority': priority})

        algo = algo_var.get()
        if algo == "FCFS":
            result = fcfs_scheduling(processes)
        elif algo == "SJF":
            result = sjf_scheduling(processes)
        elif algo == "RR":
            result = rr_scheduling(processes)
        elif algo == "Priority":
            result = priority_scheduling(processes)
        else:
            messagebox.showerror("Error", "Select a valid algorithm")
            return

        output.delete(1.0, tk.END)
        output.insert(tk.END, "Gantt Chart:\n")
        for pid, start, end in result:
            output.insert(tk.END, f"{pid}: {start} → {end}\n")

    except Exception as e:
        messagebox.showerror("Error", str(e))

root = tk.Tk()
root.title("Intelligent CPU Scheduler Simulator")

tk.Label(root, text="Select Scheduling Algorithm").grid(row=0, column=0, columnspan=4)
algo_var = tk.StringVar()
algo_menu = ttk.Combobox(root, textvariable=algo_var, values=["FCFS", "SJF", "RR", "Priority"])
algo_menu.grid(row=1, column=0, columnspan=4)
algo_menu.current(0)

tk.Label(root, text="PID").grid(row=2, column=0)
tk.Label(root, text="Arrival Time").grid(row=2, column=1)
tk.Label(root, text="Burst Time").grid(row=2, column=2)
tk.Label(root, text="Priority").grid(row=2, column=3)

entries = []
for i in range(5):  # You can change this to allow more processes
    row = []
    for j in range(4):
        e = tk.Entry(root)
        e.grid(row=i+3, column=j)
        row.append(e)
    entries.append(row)

tk.Button(root, text="Simulate", command=simulate).grid(row=8, column=0, columnspan=4)

output = tk.Text(root, height=10, width=50)
output.grid(row=9, column=0, columnspan=4)

root.mainloop()