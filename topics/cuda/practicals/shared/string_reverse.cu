#include <cstdlib>
#include <cstdio>
#include <iostream>

#include "util.hpp"

// TODO : implement a kernel that reverses a string of length n in place
__global__
void reverse_string(char* str, int n){
    extern __shared__ char stringBuffer[];
    auto i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i<n){
        stringBuffer[i]=str[i];
    }
    __syncthreads();
    str[n-i] = stringBuffer[i];
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
    auto block_dim = 64;
    auto grid_dim = (n + block_dim - 1) / block_dim;
    reverse_string<<<grid_dim, block_dim, (n + 1) * sizeof(char)>>>(string, n);
    // print reversed string
    cudaDeviceSynchronize();
    std::cout << "reversed string:\n" << string << "\n";

    // free memory
    cudaFree(string);

    return 0;
}

