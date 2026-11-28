#pragma once
// NVIDIA DLSS Ray Reconstruction of the viewport as Cycles' (integrator/denoiser_dlss.cpp), by the driver's NGX the
// DLSS SDK's headers load (DLSS_SDK_ROOT); inputs and output in CUDA arrays NGX reads as textures and writes a surface
#define NVSDK_NGX_HEADER_ONLY
#include <nvsdk_ngx.h>
#include <nvsdk_ngx_defs_dlssd.h>
#include "loader.h"
#include <filesystem>
constexpr char DLSS_PROJECT[] = "974758a4-3ed1-4a97-be35-515a49466fca"; // Flex's NGX project
// Per Upscale Mode, Cycles' quality: none (DLAA), Quality, Balanced, Performance, Ultra Performance
constexpr NVSDK_NGX_PerfQuality_Value DLSS_QUALITY[] = {NVSDK_NGX_PerfQuality_Value_DLAA,
    NVSDK_NGX_PerfQuality_Value_MaxQuality, NVSDK_NGX_PerfQuality_Value_Balanced, NVSDK_NGX_PerfQuality_Value_MaxPerf,
    NVSDK_NGX_PerfQuality_Value_UltraPerformance};
// Channels of colour, depth, diffuse and specular albedo, normal and roughness, motion, and the output
constexpr unsigned DLSS_CHANNELS[] = {4, 1, 4, 4, 4, 2, 4};

// Whether NGX, started on the current context, runs Ray Reconstruction
inline bool dlssStart() {
    NVSDK_NGX_Parameter* capabilities;
    int available = 0;
    return NVSDK_NGX_SUCCEED(NVSDK_NGX_CUDA_Init_with_ProjectID(DLSS_PROJECT, NVSDK_NGX_ENGINE_TYPE_CUSTOM, "1",
        std::filesystem::temp_directory_path().wstring().c_str())) && NVSDK_NGX_SUCCEED(
        NVSDK_NGX_CUDA_GetCapabilityParameters(&capabilities)) && NVSDK_NGX_SUCCEED(capabilities->Get(
        NVSDK_NGX_Parameter_SuperSamplingDenoising_Available, &available)) && available;
}

// A view's Ray Reconstruction from width x height to its output's size, by Upscale Mode
struct Dlss {
    unsigned width, height, outputWidth, outputHeight;
    NVSDK_NGX_Handle* feature;
    CUarray arrays[std::size(DLSS_CHANNELS)]; CUtexObject textures[std::size(DLSS_CHANNELS)]; CUsurfObject output;
};
inline Dlss dlssCreate(unsigned width, unsigned height, unsigned outputWidth, unsigned outputHeight, unsigned mode) {
    Dlss dlss{width, height, outputWidth, outputHeight};
    NVSDK_NGX_Parameter* parameters;
    CHECK(NVSDK_NGX_FAILED(NVSDK_NGX_CUDA_AllocateParameters(&parameters)));
    parameters->Set(NVSDK_NGX_Parameter_Width, width), parameters->Set(NVSDK_NGX_Parameter_Height, height);
    parameters->Set(NVSDK_NGX_Parameter_OutWidth, outputWidth);
    parameters->Set(NVSDK_NGX_Parameter_OutHeight, outputHeight);
    parameters->Set(NVSDK_NGX_Parameter_PerfQualityValue, DLSS_QUALITY[mode]);
    parameters->Set(NVSDK_NGX_Parameter_DLSS_Denoise_Mode, NVSDK_NGX_DLSS_Denoise_Mode_DLUnified);
    parameters->Set(NVSDK_NGX_Parameter_DLSS_Feature_Create_Flags,
        NVSDK_NGX_DLSS_Feature_Flags_IsHDR | NVSDK_NGX_DLSS_Feature_Flags_MVLowRes
        | NVSDK_NGX_DLSS_Feature_Flags_AlphaUpscaling);
    parameters->Set(NVSDK_NGX_Parameter_DLSS_Enable_Output_Subrects, 0);
    parameters->Set(NVSDK_NGX_Parameter_Use_HW_Depth, NVSDK_NGX_DLSS_Depth_Type_Linear);
    parameters->Set(NVSDK_NGX_Parameter_DLSS_Roughness_Mode, NVSDK_NGX_DLSS_Roughness_Mode_Packed);
    parameters->Set(NVSDK_NGX_Parameter_FreeMemOnReleaseFeature, 1);
    CHECK(NVSDK_NGX_FAILED(NVSDK_NGX_CUDA_CreateFeature(NVSDK_NGX_Feature_RayReconstruction, parameters,
        &dlss.feature)));
    CHECK(NVSDK_NGX_FAILED(NVSDK_NGX_CUDA_DestroyParameters(parameters)));
    for (size_t k = 0; k < std::size(DLSS_CHANNELS); ++k) {
        const bool out = k + 1 == std::size(DLSS_CHANNELS);
        const CUDA_ARRAY_DESCRIPTOR shape{out ? outputWidth : width, out ? outputHeight : height, CU_AD_FORMAT_FLOAT,
            DLSS_CHANNELS[k]};
        CHECK(cuArrayCreate(&dlss.arrays[k], &shape));
        CUDA_RESOURCE_DESC resource{.resType = CU_RESOURCE_TYPE_ARRAY};
        resource.res.array.hArray = dlss.arrays[k];
        const CUDA_TEXTURE_DESC texture{.addressMode = {CU_TR_ADDRESS_MODE_CLAMP, CU_TR_ADDRESS_MODE_CLAMP,
            CU_TR_ADDRESS_MODE_CLAMP}, .flags = CU_TRSF_NORMALIZED_COORDINATES};
        CHECK(cuTexObjectCreate(&dlss.textures[k], &resource, &texture, nullptr));
        if (out) CHECK(cuSurfObjectCreate(&dlss.output, &resource));
    }
    return dlss;
}
inline void dlssDestroy(const Dlss& dlss) {
    CHECK(NVSDK_NGX_FAILED(NVSDK_NGX_CUDA_ReleaseFeature(dlss.feature)));
    CHECK(cuSurfObjectDestroy(dlss.output));
    for (const CUtexObject texture : dlss.textures) CHECK(cuTexObjectDestroy(texture));
    for (const CUarray array : dlss.arrays) CHECK(cuArrayDestroy(array));
}

// The inputs, rows top to bottom (colour, linear depth, diffuse and specular albedo, normal and roughness, the motion
// since the last frame) of a frame at the jitter's offset, denoised and upscaled into output; reset where the last
// frame continues none
inline void dlssRun(const Dlss& dlss, const CUdeviceptr (&inputs)[std::size(DLSS_CHANNELS) - 1], float2 jitter,
    CUdeviceptr output, bool reset) {
    for (size_t k = 0; k < std::size(inputs); ++k) {
        const CUDA_MEMCPY2D copy{.srcMemoryType = CU_MEMORYTYPE_DEVICE, .srcDevice = inputs[k],
            .srcPitch = dlss.width * DLSS_CHANNELS[k] * sizeof(float), .dstMemoryType = CU_MEMORYTYPE_ARRAY,
            .dstArray = dlss.arrays[k], .WidthInBytes = dlss.width * DLSS_CHANNELS[k] * sizeof(float),
            .Height = dlss.height};
        CHECK(cuMemcpy2D(&copy));
    }
    NVSDK_NGX_Parameter* parameters;
    CHECK(NVSDK_NGX_FAILED(NVSDK_NGX_CUDA_AllocateParameters(&parameters)));
    parameters->Set(NVSDK_NGX_Parameter_Reset, int(reset));
    parameters->Set(NVSDK_NGX_Parameter_Jitter_Offset_X, jitter.x);
    parameters->Set(NVSDK_NGX_Parameter_Jitter_Offset_Y, jitter.y);
    const char* names[] = {NVSDK_NGX_Parameter_Color, NVSDK_NGX_Parameter_Depth, NVSDK_NGX_Parameter_DiffuseAlbedo,
        NVSDK_NGX_Parameter_SpecularAlbedo, NVSDK_NGX_Parameter_GBuffer_Normals, NVSDK_NGX_Parameter_MotionVectors};
    for (size_t k = 0; k < std::size(names); ++k) parameters->Set(names[k], (void*)&dlss.textures[k]);
    parameters->Set(NVSDK_NGX_Parameter_GBuffer_Roughness, (void*)&dlss.textures[4]);
    parameters->Set(NVSDK_NGX_Parameter_Output, (void*)&dlss.output);
    // The motion as the flow's opposite: from where a pixel's point is now to where it was
    parameters->Set(NVSDK_NGX_Parameter_MV_Scale_X, -1.0f), parameters->Set(NVSDK_NGX_Parameter_MV_Scale_Y, -1.0f);
    parameters->Set(NVSDK_NGX_Parameter_DLSS_Render_Subrect_Dimensions_Width, dlss.width);
    parameters->Set(NVSDK_NGX_Parameter_DLSS_Render_Subrect_Dimensions_Height, dlss.height);
    CHECK(NVSDK_NGX_FAILED(NVSDK_NGX_CUDA_EvaluateFeature(dlss.feature, parameters)));
    CHECK(NVSDK_NGX_FAILED(NVSDK_NGX_CUDA_DestroyParameters(parameters)));
    const CUDA_MEMCPY2D copy{.srcMemoryType = CU_MEMORYTYPE_ARRAY, .srcArray = dlss.arrays[std::size(inputs)],
        .dstMemoryType = CU_MEMORYTYPE_DEVICE, .dstDevice = output, .dstPitch = dlss.outputWidth * sizeof(float4),
        .WidthInBytes = dlss.outputWidth * sizeof(float4), .Height = dlss.outputHeight};
    CHECK(cuMemcpy2D(&copy));
}
