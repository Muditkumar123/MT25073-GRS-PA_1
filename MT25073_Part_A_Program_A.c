#include <stdio.h>
#include <stdlib.h> // for exit,atoi
#include <string.h>
#include <unistd.h> // For Fork
#include <sys/wait.h> // for wait which is critical for process synch,without this parent will not know when children are finished.
#include "MT25073_Part_A_Workers.h" // Including worker functions


int main(int argc,char *argv[]){
// Argument validation
if(argc <2){
printf("Usage: %s <cpu|mem|io> [num_processes]\n", argv[0]);
return 1;
}
//argc < 2: Checks if the we forgot to specify a mode (cpu/mem/io).
//argv[0]: The program's own name (e.g., ./programA).


// MODEL selection (Function pointers)


//selecting the mode based on input


char *mode = argv[1];

void (*worker_func)(); // Function pointer declaration,The Child process just call this without need to check which mode we are in 
//every single time

if (strcmp(mode,"cpu")==0) worker_func = run_cpu_intensive;
else if (strcmp(mode, "mem") == 0) worker_func = run_mem_intensive;
else if (strcmp(mode, "io") == 0) worker_func = run_io_intensive;
else {
        printf("Invalid mode. Use: cpu, mem, or io\n");
        return 1;
}

//Determining the number of process
int num_processes = 2;

if(argc>=3){
    num_processes = atoi(argv[2]); // converts the string i.e '5' into interger
                                  //Part d requires us to automate scaling(run with ,2,3,4,5 process)
                                  // By adding this we dont have to rewrite code late,bash can simply pass an arguement

}

// Fork Loop (creating proccesses)
printf("Starting Program A (Fork) with %d processes in %s mode...\n", num_processes, mode);


    for (int i = 0; i < num_processes; i++) {
        pid_t pid = fork(); // return 0 to child process, returns child PID to parent process

        if (pid < 0) {
            perror("Fork failed");
            exit(1);
        } else if (pid == 0) {
            // --- CHILD PROCESS ---
            worker_func(); // Run the assigned task (cpu/mem/io)
            exit(0); // CRITICAL: Child must exit here!
        }
    }

    //  Parent Waits
    for (int i = 0; i < num_processes; i++) {
        wait(NULL);
    }

    printf("All processes finished.\n");
    return 0;
}















