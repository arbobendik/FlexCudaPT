#pragma once
#include <vector_types.h>

struct Material { float3 baseColor, emission; };
// Camera at the origin looks down -z. Per triangle: three vertices, one material, cumulative emitted power.
struct Scene {
    float4* accumulation; unsigned long long handle; float3* vertices; Material* materials; double* power;
    unsigned count; float focal;
};
