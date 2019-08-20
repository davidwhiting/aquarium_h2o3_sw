#include <stdio.h>
#include <math.h>

#define N 16

// TODO make this method a kernel
void add(int* a, int* b, int* c) {
    int localIdx = // TODO calculate the index for this kernel invocation using read-only CUDA provided variables
    
    // TODO when should we do the summation? What values can localIdx take compared to N?
    if( ... ) {
        c[localIdx] = a[localIdx] + b[localIdx];
    }
}

int main( int argc, char** argv ) {
    int a[N], b[N], c[N]; 
    int *dev_a, *dev_b, *dev_c;

    // Initialize arrays a and b with data
    for (int i=0; i < N; i++) {
        a[i] = 2*i;
        b[i] = -i;
    }
    
    // Allocate memory on the GPU
    cudaMalloc( (void**)&dev_a, N * sizeof(int) ); 
    cudaMalloc( (void**)&dev_b, N * sizeof(int) );
    cudaMalloc( (void**)&dev_c, N * sizeof(int) );
    
    // Copy the data from host to GPU memory
    cudaMemcpy( dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice );
    cudaMemcpy( dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice );

    // Compute the number of block necessary based on a constant number of threads per block
    // Be careful - this can launch more threads than we need, we need to handle this in the kernel!
    int threadsPerBlock = 1024;
    int blocks = (int)ceil((float)N/threadsPerBlock);

    // Launch the kernel
    add<<<blocks,threadsPerBlock>>>(dev_a, dev_b, dev_c);
    
    // Move the result back from the GPU to the host
    cudaMemcpy( c, dev_c, N * sizeof(int), cudaMemcpyDeviceToHost );
    
    for (int i=0; i < N; i++) {
        printf( "%d + %d = %d\n", a[i], b[i], c[i] );
    }
 
    // Always free the memory you explicitly allocated
    cudaFree( dev_a );
    cudaFree( dev_b );
    cudaFree( dev_c );

    return 0;
}
