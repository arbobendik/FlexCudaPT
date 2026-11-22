// The OptiX host API main.cpp and loader.h call, on Vulkan: the module is renderer.slang's SPIR-V, whose one compute
// shader runs the raygen program a launch's record names in its header; a BVH of triangles is a bottom level, one of
// instances of those a top level; the denoiser is OptiX's alone
#pragma once
#include "cuda.h"
#include "../shaders/renderer.h"
#include <optix_types.h>
#include <cstdio>
#include <cstdint>
#include <string>
#include <thread>
#include <vector>
#include <pwd.h>
#include <spawn.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <unistd.h>

// What a launch pushes: the address of its record and its size
struct Launch { CUdeviceptr record; unsigned width, height, depth; };
constexpr unsigned WORKGROUP = 8; // Square, as renderer.slang's main runs, its threads in a row for launches one high
// Workgroups of a launch one high per row of them, as renderer.slang's ROW_GROUPS: the least count in x Vulkan guarantees
constexpr unsigned ROW_GROUPS = 65535;

// A module: its shader, op mask and the pipeline cache its pipeline is made through, read from the cache file of this
// release's SPIR-V, keyed by its hash
struct OptixModule_t { VkShaderModule shader, queue, temporal; Params params; VkPipelineCache cache; uint64_t key;
    bool extended; };
// The temporal round's count and queue, and its shifts and reuse, compiled from their entries alone (shaders.h)
extern unsigned char build_shaders_ptx[], build_extended_ptx[], build_queue_ptx[], build_extended_queue_ptx[],
    build_temporal_ptx[], build_extended_temporal_ptx[];
extern unsigned int build_queue_ptx_len, build_extended_queue_ptx_len, build_temporal_ptx_len,
    build_extended_temporal_ptx_len;
// One file, beside OptiX's disk cache, of one release's pipelines: the SPIR-V's FNV-1a hash, then the cache's data,
// whose header the driver checks against its own and device. Another release's or driver's loads as no data
inline std::string cacheFile() {
    const char* cache = std::getenv("OPTIX_CACHE_PATH");
    const std::string directory = cache ? cache : "/var/tmp/OptixCache_" + std::string(getpwuid(getuid())->pw_name);
    mkdir(directory.c_str(), 0700);
    return directory + "/flex-vulkan.bin";
}
struct OptixProgramGroup_t { OptixModule module; unsigned program; };
// In a helper renderer (main.cpp's "compile"), the file its pipelines' cache goes to, for the renderer spawning it
inline const char* helping = nullptr;
// Its pipeline, the temporal round's count and queue apart in a second, its shifts and reuse in a third
struct OptixPipeline_t { VkPipelineLayout layout; VkPipeline pipeline, queue, temporal; };

inline OptixResult optixInit() { return OPTIX_SUCCESS; }

inline OptixResult optixDeviceContextCreate(CUcontext, const OptixDeviceContextOptions*, OptixDeviceContext* context) {
    *context = nullptr;
    return OPTIX_SUCCESS;
}

// Of the GPU's own traversal: none on the CPU
inline OptixResult optixDeviceContextGetProperty(OptixDeviceContext, OptixDeviceProperty, void* value, size_t) {
    *(unsigned*)value = vulkan.properties.deviceType != VK_PHYSICAL_DEVICE_TYPE_CPU;
    return OPTIX_SUCCESS;
}

inline OptixResult optixDenoiserCreate(OptixDeviceContext, OptixDenoiserModelKind, const OptixDenoiserOptions*,
    OptixDenoiser* denoiser) {
    *denoiser = nullptr;
    return OPTIX_SUCCESS;
}
inline OptixResult optixDenoiserComputeMemoryResources(OptixDenoiser, unsigned, unsigned, OptixDenoiserSizes*) {
    return OPTIX_ERROR_NOT_SUPPORTED;
}
inline OptixResult optixDenoiserSetup(OptixDenoiser, CUstream, unsigned, unsigned, CUdeviceptr, size_t, CUdeviceptr,
    size_t) {
    return OPTIX_ERROR_NOT_SUPPORTED;
}
inline OptixResult optixDenoiserInvoke(OptixDenoiser, CUstream, const OptixDenoiserParams*, CUdeviceptr, size_t,
    const OptixDenoiserGuideLayer*, const OptixDenoiserLayer*, unsigned, unsigned, unsigned, CUdeviceptr, size_t) {
    return OPTIX_ERROR_NOT_SUPPORTED;
}

inline OptixResult optixModuleCreate(OptixDeviceContext, const OptixModuleCompileOptions* options,
    const OptixPipelineCompileOptions*, const char* input, size_t size, char*, size_t*, OptixModule* module) {
    std::vector<uint32_t> code(size / 4);
    std::memcpy(code.data(), input, size);
    const VkShaderModuleCreateInfo info{.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO, .codeSize = size,
        .pCode = code.data()};
    *module = new OptixModule_t{.params = *(const Params*)options->boundValues[0].boundValuePtr, // Its op mask
        .key = 0xcbf29ce484222325ull};
    for (size_t k = 0; k < size; ++k) // FNV-1a of the SPIR-V
        (*module)->key = ((*module)->key ^ (unsigned char)input[k]) * 0x100000001b3ull;
    std::vector<char> data;
    if (FILE* file = std::fopen(cacheFile().c_str(), "rb")) {
        uint64_t key = 0;
        std::fseek(file, 0, SEEK_END);
        data.resize(std::max(std::ftell(file) - long(sizeof(key)), 0l));
        std::fseek(file, 0, SEEK_SET);
        if (!std::fread(&key, sizeof(key), 1, file) || key != (*module)->key) data.clear();
        data.resize(std::fread(data.data(), 1, data.size(), file));
        std::fclose(file);
    }
    const VkPipelineCacheCreateInfo cache{.sType = VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO,
        .initialDataSize = data.size(), .pInitialData = data.data()};
    vkCreatePipelineCache(vulkan.device, &cache, nullptr, &(*module)->cache);
    // The temporal round's modules beside the program's: the extended ones beside the extended program
    const bool extended = (*module)->extended = input == (const char*)build_extended_ptx;
    std::vector<uint32_t> queue((extended ? build_extended_queue_ptx_len : build_queue_ptx_len) / 4);
    std::memcpy(queue.data(), extended ? build_extended_queue_ptx : build_queue_ptx, queue.size() * 4);
    std::vector<uint32_t> temporal((extended ? build_extended_temporal_ptx_len : build_temporal_ptx_len) / 4);
    std::memcpy(temporal.data(), extended ? build_extended_temporal_ptx : build_temporal_ptx, temporal.size() * 4);
    const VkShaderModuleCreateInfo queued{.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .codeSize = queue.size() * 4, .pCode = queue.data()};
    const VkShaderModuleCreateInfo reused{.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .codeSize = temporal.size() * 4, .pCode = temporal.data()};
    return vkCreateShaderModule(vulkan.device, &info, nullptr, &(*module)->shader)
        || vkCreateShaderModule(vulkan.device, &queued, nullptr, &(*module)->queue)
        || vkCreateShaderModule(vulkan.device, &reused, nullptr, &(*module)->temporal) ? OPTIX_ERROR_INVALID_INPUT
        : OPTIX_SUCCESS;
}

// The module made at once, as its compile is the pipeline's: no tasks
inline OptixResult optixModuleCreateWithTasks(OptixDeviceContext context, const OptixModuleCompileOptions* options,
    const OptixPipelineCompileOptions* compile, const char* input, size_t size, char* log, size_t* logSize,
    OptixModule* module, OptixTask* first) {
    *first = nullptr;
    return optixModuleCreate(context, options, compile, input, size, log, logSize, module);
}
inline OptixResult optixTaskExecute(OptixTask, OptixTask*, unsigned, unsigned* count) {
    *count = 0;
    return OPTIX_SUCCESS;
}
inline OptixResult optixModuleGetCompilationState(OptixModule, OptixModuleCompileState* state) {
    *state = OPTIX_MODULE_COMPILE_STATE_COMPLETED;
    return OPTIX_SUCCESS;
}

// Of a raygen program its number, of the any-hit program none: traversal skips the triangle a ray leaves itself
inline OptixResult optixProgramGroupCreate(OptixDeviceContext, const OptixProgramGroupDesc* desc, unsigned count,
    const OptixProgramGroupOptions*, char*, size_t*, OptixProgramGroup* groups) {
    for (unsigned i = 0; i < count; ++i) {
        if (desc[i].kind != OPTIX_PROGRAM_GROUP_KIND_RAYGEN) {
            groups[i] = new OptixProgramGroup_t{.program = ~0u};
            continue;
        }
        const auto program = std::find_if(std::begin(PROGRAMS), std::end(PROGRAMS),
            [&](const char* name) { return !std::strcmp(name, desc[i].raygen.entryFunctionName); });
        if (program == std::end(PROGRAMS)) return OPTIX_ERROR_INVALID_VALUE;
        groups[i] = new OptixProgramGroup_t{desc[i].raygen.module, unsigned(program - std::begin(PROGRAMS))};
    }
    return OPTIX_SUCCESS;
}

inline OptixResult optixPipelineCreate(OptixDeviceContext, const OptixPipelineCompileOptions*,
    const OptixPipelineLinkOptions*, const OptixProgramGroup* groups, unsigned, char*, size_t*,
    OptixPipeline* pipeline) {
    *pipeline = new OptixPipeline_t;
    const VkPushConstantRange range{.stageFlags = VK_SHADER_STAGE_COMPUTE_BIT, .size = sizeof(Launch)};
    const VkPipelineLayoutCreateInfo layout{.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        .setLayoutCount = 1, .pSetLayouts = &vulkan.texturesLayout, .pushConstantRangeCount = 1,
        .pPushConstantRanges = &range};
    if (vkCreatePipelineLayout(vulkan.device, &layout, nullptr, &(*pipeline)->layout)) return OPTIX_ERROR_INVALID_VALUE;
    // The module's op mask as renderer.slang's OPS0 and OPS1
    const VkSpecializationMapEntry entries[] = {{0, 0, 8}, {1, 8, 8}};
    const VkSpecializationInfo specialization{2, entries, sizeof(Params), &groups[0]->module->params};
    const OptixModule module = groups[0]->module;
    const VkShaderModule shaders[] = {module->shader, module->queue, module->temporal};
    VkComputePipelineCreateInfo info[3];
    for (int k = 0; k < 3; ++k) info[k] = {.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
        .stage = {.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, .stage = VK_SHADER_STAGE_COMPUTE_BIT,
        .module = shaders[k], .pName = "main", .pSpecializationInfo = &specialization}, // Each module's own entry
        .layout = (*pipeline)->layout};
    // The main pipeline compiled alone in this process while a helper renderer compiles the temporal round's two at
    // once: compiled beside another in one process, the driver can leave the main pipeline a binary blind to its
    // parameters. Their binaries come back through the cache's data, so here they are found at once
    VkPipeline made[3];
    VkResult results[3];
    const auto create = [&](int k) {
        results[k] = vkCreateComputePipelines(vulkan.device, module->cache, 1, &info[k], nullptr, &made[k]);
    };
    const std::string helped = cacheFile() + "." + std::to_string(getpid()) + ".helper";
    if (helping) {  // The helper: the two at once, their cache to the file given
        std::thread third(create, 2);
        create(1);
        third.join();
    } else {
        const std::string ops[] = {std::to_string(module->params.ops[0]), std::to_string(module->params.ops[1])};
        const char* args[] = {"renderer", "compile", ops[0].c_str(), ops[1].c_str(), module->extended ? "1" : "0",
            helped.c_str(), nullptr};
        pid_t helper;
        if (posix_spawn(&helper, "/proc/self/exe", nullptr, nullptr, (char* const*)args, environ))
            return OPTIX_ERROR_PIPELINE_LINK_ERROR; // A helper not started fails the compile
        create(0);
        waitpid(helper, nullptr, 0);
        std::vector<char> data;
        if (FILE* file = std::fopen(helped.c_str(), "rb")) { // After its key, as the cache file
            std::fseek(file, 0, SEEK_END);
            data.resize(std::max(std::ftell(file) - long(sizeof(module->key)), 0l));
            std::fseek(file, sizeof(module->key), SEEK_SET);
            data.resize(std::fread(data.data(), 1, data.size(), file));
            std::fclose(file);
        }
        std::remove(helped.c_str());
        const VkPipelineCacheCreateInfo given{.sType = VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO,
            .initialDataSize = data.size(), .pInitialData = data.data()};
        VkPipelineCache cache;
        vkCreatePipelineCache(vulkan.device, &given, nullptr, &cache);
        vkMergePipelineCaches(vulkan.device, module->cache, 1, &cache);
        vkDestroyPipelineCache(vulkan.device, cache, nullptr);
        create(1), create(2);
        (*pipeline)->pipeline = made[0], (*pipeline)->queue = made[1], (*pipeline)->temporal = made[2];
        if (results[0] || results[1] || results[2])
            return OPTIX_ERROR_PIPELINE_LINK_ERROR;
    }
    // The cache saved whole after the key, through a file of its own renamed into place: two renderers saving at once
    // leave one's whole, the other's pipeline coming again on its next save
    size_t size = 0;
    vkGetPipelineCacheData(vulkan.device, module->cache, &size, nullptr);
    std::vector<char> data(size);
    vkGetPipelineCacheData(vulkan.device, module->cache, &size, data.data());
    const std::string file = helping ? helping : cacheFile(), part = file + "." + std::to_string(getpid());
    if (FILE* out = std::fopen(part.c_str(), "wb")) {
        std::fwrite(&module->key, sizeof(module->key), 1, out), std::fwrite(data.data(), 1, size, out);
        std::fclose(out);
        std::rename(part.c_str(), file.c_str());
    }
    return OPTIX_SUCCESS;
}

inline OptixResult optixModuleDestroy(OptixModule module) {
    vkDestroyShaderModule(vulkan.device, module->shader, nullptr);
    vkDestroyShaderModule(vulkan.device, module->queue, nullptr);
    vkDestroyShaderModule(vulkan.device, module->temporal, nullptr);
    vkDestroyPipelineCache(vulkan.device, module->cache, nullptr);
    delete module;
    return OPTIX_SUCCESS;
}
inline OptixResult optixProgramGroupDestroy(OptixProgramGroup group) {
    delete group;
    return OPTIX_SUCCESS;
}
inline OptixResult optixPipelineDestroy(OptixPipeline pipeline) {
    vkDestroyPipeline(vulkan.device, pipeline->pipeline, nullptr);
    vkDestroyPipeline(vulkan.device, pipeline->queue, nullptr);
    vkDestroyPipeline(vulkan.device, pipeline->temporal, nullptr);
    vkDestroyPipelineLayout(vulkan.device, pipeline->layout, nullptr);
    delete pipeline;
    return OPTIX_SUCCESS;
}

// The stand-in's stack sizes: none here, as Vulkan has no stand-in
inline OptixResult optixProgramGroupGetStackSize(OptixProgramGroup, OptixStackSizes*, OptixPipeline) { return OPTIX_SUCCESS; }
inline OptixResult optixPipelineSetStackSize(OptixPipeline, unsigned, unsigned, unsigned, unsigned) { return OPTIX_SUCCESS; }

inline OptixResult optixSbtRecordPackHeader(OptixProgramGroup group, void* header) {
    std::memset(header, 0, OPTIX_SBT_RECORD_HEADER_SIZE);
    *(unsigned*)header = group->program;
    return OPTIX_SUCCESS;
}

inline OptixResult optixLaunch(OptixPipeline pipeline, CUstream, CUdeviceptr, size_t,
    const OptixShaderBindingTable* sbt, unsigned width, unsigned height, unsigned depth) {
    const Launch launch{sbt->raygenRecord, width, height, depth};
    const bool row = height == 1 && depth == 1;
    // The pass by its record's place: main.cpp's passes precede the walk's callables, one record each; the temporal
    // round's count and queue run in the second pipeline, its shifts and reuse in the third
    const unsigned program = sbt->callablesRecordBase ? unsigned(std::size(PROGRAMS)
        - (sbt->callablesRecordBase - sbt->raygenRecord) / sbt->callablesRecordStrideInBytes) : ~0u;
    const VkPipeline bound = program == PASS_TEMPORAL_COUNT || program == PASS_TEMPORAL_PREPASS ? pipeline->queue
        : program == PASS_TEMPORAL_SHIFT || program == PASS_TEMPORAL ? pipeline->temporal : pipeline->pipeline;
    const unsigned groups = (width + WORKGROUP * WORKGROUP - 1) / (WORKGROUP * WORKGROUP); // Of a row
    return run([&](VkCommandBuffer commands) {
        vkCmdBindPipeline(commands, VK_PIPELINE_BIND_POINT_COMPUTE, bound);
        vkCmdBindDescriptorSets(commands, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline->layout, 0, 1, &vulkan.textures, 0,
            nullptr);
        vkCmdPushConstants(commands, pipeline->layout, VK_SHADER_STAGE_COMPUTE_BIT, 0, sizeof(launch), &launch);
        if (row) vkCmdDispatch(commands, std::min(groups, ROW_GROUPS), (groups + ROW_GROUPS - 1) / ROW_GROUPS, 1);
        else vkCmdDispatch(commands, (width + WORKGROUP - 1) / WORKGROUP, (height + WORKGROUP - 1) / WORKGROUP, depth);
    }) ? OPTIX_ERROR_LAUNCH_FAILURE : OPTIX_SUCCESS;
}

// The blue-noise tensor of a side generated in place by FlexKernels' noiseStart and noiseSweep, pipelines of their own:
// the white start, then sweeps of 8 colours, each pass after the last; the tensor a storage buffer at set 0, binding 0,
// the side, sweep and colour pushed
extern unsigned char build_noise_start_spv[], build_noise_sweep_spv[]; // FlexKernels' SPIR-V, shaders.h's
extern unsigned int build_noise_start_spv_len, build_noise_sweep_spv_len;
inline CUresult noiseGenerate(CUdeviceptr tensor, unsigned size, unsigned sweeps) {
    const VkDescriptorSetLayoutBinding binding{0, VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1, VK_SHADER_STAGE_COMPUTE_BIT};
    const VkDescriptorSetLayoutCreateInfo set{.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .bindingCount = 1, .pBindings = &binding};
    VkDescriptorSetLayout setLayout;
    if (vkCreateDescriptorSetLayout(vulkan.device, &set, nullptr, &setLayout)) return 1;
    const VkPushConstantRange range{VK_SHADER_STAGE_COMPUTE_BIT, 0, 3 * sizeof(unsigned)};
    const VkPipelineLayoutCreateInfo info{.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO, .setLayoutCount = 1,
        .pSetLayouts = &setLayout, .pushConstantRangeCount = 1, .pPushConstantRanges = &range};
    VkPipelineLayout layout;
    if (vkCreatePipelineLayout(vulkan.device, &info, nullptr, &layout)) return 1;
    const VkDescriptorPoolSize poolSize{VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1};
    const VkDescriptorPoolCreateInfo poolInfo{.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO, .maxSets = 1,
        .poolSizeCount = 1, .pPoolSizes = &poolSize};
    VkDescriptorPool pool;
    if (vkCreateDescriptorPool(vulkan.device, &poolInfo, nullptr, &pool)) return 1;
    const VkDescriptorSetAllocateInfo allocate{.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .descriptorPool = pool, .descriptorSetCount = 1, .pSetLayouts = &setLayout};
    VkDescriptorSet descriptors;
    if (vkAllocateDescriptorSets(vulkan.device, &allocate, &descriptors)) return 1;
    const VkDescriptorBufferInfo buffer{vulkan.allocations.at(tensor).buffer, 0, VK_WHOLE_SIZE};
    const VkWriteDescriptorSet write{.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET, .dstSet = descriptors,
        .descriptorCount = 1, .descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, .pBufferInfo = &buffer};
    vkUpdateDescriptorSets(vulkan.device, 1, &write, 0, nullptr);
    VkPipeline pipelines[2];
    const unsigned char* code[] = {build_noise_start_spv, build_noise_sweep_spv};
    const unsigned lengths[] = {build_noise_start_spv_len, build_noise_sweep_spv_len};
    for (unsigned k = 0; k < 2; ++k) {
        std::vector<uint32_t> words(lengths[k] / 4); // Aligned as SPIR-V's words
        std::memcpy(words.data(), code[k], lengths[k]);
        const VkShaderModuleCreateInfo module{.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
            .codeSize = lengths[k], .pCode = words.data()};
        VkShaderModule shader;
        if (vkCreateShaderModule(vulkan.device, &module, nullptr, &shader)) return 1;
        const VkComputePipelineCreateInfo create{.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
            .stage = {.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            .stage = VK_SHADER_STAGE_COMPUTE_BIT, .module = shader, .pName = "main"}, .layout = layout};
        const VkResult made = vkCreateComputePipelines(vulkan.device, nullptr, 1, &create, nullptr, &pipelines[k]);
        vkDestroyShaderModule(vulkan.device, shader, nullptr);
        if (made) return 1;
    }
    const unsigned texels = size * size * 32, blocks = size / 16 * (size / 16) * 2;
    const CUresult result = run([&](VkCommandBuffer commands) {
        const VkMemoryBarrier after{.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER,
            .srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT, .dstAccessMask = VK_ACCESS_SHADER_READ_BIT
            | VK_ACCESS_SHADER_WRITE_BIT};
        vkCmdBindDescriptorSets(commands, VK_PIPELINE_BIND_POINT_COMPUTE, layout, 0, 1, &descriptors, 0, nullptr);
        vkCmdBindPipeline(commands, VK_PIPELINE_BIND_POINT_COMPUTE, pipelines[0]);
        vkCmdPushConstants(commands, layout, VK_SHADER_STAGE_COMPUTE_BIT, 0, sizeof(size), &size);
        vkCmdDispatch(commands, (texels + 63) / 64, 1, 1);
        vkCmdBindPipeline(commands, VK_PIPELINE_BIND_POINT_COMPUTE, pipelines[1]);
        for (unsigned sweep = 0; sweep < sweeps; ++sweep) for (unsigned colour = 0; colour < 8; ++colour) {
            vkCmdPipelineBarrier(commands, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                0, 1, &after, 0, nullptr, 0, nullptr);
            const unsigned pushed[] = {size, sweep, colour};
            vkCmdPushConstants(commands, layout, VK_SHADER_STAGE_COMPUTE_BIT, 0, sizeof(pushed), pushed);
            vkCmdDispatch(commands, (blocks + 63) / 64, 1, 1);
        }
    });
    for (VkPipeline pipeline : pipelines) vkDestroyPipeline(vulkan.device, pipeline, nullptr);
    vkDestroyDescriptorPool(vulkan.device, pool, nullptr);
    vkDestroyPipelineLayout(vulkan.device, layout, nullptr);
    vkDestroyDescriptorSetLayout(vulkan.device, setLayout, nullptr);
    return result;
}

// A build input as its level takes it: triangles or bounds at the bottom, instances of bottom levels on top
struct Geometry {
    VkAccelerationStructureGeometryKHR geometry;
    VkAccelerationStructureBuildGeometryInfoKHR info;
    uint32_t count;
    bool top;
};
inline void describe(Geometry& geometry, const OptixBuildInput& input, const OptixAccelBuildOptions& options) {
    const OptixBuildInputTriangleArray& array = input.triangleArray;
    geometry.top = input.type == OPTIX_BUILD_INPUT_TYPE_INSTANCES;
    geometry.count = geometry.top ? input.instanceArray.numInstances : array.numVertices / 3;
    geometry.geometry = geometry.top ? VkAccelerationStructureGeometryKHR{
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
        .geometryType = VK_GEOMETRY_TYPE_INSTANCES_KHR, .geometry = {.instances = {
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR}}}
        : VkAccelerationStructureGeometryKHR{.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
        .geometryType = VK_GEOMETRY_TYPE_TRIANGLES_KHR, .geometry = {.triangles = {
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
        .vertexFormat = VK_FORMAT_R32G32B32_SFLOAT,
        .vertexData = {.deviceAddress = array.vertexBuffers ? *array.vertexBuffers : 0},
        .vertexStride = 3 * sizeof(float), .maxVertex = array.numVertices ? array.numVertices - 1 : 0, .indexType = VK_INDEX_TYPE_NONE_KHR}}};
    if (input.type == OPTIX_BUILD_INPUT_TYPE_CUSTOM_PRIMITIVES) // Strands' segments, read on the device
        geometry.count = input.customPrimitiveArray.numPrimitives, geometry.geometry = {
            .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR, .geometryType = VK_GEOMETRY_TYPE_AABBS_KHR,
            .geometry = {.aabbs = {.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR,
            .data = {.deviceAddress = *input.customPrimitiveArray.aabbBuffers}, .stride = sizeof(OptixAabb)}}};
    geometry.info = {.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
        .type = geometry.top ? VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR
        : VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR,
        .flags = geometry.top ? 0u : VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR,
        .mode = options.operation == OPTIX_BUILD_OPERATION_UPDATE ? VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR
        : VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR, .geometryCount = 1, .pGeometries = &geometry.geometry};
}

// Of a level, its size and the offset of Vulkan's form of its instances after it in the output, at the alignment of
// BVHs, the output's size and the scratch for building or updating it
struct Layout { VkDeviceSize size, instances, output, scratch; };
inline Layout layout(const Geometry& geometry) {
    VkAccelerationStructureBuildSizesInfoKHR sizes{
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR};
    vulkan.vkGetAccelerationStructureBuildSizesKHR(vulkan.device, VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR,
        &geometry.info, &geometry.count, &sizes);
    const VkDeviceSize instances = (sizes.accelerationStructureSize + 255) & ~VkDeviceSize(255);
    return {sizes.accelerationStructureSize, instances,
        instances + (geometry.top ? geometry.count * sizeof(VkAccelerationStructureInstanceKHR) : 0),
        std::max(sizes.buildScratchSize, sizes.updateScratchSize)};
}

inline OptixResult optixAccelComputeMemoryUsage(OptixDeviceContext, const OptixAccelBuildOptions* options,
    const OptixBuildInput* inputs, unsigned, OptixAccelBufferSizes* sizes) {
    Geometry geometry;
    describe(geometry, *inputs, *options);
    const Layout bytes = layout(geometry);
    *sizes = {.outputSizeInBytes = bytes.output, .tempSizeInBytes = bytes.scratch,
        .tempUpdateSizeInBytes = bytes.scratch};
    return OPTIX_SUCCESS;
}

// Builds or updates a level, created in the output on a build, the handle its address; a top level over OptiX's
// instances, put in Vulkan's form after it
inline OptixResult optixAccelBuild(OptixDeviceContext, CUstream, const OptixAccelBuildOptions* options,
    const OptixBuildInput* inputs, unsigned, CUdeviceptr temp, size_t, CUdeviceptr output, size_t,
    OptixTraversableHandle* handle, const OptixAccelEmitDesc*, unsigned) {
    Geometry geometry;
    describe(geometry, *inputs, *options);
    const Layout bytes = layout(geometry);
    auto [allocation, offset] = find(output);
    if (options->operation == OPTIX_BUILD_OPERATION_BUILD) {
        allocation.bvhs.resize(1);
        const VkAccelerationStructureCreateInfoKHR info{
            .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR, .buffer = allocation.buffer,
            .offset = offset, .size = bytes.size, .type = geometry.info.type};
        if (vulkan.vkCreateAccelerationStructureKHR(vulkan.device, &info, nullptr, &allocation.bvhs[0]))
            return OPTIX_ERROR_INVALID_VALUE;
    }
    geometry.info.srcAccelerationStructure = geometry.info.mode == VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR
        ? allocation.bvhs[0] : VK_NULL_HANDLE;
    geometry.info.dstAccelerationStructure = allocation.bvhs[0];
    geometry.info.scratchData.deviceAddress = temp;
    if (geometry.top) {
        std::vector<OptixInstance> from(geometry.count);
        std::vector<VkAccelerationStructureInstanceKHR> to(geometry.count);
        cuMemcpyDtoH(from.data(), inputs->instanceArray.instances, from.size() * sizeof(OptixInstance));
        for (uint32_t i = 0; i < geometry.count; ++i) {
            std::memcpy(&to[i].transform, from[i].transform, sizeof(to[i].transform));
            to[i].instanceCustomIndex = from[i].instanceId, to[i].mask = from[i].visibilityMask;
            to[i].instanceShaderBindingTableRecordOffset = from[i].sbtOffset, to[i].flags = 0;
            to[i].accelerationStructureReference = from[i].traversableHandle;
        }
        cuMemcpyHtoD(output + bytes.instances, to.data(), to.size() * sizeof(VkAccelerationStructureInstanceKHR));
        geometry.geometry.geometry.instances.data.deviceAddress = output + bytes.instances;
    }
    const VkAccelerationStructureBuildRangeInfoKHR range{.primitiveCount = geometry.count}, *ranges = &range;
    if (run([&](VkCommandBuffer commands) {
        vulkan.vkCmdBuildAccelerationStructuresKHR(commands, 1, &geometry.info, &ranges);
    })) return OPTIX_ERROR_INVALID_VALUE;
    const VkAccelerationStructureDeviceAddressInfoKHR level{
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR,
        .accelerationStructure = allocation.bvhs[0]};
    *handle = vulkan.vkGetAccelerationStructureDeviceAddressKHR(vulkan.device, &level);
    return OPTIX_SUCCESS;
}
