# Flex

Blender render engine that path traces the scene on RTX hardware with OptiX.

Requires an RTX GPU, CUDA, Blender, Python 3, Make, Git and xxd. The first build fetches the
[OptiX 9.1 headers](https://github.com/NVIDIA/optix-dev/tree/v9.1.0).

```sh
make
blender --command extension install-file -r user_default -e build/flex.zip
```

Select Flex as the render engine. It renders geometry, Principled BSDF base color, its image texture and emission,
lights, the world and the active camera. `make test` renders a small scene headlessly and checks the result.
