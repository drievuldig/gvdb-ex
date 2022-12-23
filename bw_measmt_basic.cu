// results on A5000 (Nblocks=256*4096, Nthreads=256) =>
// single write: Equivalent mem transfer speed: 709.4GB/s
// read + write: Equivalent mem transfer speed: 685.4GB/s
// 2 reads + write: Equivalent mem transfer speed: 692.0GB/s

#include <stdio.h>
#include <iostream>

__global__ void hello_world()
{
  printf("GPU hello world!\n");
}

__global__ void vector_add(float *out, float *a, float *b) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    // printf("i = %d\n", i);
    out[i] = a[i] + b[i];
    // out[i] = 1.0;
    // out[i] = a[i];
}

int main() {
    
    int nDevices;
    cudaGetDeviceCount(&nDevices);
    
    printf("Number of devices: %d\n", nDevices);
    
    for (int i = 0; i < nDevices; i++) {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, i);
        printf("Device Number: %d\n", i);
        printf("  Device name: %s\n", prop.name);
        printf("  Memory Clock Rate (MHz): %d\n",
            prop.memoryClockRate/1024);
        printf("  Memory Bus Width (bits): %d\n",
            prop.memoryBusWidth);
        printf("  Peak Memory Bandwidth (GB/s): %.1f\n",
            2.0*prop.memoryClockRate*(prop.memoryBusWidth/8)/1.0e6);
        printf("  Total global memory (Gbytes) %.1f\n",(float)(prop.totalGlobalMem)/1024.0/1024.0/1024.0);
        printf("  Shared memory per block (Kbytes) %.1f\n",(float)(prop.sharedMemPerBlock)/1024.0);
        printf("  minor-major: %d-%d\n", prop.minor, prop.major);
        printf("  Warp-size: %d\n", prop.warpSize);
        printf("  Concurrent kernels: %s\n", prop.concurrentKernels ? "yes" : "no");
        printf("  Concurrent computation/communication: %s\n\n",prop.deviceOverlap ? "yes" : "no");
    }

    int Nblocks = 256*4096;
    int Nthreads = 256;
    int N = Nblocks * Nthreads;

    float *a, *b, *out; 

    // Allocate memory
    a   = (float*)malloc(sizeof(float) * N);
    b   = (float*)malloc(sizeof(float) * N);
    out = (float*)malloc(sizeof(float) * N);

    // Initialize array
    for(int i = 0; i < N; i++){
        a[i] = 1.0f; b[i] = 2.0f;
    }

    float *d_a, *d_b, *d_out;

    // Allocate device memory
    cudaMalloc((void**)&d_a, sizeof(float) * N);
    cudaMalloc((void**)&d_b, sizeof(float) * N);
    cudaMalloc((void**)&d_out, sizeof(float) * N);

    // Transfer data from host to device memory
    cudaMemcpy(d_a, a, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeof(float) * N, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    vector_add<<<Nblocks,Nthreads>>>(d_out, d_a, d_b);
    // hello_world<<<1,4>>>();
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaDeviceSynchronize();
    
    // Transfer data back to host memory
    cudaMemcpy(out, d_out, sizeof(float) * N, cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("time elapsed: %.1f ms\n", milliseconds);
    printf("Equivalent mem transfer speed: %.1fGB/s\n", 
        3.0*4.0*(float)N/(1'000'000.0*milliseconds));
    printf("sizeof(float): %d\n", (int)sizeof(float));
    
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_out);
    free(a);
    free(b);
    free(out);

    return 0;
}
