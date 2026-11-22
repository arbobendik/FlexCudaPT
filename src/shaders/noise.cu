// The blue-noise tensor's generation, FlexKernels' own kernels; their draws, unused here, read no tensor
static __device__ unsigned fkBlueNoise(unsigned, unsigned, unsigned) { return 0xFFFFFFFFu; }
static __device__ unsigned fkBlueNoiseSize() { return 512; }
#include "flexkernels/noise.cuh"
