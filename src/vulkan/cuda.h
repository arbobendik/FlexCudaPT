// The CUDA driver API main.cpp and loader.h call, on Vulkan: an allocation is a buffer at its device address, and
// every call records its commands, between barriers ordering all memory accesses, and waits for them
#pragma once
#include <vulkan/vulkan.h>
#include <algorithm>
#include <cstring>
#include <iterator>
#include <map>
#include <vector>

typedef unsigned long long CUdeviceptr;
typedef int CUresult;
typedef struct CUctx_st* CUcontext;
typedef struct CUstream_st* CUstream;
// A texture is its image's place in the descriptor array the shaders read, an array its image; of what loader.h
// sets, in CUDA's order: of 4 channels, read whole
typedef unsigned long long CUtexObject;
typedef struct CUarray_st { VkImage image; VkDeviceMemory memory; VkImageView view, filtered; VkExtent3D extent;
    bool bytes; }* CUarray; // Its view of whole texels, and of filtered ones once a texture filters it
enum { CU_AD_FORMAT_UNSIGNED_INT8 = 0x01, CU_AD_FORMAT_FLOAT = 0x20, CU_MEMORYTYPE_HOST = 1, CU_MEMORYTYPE_ARRAY = 3,
    CU_RESOURCE_TYPE_ARRAY = 0, CU_TR_ADDRESS_MODE_WRAP = 0, CU_TR_ADDRESS_MODE_CLAMP = 1,
    CU_TR_ADDRESS_MODE_MIRROR = 2, CU_TR_ADDRESS_MODE_BORDER = 3, CU_TR_FILTER_MODE_POINT = 0,
    CU_TR_FILTER_MODE_LINEAR = 1, CU_TRSF_READ_AS_INTEGER = 1, CU_TRSF_NORMALIZED_COORDINATES = 2,
    CU_TRSF_SRGB = 0x10 };
struct CUDA_ARRAY_DESCRIPTOR { size_t Width, Height; int Format; unsigned NumChannels; };
struct CUDA_MEMCPY2D { int srcMemoryType; const void* srcHost; size_t srcPitch; int dstMemoryType; CUarray dstArray;
    size_t WidthInBytes, Height; };
struct CUDA_RESOURCE_DESC { int resType; union { struct { CUarray hArray; } array; } res; };
struct CUDA_TEXTURE_DESC { int addressMode[3], filterMode; unsigned flags; };

// Bytes copied through the host visible buffer at a time
constexpr size_t STAGING = 64 << 20;

struct Allocation { VkBuffer buffer; VkDeviceMemory memory; size_t bytes; std::vector<VkAccelerationStructureKHR> bvhs; };
inline struct {
    VkInstance instance;
    VkPhysicalDevice physical;
    VkPhysicalDeviceProperties properties;
    VkDevice device;
    VkQueue queue;
    VkCommandPool pool;
    VkCommandBuffer commands;
    VkFence fence;
    std::map<CUdeviceptr, Allocation> allocations; // By their address
    VkBuffer staging;
    VkDeviceMemory stagingMemory;
    void* mapped;
    VkDescriptorSetLayout texturesLayout;
    // Bindless, renderer.slang's: of every array's image whole, and filtered, at its texture's place, which a filtering
    VkDescriptorSet textures; // texture's number has in its bits from 32
    std::vector<bool> taken[2]; // Of those places
    PFN_vkGetAccelerationStructureBuildSizesKHR vkGetAccelerationStructureBuildSizesKHR;
    PFN_vkCreateAccelerationStructureKHR vkCreateAccelerationStructureKHR;
    PFN_vkDestroyAccelerationStructureKHR vkDestroyAccelerationStructureKHR;
    PFN_vkCmdBuildAccelerationStructuresKHR vkCmdBuildAccelerationStructuresKHR;
    PFN_vkGetAccelerationStructureDeviceAddressKHR vkGetAccelerationStructureDeviceAddressKHR;
} vulkan;

inline CUresult cuInit(unsigned) {
    const VkApplicationInfo application{.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO, .pApplicationName = "Flex",
        .apiVersion = VK_API_VERSION_1_3};
    const VkInstanceCreateInfo info{.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, .pApplicationInfo = &application};
    return vkCreateInstance(&info, nullptr, &vulkan.instance);
}

// Index of a memory type of the properties among those of bits, also of the preferred ones if any is, of none -1
inline int memoryType(uint32_t bits, VkMemoryPropertyFlags flags, VkMemoryPropertyFlags preferred = 0) {
    if (const int type = preferred ? memoryType(bits, flags | preferred) : -1; type >= 0) return type;
    VkPhysicalDeviceMemoryProperties memory;
    vkGetPhysicalDeviceMemoryProperties(vulkan.physical, &memory);
    for (uint32_t i = 0; i < memory.memoryTypeCount; ++i)
        if (bits >> i & 1 && (memory.memoryTypes[i].propertyFlags & flags) == flags) return i;
    return -1;
}

// Buffer for every use of a device's memory of the properties, at its address with them, to allocations
inline CUresult create(VkDeviceSize bytes, VkMemoryPropertyFlags flags, VkBuffer& buffer, VkDeviceMemory& memory,
    VkMemoryPropertyFlags preferred = 0) {
    const VkBufferCreateInfo info{.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = bytes,
        .usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT | VK_BUFFER_USAGE_STORAGE_BUFFER_BIT
        | VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT | VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR
        | VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR};
    if (VkResult result = vkCreateBuffer(vulkan.device, &info, nullptr, &buffer)) return result;
    VkMemoryRequirements requirements;
    vkGetBufferMemoryRequirements(vulkan.device, buffer, &requirements);
    const VkMemoryAllocateFlagsInfo address{.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO,
        .flags = VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT};
    const VkMemoryAllocateInfo allocate{.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .pNext = &address,
        .allocationSize = requirements.size,
        .memoryTypeIndex = uint32_t(memoryType(requirements.memoryTypeBits, flags, preferred))};
    if (VkResult result = vkAllocateMemory(vulkan.device, &allocate, nullptr, &memory)) return result;
    return vkBindBufferMemory(vulkan.device, buffer, memory, 0);
}

template <class T, class F, class... A> std::vector<T> listed(F list, A... args) { // What a Vulkan call lists
    uint32_t count = 0;
    list(args..., &count, nullptr);
    std::vector<T> items(count);
    return list(args..., &count, items.data()), items;
}

// The first discrete GPU with ray queries, else the first GPU with them, its first queue family that computes
inline CUresult cuCtxCreate(CUcontext* context, void*, unsigned, int) {
    auto devices = listed<VkPhysicalDevice>(vkEnumeratePhysicalDevices, vulkan.instance);
    const char* extensions[] = {VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME, VK_KHR_RAY_QUERY_EXTENSION_NAME,
        VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME};
    const auto supported = [&](VkPhysicalDevice device) {
        const auto properties = listed<VkExtensionProperties>(vkEnumerateDeviceExtensionProperties, device, nullptr);
        return std::all_of(std::begin(extensions), std::end(extensions), [&](const char* name) {
            return std::any_of(properties.begin(), properties.end(),
                [&](const VkExtensionProperties& p) { return !std::strcmp(p.extensionName, name); });
        });
    };
    std::stable_partition(devices.begin(), devices.end(), [](VkPhysicalDevice device) {
        VkPhysicalDeviceProperties properties;
        vkGetPhysicalDeviceProperties(device, &properties);
        return properties.deviceType == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU;
    });
    const auto found = std::find_if(devices.begin(), devices.end(), supported);
    if (found == devices.end()) return VK_ERROR_FEATURE_NOT_PRESENT;
    vulkan.physical = *found;
    vkGetPhysicalDeviceProperties(vulkan.physical, &vulkan.properties);
    const auto families = listed<VkQueueFamilyProperties>(vkGetPhysicalDeviceQueueFamilyProperties, vulkan.physical);
    const uint32_t family = std::find_if(families.begin(), families.end(), [](const VkQueueFamilyProperties& f) {
        return f.queueFlags & VK_QUEUE_COMPUTE_BIT; }) - families.begin();
    const float priority = 1;
    const VkDeviceQueueCreateInfo queue{.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO, .queueFamilyIndex = family,
        .queueCount = 1, .pQueuePriorities = &priority};
    // What the renderer's SPIR-V declares: 8 and 64 bit integers, pointers of scalar layout, ray queries and an array
    // of textures of a runtime size, partly bound, indexed per thread; a device without them fails here
    VkPhysicalDeviceRayQueryFeaturesKHR rayQuery{.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR,
        .rayQuery = VK_TRUE};
    VkPhysicalDeviceAccelerationStructureFeaturesKHR bvh{
        .sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR, .pNext = &rayQuery,
        .accelerationStructure = VK_TRUE};
    VkPhysicalDeviceVulkan12Features vulkan12{.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
        .pNext = &bvh, .storageBuffer8BitAccess = VK_TRUE, .shaderInt8 = VK_TRUE,
        .shaderSampledImageArrayNonUniformIndexing = VK_TRUE, .descriptorBindingPartiallyBound = VK_TRUE,
        .runtimeDescriptorArray = VK_TRUE, .scalarBlockLayout = VK_TRUE, .bufferDeviceAddress = VK_TRUE};
    VkPhysicalDeviceFeatures2 features{.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2, .pNext = &vulkan12,
        .features = {.shaderInt64 = VK_TRUE}};
    const VkDeviceCreateInfo info{.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, .pNext = &features,
        .queueCreateInfoCount = 1, .pQueueCreateInfos = &queue, .enabledExtensionCount = uint32_t(std::size(extensions)),
        .ppEnabledExtensionNames = extensions};
    VkFormatProperties floats;  // Float images filtered linearly, which Vulkan leaves optional
    vkGetPhysicalDeviceFormatProperties(vulkan.physical, VK_FORMAT_R32G32B32A32_SFLOAT, &floats);
    if (!(floats.optimalTilingFeatures & VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT))
        return VK_ERROR_FORMAT_NOT_SUPPORTED;
    if (VkResult result = vkCreateDevice(vulkan.physical, &info, nullptr, &vulkan.device)) return result;
    vkGetDeviceQueue(vulkan.device, family, 0, &vulkan.queue);
    const VkCommandPoolCreateInfo pool{.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT, .queueFamilyIndex = family};
    vkCreateCommandPool(vulkan.device, &pool, nullptr, &vulkan.pool);
    const VkCommandBufferAllocateInfo commands{.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = vulkan.pool, .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1};
    vkAllocateCommandBuffers(vulkan.device, &commands, &vulkan.commands);
    const VkFenceCreateInfo fence{.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO};
    vkCreateFence(vulkan.device, &fence, nullptr, &vulkan.fence);
    const uint32_t textures = std::min(vulkan.properties.limits.maxPerStageDescriptorSampledImages, 1u << 16);
    VkSampler samplers[4]; // Filtering linearly by the extension: repeated, extended, clipped to none or mirrored
    for (int k = 0; k < 4; ++k) {
        const VkSamplerAddressMode mode[] = {VK_SAMPLER_ADDRESS_MODE_REPEAT, VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
            VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER, VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT};
        const VkSamplerCreateInfo sampler{.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO, .magFilter = VK_FILTER_LINEAR,
            .minFilter = VK_FILTER_LINEAR, .addressModeU = mode[k], .addressModeV = mode[k],
            .borderColor = VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK};
        vkCreateSampler(vulkan.device, &sampler, nullptr, &samplers[k]);
    }
    const VkDescriptorBindingFlags partly[] = {VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT,
        VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT, 0};
    const VkDescriptorSetLayoutBindingFlagsCreateInfo flags{
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO, .bindingCount = 3,
        .pBindingFlags = partly};
    const VkDescriptorSetLayoutBinding bindings[] = {{0, VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, textures,
        VK_SHADER_STAGE_COMPUTE_BIT}, {1, VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, textures, VK_SHADER_STAGE_COMPUTE_BIT},
        {2, VK_DESCRIPTOR_TYPE_SAMPLER, 4, VK_SHADER_STAGE_COMPUTE_BIT, samplers}};
    const VkDescriptorSetLayoutCreateInfo layout{.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .pNext = &flags, .bindingCount = 3, .pBindings = bindings};
    vkCreateDescriptorSetLayout(vulkan.device, &layout, nullptr, &vulkan.texturesLayout);
    const VkDescriptorPoolSize size[] = {{VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, 2 * textures},
        {VK_DESCRIPTOR_TYPE_SAMPLER, 4}};
    const VkDescriptorPoolCreateInfo sets{.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO, .maxSets = 1,
        .poolSizeCount = 2, .pPoolSizes = size};
    VkDescriptorPool texturesPool;
    vkCreateDescriptorPool(vulkan.device, &sets, nullptr, &texturesPool);
    const VkDescriptorSetAllocateInfo set{.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .descriptorPool = texturesPool, .descriptorSetCount = 1, .pSetLayouts = &vulkan.texturesLayout};
    vkAllocateDescriptorSets(vulkan.device, &set, &vulkan.textures);
    vulkan.taken[0].assign(textures, false), vulkan.taken[1].assign(textures, false);
#define LOAD(name) vulkan.name = (PFN_##name)vkGetDeviceProcAddr(vulkan.device, #name)
    LOAD(vkGetAccelerationStructureBuildSizesKHR);
    LOAD(vkCreateAccelerationStructureKHR);
    LOAD(vkDestroyAccelerationStructureKHR);
    LOAD(vkCmdBuildAccelerationStructuresKHR);
    LOAD(vkGetAccelerationStructureDeviceAddressKHR);
#undef LOAD
    // Cached if it can be, as the host reads every redraw's sums back through it, which uncached memory slows down
    if (CUresult result = create(STAGING, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
        vulkan.staging, vulkan.stagingMemory, VK_MEMORY_PROPERTY_HOST_CACHED_BIT)) return result;
    *context = (CUcontext)vulkan.device;
    return vkMapMemory(vulkan.device, vulkan.stagingMemory, 0, STAGING, 0, &vulkan.mapped);
}

inline void barrier(VkPipelineStageFlags stage, VkAccessFlags access) {
    const VkMemoryBarrier barrier{.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER, .srcAccessMask = VK_ACCESS_MEMORY_WRITE_BIT,
        .dstAccessMask = access};
    vkCmdPipelineBarrier(vulkan.commands, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, stage, 0, 1, &barrier, 0, nullptr, 0,
        nullptr);
}

// The commands record records, after all earlier ones, waited for until the host sees what they wrote
template <class F> CUresult run(F record) {
    const VkCommandBufferBeginInfo begin{.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT};
    vkBeginCommandBuffer(vulkan.commands, &begin);
    barrier(VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_ACCESS_MEMORY_READ_BIT | VK_ACCESS_MEMORY_WRITE_BIT);
    record(vulkan.commands);
    barrier(VK_PIPELINE_STAGE_HOST_BIT, VK_ACCESS_HOST_READ_BIT);
    vkEndCommandBuffer(vulkan.commands);
    const VkSubmitInfo submit{.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1,
        .pCommandBuffers = &vulkan.commands};
    if (VkResult result = vkQueueSubmit(vulkan.queue, 1, &submit, vulkan.fence)) return result;
    if (VkResult result = vkWaitForFences(vulkan.device, 1, &vulkan.fence, VK_TRUE, UINT64_MAX)) return result;
    return vkResetFences(vulkan.device, 1, &vulkan.fence);
}

// The allocation an address is in and the address's offset into it
inline std::pair<Allocation&, VkDeviceSize> find(CUdeviceptr ptr) {
    const auto allocation = std::prev(vulkan.allocations.upper_bound(ptr));
    return {allocation->second, ptr - allocation->first};
}

// Of a size in whole words, which fills take
inline CUresult cuMemAlloc(CUdeviceptr* ptr, size_t bytes) {
    Allocation allocation{.bytes = bytes};
    if (CUresult result = create((bytes + 3) & ~size_t(3), VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, allocation.buffer,
        allocation.memory)) return result;
    const VkBufferDeviceAddressInfo info{.sType = VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
        .buffer = allocation.buffer};
    *ptr = vkGetBufferDeviceAddress(vulkan.device, &info);
    vulkan.allocations[*ptr] = allocation;
    return 0;
}

inline CUresult cuMemFree(CUdeviceptr ptr) {
    const Allocation& allocation = vulkan.allocations.at(ptr);
    for (VkAccelerationStructureKHR bvh : allocation.bvhs)
        vulkan.vkDestroyAccelerationStructureKHR(vulkan.device, bvh, nullptr);
    vkDestroyBuffer(vulkan.device, allocation.buffer, nullptr);
    vkFreeMemory(vulkan.device, allocation.memory, nullptr);
    vulkan.allocations.erase(ptr);
    return 0;
}

inline CUresult cuMemGetAddressRange(CUdeviceptr* base, size_t* bytes, CUdeviceptr ptr) {
    const auto [allocation, offset] = find(ptr);
    *bytes = allocation.bytes;
    *base = ptr - offset;
    return 0;
}

inline CUresult cuMemcpyHtoD(CUdeviceptr dst, const void* src, size_t bytes) {
    const auto [allocation, offset] = find(dst);
    for (size_t done = 0; done < bytes; done += STAGING) {
        const VkBufferCopy region{.dstOffset = offset + done, .size = std::min(bytes - done, STAGING)};
        std::memcpy(vulkan.mapped, (const char*)src + done, region.size);
        if (CUresult result = run([&](VkCommandBuffer commands) {
            vkCmdCopyBuffer(commands, vulkan.staging, allocation.buffer, 1, &region); })) return result;
    }
    return 0;
}

inline CUresult cuMemcpyDtoH(void* dst, CUdeviceptr src, size_t bytes) {
    const auto [allocation, offset] = find(src);
    for (size_t done = 0; done < bytes; done += STAGING) {
        const VkBufferCopy region{.srcOffset = offset + done, .size = std::min(bytes - done, STAGING)};
        if (CUresult result = run([&](VkCommandBuffer commands) {
            vkCmdCopyBuffer(commands, allocation.buffer, vulkan.staging, 1, &region); })) return result;
        std::memcpy((char*)dst + done, vulkan.mapped, region.size);
    }
    return 0;
}

inline CUresult cuMemcpyDtoD(CUdeviceptr dst, CUdeviceptr src, size_t bytes) {
    const auto [to, toOffset] = find(dst);
    const auto [from, fromOffset] = find(src);
    const VkBufferCopy region{fromOffset, toOffset, bytes};
    return run([&](VkCommandBuffer commands) { vkCmdCopyBuffer(commands, from.buffer, to.buffer, 1, &region); });
}

inline CUresult cuMemsetD32(CUdeviceptr ptr, unsigned value, size_t count) {
    const auto [allocation, offset] = find(ptr);
    return run([&](VkCommandBuffer commands) {
        vkCmdFillBuffer(commands, allocation.buffer, offset, 4 * count, value); });
}

// Of the words the bytes are in, from one
inline CUresult cuMemsetD8(CUdeviceptr ptr, unsigned char value, size_t count) {
    return cuMemsetD32(ptr, value * 0x01010101u, (count + 3) / 4);
}

// An image of an array's texels as unsigned integers, bytes or floats' words, which the shaders load whole
inline CUresult cuArrayCreate(CUarray* array, const CUDA_ARRAY_DESCRIPTOR* desc) {
    *array = new CUarray_st{.extent = {uint32_t(desc->Width), uint32_t(desc->Height), 1},
        .bytes = desc->Format != CU_AD_FORMAT_FLOAT};
    const VkImageCreateInfo info{.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .flags = VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT, .imageType = VK_IMAGE_TYPE_2D,
        .format = desc->Format == CU_AD_FORMAT_FLOAT ? VK_FORMAT_R32G32B32A32_UINT : VK_FORMAT_R8G8B8A8_UINT,
        .extent = (*array)->extent, .mipLevels = 1, .arrayLayers = 1, .samples = VK_SAMPLE_COUNT_1_BIT,
        .tiling = VK_IMAGE_TILING_OPTIMAL, .usage = VK_IMAGE_USAGE_SAMPLED_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT};
    if (VkResult result = vkCreateImage(vulkan.device, &info, nullptr, &(*array)->image)) return result;
    VkMemoryRequirements requirements;
    vkGetImageMemoryRequirements(vulkan.device, (*array)->image, &requirements);
    const VkMemoryAllocateInfo allocate{.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = requirements.size,
        .memoryTypeIndex = uint32_t(memoryType(requirements.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT))};
    if (VkResult result = vkAllocateMemory(vulkan.device, &allocate, nullptr, &(*array)->memory)) return result;
    if (VkResult result = vkBindImageMemory(vulkan.device, (*array)->image, (*array)->memory, 0)) return result;
    const VkImageViewCreateInfo view{.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, .image = (*array)->image,
        .viewType = VK_IMAGE_VIEW_TYPE_2D, .format = info.format,
        .subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1}};
    return vkCreateImageView(vulkan.device, &view, nullptr, &(*array)->view);
}

// An image's layout changed, after all earlier commands' writes and before all later commands' accesses
inline void layout(VkCommandBuffer commands, VkImage image, VkImageLayout from, VkImageLayout to) {
    const VkImageMemoryBarrier barrier{.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        .srcAccessMask = VK_ACCESS_MEMORY_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_MEMORY_READ_BIT | VK_ACCESS_MEMORY_WRITE_BIT, .oldLayout = from, .newLayout = to,
        .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED, .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED, .image = image,
        .subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1}};
    vkCmdPipelineBarrier(commands, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, 0, 0,
        nullptr, 0, nullptr, 1, &barrier);
}

// Of host rows into an array's image, as loader.h pipes them, of no gaps: through the staging buffer a run of rows at a
// time, for the shaders to read
inline CUresult cuMemcpy2D(const CUDA_MEMCPY2D* copy) {
    const CUarray array = copy->dstArray;
    const size_t rows = STAGING / copy->WidthInBytes;
    for (size_t row = 0; row < copy->Height; row += rows) {
        const uint32_t count = uint32_t(std::min(rows, copy->Height - row));
        std::memcpy(vulkan.mapped, (const char*)copy->srcHost + row * copy->srcPitch, count * copy->WidthInBytes);
        if (CUresult result = run([&](VkCommandBuffer commands) {
            layout(commands, array->image, row ? VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL : VK_IMAGE_LAYOUT_UNDEFINED,
                VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
            const VkBufferImageCopy region{.imageSubresource = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1},
                .imageOffset = {0, int32_t(row), 0}, .imageExtent = {array->extent.width, count, 1}};
            vkCmdCopyBufferToImage(commands, vulkan.staging, array->image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1,
                &region);
            layout(commands, array->image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
        })) return result;
    }
    return 0;
}

inline CUresult cuArrayDestroy(CUarray array) {
    vkDestroyImageView(vulkan.device, array->view, nullptr);
    vkDestroyImageView(vulkan.device, array->filtered, nullptr);
    vkDestroyImage(vulkan.device, array->image, nullptr);
    vkFreeMemory(vulkan.device, array->memory, nullptr);
    delete array;
    return 0;
}

// An array's image at the first free place of the shaders' textures, whole, or filtered through a view of floats,
// RGBA8 as k / 255 from sRGB if the texture reads it so, by the sampler of its extension; the texture's number
inline CUresult cuTexObjectCreate(CUtexObject* object, const CUDA_RESOURCE_DESC* resource,
    const CUDA_TEXTURE_DESC* texture, const void*) {
    const CUarray array = resource->res.array.hArray;
    const bool filtered = texture->filterMode == CU_TR_FILTER_MODE_LINEAR;
    std::vector<bool>& taken = vulkan.taken[filtered];
    *object = std::find(taken.begin(), taken.end(), false) - taken.begin();
    if (*object == taken.size()) return VK_ERROR_OUT_OF_POOL_MEMORY;
    taken[*object] = true;
    if (filtered) {
        const VkImageViewCreateInfo view{.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, .image = array->image,
            .viewType = VK_IMAGE_VIEW_TYPE_2D, .format = !array->bytes ? VK_FORMAT_R32G32B32A32_SFLOAT
            : texture->flags & CU_TRSF_SRGB ? VK_FORMAT_R8G8B8A8_SRGB : VK_FORMAT_R8G8B8A8_UNORM,
            .subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1}};
        if (VkResult result = vkCreateImageView(vulkan.device, &view, nullptr, &array->filtered)) return result;
    }
    const VkDescriptorImageInfo image{.imageView = filtered ? array->filtered : array->view,
        .imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL};
    const VkWriteDescriptorSet write{.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET, .dstSet = vulkan.textures,
        .dstBinding = filtered, .dstArrayElement = uint32_t(*object), .descriptorCount = 1,
        .descriptorType = VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, .pImageInfo = &image};
    vkUpdateDescriptorSets(vulkan.device, 1, &write, 0, nullptr);
    *object |= CUtexObject(filtered) << 32;
    return 0;
}

inline CUresult cuTexObjectDestroy(CUtexObject object) { return vulkan.taken[object >> 32][uint32_t(object)] = false; }
