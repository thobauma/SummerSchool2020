#include <cstdlib>
#include <cstdio>
#include <iostream>

#include "util.hpp"

// naive solution:
__global__
void reverse_stringNaiveSol(char* str, int n){
    int i = threadIdx.x;
    if (i<n){
        char tmp = str[i];
        str[i] = str[n-i-1];
        str[n-i-1] = tmp;
    }
}
// reverse_stringNaiveSol<<<1,1024>>>(string,n);


// shared version:
__global__
void reverse_stringSharedSol(char* str, int n){
    __shared__ char tmp[1024];
    int i = threadIdx.x;
    if (i<n){
        char tmp[i] = str[i];
        __syncthreads();
        str[i] = tmp[n-i-1];
    }
}

// optimal solution
__global__
void reverse_stringOptimalSol(char* str, int n){
    int i = threadIdx.x;
    if (i<n/2){
        char tmp = str[i];
        str[i] = str[n-i-1];
        str[n-i-1] = tmp;
    }
}


// TODO : implement a kernel that reverses a string of length n in place
// MY VERSION
__global__
void reverse_string(char* str, int n){
    extern __shared__ char stringBuffer[];
    auto i = threadIdx.x;
    // auto i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i<n){
        stringBuffer[i]=str[i];
    }
    __syncthreads();
    str[n-i-1] = stringBuffer[i];
}

int main(int argc, char** argv) {
    // check that the user has passed a string to reverse
    if(argc<2) {
        std::cout << "useage : ./string_reverse \"string to reverse\"\n" << std::endl;
        exit(0);
    }

    // determine the length of the string, and copy in to buffer
    auto n = strlen(argv[1]);
    auto string = malloc_managed<char>(n+1);
    std::copy(argv[1], argv[1]+n, string);
    string[n] = 0; // add null terminator

    std::cout << "string to reverse:\n" << string << "\n";

    // TODO : call the string reverse function
    auto block_dim = n;
    auto grid_dim = (n + block_dim - 1) / block_dim;
    reverse_stringOptimalSol<<<1,1024>>>(string,n);
    // reverse_string<<<1, block_dim, (n + 1) * sizeof(char)>>>(string, n);
    // reverse_string<<<grid_dim, block_dim, (n + 1) * sizeof(char)>>>(string, n);
    // print reversed string
    cudaDeviceSynchronize();
    std::cout << "reversed string:\n" << string << "\n";

    // free memory
    cudaFree(string);

    return 0;
}

