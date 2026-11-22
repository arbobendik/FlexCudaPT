CXXFLAGS ?= -O2 -std=c++20
NVCC ?= nvcc
CUDA_PATH ?= /opt/cuda
OPTIX_PATH ?= .deps/optix
# FlexKernels' version, as the module it generates loads in it alone
SLANG_VERSION ?= 2026.19
SLANG_PATH ?= .deps/slang-$(SLANG_VERSION)
SLANGC ?= $(SLANG_PATH)/bin/slangc
CPPFLAGS += -I$(CUDA_PATH)/include -I$(OPTIX_PATH)/include
LDLIBS += -L$(CUDA_PATH)/lib64 -lcuda -ldl

build/flex.zip: src/__init__.py src/blender_manifest.toml src/hosek_wilkie.npy src/hosek_wilkie.LICENSE build/renderer \
	build/renderer-vulkan build/native $(wildcard build/bluenoise-512x512x32.bin)  # The tensor CI's packaging fetches
	python3 -m zipfile -c $@ $^

# The same tensor of any side on the CPU, by FlexKernels' noise.cpp: test.py's reference for the generation
build/bluenoise: tools/bluenoise.cpp src/shaders/flexkernels/noise.cpp
	mkdir -p build
	$(CXX) -std=c++20 -O2 -fopenmp -ffunction-sections -Wl,--gc-sections -Isrc/shaders/flexkernels \
		-I$(SLANG_PATH)/include $< -o $@

# What the native programs' helper compiles with NVRTC, which it ships: the renderer's source and the headers it reads
build/native: src/shaders/renderer.cu src/shaders/renderer.h src/shaders/adapter.h src/shaders/adapter.cuh \
	src/shaders/flexkernels/pathtracer.cuh
	rm -rf $@ && mkdir -p $@/flexkernels
	cp $(filter-out %pathtracer.cuh,$^) $(SLANG_PATH)/include/slang-cuda-prelude.h $(CUDA_PATH)/include/cuda_fp16.h \
		$(CUDA_PATH)/include/cuda_fp16.hpp $@
	cp -r $(OPTIX_PATH)/include/* $@
	cp src/shaders/flexkernels/pathtracer.cuh $@/flexkernels
	cp -L $(CUDA_PATH)/lib64/libnvrtc.so.13 $(CUDA_PATH)/lib64/libnvrtc-builtins.so.13.? $@

build/renderer: src/main.cpp src/loader.h src/native.h src/shaders/renderer.h build/shaders.h
	$(CXX) $(CPPFLAGS) -Ibuild $(CXXFLAGS) -ffp-contract=off $< -o $@ $(LDLIBS)

# The walk's CUDA reads Slang's prelude from the Slang it pins
PTXFLAGS = -std=c++20 -ptx -arch=compute_75 --use_fast_math -rdc=true -I$(OPTIX_PATH)/include -I$(SLANG_PATH)/include
build/shaders.h: src/shaders/renderer.cu src/shaders/renderer.h src/shaders/adapter.h src/shaders/adapter.cuh \
	src/shaders/flexkernels/pathtracer.cuh src/shaders/noise.cu src/shaders/flexkernels/noise.cuh $(SLANGC) \
	$(OPTIX_PATH)/include/optix.h
	mkdir -p build
	$(NVCC) $(PTXFLAGS) $< -o build/shaders.ptx
	$(NVCC) $(PTXFLAGS) -DSTANDIN $< -o build/standin.ptx
	$(NVCC) $(PTXFLAGS) -DEXTENDED $< -o build/extended.ptx
	$(NVCC) $(PTXFLAGS) -DEXTENDED -DSTANDIN $< -o build/extended_standin.ptx
	$(NVCC) $(PTXFLAGS) src/shaders/noise.cu -o build/noise.ptx
	xxd -i build/shaders.ptx > $@
	xxd -i build/noise.ptx >> $@
	xxd -i build/standin.ptx >> $@
	xxd -i build/extended.ptx >> $@
	xxd -i build/extended_standin.ptx >> $@

# The same host on Vulkan, which src/vulkan stands in for CUDA and OptiX on
build/renderer-vulkan: src/main.cpp src/loader.h src/shaders/renderer.h src/vulkan/cuda.h src/vulkan/optix_stubs.h \
	src/vulkan/vector_types.h build/vulkan/shaders.h $(OPTIX_PATH)/include/optix.h
	$(CXX) -Isrc/vulkan -I$(OPTIX_PATH)/include -Ibuild/vulkan $(CXXFLAGS) -ffp-contract=off $< -o $@ -lvulkan

# Under the name of the PTX, which the host loads; shading fills its program's stack before reading it
build/vulkan/shaders.h: src/shaders/renderer.slang src/shaders/renderer.h src/shaders/flexkernels/pathtracer.slang-module \
	src/shaders/flexkernels/noise-start.spv src/shaders/flexkernels/noise-sweep.spv \
	$(SLANGC)
	mkdir -p build/vulkan
	$(SLANGC) -warnings-disable 41035 -O2 -Isrc/shaders/flexkernels $< -target spirv -o build/vulkan/shaders.spv
	$(SLANGC) -warnings-disable 41035 -O2 -DEXTENDED -Isrc/shaders/flexkernels $< -target spirv -o build/vulkan/extended.spv
	# The temporal round's count and queue alone, the second pipeline's, and its queued shifts and reuse alone, the
	# third's: what each entry reaches
	$(SLANGC) -warnings-disable 41035 -O2 -Isrc/shaders/flexkernels $< -entry queue -target spirv -o build/vulkan/queue.spv
	$(SLANGC) -warnings-disable 41035 -O2 -DEXTENDED -Isrc/shaders/flexkernels $< -entry queue -target spirv \
		-o build/vulkan/extended_queue.spv
	$(SLANGC) -warnings-disable 41035 -O2 -Isrc/shaders/flexkernels $< -entry temporal -target spirv \
		-o build/vulkan/temporal.spv
	$(SLANGC) -warnings-disable 41035 -O2 -DEXTENDED -Isrc/shaders/flexkernels $< -entry temporal -target spirv \
		-o build/vulkan/extended_temporal.spv
	xxd -i -n build_shaders_ptx build/vulkan/shaders.spv > $@
	xxd -i -n build_extended_ptx build/vulkan/extended.spv >> $@
	xxd -i -n build_queue_ptx build/vulkan/queue.spv >> $@
	xxd -i -n build_extended_queue_ptx build/vulkan/extended_queue.spv >> $@
	xxd -i -n build_noise_start_spv src/shaders/flexkernels/noise-start.spv >> $@
	xxd -i -n build_noise_sweep_spv src/shaders/flexkernels/noise-sweep.spv >> $@
	xxd -i -n build_temporal_ptx build/vulkan/temporal.spv >> $@
	xxd -i -n build_extended_temporal_ptx build/vulkan/extended_temporal.spv >> $@
	printf '#define build_standin_ptx build_shaders_ptx\n' >> $@ # Its own stand-in: Vulkan has no inlining to undo
	printf '#define build_standin_ptx_len build_shaders_ptx_len\n' >> $@
	printf '#define build_extended_standin_ptx build_extended_ptx\n' >> $@
	printf '#define build_extended_standin_ptx_len build_extended_ptx_len\n' >> $@

$(SLANGC):
	mkdir -p $(SLANG_PATH)
	curl -sSfL https://github.com/shader-slang/slang/releases/download/v$(SLANG_VERSION)/slang-$(SLANG_VERSION)-linux-x86_64.tar.gz \
		| tar -xz -C $(SLANG_PATH)

$(OPTIX_PATH)/include/optix.h:
	git clone --depth 1 --branch v9.1.0 https://github.com/NVIDIA/optix-dev.git $(OPTIX_PATH)

.PHONY: install test clean
install: build/flex.zip  # A running Blender loads the new build within a second
	blender -b --command extension install-file -r user_default -e $<

test: export BLENDER_USER_RESOURCES = $(CURDIR)/build/blender
test: install build/bluenoise  # Into the exported resources instead of the user's
	blender -b --python-exit-code 1 -P src/test.py

clean:
	rm -rf build
