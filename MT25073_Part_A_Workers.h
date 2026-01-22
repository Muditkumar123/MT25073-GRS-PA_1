#include <stdio.h> // input output
#include<stdlib.h> // standard library (malloc,free,exit,atio)
#include<string.h> //string manipulation (memset,strcmp)
#include<unistd.h> // Posix api (fork,getpid,unlink,sleep)
#include<math.h> //math functions
#include <pthread.h> //threading

// Roll No MT25073: Last digit 3 -> 3000 iterations

#define LOOP_COUNT 3000
#define MEM_BLOCK_SIZE (5*1024*1024) //5Mb per iteration , 10 mb of large data to move between CPU and Memory
#define IO_CHUNK_SIZE (128*1024) //128kb of text data,that will be read/write repeatedly




void run_cpu_intensive(){ //keep cpu busy by calculating numbers without waiting for memory or disk

double result = 0.0; //to store calculation

for(int i = 0;i<LOOP_COUNT;i++){
    
    for(int j=0;j<25000;j++){//a single math operation is fast for CPU,doing double loop to ensure cpu actually does the calculation
        // This forces the ALU (Arithmetic Logic Unit) to work hard
        result+=sqrt((double)j)*sin((double)j);
    }
}
// TRICK: Compilers are smart. If you calculate 'result' but never use it, 
// the compiler might delete upper whole loop to "optimize" code.
// This fake check forces the compiler to actually run the loop.
    if (result == 12345.0) printf("Ignore this\n");

}

void run_mem_intensive(){ //goal is to stress ram by allocating and accessing large data blocks
// 'volatile' tells the compiler: "Do not optimize this variable! 
// Always go to RAM to read it, never just keep it in a CPU register."
volatile char temp;

for(int i = 0;i<LOOP_COUNT;i++){

char *buffer=(char *)malloc(MEM_BLOCK_SIZE) ;//Allocate 5MB of memory

if(buffer == NULL){
    perror("Memory allocation Failed");
    exit(1);
}

// memset fills memory block with values
// Critical: 'malloc' is lazy. It promises memory but doesn't give physical RAM 
// until you actually WRITE to it. This forces the OS to map physical pages.
memset(buffer,i%255,MEM_BLOCK_SIZE);
// This prevents the CPU from just "waiting" on RAM; it must perform addition.
for (int repeat = 0; repeat < 50; repeat++) {
            // Stride of 4096 (page size) to touch many pages quickly
            for (int k = 0; k < MEM_BLOCK_SIZE; k += 4096) {
                 buffer[k] += 1; // Read-Modify-Write
            }
        }


// 3. READ: Access specific bytes (start, middle, end).
// This jumps around memory, which is harder for the CPU cache to predict.
temp=buffer[0];
temp=buffer[MEM_BLOCK_SIZE / 2];
temp=buffer[MEM_BLOCK_SIZE - 1];

free(buffer);


}

}


void run_io_intensive(){ // Goal is to spend the time waiting for disk operations
char filename[64];
//allocate buffer which will hold data that we will write to disk
char *data=(char *)malloc(IO_CHUNK_SIZE);

if(!data) return;


// Fill the buffer with the letter 'A' so we have content to write.
memset(data,'A',IO_CHUNK_SIZE);

data[IO_CHUNK_SIZE - 1] = '\0'; // Null-terminate string safety

// UNIQUE FILENAME GENERATION:
// We use getpid() (Process ID) and pthread_self() (Thread ID).
// Why? If we run 2 threads at the same time, they cannot write to the SAME file 
// or they will corrupt data. This ensures every worker has its own sandbox file.

snprintf(filename, sizeof(filename), "temp_io_%d_%lu.txt", getpid(), (unsigned long)pthread_self()); //it avoids race condition

for(int i=0;i<LOOP_COUNT;i++){
FILE *fp =fopen(filename,"w+"); 

if(fp==NULL){
    perror("File Open Failed");
    free(data);
    exit(1);
}

// dumping 64KB of data to hard disk
fwrite(data,1,IO_CHUNK_SIZE,fp);


// Force the OS to flush RAM cache to Physical Disk
        fflush(fp);         // Flush C library buffer to Kernel
        fsync(fileno(fp));  // Flush Kernel buffer to Disk Hardware
        // ----------------




//REWIND: Move the file cursor back to the start (byte 0).
rewind(fp);


// READ: Read 100 bytes back into a small buffer.
 // This proves the data is actually on the disk (or disk cache).
char buffer[100];
fread(buffer,1,sizeof(buffer),fp);

fclose(fp);

// .DELETE: 'unlink' deletes the file from the directory.
// We do this so we don't fill the hard drive with 3000 junk files.
    unlink(filename);



}

   free(data); //clean up initial buffer 
    


}
