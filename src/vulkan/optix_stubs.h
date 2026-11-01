// The OptiX host API main.cpp and loader.h call, on Vulkan: the module is renderer.slang's SPIR-V, whose one compute
// shader runs the raygen program a launch's record names in its header; a BVH of triangles is a bottom level, one of
// instances of those a top level; the denoiser is OptiX's alone
#pragma once
#include "cuda.h"
#include "../shaders/renderer.h"
#include <optix_types.h>

// What a launch pushes: the address of its record and its size
struct Launch { CUdeviceptr record; unsigned width, height, depth; };
constexpr unsigned WORKGROUP = 8; // Square, as renderer.slang's main runs, its threads in a row for launches one high

struct OptixModule_t { VkShaderModule shader; Params params; };
struct OptixProgramGroup_t { OptixModule module; unsigned program; };
struct OptixPipeline_t { VkPipelineLayout layout; VkPipeline pipeline; };

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
    *module = new OptixModule_t{.params = *(const Params*)options->boundValues[0].boundValuePtr}; // Its op mask
    return vkCreateShaderModule(vulkan.device, &info, nullptr, &(*module)->shader) ? OPTIX_ERROR_INVALID_INPUT
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
    const VkComputePipelineCreateInfo info{.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
        .stage = {.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, .stage = VK_SHADER_STAGE_COMPUTE_BIT,
        .module = groups[0]->module->shader, .pName = "main", .pSpecializationInfo = &specialization},
        .layout = (*pipeline)->layout};
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
        vkCmdBindDescriptorSets(commands, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline->layout, 0, 1, &vulkan.textures, 0,
            nullptr);
        vkCmdPushConstants(commands, pipeline->layout, VK_SHADER_STAGE_COMPUTE_BIT, 0, sizeof(launch), &launch);
        vkCmdDispatch(commands, row ? (width + WORKGROUP * WORKGROUP - 1) / (WORKGROUP * WORKGROUP)
            : (width + WORKGROUP - 1) / WORKGROUP, (height + WORKGROUP - 1) / WORKGROUP, depth);
    }) ? OPTIX_ERROR_LAUNCH_FAILURE : OPTIX_SUCCESS;
}

// A build input as its level takes it: triangles at the bottom, instances of bottom levels on top
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
