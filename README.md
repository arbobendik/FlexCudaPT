# Flex

Blender render engine that path traces the scene on RTX hardware with OptiX, or on any GPU with Vulkan ray queries, in
C++, CUDA and Slang. It reuses paths across pixels and samples with NVIDIA's ReSTIR PT Enhanced (Lin et al., 2026) and
shades with FlexLight's BSDF, which makes it about 4x faster than Cycles and lets it converge around 60x faster in equal
time.

Requires an RTX GPU or a GPU with Vulkan ray queries, CUDA, the Vulkan headers and loader, Blender, Python 3, Make, Git,
curl and xxd. The first build fetches the [OptiX 9.1 headers](https://github.com/NVIDIA/optix-dev/tree/v9.1.0) and
[Slang 2026.19](https://github.com/shader-slang/slang/releases/tag/v2026.19).

```sh
make install
```

This builds the extension and installs it into Blender without launching it; a running Blender loads the new build by
itself. GitHub Actions builds every push to main and every pull request; every push to main also publishes `flex.zip`
as a [release](https://github.com/arbobendik/FlexCudaPT/releases).

Select Flex as the render engine, for final renders and the viewport's rendered shading. It renders meshes, hair strands
of particle hair paths and curves objects, lights and the world through perspective and orthographic cameras. Material
node trees resolve to a smooth, normal mapped or bumped normal, albedo, metallic, roughness, emission, transparency and
IOR per hit, with coat, sheen (the Sheen BSDF's Ashikhmin distribution as Ashikhmin's velvet), anisotropy, translucency,
subsurface scattering and Principled Hair or the old Hair BSDF, and their volumes to media that absorb, scatter by their
Henyey-Greenstein anisotropy and emit, constant or varying by their node trees and, in a smoke simulation's domain, by
its density, color, flame, heat and temperature grids as Principled Volume's attributes, Volume Info and Attribute nodes
read them. The world's volume fills the scene, homogeneous and emitting nothing, and lights emit by their node trees.
Panoramic cameras, OpenVDB volumes, OSL scripts and true displacement are not supported; displacement shades as a bump.
Max samples, max bounces, paths per sample and, with OptiX, denoising are set in the Flex panel of the render
properties; its ReSTIR subpanel toggles ReSTIR, its biased decorrelation, the number of spatial neighbors and the reuse
of the last view's samples up to a camera jump.
Camera properties include Cycles' depth of field and aperture settings, used in final renders and rendered camera views.
The extension's preferences choose OptiX or Vulkan, which traces with ray queries on any GPU that has them and does not
denoise. `make test` installs the build into Blender resources of its own and renders scenes headlessly with OptiX and
with Vulkan and checks the results.
