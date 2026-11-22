// bluenoise SIDE OUT: the blue-noise tensor the add-on ships, generated on the CPU by FlexKernels' own noise.cpp:
// white, then 64 sweeps of 8 colours' blocks, as the renderer's kernels generate it, bit for bit
#include <cstdio>
#include <cstdlib>
#include <vector>
#include "noise.cpp"
int main(int, char** argv) {
    const uint32_t size = std::atoi(argv[1]), texels = size * size * 32, blocks = size / 16 * (size / 16) * 2;
    std::vector<uint32_t> ranks(texels);
    RWStructuredBuffer<uint32_t> tensor{ranks.data(), texels};
    for (uint32_t i = 0; i < texels; ++i) ranks[i] = noiseWhite(i % size, i / size % size, i / (size * size), size);
    for (uint32_t sweep = 0; sweep < 64; ++sweep) for (uint32_t colour = 0; colour < 8; ++colour) {
        #pragma omp parallel for
        for (int32_t block = 0; block < int32_t(blocks); ++block) noiseSweepBlock_0(tensor, sweep, colour, block, size);
    }
    FILE* file = std::fopen(argv[2], "wb");
    return !file || std::fwrite(ranks.data(), sizeof(uint32_t), texels, file) != texels || std::fclose(file);
}
