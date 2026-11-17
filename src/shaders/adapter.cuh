// FlexKernels' scene hooks (walk.slang's HookScene) by the renderer's own functions, in the order walk.slang lists
// them: thin calls, its types converted to and from the renderer's. The scene is the one the raygens read
static __device__ const Scene& hookScene() { return *(const Scene*)optixGetSbtDataPointer(); }
static __device__ Hit nativeHit(FKHit hit) { return {hit.triangle_index, hit.instance_index, hit.uv}; }
// A miss has no instance, as the walk tests it; no point lights exist to consider. Off a surface, past its margin, as
// traverse starts by default, skipping the face a straight pass leaves by, if it was reached past that margin; from no
// margin, as from a medium's vertex, skipping the face it starts on, if any. Seen straight from the camera, hidden
// layers passed as pixelDomain passes them
static __device__ FKHit fcptTraverseInstanceBVH(FKRay ray, bool consider_point_lights, float max_len, bool surface,
    FKHit left, bool viewed) {
    const Scene& scene = hookScene();
    float distance = 0;
    Hit hit = surface ? traverse(scene, ray.origin, ray.unit_direction, max_len, distance,
        left.instance_index != NONE && left.distance >= MARGIN ? key(scene, nativeHit(left)) : NONE)
        : traverse(scene, ray.origin, ray.unit_direction, max_len, distance,
        left.instance_index != NONE ? key(scene, nativeHit(left)) : NONE, 0);
    for (bool first = true; viewed && hit.triangle != NONE && scene.materials[key(scene, hit)].hidden != 0;
        first = false) {
        if (first) distance = __uint_as_float(__float_as_uint(distance) - 1);
        hit = nextLayer(scene, ray.origin, ray.unit_direction, max_len, distance, first ? NONE : key(scene, hit));
    }
    return {hit.uv, hit.triangle == NONE ? NONE : hit.instance, hit.triangle, 0, distance};
}
// Blocked, all zero; the medium's scattering passing reads none of. The vertex's ray: its incoming segment and cone
// width
static __device__ __noinline__ float3 fcptShadowTransmittanceIn(FKRay ray, float l, float3 extinction, unsigned filling,
    unsigned random_state, unsigned depth, unsigned lobe, bool surface, float length, float width, FKHit left,
    FKHit light) {
    float3 transmitted;
    return occluded(hookScene(), ray.origin, ray.unit_direction, l, Medium{make_float3(0, 0, 0), extinction}, filling,
        random_state, Ray{depth == 0, false, lobe, float(depth), length, width}, surface, transmitted,
        left.instance_index != NONE ? key(hookScene(), nativeHit(left)) : NONE,  // A light casting none: past all
        light.instance_index != NONE && hookScene().materials[key(hookScene(), nativeHit(light))].opaque & 4 ? 0
        : SHADOWS)
        ? make_float3(0, 0, 0) : transmitted;
}
// FlexLight's geometry offset of a triangle's point at position, along its smooth normal, by its corners' normals' tilt
// off the face; none on a strand's segment, which has no corners
static __device__ float geometryOffsetAt(const Scene& scene, Hit at, float3 face, float3 position) {
    if (STRAND(scene, at.instance)) return 0;
    const Corners corner = corners(scene.vertices, scene.instances[at.instance], at.triangle);
    const Corners normal = cornerNormals(scene.normals, scene.instances[at.instance], at.triangle);
    return geometryOffset(corner[0], corner[1], corner[2], normal[0], normal[1], normal[2], face,
        make_float3(1 - at.uv.x - at.uv.y, at.uv.x, at.uv.y), position);
}
// A shaded surface as the walk takes it, unfaced, its material as the walk's BSDF takes it, absorbing nothing (FK's
// walk keeps FlexLight's absorption; the renderer's media absorb); shading takes no random number. Rays leave a
// surface letting no light through by FlexLight's geometry offset; one transmitting or translucent, and a fiber, from
// the hit: a start lifted along the smooth normal passes the far side of a shell thinner than the lift, which an
// eighth of the face's shortest edge reaches on any thin closed mesh shaded smooth
static __device__ FKSurface walkSurface(const Scene& scene, Hit at, const Surface& surface, float3 position,
    unsigned random_state) {
    const float3 face = faceNormal(scene, at);
    const bool enclosed = encloses(scene, surface, at.instance);
    const bool hair = used(HAIR) && dot(surface.hair, surface.hair) > 0;  // Its fiber, which rays leave from the vertex
    const bool passes = surface.transparency > 0 || used(TRANSLUCENT) && rgb_to_greyscale(surface.translucent) > 0;
    return {surface.normal, face, hair || passes ? 0.0f : geometryOffsetAt(scene, at, face, position), {surface.albedo,
        surface.emissive,
        surface.roughness, surface.metallic, surface.transparency, surface.ior, make_float3(1, 1, 1),
        used(SPECULAR) ? surface.tint : make_float3(1, 1, 1), used(SPECULAR) ? surface.level : 1,
        used(TRANSLUCENT) ? surface.translucent : make_float3(0, 0, 0),
        used(SHEEN) ? surface.sheen : make_float3(0, 0, 0), used(SHEEN) ? surface.sheen_roughness : 0.5f,
        used(ANISOTROPIC) ? surface.anisotropy : 0, used(ANISOTROPIC) ? surface.anisotropic_rotation : 0,
        used(ANISOTROPIC) ? surface.tangent : make_float3(0, 0, 0), used(VELVET) ? surface.velvet : 0,
        used(TOON) ? surface.toon : make_float3(0, 0, 0), used(DISPERSION) ? surface.dispersion : 0}, false,
        random_state, surface.coverage,
        enclosed, enclosed ? FKMedium{volume(surface).scatter, volume(surface).extinction, volume(surface).g}
        : FKMedium{},
        enclosed ? fills(scene, at.instance, at.triangle) : NONE, surface.hair};
}
// A light sample's emission as the renderer's light sampling shaded it: its emission program toward the triangle's
// face, for no ray a bounce past the vertex sampling it, and its smooth normal; the shadow ray ends at the sampled
// point itself, not lifted
static __device__ __noinline__ FKSurface fcptLightSurfaceAt(FKHit hit, float3 point, unsigned random_state, float3 dir,
    unsigned depth, float length) {
    const Scene& scene = hookScene();
    const Hit at = nativeHit(hit);
    const Corners corner = corners(scene.vertices, scene.instances[at.instance], at.triangle);
    FKSurface light = walkSurface(scene, at, shade(scene, at.instance, at.triangle, at.uv.x, at.uv.y,
        cross(corner[1] - corner[0], corner[2] - corner[0]), dir,
        Ray{false, false, LOBE_NONE, float(depth + 1), length}, 0, true), point, random_state);
    light.smooth_n = smoothNormal(scene, at);
    return light;
}
// The surface as the walk's loop shades a hit
static __device__ __noinline__ FKSurface fcptSurfaceAtPath(FKHit hit, float3 origin, unsigned random_state, float width,
    unsigned layer, unsigned depth, unsigned lobe, float3 dir) {
    const Scene& scene = hookScene();
    const Hit at = nativeHit(hit);
    return walkSurface(scene, at, shade(scene, at.instance, at.triangle, at.uv.x, at.uv.y, smoothNormal(scene, at), dir,
        Ray{depth == 0, false, lobe, float(depth), hit.distance, width}, layer), hitPosition(scene, scene.vertices, at),
        random_state);
}
// Whether hair is compiled in: the renderer's own switch, false in the PTX compiled without it, which folds the walk's
// hair code out; bound per scene where it is compiled
static __device__ __forceinline__ bool fcptHairUsed() { return used(HAIR); }
static __device__ __forceinline__ bool fcptDispersionUsed() { return used(DISPERSION); }
// Whether the walk shades a light sample's emitter only once its shadow ray lets light through: on OptiX, where many
// emitters each shaded before the test cost more than the test's branch
static __device__ __forceinline__ constexpr bool fcptShadowFirst() { return true; }
// A hair fiber's scattering, as the renderer's walk takes it: of its fiber along hair by its level, its color and the
// specular tint, which are all the hair's BSDF reads of a surface
static __device__ SampleBSDF fcptConnectHair(float3 hair, float3 albedo, float3 tint, float3 in_dir, float3 out_dir) {
    Surface fiber{};
    fiber.hair = hair, fiber.albedo = albedo, fiber.tint = tint;
    return connectHair(hookScene(), fiber, in_dir, out_dir);
}
static __device__ SampleBSDF fcptSampleHair(float3 hair, float3 albedo, float3 tint, float3 in_dir,
    unsigned random_state) {
    Surface fiber{};
    fiber.hair = hair, fiber.albedo = albedo, fiber.tint = tint;
    return sampleHair(hookScene(), fiber, in_dir, random_state);
}
static __device__ unsigned fcptLayers(FKHit hit) {
    return hookScene().materials[key(hookScene(), nativeHit(hit))].layers;
}
// Its size: stored negative, it marks an extinction drawn exactly
static __device__ float fcptMajorant(unsigned filling) {
    return fabsf(hookScene().instances[owner(hookScene(), filling)].majorant);
}
// Whether varying media are compiled in: the renderer's own constant, which folds the walk's code for them
static __device__ bool fcptVaryingUsed() { return used(MEDIUM); }
// The medium a ray leaving a volume through the face of hit enters
static __device__ FKMedium fcptOutsideMedium(FKHit hit) {
    const Medium medium = outside(hookScene(), hit.instance_index);
    return {medium.scatter, medium.extinction, medium.g};
}
static __device__ __noinline__ FKMedium fcptCameraMedium(float3 direction, float distance, unsigned* filling) {
    const Medium medium = cameraMedium(hookScene(), direction, distance, *filling);
    return {medium.scatter, medium.extinction, medium.g};
}
static __device__ float fcptTrackMedium(unsigned filling, float3 origin, float3 dir, float distance,
    unsigned* random_state, float3* weight, float3* glowed, float3* scatter, float3* extinction, float* g,
    unsigned depth, unsigned lobe, bool camera) {
    Medium medium = {*scatter, *extinction, *g};
    const float along = track(hookScene(), medium, filling, origin, dir, distance, *random_state, *weight, *glowed,
        Ray{camera, false, lobe, float(depth), distance});
    *scatter = medium.scatter, *extinction = medium.extinction, *g = medium.g;
    return along;
}
static __device__ float3 fcptHitPosition(FKHit hit) {
    return hitPosition(hookScene(), hookScene().vertices, nativeHit(hit));
}
static __device__ SlangMatrix<float, 3, 3> fcptWorldTriangle(unsigned instance, unsigned triangle) {
    const Corners corner = corners(hookScene().vertices, hookScene().instances[instance], triangle);
    return makeMatrix<float, 3, 3>(corner[0], corner[1], corner[2]);
}
// The light tree's nodes as FlexLight's texels: x whether a leaf (0 a node, 1 a triangle, 2 a point light, none here),
// a leaf's y its instance and z its triangle within it, which a node's leave meaningless, w unused; a node's second
// child, the first following it
static __device__ LightNode fcptLightBounds(unsigned n) { return hookScene().lights[n]; }
static __device__ uint4 fcptLightNode(unsigned n) {
    const LightNode& node = hookScene().lights[n];
    return make_uint4(node.leaf, node.instance, node.child - hookScene().instances[node.instance].first, 0);
}
static __device__ unsigned fcptLightSecond(unsigned n) { return hookScene().lights[n].child; }
// A light's slot, its triangle's number, whose trail of 64 bits is x low and y high; none of a strand, which no light
// sampling picks
static __device__ unsigned fcptLightSlot(FKHit hit) {
    return STRAND(hookScene(), hit.instance_index) ? NONE : key(hookScene(), nativeHit(hit));
}
static __device__ uint4 fcptLightTrail(unsigned j) {
    const unsigned long long trail = hookScene().trails[j];
    return make_uint4(unsigned(trail), unsigned(trail >> 32), 0, 0);
}
static __device__ bool fcptSlotLeaf(unsigned n, unsigned j) {
    const Hit light = owned(hookScene(), j);
    return hookScene().lights[n].child == light.triangle && hookScene().lights[n].instance == light.instance;
}
// FK: point lights, which the renderer has none of; no node names one
static __device__ FKLight fcptLight(unsigned index) { return {}; }
static __device__ unsigned fcptTriangleOffset(unsigned instance) { return hookScene().instances[instance].first; }
static __device__ float3 fcptCalculatePointLightContrib(unsigned index) { return make_float3(0, 0, 0); }
// The world the renderer shades escapes by, along an escape's direction from FK's vertex b, the renderer's bounce
// b + 2, left by FK's lobe; FK takes it for its environment map wherever its size passes 1 x 1, which none has: the
// world always shades. No ambient color without a world
static __device__ float3 fcptEnvMapSample(float3 dir, unsigned depth, unsigned lobe) {
    return environment(hookScene(), dir, Ray{false, false, lobe, float(depth + 2u), 0});
}
// Its luminance CDF by cell, (cdf, share), the marginal in the last column; none where the world is not sampled
static __device__ float4 fcptEnvironmentCdf(uint2 cell) {
    const float2 c = hookScene().environmentCdf[cell.y * hookScene().cdfWidth + cell.x];
    return make_float4(c.x, c.y, 0, 0);
}
static __device__ uint2 fcptEnvironmentCdfSize() {
    return used(SKY) ? make_uint2(hookScene().cdfWidth, hookScene().cdfHeight) : make_uint2(0, 0);
}
static __device__ uint2 fcptEnvironmentMapSize() { return make_uint2(2, 2); }
static __device__ float3 fcptAmbient() { return make_float3(0, 0, 0); }
static __device__ unsigned fcptMaxBounces() { return hookScene().settings.bounces; }
static __device__ FKHit fcptReservoirHit(Reservoir r) { return {r.rc.uv, r.rc.instance, r.rc.triangle, 0, 0}; }
static __device__ void fcptWithReservoirHit(Reservoir* r, const FKHit* hit) { r->rc = nativeHit(*hit); }
// Reuse-pass hooks: a pixel's domain is its seed's camera ray (pixelDomain); none off the image or on a miss
static __device__ unsigned pixelIndex(int2 p) { return p.y * hookScene().width + p.x; }
static __device__ bool onImage(int2 p) {
    return p.x >= 0 && p.y >= 0 && p.x < int(hookScene().width) && p.y < int(hookScene().height);
}
static __device__ FKDomain fkDomain(const Domain& dom) {
    return {dom.x0, dom.x1, {dom.hit.uv, dom.hit.triangle == NONE ? NONE : dom.hit.instance, dom.hit.triangle, 0,
        length(dom.x1 - dom.x0)}, dom.width, dom.spread};
}
static __device__ Domain nativeDomain(const FKDomain& dom) {
    return {dom.x0, dom.x1, nativeHit(dom.hit), dom.width, dom.spread};
}
// The scene the previous frame traced: the anchor's on a view's first frame, which reuses its reservoirs
static __device__ const Scene& previousScene() { return hookScene().frame == 0 ? *hookScene().anchor : hookScene(); }
static __device__ uint3 imageSize() { return make_uint3(hookScene().width, hookScene().height, 1); }
// Every pixel on the image is current, a miss keeping its confidence; the passes draw its domain from the seed
static __device__ bool fcptCurrentDomain(int2 p, FKDomain* dom) {
    *dom = {};
    dom->hit.instance_index = NONE;
    return onImage(p);
}
static __device__ bool fcptStoredDomainInitial(int2 p, unsigned seed, FKDomain* dom) {
    if (!onImage(p)) return false;
    *dom = fkDomain(pixelDomain(hookScene(), VIEW(hookScene().camera), pixelIndex(p), imageSize(), seed));
    return dom->hit.instance_index != NONE;
}
static __device__ bool fcptStoredDomainTemporal(int2 p, unsigned seed, FKDomain* dom) {
    return fcptStoredDomainInitial(p, seed, dom);
}
static __device__ FKDomain fcptPreviousDomain(int2 q, unsigned seed) {
    return fkDomain(pixelDomain(previousScene(), VIEW(hookScene().previousCamera), pixelIndex(q), imageSize(), seed));
}
static __device__ float2 fcptPixelOf(float3 position, bool previous) {
    return previous ? project(VIEW(hookScene().previousCamera), position, imageSize())
        : project(VIEW(hookScene().camera), position, imageSize());
}
// Within a view the camera and the scene stay, so every sample keeps its domain; a view's first frame reuses the
// anchor's, whose scene it shifts into
static __device__ bool fcptSceneUnchanged() { return hookScene().frame > 0; }
static __device__ bool fcptPreviousScenes() { return true; }
// The walk as the callables run it: generating, or replaying in this scene or the previous frame's
static __device__ Shift fcptWalk(FKDomain dom, Reservoir r, bool replay, float scale, Selection* sel) {
    const Domain native = nativeDomain(dom);
    return optixDirectCall<Shift>(replay ? 1 : 0, &native, &r, scale, sel);
}
static __device__ Shift fcptShiftPrevious(FKDomain dom, Reservoir r) {
    // Nothing to shift, or nothing seen there
    if (r.w <= 0.0f || dom.hit.instance_index == NONE) return Shift{make_float3(0, 0, 0), 0};
    const Domain native = nativeDomain(dom);
    Selection sel{};
    return optixDirectCall<Shift>(hookScene().frame == 0 ? 2 : 1, &native, &r, 0.0f, &sel);
}
static __device__ uint2 fcptRenderSize() { return make_uint2(hookScene().width, hookScene().height); }
static __device__ unsigned fcptFrame() { return hookScene().frame; }
static __device__ unsigned fcptSamples() { return hookScene().settings.paths; }
static __device__ unsigned fcptRestirNeighbours() { return hookScene().settings.neighbors; }
static __device__ unsigned fcptRestirDecorrelation() { return hookScene().settings.decorrelation; }
static __device__ int4 fcptPairing(int2 texel, unsigned t) {
    const int sizes[] = {PAIRING_SIZES[0], PAIRING_SIZES[1], PAIRING_SIZES[2]};
    const char2 delta = hookScene().pairing[t][texel.y * sizes[t] + texel.x];
    return make_int4(delta.x, delta.y, 0, 0);
}
static __device__ Reservoir fcptLoadReservoirInitial(int2 p) { return hookScene().initial[pixelIndex(p)]; }
static __device__ Reservoir fcptLoadReservoirTemporal(int2 p) { return hookScene().temporal[pixelIndex(p)]; }
static __device__ Reservoir fcptLoadReservoirPrevious(int2 q) { return hookScene().previous[pixelIndex(q)]; }
// A reservoir's layer 0 as the passes read it: seed, path, unbiased contribution weight, confidence
static __device__ uint4 fcptReservoirPrevious(int2 q, unsigned layer) {
    const Reservoir& r = hookScene().previous[pixelIndex(q)];
    return make_uint4(r.seed, r.path, __float_as_uint(r.w), __float_as_uint(r.c));
}
static __device__ uint4 fcptReservoirTemporal(int2 q, unsigned layer) {
    const Reservoir& r = hookScene().temporal[pixelIndex(q)];
    return make_uint4(r.seed, r.path, __float_as_uint(r.w), __float_as_uint(r.c));
}
// Without ReSTIR the scene holds one reservoir and the initial pass stores none
static __device__ void fcptStoreReservoirInitial(int2 p, Reservoir r, FKHit x1) {
    if (onImage(p) && hookScene().settings.restir) hookScene().initial[pixelIndex(p)] = r;
}
static __device__ void fcptStoreReservoirTemporal(int2 p, Reservoir r, FKHit x1) {
    if (onImage(p)) hookScene().temporal[pixelIndex(p)] = r;
}
static __device__ void fcptStoreReservoirPrevious(int2 p, Reservoir r, FKHit x1) {
    if (onImage(p)) hookScene().previous[pixelIndex(p)] = r;
}
// No layer stored beside the reservoir: its primary hit is drawn again from the sample's seed
static __device__ void fcptStorePreviousLayer(int2 p, unsigned layer, uint4 value) {}
static __device__ uint4 fcptDuplication(int2 q) {
    return make_uint4(__float_as_uint(hookScene().duplication[pixelIndex(q)]), 0, 0, 0);
}
static __device__ void fcptStoreDuplication(int2 p, uint4 value) {
    if (onImage(p)) hookScene().duplication[pixelIndex(p)] = __uint_as_float(value.x);
}
static __device__ uint4 shiftTexel(const Shift& shift) {
    return make_uint4(__float_as_uint(shift.f.x), __float_as_uint(shift.f.y), __float_as_uint(shift.f.z),
        __float_as_uint(shift.jac));
}
static __device__ Shift texelShift(uint4 v) {
    return {make_float3(__uint_as_float(v.x), __uint_as_float(v.y), __uint_as_float(v.z)), __uint_as_float(v.w)};
}
static __device__ uint4 fcptShiftData(int2 p, unsigned layer) {
    return shiftTexel(hookScene().shifts[3 * pixelIndex(p) + layer]);
}
static __device__ void fcptStoreShiftData(int2 p, unsigned layer, uint4 value) {
    if (onImage(p)) hookScene().shifts[3 * pixelIndex(p) + layer] = texelShift(value);
}
// The temporal round's shifts in the spatial round's first two slots and its neighbours, a pixel index, -1 for none,
// in the third: all three free until the spatial round's prepass rewrites them
static __device__ uint4 fcptTemporalShift(int2 p, unsigned layer) { return fcptShiftData(p, layer); }
static __device__ void fcptStoreTemporalShift(int2 p, unsigned layer, uint4 value) { fcptStoreShiftData(p, layer, value); }
static __device__ void fcptStoreTemporalNeighbor(int2 p, int2 q) {
    if (onImage(p)) hookScene().shifts[3 * pixelIndex(p) + 2].f.x = __int_as_float(q.x < 0 ? -1 : int(pixelIndex(q)));
}
// OptiX's temporal round unqueued: restir_temporal makes each pixel's two shifts itself
static __device__ bool fcptTemporalQueued() { return false; }
static __device__ int2 fcptLoadTemporalNeighbor(int2 p) {
    const int q = __float_as_int(hookScene().shifts[3 * pixelIndex(p) + 2].f.x);
    return q < 0 ? make_int2(-1, -1) : make_int2(q % int(hookScene().width), q / int(hookScene().width));
}
static __device__ bool fcptRestirUsed() { return hookScene().settings.restir; }
// The world seen along a path whose camera ray hits nothing, at its share of the pixel's paths
static __device__ float3 fcptMissed(int2 p, FKDomain dom, float scale) {
    return environment(hookScene(), normalize(dom.x1 - dom.x0), {true, false, LOBE_NONE, 1, 0})
        / hookScene().settings.paths;
}
// Added to the pixel's sum: the initial pass's with its sample counted, the spatial pass's without
static __device__ void fcptAddColor(int2 p, float4 color) {
    float4& sum = hookScene().accumulation[pixelIndex(p)];
    sum = make_float4(sum.x + color.x, sum.y + color.y, sum.z + color.z, sum.w + color.w);
}
// The queue by global atomics, FlexKernels' CUDA branch
static __device__ unsigned fcptQueueCountAdd(unsigned bin, unsigned jobs) {
    return atomicAdd(hookScene().queue + 3 + bin, jobs);
}
static __device__ unsigned fcptQueueCountLoad(unsigned bin) { return hookScene().queue[3 + bin]; }
static __device__ unsigned fcptQueueCursorAdd(unsigned bin, unsigned jobs) {
    return atomicAdd(hookScene().queue + 43 + bin, jobs);
}
static __device__ void fcptQueueJobStore(unsigned index, unsigned job) { hookScene().queue[QUEUE_HEADER + index] = job; }
// The indirect dispatch's size, which launches over the whole queue leave unread
static __device__ void fcptQueueDispatchStore(unsigned x, unsigned y, unsigned z) {}
static __device__ unsigned fcptQueuedShifts(unsigned index) { return hookScene().queue[index]; }
