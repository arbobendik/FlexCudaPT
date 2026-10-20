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

// Index of a memory type of the properties among those of bits, of none -1
inline int memoryType(uint32_t bits, VkMemoryPropertyFlags flags) {
    VkPhysicalDeviceMemoryProperties memory;
    vkGetPhysicalDeviceMemoryProperties(vulkan.physical, &memory);
    for (uint32_t i = 0; i < memory.memoryTypeCount; ++i)
        if (bits >> i & 1 && (memory.memoryTypes[i].propertyFlags & flags) == flags) return i;
    return -1;
}

// Buffer for every use of a device's memory of the properties, at its address with them, to allocations
inline CUresult create(VkDeviceSize bytes, VkMemoryPropertyFlags flags, VkBuffer& buffer, VkDeviceMemory& memory) {
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
        .allocationSize = requirements.size, .memoryTypeIndex = uint32_t(memoryType(requirements.memoryTypeBits, flags))};
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
    // What the renderer's SPIR-V declares: 8 and 64 bit integers, pointers of scalar layout and ray queries
    VkPhysicalDeviceRayQueryFeaturesKHR rayQuery{.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR,
        .rayQuery = VK_TRUE};
    VkPhysicalDeviceAccelerationStructureFeaturesKHR bvh{
        .sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR, .pNext = &rayQuery,
        .accelerationStructure = VK_TRUE};
    VkPhysicalDeviceVulkan12Features vulkan12{.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
        .pNext = &bvh, .storageBuffer8BitAccess = VK_TRUE, .shaderInt8 = VK_TRUE, .scalarBlockLayout = VK_TRUE,
        .bufferDeviceAddress = VK_TRUE};
    VkPhysicalDeviceFeatures2 features{.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2, .pNext = &vulkan12,
        .features = {.shaderInt64 = VK_TRUE}};
    const VkDeviceCreateInfo info{.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, .pNext = &features,
        .queueCreateInfoCount = 1, .pQueueCreateInfos = &queue, .enabledExtensionCount = uint32_t(std::size(extensions)),
        .ppEnabledExtensionNames = extensions};
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
#define LOAD(name) vulkan.name = (PFN_##name)vkGetDeviceProcAddr(vulkan.device, #name)
    LOAD(vkGetAccelerationStructureBuildSizesKHR);
    LOAD(vkCreateAccelerationStructureKHR);
    LOAD(vkDestroyAccelerationStructureKHR);
    LOAD(vkCmdBuildAccelerationStructuresKHR);
    LOAD(vkGetAccelerationStructureDeviceAddressKHR);
#undef LOAD
    if (CUresult result = create(STAGING, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
        vulkan.staging, vulkan.stagingMemory)) return result;
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
inline Allocation& find(CUdeviceptr ptr, VkDeviceSize& offset) {
    const auto allocation = std::prev(vulkan.allocations.upper_bound(ptr));
    offset = ptr - allocation->first;
    return allocation->second;
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
    VkDeviceSize offset;
    *bytes = find(ptr, offset).bytes;
    *base = ptr - offset;
    return 0;
}

inline CUresult cuMemcpyHtoD(CUdeviceptr dst, const void* src, size_t bytes) {
    VkDeviceSize offset;
    const VkBuffer buffer = find(dst, offset).buffer;
    for (size_t done = 0; done < bytes; done += STAGING) {
        const VkBufferCopy region{.dstOffset = offset + done, .size = std::min(bytes - done, STAGING)};
        std::memcpy(vulkan.mapped, (const char*)src + done, region.size);
        if (CUresult result = run([&](VkCommandBuffer commands) {
            vkCmdCopyBuffer(commands, vulkan.staging, buffer, 1, &region); })) return result;
    }
    return 0;
}

inline CUresult cuMemcpyDtoH(void* dst, CUdeviceptr src, size_t bytes) {
    VkDeviceSize offset;
    const VkBuffer buffer = find(src, offset).buffer;
    for (size_t done = 0; done < bytes; done += STAGING) {
        const VkBufferCopy region{.srcOffset = offset + done, .size = std::min(bytes - done, STAGING)};
        if (CUresult result = run([&](VkCommandBuffer commands) {
            vkCmdCopyBuffer(commands, buffer, vulkan.staging, 1, &region); })) return result;
        std::memcpy((char*)dst + done, vulkan.mapped, region.size);
    }
    return 0;
}

inline CUresult cuMemcpyDtoD(CUdeviceptr dst, CUdeviceptr src, size_t bytes) {
    VkBufferCopy region{.size = bytes};
    const VkBuffer to = find(dst, region.dstOffset).buffer, from = find(src, region.srcOffset).buffer;
    return run([&](VkCommandBuffer commands) { vkCmdCopyBuffer(commands, from, to, 1, &region); });
}

inline CUresult cuMemsetD32(CUdeviceptr ptr, unsigned value, size_t count) {
    VkDeviceSize offset;
    const VkBuffer buffer = find(ptr, offset).buffer;
    return run([&](VkCommandBuffer commands) { vkCmdFillBuffer(commands, buffer, offset, 4 * count, value); });
}

// Of the words the bytes are in, from one
inline CUresult cuMemsetD8(CUdeviceptr ptr, unsigned char value, size_t count) {
    return cuMemsetD32(ptr, value * 0x01010101u, (count + 3) / 4);
}
