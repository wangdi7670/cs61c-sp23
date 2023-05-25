#include "ex2.h"

void v_add_naive(double* x, double* y, double* z) {
    #pragma omp parallel
    {
        for(int i=0; i<ARRAY_SIZE; i++)
            z[i] = x[i] + y[i];
    }
}

// Adjacent Method
void v_add_optimized_adjacent(double* x, double* y, double* z) {
    // TODO: Implement this function
    // Do NOT use the `for` directive here!
    #pragma omp parallel
    {
        int n = omp_get_num_threads();
        int thread_id = omp_get_thread_num();
        for (int i = thread_id; i < ARRAY_SIZE; i += n) {
            z[i] = x[i] + y[i];
        }
    }
}

// Chunks Method
void v_add_optimized_chunks(double* x, double* y, double* z) {
    // TODO: Implement this function
    // Do NOT use the `for` directive here!

    #pragma omp parallel
    {
        int n = omp_get_num_threads();
        int thread_id = omp_get_thread_num();
        int chunk_size = ARRAY_SIZE / n;
        
        int j;
        if (thread_id == n - 1) {
            j = ARRAY_SIZE;
        } else {
            j = (thread_id + 1) * chunk_size;
        }

        for (int i = thread_id * chunk_size; i < j; i++) {
            z[i] = x[i] + y[i];
        }
    }


}
