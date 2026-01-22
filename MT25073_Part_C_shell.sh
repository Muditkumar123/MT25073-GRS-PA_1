#!/bin/bash

# Name: Mudit Kumar
# Roll No: MT25073
# Assignment: PA01 Part C - Automation Script (Column Fix for WSL2)

# Output CSV File
OUTPUT_FILE="MT25073_Part_C_CSV.csv"

# Write Header to CSV
echo "Program,Mode,Execution_Time(s),CPU_Usage(%),Disk_Reads_KB,Disk_Writes_KB" > $OUTPUT_FILE

echo "Starting Automation for Part C (Linux Home)..."
echo "---------------------------------"

# Function to run a single test case
run_test() {
    PROG_NAME=$1    # e.g., ./MT25073_Part_A_Program_A
    MODE=$2         # e.g., cpu
    ALIAS=$3        # e.g., Program_A

    echo "Running $ALIAS with mode $MODE..."

    # 1. ROBUST DISK STATS (SUM ALL DRIVES)
    # Your iostat has extra columns.
    # We sum columns $6 (Total Reads) and $7 (Total Writes) for ALL devices.
    STATS_START=$(iostat -d -k | awk '/Device/ {found=1; next} found {r+=$6; w+=$7} END {print r, w}')
    READ_START=$(echo $STATS_START | awk '{print $1}')
    WRITE_START=$(echo $STATS_START | awk '{print $2}')

    # 2. EXECUTION
    # Run in background (&) with CPU pinning
    /usr/bin/time -f "%e" -o time_temp.txt taskset -c 0 $PROG_NAME $MODE &
    PID=$!

    # 3. Wait a moment for threads/processes to spin up
    sleep 2

    # 4. CAPTURE CPU USAGE (Fixed for 15-char limit)
    FULL_NAME=$(basename "$PROG_NAME")
    TRUNCATED_NAME=$(echo "$FULL_NAME" | cut -c 1-15)
    
    # Sum CPU usage of all matching processes
    CPU_USAGE=$(ps -C "$TRUNCATED_NAME" -o %cpu --no-headers | awk '{s+=$1} END {print s}')

    if [ -z "$CPU_USAGE" ]; then
        CPU_USAGE="0.0"
    fi

    # 5. Wait for finish
    wait $PID

    # 6. Capture Execution Time
    EXEC_TIME=$(cat time_temp.txt)

    # 7. CAPTURE DISK END STATS (Columns 6 & 7)
    STATS_END=$(iostat -d -k | awk '/Device/ {found=1; next} found {r+=$6; w+=$7} END {print r, w}')
    READ_END=$(echo $STATS_END | awk '{print $1}')
    WRITE_END=$(echo $STATS_END | awk '{print $2}')
    
    # Calculate Difference
    READ_DIFF=$(awk "BEGIN {print $READ_END - $READ_START}")
    WRITE_DIFF=$(awk "BEGIN {print $WRITE_END - $WRITE_START}")

    # 8. Log to CSV
    echo "$ALIAS,$MODE,$EXEC_TIME,$CPU_USAGE,$READ_DIFF,$WRITE_DIFF" >> $OUTPUT_FILE
    
    echo "Done. Time: ${EXEC_TIME}s, Disk Writes: ${WRITE_DIFF} KB"
    echo "---------------------------------"
}

# --- Execute the 6 Variants ---

# Program A (Processes)
run_test "./MT25073_Part_A_Program_A" "cpu" "Program_A"
run_test "./MT25073_Part_A_Program_A" "mem" "Program_A"
run_test "./MT25073_Part_A_Program_A" "io"  "Program_A"

# Program B (Threads)
run_test "./MT25073_Part_A_Program_B" "cpu" "Program_B"
run_test "./MT25073_Part_A_Program_B" "mem" "Program_B"
run_test "./MT25073_Part_A_Program_B" "io"  "Program_B"

# Cleanup
rm -f time_temp.txt

echo "All tests complete. Results saved to $OUTPUT_FILE"