// FlexKernels' ReSTIR walk (flexkernels-restir/pathtracer.cuh) in place of its BSDFs alone: the types its hooks take,
// laid out as walk.slang's, and the hooks, which adapter.cuh defines past the renderer's functions they call
#define Matrix SlangMatrix
#include "flexkernels-restir/slang-cuda-prelude.h"
#undef Matrix
struct FKHit { float2 uv; unsigned instance_index, triangle_index, is_point_light; float distance; };
struct FKRay { float3 origin, unit_direction; };
struct FKMedium { float3 scatter, extinction; };
struct FKSurface {
    float3 smooth_n, geometry_n; float geometry_offset; BSDFMaterial material; bool skip; unsigned random_state;
    float coverage; bool encloses; FKMedium volume; unsigned fills;
};
struct FKLight { float3 position; float is_area_light; float3 color; float intensity, variance; };
__device__ FKHit fcptTraverseInstanceBVH(FKRay ray, bool consider_point_lights, float max_len, bool surface, FKHit left);
__device__ float3 fcptShadowTransmittance(FKRay ray, float l);
__device__ float3 fcptShadowTransmittanceIn(FKRay ray, float l, float3 extinction, unsigned filling,
    unsigned random_state, unsigned depth, unsigned lobe, bool surface, float length, float width);
__device__ FKSurface fcptLightSurfaceAt(FKHit hit, float3 point, unsigned random_state, float3 dir, unsigned depth,
    float length);
__device__ FKSurface fcptSurfaceAtPath(FKHit hit, float3 origin, unsigned random_state, float width, unsigned layer,
    unsigned depth, unsigned lobe, float3 dir);
__device__ unsigned fcptLayers(FKHit hit);
__device__ float fcptMajorant(unsigned filling);
__device__ FKMedium fcptCameraMedium(float3 direction, float distance, unsigned* filling);
__device__ float fcptTrackMedium(unsigned filling, float3 origin, float3 dir, float distance, unsigned* random_state,
    float3* weight, float3* glowed, float3* scatter, float3* extinction, unsigned depth, unsigned lobe, bool camera);
__device__ float3 fcptHitPosition(FKHit hit);
__device__ SlangMatrix<float, 3, 3> fcptWorldTriangle(unsigned instance, unsigned triangle);
__device__ LightNode fcptLightBounds(unsigned n);
__device__ uint4 fcptLightNode(unsigned n);
__device__ unsigned fcptLightSecond(unsigned n);
__device__ unsigned fcptLightSlot(FKHit hit);
__device__ uint4 fcptLightTrail(unsigned j);
__device__ bool fcptSlotLeaf(unsigned n, unsigned j);
__device__ FKLight fcptLight(unsigned index);
__device__ unsigned fcptTriangleOffset(unsigned instance);
__device__ float3 fcptCalculatePointLightContrib(unsigned index);
__device__ float3 fcptEnvMapSample(float3 dir, unsigned depth, unsigned lobe);
__device__ float4 fcptEnvironmentCdf(uint2 cell);
__device__ uint2 fcptEnvironmentCdfSize();
__device__ uint2 fcptEnvironmentMapSize();
__device__ float3 fcptAmbient();
__device__ unsigned fcptMaxBounces();
__device__ FKHit fcptReservoirHit(Reservoir r);
__device__ void fcptWithReservoirHit(Reservoir* r, const FKHit* hit);
#include "flexkernels-restir/pathtracer.cuh"
// The renderer's own camera domain and vertex, which the walk's replace at C3, by other names until then
#define Domain NativeDomain
#define Vertex NativeVertex
