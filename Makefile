CXXFLAGS ?= -O2 -std=c++20
NVCC ?= nvcc
CUDA_PATH ?= /opt/cuda
OPTIX_PATH ?= .deps/optix
CPPFLAGS += -I$(CUDA_PATH)/include -I$(OPTIX_PATH)/include
LDLIBS += -L$(CUDA_PATH)/lib64 -lcuda -ldl

build/flex.zip: src/__init__.py src/blender_manifest.toml
	mkdir -p build
	python3 -m zipfile -c $@ $^

build/renderer: src/main.cpp src/loader.h src/shaders/renderer.h build/shaders.h
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< -o $@ $(LDLIBS)

build/shaders.h: src/shaders/renderer.cu src/shaders/renderer.h $(OPTIX_PATH)/include/optix.h
	mkdir -p build
	$(NVCC) -std=c++20 -ptx -arch=compute_75 -I$(OPTIX_PATH)/include $< -o build/shaders.ptx
	xxd -i build/shaders.ptx > $@

$(OPTIX_PATH)/include/optix.h:
	git clone --depth 1 --branch v9.1.0 https://github.com/NVIDIA/optix-dev.git $(OPTIX_PATH)

.PHONY: clean
clean:
	rm -rf build
