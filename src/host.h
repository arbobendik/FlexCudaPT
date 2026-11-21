#pragma once
#include <cstdlib>
#include <string>
#include <pwd.h>
#include <unistd.h>

// OptiX's disk cache, by the user's name
inline std::string cacheDirectory() {
    const char* path = std::getenv("OPTIX_CACHE_PATH");
    return path ? path : "/var/tmp/OptixCache_" + std::string(getpwuid(getuid())->pw_name);
}
