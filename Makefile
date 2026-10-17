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

build/flex.zip: src/__init__.py src/blender_manifest.toml build/renderer
	python3 -m zipfile -c $@ $^

build/renderer: src/main.cpp src/loader.h src/shaders/renderer.h build/shaders.h
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< -o $@ $(LDLIBS)

build/shaders.h: src/shaders/renderer.cu src/shaders/renderer.h src/shaders/flexkernels/pathtracer.cuh $(SLANGC) \
	$(OPTIX_PATH)/include/optix.h
	mkdir -p build
	$(NVCC) -std=c++20 -ptx -arch=compute_75 --use_fast_math -I$(OPTIX_PATH)/include -I$(SLANG_PATH)/include $< -o build/shaders.ptx
	xxd -i build/shaders.ptx > $@

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
test: install  # Into the exported resources instead of the user's
	blender -b --python-exit-code 1 -P src/test.py

clean:
	rm -rf build
