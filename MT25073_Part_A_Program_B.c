#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include <pthread.h>
#include "MT25073_Part_A_Workers.h"

void* thread_wrapper(void* arg){
  void(*worker_func) () = (void(*)()) arg;// // Casting  the void* argument back to a function pointer
  
  worker_func(); // ex

  return NULL;  // pthread_create requires a function that takes a void* argument and returns a void*. 
                //However,  worker functions (e.g., void run_cpu_intensive()) take no arguments and return nothing.
                //pthread_create enforces a specific function signature (void* (*start_routine) (void *))
                // worker functions are void void. The wrapper adapts them to match the required signature.

}

int main(int argc, char *argv[]) {
    // Argument Validation
    if(argc<2) {
    printf("Usage: %s <cpu|mem|io> [num_threads]\n", argv[0]);
    return 1;
    }
   
    char *mode=argv[1];
    void(*worker_func)();

    if (strcmp(mode, "cpu")==0) worker_func = run_cpu_intensive;
        else if(strcmp(mode, "mem")==0) worker_func = run_mem_intensive;
        else if(strcmp(mode, "io")==0) worker_func = run_io_intensive;
        else {
        printf("Invalid mode. Use: cpu, mem, or io\n");
        return 1;
    }

    //  Determine Number of Threads
    // Default is 2 (Part A), but scalable for Part D (up to 8).
    int num_threads = 2;
    if (argc >= 3) {
        num_threads = atoi(argv[2]);
    }

    pthread_t threads[num_threads]; // Array to store Thread IDs
    printf("Starting Program B (Threads) with %d threads in %s mode...\n", num_threads, mode);

    // Create Threads
    for(int i=0;i<num_threads;i++) {
        // We pass 'worker_func' as the argument to the wrapper
        if (pthread_create(&threads[i], NULL, thread_wrapper,(void*)worker_func)!=0) {
            perror("Thread creation failed"); //Arg1 :Where to store the ID of the new thread.
            return 1;                         // Arg 2 (NULL): Default thread attributes (stack size, scheduling priority).
                                              //Arg 3: The function the thread should start executing.
                                             // Arg 4 : The argument we pass to that function. Here, we are passing the address of the worker function (e.g., run_cpu_intensive) so the wrapper knows what to run.  
        }
    }

    //  Join Threads (Wait)
    // The main thread waits here until all worker threads return.
    for (int i=0;i<num_threads;i++) {
        pthread_join(threads[i], NULL);
    }

    printf("All threads finished.\n");
    return 0;
}