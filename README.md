# Flex

Blender render engine that path traces the scene on RTX hardware with OptiX, in C++ and CUDA. It reuses paths across
pixels and samples with NVIDIA's ReSTIR PT Enhanced (Lin et al., 2026) and shades with FlexLight's BSDF, which makes it
about 4x faster than Cycles and lets it converge around 60x faster in equal time.

Requires an RTX GPU, CUDA, Blender, Python 3, Make, Git and xxd. The first build fetches the
[OptiX 9.1 headers](https://github.com/NVIDIA/optix-dev/tree/v9.1.0).

```sh
make install
```

This builds the extension and installs it into Blender without launching it; a running Blender loads the new build by
itself. GitHub Actions builds every push to main and every pull request; every push to main also publishes `flex.zip`
as a [release](https://github.com/arbobendik/flex-cuda-pt/releases).

Select Flex as the render engine, for final renders and the viewport's rendered shading. It renders geometry, lights and
the world through perspective cameras. Material node trees resolve to a smooth or normal mapped normal, albedo,
metallic, roughness, emission, transparency and IOR per hit, and their volumes to the absorption color and density that
media absorb by. Max samples, max bounces, paths per sample and resolution are set in the Flex panel of the render
properties; its ReSTIR subpanel toggles ReSTIR, its biased decorrelation and the number of spatial neighbors.
`make test` renders a small scene headlessly and checks the result.
