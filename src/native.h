#pragma once
// Native programs: a scene's chosen material programs as straight-line CUDA, each step the interpreter's own with its
// code and fields as literals, so the compiler folds its switch and keeps the stack in registers. They are compiled
// with the renderer's source by NVRTC in a helper process, off the frames; the interpreter renders until they swap in.
#include "shaders/renderer.h"
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <string>
#include <vector>
#include <dlfcn.h>
#include <csignal>
#include <sys/prctl.h>
#include <unistd.h>

// The programs worth native code: by shade()'s calls at the hot call sites times their length, the fewest covering 90 %
// of those reading no bake, whose cost is their texel fetches, which native code keeps
inline std::vector<unsigned> chooseNative(const std::vector<Op>& ops, const std::vector<unsigned>& calls) {
    std::vector<std::pair<double, unsigned>> costs;
    double total = 0;
    for (unsigned start = 0; start < calls.size(); ++start) {
        if (!calls[start]) continue;
        unsigned end = start;
        bool baked = false;
        for (; ops[end].code; ++end) baked |= (ops[end].code & CODE) == BAKED;
        if (baked) continue;
        costs.push_back({double(calls[start]) * (end - start), start}), total += costs.back().first;
    }
    std::sort(costs.rbegin(), costs.rend());
    std::vector<unsigned> chosen;
    double covered = 0;
    for (const auto& [cost, start] : costs) {
        if (covered >= 0.9 * total) break;
        chosen.push_back(start), covered += cost;
    }
    return chosen;
}

// How the generator writes each step: kind, the values it pops and the arguments before them (x the point, c its code,
// o its fields); a step without an entry leaves its program to the interpreter
struct Emitter { unsigned code; const char* name; char kind; int pops; const char* lead; };
#define E(code, kind, pops, lead) {code, #code, kind, pops, lead}
constexpr Emitter EMITTERS[] = {E(PUSH, 'p', 0, ""), E(STORE, 's', 0, ""), E(LOAD, 'l', 0, ""), E(SHIFT, 'h', 0, ""),
    E(SHIFTED, 'H', 0, ""), E(CAMERA_POINT, 'c', 0, ""), E(WINDOW, 'c', 0, ""),
    E(SPECULAR, 'm', 0, ""), E(TRANSLUCENT, 'm', 0, ""), E(SHEEN, 'm', 0, ""), E(ANISOTROPIC, 'm', 0, ""),
    E(PHASE, 'm', 0, ""), E(VELVET, 'm', 0, ""), E(TOON, 'm', 0, ""), E(DISPERSION, 'm', 0, ""),
    E(UV, 'f', 0, "x"), E(GENERATED, 'f', 0, "x"), E(OBJECT, 'f', 0, "x"), E(VERTEX_COLOR, 'f', 0, "x"),
    E(VERTEX_ALPHA, 'f', 0, "x"), E(NORMAL, 'f', 0, "x"), E(POSITION, 'f', 0, "x"), E(INCOMING, 'f', 0, "x"),
    E(BACKFACING, 'f', 0, "x"), E(ADD, 'b', 2, ""), E(SUBTRACT, 'b', 2, ""), E(MULTIPLY, 'b', 2, ""),
    E(DOT_PRODUCT, 'b', 2, ""), E(MAXIMUM, 'b', 2, ""), E(LOGARITHM, 'b', 2, ""), E(DIVIDE, 'b', 2, ""),
    E(POWER, 'b', 2, ""), E(MINIMUM, 'b', 2, ""), E(LESS_THAN, 'b', 2, ""), E(MODULO, 'b', 2, ""),
    E(ARCTAN2, 'b', 2, ""), E(CROSS_PRODUCT, 'b', 2, ""), E(EXPONENT, 'f', 1, ""), E(FLOOR, 'f', 1, ""),
    E(SINE, 'f', 1, ""), E(COSINE, 'f', 1, ""), E(TANGENT, 'f', 1, ""), E(ARCSINE, 'f', 1, ""),
    E(ARCCOSINE, 'f', 1, ""), E(ARCTANGENT, 'f', 1, ""), E(SINH, 'f', 1, ""), E(COSH, 'f', 1, ""),
    E(TANH, 'f', 1, ""), E(RGB_TO_HSV, 'f', 1, ""), E(HSV_TO_RGB, 'f', 1, ""), E(RGB_TO_HSL, 'f', 1, ""),
    E(HSL_TO_RGB, 'f', 1, ""), E(MIRROR_BALL, 'f', 1, ""), E(SNAP, 'f', 2, ""), E(BOX, 'f', 2, ""),
    E(MAGIC, 'f', 2, ""), E(WHITE_NOISE, 'f', 2, ""), E(DIELECTRIC, 'f', 2, ""), E(MULTIPLY_ADD, 'f', 3, ""),
    E(SELECT, 'f', 3, ""), E(ROTATE, 'f', 3, ""), E(BRICK, 'f', 4, ""), E(NOISE, 'f', 4, ""),
    E(VORONOI, 'f', 5, ""), E(HAIR, 'f', 1, "x"), E(OBJECT_INFO, 'f', 1, "x"), E(INSTANCER, 'f', 1, "x"),
    E(LIGHT_PATH, 'f', 1, "x"), E(NORMAL_MAP, 'f', 1, "x"), E(TRANSFORM, 'f', 2, "x"), E(BUMP, 'f', 5, "x"),
    E(BAKED, 'f', 1, "xo"), E(GRID, 'f', 1, "xo"), E(EQUIRECTANGULAR, 'f', 1, "o"), E(IMAGE, 'i', 1, "xco"),
    E(ALPHA, 'i', 1, "xco"), E(IMAGE_LINEAR, 'i', 1, "xco"), E(ALPHA_LINEAR, 'i', 1, "xco"),
    E(IMAGE_CUBIC, 'i', 1, "xco"), E(ALPHA_CUBIC, 'i', 1, "xco")};
#undef E

// A program as straight-line CUDA: the stack simulated here, each value a const of its step's op function, a literal
// read from a constant array of the steps' words, which the compiler folds (loaded, an identity check's: from the
// scene as the interpreter reads them, none folded); then the Surface as shade() reads the stack. Empty if a step has
// no emitter.
inline std::string nativeProgram(const std::vector<Op>& ops, unsigned start, bool loaded) {
    std::vector<std::string> stack, saved(32); // The slots, as many as the interpreter's
    std::string body;
    unsigned n = 0;
    const auto value = [&](const std::string& e) {
        const std::string name = "v" + std::to_string(++n);
        body += "    const float3 " + name + " = " + e + ";\n";
        return name;
    };
    const auto pop = [&] { std::string top = stack.back(); stack.pop_back(); return top; };
    unsigned end = start;
    for (; ops[end].code; ++end) {
        const unsigned word = ops[end].code, code = word & CODE;
        const Emitter* e = std::find_if(std::begin(EMITTERS), std::end(EMITTERS),
            [&](const Emitter& e) { return e.code == code; });
        if (e == std::end(EMITTERS) || stack.size() < unsigned(e->pops)) return {};
        const std::string own = "o[" + std::to_string(end - start) + "]";
        if (e->kind == 'p') stack.push_back(own + ".value");
        else if (e->kind == 's') saved[ops[end].texel] = stack.back();
        else if (e->kind == 'l' && saved[ops[end].texel].empty()) return {};
        else if (e->kind == 'l') stack.push_back(saved[ops[end].texel]);
        else if (e->kind == 'h') body += "    op_SHIFT(x, " + stack.back() + ");\n";
        else if (e->kind == 'H') { std::string b = pop(); stack.back() = b; body += "    op_SHIFTED(x);\n"; }
        else if (e->kind == 'c') stack.push_back(value("op_CAMERA_POINT(x, " + std::to_string(code) + ")"));
        else if (e->kind == 'b') {
            const bool imm = word & IMMEDIATE, from = word & FROM, left = word & LEFT, first = word & FIRST;
            const std::string slot = saved[word >> 8 & 31];
            if (from && slot.empty()) return {};
            const std::string b = imm && !left ? own + ".value" : from && !first ? slot : pop();
            const std::string a = imm && left ? own + ".value" : from && first ? slot : pop();
            stack.push_back(value(std::string("op_") + e->name + "(" + a + ", " + b + ")"));
        } else if (e->kind != 'm') {
            std::string args;
            for (const char* r = e->lead; *r; ++r)
                args += *r == 'x' ? "x, " : *r == 'c' ? std::to_string(code) + ", " : own + ", ";
            for (unsigned k = stack.size() - e->pops; k < stack.size(); ++k) args += stack[k] + ", ";
            stack.resize(stack.size() - e->pops);
            stack.push_back(value(std::string("op_") + (e->kind == 'i' ? "IMAGE" : e->name) + "("
                + args.substr(0, args.size() - 2) + ")"));
        }
        if (word & KEEP) saved[word >> 13 & 31] = stack.back();
    }
    const size_t d = stack.size();
    if (d < 13) return {};
    const std::string z = "make_float3(0, 0, 0)";
    const auto opt = [&](size_t i, const char* mark, size_t more, const char* f, const std::string& zero) {
        return d > more ? "used(" + std::string(mark) + ") ? " + stack[i] + f + " : " + zero : zero;
    };
    const std::string fields[] = {"normalize(" + stack[0] + ")", stack[1], stack[2] + ".x", stack[3] + ".x", stack[4],
        stack[5] + ".x", stack[6] + ".x", stack[7], stack[8] + ".x", stack[9] + ".x", stack[10], stack[11] + ".x",
        stack[12], opt(13, "TRANSLUCENT", 13, "", z), opt(14, "SHEEN", 15, "", z), opt(15, "SHEEN", 15, ".x", "0.5f"),
        opt(16, "ANISOTROPIC", 18, ".x", "0"), opt(17, "ANISOTROPIC", 18, ".x", "0"), opt(18, "ANISOTROPIC", 18, "", z),
        opt(19, "MEDIUM", 19, "", z), opt(20, "HAIR", 20, "", z), opt(21, "PHASE", 21, ".x", "0"),
        opt(22, "VELVET", 22, ".x", "0"), opt(23, "TOON", 23, "", z), opt(24, "DISPERSION", 24, ".x", "0")};
    std::string text, words; // Each step as an Op, its fields' bits cast to its value's floats, as no word array read
    for (unsigned k = start; k < end; ++k) { // through an Op* may be (its loads folded by the compiler as undefined)
        char word[160];
        std::snprintf(word, sizeof(word), "%s{%#xu, {{__builtin_bit_cast(float, %#xu), "
            "__builtin_bit_cast(float, %#xu), __builtin_bit_cast(float, %#xu)}}}", k > start ? ", " : "", ops[k].code,
            ops[k].texel, ops[k].width, ops[k].height), words += word;
    }
    if (!loaded) text = "__device__ const Op native" + std::to_string(start) + "_[] = {" + words + "};\n";
    text += "__device__ __forceinline__ Surface native" + std::to_string(start) + "(Shading& x) {\n    const Op* o = "
        + (loaded ? "x.scene.ops + " + std::to_string(start) : "native" + std::to_string(start) + "_")
        + ";\n" + body + "    return {";
    for (size_t i = 0; i < std::size(fields); ++i) text += (i ? ", " : "") + fields[i];
    return text + "};\n}\n";
}

// The chosen programs' functions and shade()'s cases calling them, those without one left to the interpreter
inline std::string generateNative(const std::vector<Op>& ops, const std::vector<unsigned>& chosen, bool loaded) {
    std::string functions, cases = "#define NATIVE_CASES";
    for (const unsigned start : chosen)
        if (const std::string program = nativeProgram(ops, start, loaded); !program.empty())
            functions += program, cases += " case " + std::to_string(start) + ": return native"
                + std::to_string(start) + "(x);";
    return functions + cases + "\n";
}

// Where the add-on ships what the helper compiles with: beside the renderer's binary
inline std::string nativeDirectory() {
    char self[4096];
    const ssize_t length = readlink("/proc/self/exe", self, sizeof(self) - 1);
    self[std::max<ssize_t>(length, 0)] = 0;
    const char* slash = std::strrchr(self, '/');
    return std::string(self, slash ? slash - self : 0) + "/native";
}

// The helper process: renderer.cu shipped beside the binary, with dir/native.cuh, through NVRTC into dir/native.ptx;
// extended as the scene's module is. Without NVRTC (libnvrtc beside it), none: the scene keeps the interpreter.
inline int compileNative(const char* dir, bool extended) {
    prctl(PR_SET_PDEATHSIG, SIGKILL); // Ended with its renderer
    const std::string here = nativeDirectory();
    for (const auto& entry : std::filesystem::directory_iterator(here)) // Its builtins first, which it opens by name
        if (entry.path().filename().string().starts_with("libnvrtc-builtins.so"))
            dlopen(entry.path().c_str(), RTLD_NOW | RTLD_GLOBAL);
    void* nvrtc = dlopen((here + "/libnvrtc.so.13").c_str(), RTLD_NOW);
    if (!nvrtc) return 1;
    using Create = int (*)(void**, const char*, const char*, int, const char* const*, const char* const*);
    using Compile = int (*)(void*, int, const char* const*);
    using Size = int (*)(void*, size_t*);
    using Get = int (*)(void*, char*);
    const auto create = (Create)dlsym(nvrtc, "nvrtcCreateProgram");
    const auto compile = (Compile)dlsym(nvrtc, "nvrtcCompileProgram");
    const auto size = (Size)dlsym(nvrtc, "nvrtcGetPTXSize");
    const auto get = (Get)dlsym(nvrtc, "nvrtcGetPTX");
    const auto read = [](const std::string& path) {
        std::string text;
        if (FILE* file = std::fopen(path.c_str(), "rb")) {
            char buffer[1 << 16];
            for (size_t n; (n = std::fread(buffer, 1, sizeof(buffer), file));) text.append(buffer, n);
            std::fclose(file);
        }
        return text;
    };
    const std::string source = read(here + "/renderer.cu"), cases = read(std::string(dir) + "/native.cuh");
    const char* header = cases.c_str();
    const char* name = "native.cuh";
    void* program;
    if (source.empty() || create(&program, source.c_str(), "renderer.cu", 1, &header, &name)) return 1;
    const std::string include = "-I" + here; // The Makefile's PTXFLAGS, the scene's own steps native
    std::vector<const char*> options = {"-std=c++20", "-arch=compute_75", "--use_fast_math", "-rdc=true",
        include.c_str(), "-DNATIVE", "-DINFINITY=__int_as_float(0x7f800000)"};
    if (extended) options.push_back("-DEXTENDED");
    if (std::getenv("FLEX_NATIVE_EXACT")) options.push_back("--fmad=false"); // An identity check's, as its build
    if (compile(program, options.size(), options.data())) return 1;
    size_t bytes;
    size(program, &bytes);
    std::string ptx(bytes, 0);
    get(program, ptx.data());
    FILE* file = std::fopen((std::string(dir) + "/native.ptx").c_str(), "wb");
    if (!file) return 1;
    std::fwrite(ptx.data(), 1, bytes - 1, file);
    return std::fclose(file) != 0;
}
