# PA01: Linux Process & Thread Management

**Name:** Mudit Kumar  
**Roll No:** MT25073  
**Course:** Operating Systems (CSE501)

## Overview
This assignment compares the performance overhead of **Processes (fork)** versus **Threads (pthreads)** under three distinct workloads:

1. **CPU Intensive:** Complex mathematical calculations (`sqrt`, `sin`).
2. **Memory Intensive:** Large buffer allocation (5MB) with stride access to trigger TLB misses.
3. **I/O Intensive:** Repeated 128KB file writes using `fsync()` to force physical disk I/O.

## Project Structure

### Source Code
- `MT25073_Part_A_Workers.h`: Header file containing the core logic for CPU, Memory, and I/O tasks.
- `MT25073_Part_A_Program_A.c`: Driver program using **Processes** (`fork()` + `wait()`).
- `MT25073_Part_A_Program_B.c`: Driver program using **Threads** (`pthread_create()` + `join()`).
- `Makefile`: Build script to compile both programs with `-pthread` and `-lm` flags.

### Automation Scripts
- `MT25073_Part_C_shell.sh`: Runs a baseline test (2 workers) for all modes and captures execution time, CPU usage, and robust Disk I/O stats (summing all virtual drives).
- `MT25073_Part_D_shell.sh`: Runs scalability tests (2–5 processes, 2–8 threads) to generate data for performance analysis.

### Output Files
- `MT25073_Part_C_CSV.csv`: Baseline performance metrics.
- `MT25073_Part_D_CSV.csv`: Scalability performance metrics.
- `MT25073_Report.pdf`: Final analysis report with plots.

---

## How to Compile and Run (WSL2 Workflow)

### 1. Sync Windows Files to Linux
If editing code in Windows (VS Code), copy the latest files to the Linux environment before compiling:

```bash
# Go to Linux directory
cd ~/PA01_Linux

# Copy fresh files from Windows Desktop (Overwrite existing)
cp "/mnt/c/Users/Mudit/Desktop/MTECH assignments/GRS Assignment/"* .

### 2. Compilation
Use the provided Makefile to clean and build both programs:

```bash
make clean && make

This generates two executables:

- `MT25073_Part_A_Program_A`
- `MT25073_Part_A_Program_B`

### 3. Running Part C (Baseline)

This script runs the programs with 2 workers and logs data to `MT25073_Part_C_CSV.csv`.

```bash
chmod +x MT25073_Part_C_shell.sh
./MT25073_Part_C_shell.sh


### 4. Running Part D (Scalability)

This script iterates through multiple worker counts (Processes: 2–5, Threads: 2–8) and logs data to `MT25073_Part_D_CSV.csv`.

```bash
chmod +x MT25073_Part_D_shell.sh
./MT25073_Part_D_shell.sh

### 5. Export Results to Windows

After running the tests, copy the CSVs, report, and source code back to Windows for submission:

```bash
cp -r ~/PA01_Linux/* "/mnt/c/Users/Mudit/Desktop/MTECH assignments/GRS Assignment/"


## AI Declaration

I utilized an AI assistant to support the development of this assignment. My usage was as follows:

- **C Code Development:** The AI generated the initial code structure and logic for the worker functions (`MT25073_Part_A_Workers.h`) and the main driver programs (`.c` files). I manually transcribed and verified this code line-by-line to ensure I fully understood the implementation logic (processes, threads, and memory management) before compiling. While the code structure aligns with the AI's suggestions, the final transcription is my own.

- **Scripting Support:** The AI provided the logic for the Bash scripts, specifically the `seq` loops for iterating through process counts and the `taskset` command for CPU pinning.

- **Debugging & Environment:** The AI was instrumental in diagnosing WSL2-specific issues, such as identifying the correct `iostat` columns (summing `$6` and `$7`) to capture virtual disk writes.

- **Visualization:** The AI provided the Python script used to generate the performance graphs from the raw CSV data.

All final analysis and conclusions regarding the performance differences are based on the data I collected.
