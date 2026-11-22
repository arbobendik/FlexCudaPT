#pragma once
#include "shaders/renderer.h"
#include <cstdlib>
#include <string>
#include <pwd.h>
#include <unistd.h>

// Varying media, strands or hair, the steps after MEDIUM, a panoramic camera, a script reading its hit's triangle or
// a rarer noise: the extended PTX alone
inline bool extended(const Params& params) {
    return params.ops[MEDIUM >> 6] >> (MEDIUM & 63) & 15 || params.ops[PANORAMA >> 6] >> (PANORAMA & 63) & 1
        || params.ops[TRIANGLE >> 6] >> (TRIANGLE & 63) & 1 || params.ops[NOISE_EXTRA >> 6] >> (NOISE_EXTRA & 63) & 1;
}

// OptiX's disk cache, by the user's name
inline std::string cacheDirectory() {
    const char* path = std::getenv("OPTIX_CACHE_PATH");
    return path ? path : "/var/tmp/OptixCache_" + std::string(getpwuid(getuid())->pw_name);
}
