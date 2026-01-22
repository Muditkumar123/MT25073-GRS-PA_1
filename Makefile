# Name: Mudit Kumar
# Roll No: MT25073
# Assignment: PA01

# Compiler to use
CC = gcc

# Compiler Flags
# -Wall: Enable all warnings (good for debugging)
CFLAGS = -Wall

# Linker Flags
# -pthread: Required for threading (Program B) and pthread_self() (used in workers)
# -lm: Required for math functions (sqrt, sin) used in cpu_worker
LIBS = -pthread -lm

# Target Executable Names
TARGET_A = MT25073_Part_A_Program_A
TARGET_B = MT25073_Part_A_Program_B

# Default target: builds both programs when you type 'make'
all: $(TARGET_A) $(TARGET_B)

# Rule to build Program A
# Format: gcc -o <output_name> <input_file.c> <flags>
$(TARGET_A): MT25073_Part_A_Program_A.c MT25073_Part_A_Workers.h
	$(CC) $(CFLAGS) -o $(TARGET_A) MT25073_Part_A_Program_A.c $(LIBS)

# Rule to build Program B
$(TARGET_B): MT25073_Part_A_Program_B.c MT25073_Part_A_Workers.h
	$(CC) $(CFLAGS) -o $(TARGET_B) MT25073_Part_A_Program_B.c $(LIBS)


clean:
	rm -f $(TARGET_A) $(TARGET_B)