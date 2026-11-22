// FlexKernels' ReSTIR walk (flexkernels/pathtracer.cuh) in place of its BSDFs alone: the types its hooks take,
// laid out as walk.slang's, and the hooks, which adapter.cuh defines past the renderer's functions they call
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"
#undef Matrix
struct FKHit { float2 uv; unsigned instance_index, triangle_index, is_point_light; float distance; };
struct FKRay { float3 origin, unit_direction; };
struct FKMedium { float3 scatter, extinction; float g; };
struct FKSurface {
    float3 smooth_n, geometry_n; float geometry_offset; BSDFMaterial material; bool skip; unsigned random_state;
    float coverage; bool encloses; FKMedium volume; unsigned fills; float3 hair;
};
struct FKLight { float3 position; float is_area_light; float3 color; float intensity, variance; };
static __device__ FKHit fcptTraverseInstanceBVH(FKRay ray, bool consider_point_lights, float max_len, bool surface,
    FKHit left, bool viewed);
static __device__ __noinline__ float3 fcptShadowTransmittanceIn(FKRay ray, float l, float3 extinction, unsigned filling,
    unsigned random_state, unsigned depth, unsigned lobe, bool surface, float length, float width, FKHit left,
    FKHit light);
static __device__ __noinline__ FKSurface fcptLightSurfaceAt(FKHit hit, float3 point, unsigned random_state, float3 dir,
    unsigned depth, float length);
static __device__ __noinline__ FKSurface fcptSurfaceAtPath(FKHit hit, float3 origin, unsigned random_state, float width,
    unsigned layer, unsigned depth, unsigned lobe, float3 dir);
struct SampleBSDF;  // FlexKernels' sampled BSDF, which the hair hooks hand back
static __device__ __forceinline__ bool fcptHairUsed();
static __device__ __forceinline__ bool fcptDispersionUsed();
static __device__ __forceinline__ constexpr bool fcptShadowFirst();
static __device__ __forceinline__ bool fcptWorldReadsPath();
static __device__ SampleBSDF fcptConnectHair(float3 hair, float3 albedo, float3 tint, float3 in_dir, float3 out_dir);
static __device__ SampleBSDF fcptSampleHair(float3 hair, float3 albedo, float3 tint, float3 in_dir,
    unsigned random_state);
static __device__ unsigned fcptLayers(FKHit hit);
static __device__ float fcptMajorant(unsigned filling);
static __device__ bool fcptVaryingUsed();
static __device__ FKMedium fcptOutsideMedium(FKHit hit);
static __device__ __noinline__ FKMedium fcptCameraMedium(float3 direction, float distance, unsigned* filling);
static __device__ float fcptTrackMedium(unsigned filling, float3 origin, float3 dir, float distance,
    unsigned* random_state, float3* weight, float3* glowed, float3* scatter, float3* extinction, float* g,
    unsigned depth, unsigned lobe, bool camera);
static __device__ float3 fcptHitPosition(FKHit hit);
static __device__ SlangMatrix<float, 3, 3> fcptWorldTriangle(unsigned instance, unsigned triangle);
static __device__ LightNode fcptLightBounds(unsigned n);
static __device__ uint4 fcptLightNode(unsigned n);
static __device__ unsigned fcptLightSecond(unsigned n);
static __device__ unsigned fcptLightSlot(FKHit hit);
static __device__ uint4 fcptLightTrail(unsigned j);
static __device__ bool fcptSlotLeaf(unsigned n, unsigned j);
static __device__ FKLight fcptLight(unsigned index);
static __device__ unsigned fcptTriangleOffset(unsigned instance);
static __device__ float3 fcptCalculatePointLightContrib(unsigned index);
static __device__ float3 fcptEnvMapSample(float3 dir, unsigned depth, unsigned lobe);
static __device__ float4 fcptEnvironmentCdf(uint2 cell);
static __device__ uint2 fcptEnvironmentCdfSize();
static __device__ uint2 fcptEnvironmentMapSize();
static __device__ float3 fcptAmbient();
static __device__ unsigned fcptMaxBounces();
static __device__ FKHit fcptReservoirHit(Reservoir r);
static __device__ void fcptWithReservoirHit(Reservoir* r, const FKHit* hit);
// The reuse passes' hooks (FK_RESTIR_PASSES), over the pixels the image's size spans
struct Domain;
struct Selection;
static __device__ bool fcptCurrentDomain(int2 p, Domain* dom);
static __device__ bool fcptStoredDomainInitial(int2 p, unsigned seed, Domain* dom);
static __device__ bool fcptStoredDomainTemporal(int2 p, unsigned seed, Domain* dom);
static __device__ Domain fcptPreviousDomain(int2 q, unsigned seed);
static __device__ float2 fcptPixelOf(float3 position, bool previous);
static __device__ bool fcptSceneUnchanged();
static __device__ bool fcptPreviousScenes();
static __device__ Shift fcptWalk(Domain dom, Reservoir r, bool replay, float scale, Selection* sel);
static __device__ Shift fcptShiftPrevious(Domain dom, Reservoir r);
static __device__ uint2 fcptRenderSize();
static __device__ unsigned fcptFrame();
static __device__ unsigned fcptSamples();
static __device__ unsigned fcptRestirNeighbours();
static __device__ unsigned fcptRestirDecorrelation();
static __device__ int4 fcptPairing(int2 texel, unsigned t);
static __device__ Reservoir fcptLoadReservoirInitial(int2 p);
static __device__ Reservoir fcptLoadReservoirTemporal(int2 p);
static __device__ Reservoir fcptLoadReservoirPrevious(int2 q);
static __device__ uint4 fcptReservoirPrevious(int2 q, unsigned layer);
static __device__ uint4 fcptReservoirTemporal(int2 q, unsigned layer);
static __device__ void fcptStoreReservoirInitial(int2 p, Reservoir r, FKHit x1);
static __device__ void fcptStoreReservoirTemporal(int2 p, Reservoir r, FKHit x1);
static __device__ void fcptStoreReservoirPrevious(int2 p, Reservoir r, FKHit x1);
static __device__ void fcptStorePreviousLayer(int2 p, unsigned layer, uint4 value);
static __device__ uint4 fcptDuplication(int2 q);
static __device__ void fcptStoreDuplication(int2 p, uint4 value);
static __device__ uint4 fcptTemporalShift(int2 p, unsigned layer);
static __device__ void fcptStoreTemporalShift(int2 p, unsigned layer, uint4 value);
static __device__ void fcptStoreTemporalNeighbor(int2 p, int2 q);
static __device__ int2 fcptLoadTemporalNeighbor(int2 p);
static __device__ bool fcptTemporalQueued();
static __device__ uint4 fcptShiftData(int2 p, unsigned layer);
static __device__ void fcptStoreShiftData(int2 p, unsigned layer, uint4 value);
static __device__ bool fcptRestirUsed();
static __device__ float3 fcptMissed(int2 p, Domain dom, float scale);
static __device__ void fcptAddColor(int2 p, float4 color);
static __device__ unsigned fcptQueueCountAdd(unsigned bin, unsigned jobs);
static __device__ unsigned fcptQueueCountLoad(unsigned bin);
static __device__ unsigned fcptQueueCursorAdd(unsigned bin, unsigned jobs);
static __device__ void fcptQueueJobStore(unsigned index, unsigned job);
static __device__ void fcptQueueDispatchStore(unsigned x, unsigned y, unsigned z);
static __device__ unsigned fcptQueuedShifts(unsigned index);
// The blue-noise tensor's rank at texel (x, y) of layer t, white (0xFFFFFFFF) without one, and its side
static __device__ unsigned fkBlueNoise(unsigned x, unsigned y, unsigned t);
static __device__ unsigned fkBlueNoiseSize();
#include "flexkernels/pathtracer.cuh"
// The walk's camera domain beside the renderer's own, which its pixels keep
typedef Domain FKDomain;
#define Domain NativeDomain
