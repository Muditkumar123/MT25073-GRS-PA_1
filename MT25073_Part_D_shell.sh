#!/bin/bash

# Name: Mudit Kumar
# Roll No: MT25073
# Assignment: PA01 Part D - Scaling Automation
#
# AI Declaration:
# I utilized an AI assistant (Gemini) to generate the structure of this automation script.
# The AI suggested:
# 1. Using loops to iterate through the required processes (2-5) and threads (2-8).
# 2. The logic for pinning processes to a single core using 'taskset'.
# 3. Correcting the 'iostat' logic for WSL to use columns $6 and $7 (Total Reads/Writes) 
#    instead of rate columns, and summing all drives to capture virtual disk activity.
# 4. Applying the 15-character truncation fix for the 'ps' command to correctly capture CPU usage.

# Output CSV File
OUTPUT_FILE="MT25073_Part_D_CSV.csv"

# Write Header
echo "Program,Mode,Count,Execution_Time(s),CPU_Usage(%),Disk_Reads_KB,Disk_Writes_KB" > $OUTPUT_FILE

echo "Starting Scaling Tests for Part D (Linux Home)..."
echo "---------------------------------"

# Function to run a single test case with a specific count
run_test_scaled() {
    PROG_NAME=$1    # e.g., ./MT25073_Part_A_Program_A
    MODE=$2         # e.g., cpu
    ALIAS=$3        # e.g., Program_A
    COUNT=$4        # Number of processes or threads

    echo "Running $ALIAS ($MODE) with count: $COUNT"

    # 1. ROBUST DISK STATS (SUM ALL DRIVES & USE COLUMNS 6/7)
    # Your iostat has extra columns (kB_dscd/s).
    # We sum columns $6 (Total Reads) and $7 (Total Writes) for ALL devices.
    STATS_START=$(iostat -d -k | awk '/Device/ {found=1; next} found {r+=$6; w+=$7} END {print r, w}')
    READ_START=$(echo $STATS_START | awk '{print $1}')
    WRITE_START=$(echo $STATS_START | awk '{print $2}')

    # 2. EXECUTION
    # Run in background (&) with CPU pinning
    /usr/bin/time -f "%e" -o time_temp.txt taskset -c 0 $PROG_NAME $MODE $COUNT &
    PID=$!

    # 3. Wait for spin up
    sleep 2

    # 4. CAPTURE CPU USAGE (Fixed for 15-char limit)
    FULL_NAME=$(basename "$PROG_NAME")
    TRUNCATED_NAME=$(echo "$FULL_NAME" | cut -c 1-15)
    
    # Sum CPU usage of all matching processes (Parent + Children)
    CPU_USAGE=$(ps -C "$TRUNCATED_NAME" -o %cpu --no-headers | awk '{s+=$1} END {print s}')
    if [ -z "$CPU_USAGE" ]; then CPU_USAGE="0.0"; fi

    # 5. Wait for finish
    wait $PID

    # 6. Capture Time
    EXEC_TIME=$(cat time_temp.txt)

    # 7. CAPTURE DISK END STATS
    STATS_END=$(iostat -d -k | awk '/Device/ {found=1; next} found {r+=$6; w+=$7} END {print r, w}')
    READ_END=$(echo $STATS_END | awk '{print $1}')
    WRITE_END=$(echo $STATS_END | awk '{print $2}')
    
    # Calculate Difference
    READ_DIFF=$(awk "BEGIN {print $READ_END - $READ_START}")
    WRITE_DIFF=$(awk "BEGIN {print $WRITE_END - $WRITE_START}")

    # 8. Log to CSV (Added COUNT column)
    echo "$ALIAS,$MODE,$COUNT,$EXEC_TIME,$CPU_USAGE,$READ_DIFF,$WRITE_DIFF" >> $OUTPUT_FILE
}

# --- 1. Scale Program A (Processes: 2, 3, 4, 5) ---
# Assignment asks for 2, 3, 4, 5 processes
for N in {2..5}; do
    run_test_scaled "./MT25073_Part_A_Program_A" "cpu" "Program_A" $N
    run_test_scaled "./MT25073_Part_A_Program_A" "mem" "Program_A" $N
    run_test_scaled "./MT25073_Part_A_Program_A" "io"  "Program_A" $N
done

# --- 2. Scale Program B (Threads: 2, 3, 4, 5, 6, 7, 8) ---
# Assignment asks for 2 to 8 threads
for N in {2..8}; do
    run_test_scaled "./MT25073_Part_A_Program_B" "cpu" "Program_B" $N
    run_test_scaled "./MT25073_Part_A_Program_B" "mem" "Program_B" $N
    run_test_scaled "./MT25073_Part_A_Program_B" "io"  "Program_B" $N
done

rm -f time_temp.txt
echo "Part D Scaling Complete. Data saved to $OUTPUT_FILE"