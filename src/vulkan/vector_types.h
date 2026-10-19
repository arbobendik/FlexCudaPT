// CUDA's vector types renderer.h, main.cpp and loader.h use, aligned as CUDA aligns them
#pragma once
struct alignas(8) float2 { float x, y; };
struct float3 { float x, y, z; };
struct alignas(16) float4 { float x, y, z, w; };
struct alignas(2) char2 { signed char x, y; };
