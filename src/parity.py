# End-to-end parity test, run by make test: renders a scene of textures, among them one mirrored and interpolated at
# negative coordinates, node programs, an emitter, a point light, glossy metal, glass and a volume under a sky with Flex
# on OptiX and on Vulkan, with ReSTIR and without, and compares the images, which trace the same random numbers.
import bpy, bmesh, math, numpy

SIZE = 64

scene = bpy.data.scenes.new('parity')
scene.render.engine = 'FLEX'
scene.render.resolution_x = scene.render.resolution_y = SIZE
scene.render.image_settings.file_format = 'OPEN_EXR'
scene.render.filepath = bpy.app.tempdir + 'parity.exr'
scene.flex_samples = 256
scene.world = bpy.data.worlds.new('sky')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0.1, 0.2, 0.4, 1)

def add(data, location, rotation=(0, 0, 0)):
    ob = bpy.data.objects.new(data.name, data)
    ob.location, ob.rotation_euler = location, rotation
    scene.collection.objects.link(ob)
    return ob

def mesh(name, create, location, rotation=(0, 0, 0)):  # Of a bmesh operator's shape, with a Principled BSDF, returned
    data = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bm.loops.layers.uv.new()
    create(bm)
    bm.to_mesh(data)
    data.materials.append(bpy.data.materials.new(name))
    add(data, location, rotation)
    return data.materials[0].node_tree.nodes['Principled BSDF']

scene.camera = add(bpy.data.cameras.new('camera'), (0, -3, 2), (math.radians(60), 0, 0))
add(bpy.data.lights.new('light', 'POINT'), (1, -1, 3)).data.energy = 500
floor = mesh('floor', lambda bm: bmesh.ops.create_grid(bm, size=2, calc_uvs=True), (0, 0, 0))
image = floor.id_data.nodes.new('ShaderNodeTexImage')
image.image = bpy.data.images.new('checker', 4, 4)
image.image.pixels.foreach_set([c for i in range(16) for c in ((0.9, 0.9, 0.9, 1) if (i + i // 4) % 2 else
    (0.2, 0.3, 0.1, 1))])
image.interpolation = 'Closest'
floor.id_data.links.new(image.outputs['Color'], floor.inputs['Base Color'])
mirrored = floor.id_data.nodes.new('ShaderNodeTexImage')  # At negative UVs, between texels, of a width no power of two
mirrored.image = bpy.data.images.new('mirrored', 3, 3)
mirrored.image.pixels.foreach_set([c for i in range(9) for c in (*(0.1 + 0.1 * i,) * 3, 1)])
mirrored.interpolation, mirrored.extension = 'Linear', 'MIRROR'
negative = floor.id_data.nodes.new('ShaderNodeVectorMath')
negative.operation, negative.inputs['Scale'].default_value = 'SCALE', -3
floor.id_data.links.new(floor.id_data.nodes.new('ShaderNodeTexCoord').outputs['UV'], negative.inputs[0])
floor.id_data.links.new(negative.outputs[0], mirrored.inputs['Vector'])
floor.id_data.links.new(mirrored.outputs['Color'], floor.inputs['Roughness'])
metal = mesh('metal', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=32, v_segments=16, radius=0.5,
    calc_uvs=True), (-0.8, 0, 0.5))
metal.inputs['Metallic'].default_value, metal.inputs['Roughness'].default_value = 1, 0.1
noise = metal.id_data.nodes.new('ShaderNodeTexNoise')
metal.id_data.links.new(noise.outputs['Color'], metal.inputs['Base Color'])
glass = mesh('glass', lambda bm: bmesh.ops.create_cube(bm, size=0.8, calc_uvs=True), (0.8, 0, 0.4),
    (0, 0, math.radians(30)))
glass.inputs['Transmission Weight'].default_value, glass.inputs['Roughness'].default_value = 1, 0
glass.inputs['IOR'].default_value = 1.45
absorption = glass.id_data.nodes.new('ShaderNodeVolumeAbsorption')
absorption.inputs['Color'].default_value, absorption.inputs['Density'].default_value = (0.8, 0.4, 0.2, 1), 2
glass.id_data.links.new(absorption.outputs[0], glass.id_data.nodes['Material Output'].inputs['Volume'])
emitter = mesh('emitter', lambda bm: bmesh.ops.create_grid(bm, size=0.3, calc_uvs=True), (0, 1, 1),
    (math.radians(90), 0, 0))
emitter.inputs['Emission Strength'].default_value = 5
voronoi = emitter.id_data.nodes.new('ShaderNodeTexVoronoi')
emitter.id_data.links.new(voronoi.outputs['Color'], emitter.inputs['Emission Color'])

engine = bpy.types.RenderEngine.bl_rna_get_subclass_py('FLEX')
preferences = bpy.context.preferences.addons[engine.__module__].preferences
blocks = lambda pixels: pixels.reshape(8, 8, 8, 8, 3).mean((1, 3))  # Of 8 x 8 pixels

def render(device):
    preferences.device = device
    bpy.ops.render.render(scene=scene.name, write_still=True)
    return numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]

for restir in (False, True):
    scene.flex_restir = restir
    optix, vulkan = render('OPTIX'), render('VULKAN')
    assert numpy.isfinite(optix).all() and numpy.isfinite(vulkan).all(), f'finite {restir}'
    assert numpy.isclose(vulkan.mean(), optix.mean(), rtol=0.01), f'mean {restir}: {vulkan.mean()} vs {optix.mean()}'
    # Reuse spreads the backends' last bits of difference over the neighborhoods it resamples, so their blocks differ as
    # its noise does, which their means average out
    rtol, atol = (0.1, 0.02) if restir else (0.05, 0.01)
    assert numpy.allclose(blocks(vulkan), blocks(optix), rtol=rtol, atol=atol), \
        f'blocks {restir}: {numpy.abs(blocks(vulkan) - blocks(optix)).max()}'
