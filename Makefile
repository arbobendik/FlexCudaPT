CXXFLAGS ?= -O2 -std=c++20
CUDA_PATH ?= /opt/cuda
OPTIX_PATH ?= .deps/optix
CPPFLAGS += -I$(CUDA_PATH)/include -I$(OPTIX_PATH)/include
LDLIBS += -L$(CUDA_PATH)/lib64 -lcuda -ldl

build/flex.zip: src/__init__.py src/blender_manifest.toml
	mkdir -p build
	python3 -m zipfile -c $@ $^

build/renderer: src/main.cpp src/loader.h $(OPTIX_PATH)/include/optix.h
	mkdir -p build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< -o $@ $(LDLIBS)

$(OPTIX_PATH)/include/optix.h:
	git clone --depth 1 --branch v9.1.0 https://github.com/NVIDIA/optix-dev.git $(OPTIX_PATH)

.PHONY: clean
clean:
	rm -rf build
