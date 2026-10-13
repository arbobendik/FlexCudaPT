# Flex

Blender render engine that path traces the scene on RTX hardware with OptiX.

Requires an RTX GPU, CUDA, Blender, Python 3, Make, Git and xxd. The first build fetches the
[OptiX 9.1 headers](https://github.com/NVIDIA/optix-dev/tree/v9.1.0).

```sh
make install
```

This builds the extension and installs it into Blender without launching it; a running Blender loads the new build by
itself. GitHub Actions builds every push to main and every pull request; pushing a `v*` tag also publishes `flex.zip` as
a release.

Select Flex as the render engine, for final renders and the viewport's rendered shading. It renders geometry, lights and
the world through perspective cameras. Material node trees resolve to a normal, albedo, metallic, roughness, emission,
transparency and IOR per hit, of which the shading so far uses albedo and emission. Max samples and resolution are set
in the Flex panel of the render properties. `make test` renders a small scene headlessly and checks the result.
