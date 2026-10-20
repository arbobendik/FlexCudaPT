// The OptiX host API main.cpp and loader.h call, on Vulkan: the module is renderer.slang's SPIR-V, whose one compute
// shader runs the raygen program a launch's record names in its header; a BVH is OptiX's triangles under a top level
// of one instance; the denoiser is OptiX's alone
#pragma once
#include "cuda.h"
#include <optix_types.h>

// The raygen programs, numbered as renderer.slang's main runs them
constexpr const char* PROGRAMS[] = {"__raygen__initial", "__raygen__temporal", "__raygen__shift", "__raygen__spatial",
    "__raygen__duplicates", "__raygen__lights", "__raygen__denoise"};
// What a launch pushes: the address of its record and its size
struct Launch { CUdeviceptr record; unsigned width, height, depth; };
constexpr unsigned WORKGROUP = 8; // Square, as renderer.slang's main runs, its threads in a row for launches one high

struct OptixDeviceContext_t {};
struct OptixDenoiser_t {};
struct OptixModule_t { VkShaderModule shader; };
struct OptixProgramGroup_t { OptixModule module; unsigned program; };
struct OptixPipeline_t { VkPipelineLayout layout; VkPipeline pipeline; };

inline OptixResult optixInit() { return OPTIX_SUCCESS; }

inline OptixResult optixDeviceContextCreate(CUcontext, const OptixDeviceContextOptions*, OptixDeviceContext* context) {
    *context = new OptixDeviceContext_t;
    return OPTIX_SUCCESS;
}

// Of the GPU's own traversal: none on the CPU
inline OptixResult optixDeviceContextGetProperty(OptixDeviceContext, OptixDeviceProperty, void* value, size_t) {
    *(unsigned*)value = vulkan.properties.deviceType != VK_PHYSICAL_DEVICE_TYPE_CPU;
    return OPTIX_SUCCESS;
}

inline OptixResult optixDenoiserCreate(OptixDeviceContext, OptixDenoiserModelKind, const OptixDenoiserOptions*,
    OptixDenoiser* denoiser) {
    *denoiser = new OptixDenoiser_t;
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

inline OptixResult optixModuleCreate(OptixDeviceContext, const OptixModuleCompileOptions*,
    const OptixPipelineCompileOptions*, const char* input, size_t size, char*, size_t*, OptixModule* module) {
    std::vector<uint32_t> code(size / 4);
    std::memcpy(code.data(), input, size);
    const VkShaderModuleCreateInfo info{.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO, .codeSize = size,
        .pCode = code.data()};
    *module = new OptixModule_t;
    return vkCreateShaderModule(vulkan.device, &info, nullptr, &(*module)->shader) ? OPTIX_ERROR_INVALID_INPUT
        : OPTIX_SUCCESS;
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
        .pushConstantRangeCount = 1, .pPushConstantRanges = &range};
    if (vkCreatePipelineLayout(vulkan.device, &layout, nullptr, &(*pipeline)->layout)) return OPTIX_ERROR_INVALID_VALUE;
    const VkComputePipelineCreateInfo info{.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
        .stage = {.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, .stage = VK_SHADER_STAGE_COMPUTE_BIT,
        .module = groups[0]->module->shader, .pName = "main"}, .layout = (*pipeline)->layout};
    return vkCreateComputePipelines(vulkan.device, VK_NULL_HANDLE, 1, &info, nullptr, &(*pipeline)->pipeline)
        ? OPTIX_ERROR_PIPELINE_LINK_ERROR : OPTIX_SUCCESS;
}

inline OptixResult optixModuleDestroy(OptixModule module) {
    vkDestroyShaderModule(vulkan.device, module->shader, nullptr);
    delete module;
    return OPTIX_SUCCESS;
}
inline OptixResult optixProgramGroupDestroy(OptixProgramGroup group) {
    delete group;
    return OPTIX_SUCCESS;
}
inline OptixResult optixPipelineDestroy(OptixPipeline pipeline) {
    vkDestroyPipeline(vulkan.device, pipeline->pipeline, nullptr);
    vkDestroyPipelineLayout(vulkan.device, pipeline->layout, nullptr);
    delete pipeline;
    return OPTIX_SUCCESS;
}

inline OptixResult optixSbtRecordPackHeader(OptixProgramGroup group, void* header) {
    std::memset(header, 0, OPTIX_SBT_RECORD_HEADER_SIZE);
    *(unsigned*)header = group->program;
    return OPTIX_SUCCESS;
}

inline OptixResult optixLaunch(OptixPipeline pipeline, CUstream, CUdeviceptr, size_t,
    const OptixShaderBindingTable* sbt, unsigned width, unsigned height, unsigned depth) {
    const Launch launch{sbt->raygenRecord, width, height, depth};
    const bool row = height == 1 && depth == 1;
    return run([&](VkCommandBuffer commands) {
        vkCmdBindPipeline(commands, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline->pipeline);
        vkCmdPushConstants(commands, pipeline->layout, VK_SHADER_STAGE_COMPUTE_BIT, 0, sizeof(launch), &launch);
        vkCmdDispatch(commands, row ? (width + WORKGROUP * WORKGROUP - 1) / (WORKGROUP * WORKGROUP)
            : (width + WORKGROUP - 1) / WORKGROUP, (height + WORKGROUP - 1) / WORKGROUP, depth);
    }) ? OPTIX_ERROR_LAUNCH_FAILURE : OPTIX_SUCCESS;
}

// The triangles of a build input, as the bottom level takes them, and the one instance of it the top level takes
struct Geometry {
    VkAccelerationStructureGeometryKHR triangles, instances;
    VkAccelerationStructureBuildGeometryInfoKHR bottom, top;
    uint32_t count;
};
inline void describe(Geometry& geometry, const OptixBuildInput& input, const OptixAccelBuildOptions& options) {
    const OptixBuildInputTriangleArray& array = input.triangleArray;
    geometry.count = array.numVertices / 3;
    geometry.triangles = {.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
        .geometryType = VK_GEOMETRY_TYPE_TRIANGLES_KHR, .geometry = {.triangles = {
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR,
        .vertexFormat = VK_FORMAT_R32G32B32_SFLOAT,
        .vertexData = {.deviceAddress = array.vertexBuffers ? *array.vertexBuffers : 0},
        .vertexStride = 3 * sizeof(float), .maxVertex = array.numVertices ? array.numVertices - 1 : 0, .indexType = VK_INDEX_TYPE_NONE_KHR}}};
    geometry.instances = {.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR,
        .geometryType = VK_GEOMETRY_TYPE_INSTANCES_KHR, .geometry = {.instances = {
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR}}};
    geometry.bottom = {.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
        .type = VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR,
        .flags = VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR,
        .mode = options.operation == OPTIX_BUILD_OPERATION_UPDATE ? VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR
        : VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR, .geometryCount = 1, .pGeometries = &geometry.triangles};
    geometry.top = {.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR,
        .type = VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR, .mode = VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR,
        .geometryCount = 1, .pGeometries = &geometry.instances};
}

// Of each level, the offsets of the top level and its instance after the bottom level in the output, each at the
// alignment of BVHs, and of the scratch for building or updating either
struct Layout { VkDeviceSize bottom, top, offset, instance, output, scratch; };
inline Layout layout(const Geometry& geometry) {
    VkAccelerationStructureBuildSizesInfoKHR bottom{.sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR},
        top = bottom;
    const uint32_t instances = 1;
    vulkan.vkGetAccelerationStructureBuildSizesKHR(vulkan.device, VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR,
        &geometry.bottom, &geometry.count, &bottom);
    vulkan.vkGetAccelerationStructureBuildSizesKHR(vulkan.device, VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR,
        &geometry.top, &instances, &top);
    const auto aligned = [](VkDeviceSize bytes) { return (bytes + 255) & ~VkDeviceSize(255); };
    const VkDeviceSize offset = aligned(bottom.accelerationStructureSize);
    const VkDeviceSize instance = offset + aligned(top.accelerationStructureSize);
    return {bottom.accelerationStructureSize, top.accelerationStructureSize, offset, instance,
        instance + sizeof(VkAccelerationStructureInstanceKHR),
        std::max({bottom.buildScratchSize, bottom.updateScratchSize, top.buildScratchSize})};
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

// Builds or updates the bottom level, created in the output on a build, then builds the top level over it, the handle
// its address
inline OptixResult optixAccelBuild(OptixDeviceContext, CUstream, const OptixAccelBuildOptions* options,
    const OptixBuildInput* inputs, unsigned, CUdeviceptr temp, size_t, CUdeviceptr output, size_t,
    OptixTraversableHandle* handle, const OptixAccelEmitDesc*, unsigned) {
    Geometry geometry;
    describe(geometry, *inputs, *options);
    const Layout bytes = layout(geometry);
    VkDeviceSize offset;
    Allocation& allocation = find(output, offset);
    if (options->operation == OPTIX_BUILD_OPERATION_BUILD) {
        allocation.bvhs.resize(2);
        for (int level = 0; level < 2; ++level) {
            const VkAccelerationStructureCreateInfoKHR info{
                .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR, .buffer = allocation.buffer,
                .offset = offset + (level ? bytes.offset : 0),
                .size = level ? bytes.top : bytes.bottom,
                .type = level ? VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR : VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR};
            if (vulkan.vkCreateAccelerationStructureKHR(vulkan.device, &info, nullptr, &allocation.bvhs[level]))
                return OPTIX_ERROR_INVALID_VALUE;
        }
    }
    geometry.bottom.srcAccelerationStructure = geometry.bottom.mode == VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR
        ? allocation.bvhs[0] : VK_NULL_HANDLE;
    geometry.bottom.dstAccelerationStructure = allocation.bvhs[0];
    geometry.top.dstAccelerationStructure = allocation.bvhs[1];
    geometry.bottom.scratchData.deviceAddress = geometry.top.scratchData.deviceAddress = temp;
    const VkAccelerationStructureDeviceAddressInfoKHR bottom{
        .sType = VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR,
        .accelerationStructure = allocation.bvhs[0]}, top{bottom.sType, nullptr, allocation.bvhs[1]};
    const VkAccelerationStructureInstanceKHR instance{.transform = {.matrix = {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}}},
        .mask = 0xFF, .accelerationStructureReference = vulkan.vkGetAccelerationStructureDeviceAddressKHR(vulkan.device,
        &bottom)};
    geometry.instances.geometry.instances.data.deviceAddress = output + bytes.instance;
    const VkAccelerationStructureBuildRangeInfoKHR triangles{.primitiveCount = geometry.count}, instances{1};
    const VkAccelerationStructureBuildRangeInfoKHR *bottomRange = &triangles, *topRange = &instances;
    if (run([&](VkCommandBuffer commands) {
        vulkan.vkCmdBuildAccelerationStructuresKHR(commands, 1, &geometry.bottom, &bottomRange);
        vkCmdUpdateBuffer(commands, allocation.buffer, offset + bytes.instance, sizeof(instance), &instance);
        barrier(VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR,
            VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR | VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR
            | VK_ACCESS_SHADER_READ_BIT);
        vulkan.vkCmdBuildAccelerationStructuresKHR(commands, 1, &geometry.top, &topRange);
    })) return OPTIX_ERROR_INVALID_VALUE;
    *handle = vulkan.vkGetAccelerationStructureDeviceAddressKHR(vulkan.device, &top);
    return OPTIX_SUCCESS;
}
