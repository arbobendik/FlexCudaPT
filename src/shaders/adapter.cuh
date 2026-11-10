// FlexKernels' scene hooks (walk.slang's HookScene) by the renderer's own functions, in the order walk.slang lists them:
// thin calls, its types converted to and from the renderer's. The scene is the one the raygens read
__device__ const Scene& hookScene() { return *(const Scene*)optixGetSbtDataPointer(); }
__device__ Hit nativeHit(FKHit hit) { return {hit.triangle_index, hit.instance_index, hit.uv}; }
// A miss has no instance, as the walk tests it; no point lights exist to consider. Off a surface, past its margin, as
// traverse starts by default, skipping the face a straight pass leaves by, if it was reached past that margin; from a
// medium's vertex, on none, right at it
__device__ FKHit fcptTraverseInstanceBVH(FKRay ray, bool consider_point_lights, float max_len, bool surface,
    FKHit left) {
    const Scene& scene = hookScene();
    float distance = 0;
    const Hit hit = surface ? traverse(scene, ray.origin, ray.unit_direction, max_len, distance,
        left.instance_index != NONE && left.distance >= MARGIN ? key(scene, nativeHit(left)) : NONE)
        : traverse(scene, ray.origin, ray.unit_direction, max_len, distance, NONE, 0);
    return {hit.uv, hit.triangle == NONE ? NONE : hit.instance, hit.triangle, 0, distance};
}
// FK: the sky's shadow toward a sample of the environment's CDF, which the renderer has none of until C9-C10
__device__ float3 fcptShadowTransmittance(FKRay ray, float l) { return make_float3(0, 0, 0); }
// Blocked, all zero; the medium's scattering passing reads none of. The vertex's ray: its incoming segment and cone width
__device__ float3 fcptShadowTransmittanceIn(FKRay ray, float l, float3 extinction, unsigned filling,
    unsigned random_state, unsigned depth, unsigned lobe, bool surface, float length, float width) {
    float3 transmitted;
    return occluded(hookScene(), ray.origin, ray.unit_direction, l, Medium{make_float3(0, 0, 0), extinction}, filling,
        random_state, Ray{depth == 0, false, lobe, float(depth), length, width}, surface, transmitted)
        ? make_float3(0, 0, 0) : transmitted;
}
// A shaded surface as the walk takes it, unfaced, its material as the walk's BSDF takes it, absorbing nothing (FK's walk
// keeps FlexLight's absorption; the renderer's media absorb); shading takes no random number
__device__ FKSurface walkSurface(const Scene& scene, Hit at, const Surface& surface, float3 position,
    unsigned random_state) {
    const float3 face = faceNormal(scene, at);
    return {surface.normal, face, geometryOffset(scene, at, face, position), {surface.albedo, surface.emissive,
        surface.roughness, surface.metallic, surface.transparency, surface.ior, make_float3(1, 1, 1),
        used(SPECULAR) ? surface.tint : make_float3(1, 1, 1), used(SPECULAR) ? surface.level : 1,
        used(TRANSLUCENT) ? surface.translucent : make_float3(0, 0, 0),
        used(SHEEN) ? surface.sheen : make_float3(0, 0, 0), used(SHEEN) ? surface.sheen_roughness : 0.5f,
        used(ANISOTROPIC) ? surface.anisotropy : 0, used(ANISOTROPIC) ? surface.anisotropic_rotation : 0,
        used(ANISOTROPIC) ? surface.tangent : make_float3(0, 0, 0)}, false, random_state, surface.coverage,
        encloses(scene, surface, at.instance), {volume(surface).scatter, volume(surface).extinction},
        fills(scene, at.instance, at.triangle)};
}
// A light sample's emission as sampleLight shades it: its emission program, toward the triangle's face, for no ray a
// bounce past the vertex sampling it
__device__ FKSurface fcptLightSurfaceAt(FKHit hit, float3 point, unsigned random_state, float3 dir, unsigned depth,
    float length) {
    const Scene& scene = hookScene();
    const Hit at = nativeHit(hit);
    const Corners corner = corners(scene.vertices, scene.instances[at.instance], at.triangle);
    return walkSurface(scene, at, shade(scene, at.instance, at.triangle, at.uv.x, at.uv.y,
        cross(corner[1] - corner[0], corner[2] - corner[0]), dir, Ray{false, false, LOBE_NONE, float(depth + 1), length},
        0, true), point, random_state);
}
// The surface as the walk's loop shades a hit
__device__ FKSurface fcptSurfaceAtPath(FKHit hit, float3 origin, unsigned random_state, float width, unsigned layer,
    unsigned depth, unsigned lobe, float3 dir) {
    const Scene& scene = hookScene();
    const Hit at = nativeHit(hit);
    return walkSurface(scene, at, shade(scene, at.instance, at.triangle, at.uv.x, at.uv.y, smoothNormal(scene, at), dir,
        Ray{depth == 0, false, lobe, float(depth), hit.distance, width}, layer), hitPosition(scene, scene.vertices, at),
        random_state);
}
__device__ unsigned fcptLayers(FKHit hit) { return hookScene().materials[key(hookScene(), nativeHit(hit))].layers; }
__device__ float fcptMajorant(unsigned filling) { return hookScene().instances[owner(hookScene(), filling)].majorant; }
__device__ FKMedium fcptCameraMedium(float3 direction, float distance, unsigned* filling) {
    const Medium medium = cameraMedium(hookScene(), direction, distance, *filling);
    return {medium.scatter, medium.extinction};
}
__device__ float fcptTrackMedium(unsigned filling, float3 origin, float3 dir, float distance, unsigned* random_state,
    float3* weight, float3* glowed, float3* scatter, float3* extinction, unsigned depth, unsigned lobe, bool camera) {
    Medium medium = {*scatter, *extinction};
    const float along = track(hookScene(), medium, filling, origin, dir, distance, *random_state, *weight, *glowed,
        Ray{camera, false, lobe, float(depth), distance});
    *scatter = medium.scatter, *extinction = medium.extinction;
    return along;
}
__device__ float3 fcptHitPosition(FKHit hit) { return hitPosition(hookScene(), hookScene().vertices, nativeHit(hit)); }
__device__ SlangMatrix<float, 3, 3> fcptWorldTriangle(unsigned instance, unsigned triangle) {
    const Corners corner = corners(hookScene().vertices, hookScene().instances[instance], triangle);
    return makeMatrix<float, 3, 3>(corner[0], corner[1], corner[2]);
}
// The light tree's nodes as FlexLight's texels: x whether a leaf (0 a node, 1 a triangle, 2 a point light, none here),
// a leaf's y its instance and z its triangle within it, which a node's leave meaningless, w unused; a node's second
// child, the first following it
__device__ LightNode fcptLightBounds(unsigned n) { return hookScene().lights[n]; }
__device__ uint4 fcptLightNode(unsigned n) {
    const LightNode& node = hookScene().lights[n];
    return make_uint4(node.leaf, node.instance, node.child - hookScene().instances[node.instance].first, 0);
}
__device__ unsigned fcptLightSecond(unsigned n) { return hookScene().lights[n].child; }
// A light's slot, its triangle's number, whose trail of 64 bits is x low and y high; none of a strand, which no light
// sampling picks
__device__ unsigned fcptLightSlot(FKHit hit) {
    return STRAND(hookScene(), hit.instance_index) ? NONE : key(hookScene(), nativeHit(hit));
}
__device__ uint4 fcptLightTrail(unsigned j) {
    const unsigned long long trail = hookScene().trails[j];
    return make_uint4(unsigned(trail), unsigned(trail >> 32), 0, 0);
}
__device__ bool fcptSlotLeaf(unsigned n, unsigned j) {
    const Hit light = owned(hookScene(), j);
    return hookScene().lights[n].child == light.triangle && hookScene().lights[n].instance == light.instance;
}
// FK: point lights, which the renderer has none of; no node names one
__device__ FKLight fcptLight(unsigned index) { return {}; }
__device__ unsigned fcptTriangleOffset(unsigned instance) { return hookScene().instances[instance].first; }
__device__ float3 fcptCalculatePointLightContrib(unsigned index) { return make_float3(0, 0, 0); }
// The world the renderer shades escapes by, along an escape's direction from FK's vertex b, the renderer's bounce b + 2,
// left by FK's lobe; FK takes it for its environment map wherever its size passes 1 x 1, which none has: the world
// always shades. Its luminance CDF none (FK: sky sampling, which the renderer has none of until C9-C10), nor an ambient
// color without a world
__device__ float3 fcptEnvMapSample(float3 dir, unsigned depth, unsigned lobe) {
    return environment(hookScene(), dir, Ray{false, false, lobe, float(depth + 2u), 0});
}
__device__ float4 fcptEnvironmentCdf(uint2 cell) { return make_float4(0, 0, 0, 0); }
__device__ uint2 fcptEnvironmentCdfSize() { return make_uint2(0, 0); }
__device__ uint2 fcptEnvironmentMapSize() { return make_uint2(2, 2); }
__device__ float3 fcptAmbient() { return make_float3(0, 0, 0); }
__device__ unsigned fcptMaxBounces() { return hookScene().settings.bounces; }
__device__ FKHit fcptReservoirHit(Reservoir r) { return {r.rc.uv, r.rc.instance, r.rc.triangle, 0, 0}; }
__device__ void fcptWithReservoirHit(Reservoir* r, const FKHit* hit) { r->rc = nativeHit(*hit); }
