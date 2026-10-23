# End-to-end test, run by make test: renders a lit plane, half colored and half textured, and a textured emitter under a
# sky with Flex through a render border and checks the pixels, then draws the same view through the engine's viewport
# methods and compares.
import bpy, bmesh, gpu, io, math, numpy, os, sys, types
from mathutils import Matrix

SIZE = 64
COLOR = (0.8, 0.2, 0.1)
TEXELS = ((1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 1))  # 2x2 texture, bottom row first
SKY = (0.1, 0.2, 0.4)

def new(name):  # Scene rendered by Flex into an EXR of SIZE x SIZE pixels at 256 samples, under the sky
    scene = bpy.data.scenes.new(name)
    scene.render.engine = 'FLEX'
    scene.render.resolution_x = scene.render.resolution_y = SIZE
    scene.flex_samples = 256
    scene.render.image_settings.file_format = 'OPEN_EXR'
    scene.render.filepath = bpy.app.tempdir + name + '.exr'
    scene.world = bpy.data.worlds.new('sky')
    scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (*SKY, 1)
    return scene

scene = new('test')
scene.render.use_border = True
scene.render.border_max_y = 0.875  # Leaves the top eighth unrendered

def add(data, location, rotation=(0, 0, 0)):
    ob = bpy.data.objects.new(data.name, data)
    ob.location, ob.rotation_euler = location, rotation
    scene.collection.objects.link(ob)
    return ob

def shape(name, create, location, rotation=(0, 0, 0)):  # Of a bmesh operator's shape, with a Principled BSDF, returned
    data = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bm.loops.layers.uv.new()
    create(bm)
    bm.to_mesh(data)
    data.materials.append(bpy.data.materials.new(name))
    add(data, location, rotation)
    return data.materials[0].node_tree.nodes['Principled BSDF']

def plane(name, x, y=0, size=1):  # Square at height 0 with a Principled BSDF, returned
    bsdf = shape(name, lambda bm: bmesh.ops.create_grid(bm, size=size / 2, calc_uvs=True), (x, y, 0))
    data = bpy.data.meshes[name]
    data.shade_smooth()  # The colored plane's normals slightly off the face: light sampling leaves it at an offset
    data.normals_split_custom_set([(0, 0.01 if name == 'colored' else 0, 1)] * len(data.loops))
    bsdf.inputs['IOR'].default_value = 1  # Pure colors: no specular
    return bsdf

# The camera looks down on [-1, 1]^2: sky above and below the planes, colored plane left, textured plane right, light
# behind the camera, black plane emitting the texture at the bottom center.
scene.camera = add(bpy.data.cameras.new('camera'), (0, 0, 1))
scene.camera.data.angle = math.pi / 2
add(bpy.data.lights.new('light', 'POINT'), (0, 0, 2)).data.energy = 1e4  # Outshines the sky's tint
colored = plane('colored', -0.5)
textured = plane('textured', 0.5)
texture = textured.id_data.nodes.new('ShaderNodeTexImage')
texture.image = bpy.data.images.new('texture', 2, 2)
texture.image.pixels.foreach_set([c for texel in TEXELS for c in (*texel, 1)])
textured.id_data.links.new(texture.outputs['Color'], textured.inputs['Base Color'])
ramp = colored.id_data.nodes.new('ShaderNodeValToRGB')  # Colors the plane, as a ramp of one color over the texture
for element in ramp.color_ramp.elements: element.color = (*COLOR, 1)
source = colored.id_data.nodes.new('ShaderNodeTexImage')
source.image = texture.image
colored.id_data.links.new(source.outputs['Color'], ramp.inputs['Fac'])
colored.id_data.links.new(ramp.outputs['Color'], colored.inputs['Base Color'])
opaque = textured.id_data.nodes.new('ShaderNodeValue')  # Rendered: alpha linked from a constant
opaque.outputs[0].default_value = 1
textured.id_data.links.new(opaque.outputs[0], textured.inputs['Alpha'])
cutout = plane('cutout', 0, 0, 4)  # Passes rays straight through: textured alpha of 0
alpha = cutout.id_data.nodes.new('ShaderNodeTexImage')
alpha.image = bpy.data.images.new('clear', 1, 1, alpha=True)
alpha.image.pixels.foreach_set((0, 0, 0, 0))
cutout.id_data.links.new(alpha.outputs['Alpha'], cutout.inputs['Alpha'])
fog = plane('fog', 0, 0, 4).id_data  # Passes rays straight through: volume only, of no density
output = fog.nodes['Material Output']
fog.links.remove(output.inputs['Surface'].links[0])
volume = fog.nodes.new('ShaderNodeVolumePrincipled')
volume.inputs['Density'].default_value = 0
fog.links.new(volume.outputs['Volume'], output.inputs['Volume'])
for name in ('cutout', 'fog'): bpy.data.objects[name].location.z = 0.5  # Between the camera and the other planes
emitter = plane('emitter', 0, -0.75, 0.5)
emitter.inputs['Base Color'].default_value = (0, 0, 0, 1)
emitter.inputs['Emission Strength'].default_value = 1
emitter.id_data.links.new(emitter.id_data.nodes.new('ShaderNodeTexImage').outputs['Color'],
    emitter.inputs['Emission Color'])
emitter.id_data.nodes['Image Texture'].image = texture.image
# Rendered through the outputs for Cycles, as versioning leaves materials saved without nodes: the one for EEVEE is not
emitter.id_data.nodes['Material Output'].target = 'CYCLES'
eevee = emitter.id_data.nodes.new('ShaderNodeOutputMaterial')
eevee.target = 'EEVEE'
emitter.id_data.links.new(emitter.id_data.nodes.new('ShaderNodeBsdfPrincipled').outputs[0], eevee.inputs['Surface'])
scene.world.node_tree.nodes['World Output'].target = 'CYCLES'
leaf = plane('leaf', 0.5, -0.75, 0.25)  # Rendered: textured alpha in the deactivated tree, emitting through Cycles'
leaf.id_data.links.new(leaf.id_data.nodes.new('ShaderNodeTexImage').outputs['Alpha'], leaf.inputs['Alpha'])
leaf.id_data.nodes['Image Texture'].image = texture.image
leaf.id_data.nodes['Material Output'].is_active_output = False
cycles = leaf.id_data.nodes.new('ShaderNodeOutputMaterial')
cycles.target = 'CYCLES'
leaf.id_data.links.new(leaf.id_data.nodes.new('ShaderNodeEmission').outputs[0], cycles.inputs['Surface'])
void = plane('void', 0.8, -0.875, 0.2).id_data  # Black: an output without a shader
void.links.remove(void.nodes['Material Output'].inputs['Surface'].links[0])
bare = plane('bare', 0.8, -0.625, 0.2).id_data  # Black: no output
bare.nodes.remove(bare.nodes['Material Output'])
for node in (node for material in bpy.data.materials for node in material.node_tree.nodes if node.type == 'TEX_IMAGE'):
    node.interpolation = 'Closest'  # Whole texels

def render():  # The scene rendered, its pixels' colors
    bpy.ops.render.render(scene=scene.name, write_still=True)
    return numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]

STATS = []
def stats(*args): STATS.append(args[0])
bpy.app.handlers.render_stats.append(stats)
pixels = render()
bpy.app.handlers.render_stats.remove(stats)
progress = [message for message in STATS if ' | Sample ' in message]
counts = [int(message.split('Sample ')[1].split('/')[0]) for message in progress]
assert counts[0] == 1 and counts[-1] == scene.flex_samples and all(
    0 < batch <= 64 for batch in numpy.diff([0, *counts])), 'sample progress'
assert len(counts) <= 10, 'batched progress'
assert all('Remaining:' in message and 'samples/s' in message for message in progress), 'performance stats'
# With persistent data the engine keeps its scene between renders, which still take Flex's settings as since changed
# alone: raising the samples renders what a render without persistent data does
shot = lambda: bpy.ops.render.render(scene=scene.name, write_still=True) and bpy.data.images.load(scene.render.filepath)
scene.render.use_persistent_data, samples, scene.flex_samples = True, scene.flex_samples, 1
render()
scene.flex_samples = 2
persisted = numpy.array(shot().pixels)
scene.render.use_persistent_data = False
assert numpy.array_equal(persisted, numpy.array(shot().pixels)), 'persistent settings'
scene.flex_samples = samples

def chroma(x, y, size, color):  # Whether the block of pixels has the color's hue
    mean = pixels[y + 2:y + size - 2, x + 2:x + size - 2].mean((0, 1))
    return numpy.allclose(mean / mean.sum(), numpy.array(color) / sum(color), atol=0.02)

assert numpy.allclose(pixels[:14, :20], SKY, atol=0.01) and numpy.allclose(pixels[50:56], SKY, atol=0.01), 'sky'
assert not pixels[56:].any(), 'border'
assert chroma(0, 16, 32, COLOR), 'color'
for texel, (x, y) in zip(TEXELS, ((32, 16), (48, 16), (32, 32), (48, 32))):
    assert chroma(x, y, 16, texel), f'texture {texel}'
assert not numpy.allclose(pixels[18:46, 34:62], SKY, atol=0.01), 'opaque'  # The textured plane hides the sky
for texel, (x, y) in zip(TEXELS, ((24, 0), (32, 0), (24, 8), (32, 8))):
    assert chroma(x, y, 8, texel), f'emission {texel}'
assert chroma(44, 4, 8, (1, 1, 1)), 'leaf'
for y in (2, 10): assert not pixels[y:y + 4, 56:60].any(), 'black'  # Reflecting nothing, as in Cycles
lit = pixels[18:46, 2:30].sum(2)  # Light sampling leaves no pixel of the colored plane dark or far off its neighbors
assert lit.min() > 0.5 * lit.mean() and lit.max() < 2 * lit.mean(), 'lighting'

class Viewport:  # Stands in for the engine instance Blender creates for a viewport, which background mode has none of
    engine = bpy.types.RenderEngine.bl_rna_get_subclass_py('FLEX')
    start = engine.start
    trace = engine.trace
    view_update = engine.view_update
    view_draw = engine.view_draw
    visible = ()
    shared = open(os.memfd_create('flex'), 'rb', 0)
    __init__ = engine.spawn
    def tag_redraw(self): self.redraw = True
    def bind_display_space_shader(self, scene): pass
    def unbind_display_space_shader(self): pass

# EEVEE's specular shader resolves to a surface of its base color with a dielectric's specular reflection, not black
specular = bpy.data.materials.new('specular').node_tree
specular.links.new(specular.nodes.new('ShaderNodeEeveeSpecular').outputs[0],
    specular.nodes['Material Output'].inputs['Surface'])
module = Viewport.engine.start.__globals__
surface = module['fold'](module['resolve'](specular.nodes['Material Output'].inputs['Surface']))
assert numpy.any(surface[1]) and numpy.all(surface[6] == 1.5), 'eevee specular'

gpu.init()
bpy.context.window.scene = scene
depsgraph = bpy.context.evaluated_depsgraph_get()
viewport = Viewport()
offscreen = gpu.types.GPUOffScreen(SIZE, SIZE, format='RGBA32F')
region = types.SimpleNamespace(width=SIZE, height=SIZE)
region_data = types.SimpleNamespace(view_matrix=scene.camera.matrix_world.inverted(),
    window_matrix=scene.camera.calc_matrix_camera(depsgraph, x=SIZE, y=SIZE), view_perspective='CAMERA')
context = types.SimpleNamespace(region=region, region_data=region_data,
    space_data=types.SimpleNamespace(camera=scene.camera))
with offscreen.bind():
    gpu.matrix.load_matrix(Matrix.Identity(4))
    # Pixel space, as in a viewport
    gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE, 2 / SIZE, 1, 1)))
    viewport.view_update(context, depsgraph)
    viewport.view_draw(context, depsgraph)
    assert 0 < viewport.memory[0] <= viewport.memory[1], 'memory stats'
    while viewport.__dict__.pop('redraw', False): viewport.view_draw(context, depsgraph)  # Until the sample limit
    drawn = numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0, 'FLOAT').to_list())
assert numpy.allclose(drawn[:56, :, :3], pixels[:56], rtol=0.05, atol=0.01), 'viewport'
# Light sampling passes through the cutout and emission it reaches is not added again: the cutout changes no light
bpy.data.objects['cutout'].hide_render = True
uncut = render()
assert numpy.allclose(uncut[18:46, 2:30].mean((0, 1)), pixels[18:46, 2:30].mean((0, 1)), rtol=0.1), 'straight through'
# A black dielectric reflects white whatever its specular tint and level, as FlexLight's BSDF, which the exporter still
# folds
colored.id_data.links.remove(colored.inputs['Base Color'].links[0])
colored.inputs['Base Color'].default_value = (0, 0, 0, 1)
colored.inputs['IOR'].default_value = 1.5
colored.inputs['Specular IOR Level'].default_value = 1
colored.inputs['Specular Tint'].default_value = (0, 1, 0, 1)
flex = sys.modules[Viewport.engine.__module__]
surface = flex.fold(flex.resolve(colored.outputs[0].links[0].to_socket))
assert numpy.allclose(numpy.array(surface[6:9]), ((1.5,) * 3, (0, 1, 0), (2,) * 3)), 'specular level'
pixels = render()
red, green, blue = pixels[18:46, 2:30].mean((0, 1))
assert max(red, green, blue) < 1.02 * min(red, green, blue), 'specular tint'
# A black cutout covering half lets half the light through to the textured plane and half its light back
alpha.image.pixels.foreach_set((0, 0, 0, 0.5))
cutout.inputs['Base Color'].default_value = (0, 0, 0, 1)
bpy.data.objects['cutout'].hide_render = False
pixels = render()
assert 0.2 < pixels[18:46, 34:62].mean() / uncut[18:46, 34:62].mean() < 0.32, 'coverage'
for ob in scene.objects: ob.hide_render = ob != scene.camera  # Nothing left to render but the sky
empty = render()[:56]
assert numpy.allclose(empty, SKY, atol=0.01), 'empty'
# A white dielectric under a white sky diffuses what its Fresnel leaves beside its specular, never more than it
# receives: each pixel holds its single-scatter directional albedo at its view cosine, a mean of 0.9903 derived
# numerically
bpy.data.objects['colored'].hide_render = False
colored.inputs['Base Color'].default_value = colored.inputs['Specular Tint'].default_value = (1, 1, 1, 1)
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
pixels = render()
assert abs(pixels[18:46, 2:30].mean() - 0.9903) < 0.005, 'furnace'
colored.inputs['Specular Tint'].default_value = (1, 0.08, 0.375, 1)  # Changes nothing, FlexLight's BSDF has no tint
pixels = render()
assert abs(pixels[18:46, 2:30].mean() - 0.9903) < 0.005, 'tinted furnace'
# Huge, black and turned 60 degrees under the white sky, the colored plane reflects FlexLight's specular albedo at that
# angle
colored.inputs['Base Color'].default_value = (0, 0, 0, 1)
colored.inputs['Specular Tint'].default_value, colored.inputs['Roughness'].default_value = (1, 1, 1, 1), 0.434
bpy.data.objects['colored'].location, bpy.data.objects['colored'].rotation_euler = (0, 0, 0), (math.radians(60), 0, 0)
bpy.data.objects['colored'].scale, scene.camera.data.angle = (100, 100, 1), math.radians(10)
pixels = render()[:56]
assert abs(pixels.mean() - 0.0735) < 0.004, 'grazing specular'
# Metallic blends a metal and a dielectric linearly: under a black ceiling, the white sky a white plane of IOR 1 passes
# halfway between them is the mean of what each passes
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.camera.data.angle, scene.flex_samples = 0.1, 16
probe = plane('probe', 0, 0, 4)
plane('ceiling', 0, 0, 100).inputs['Base Color'].default_value = (0, 0, 0, 1)
bpy.data.objects['ceiling'].location.z = 2
probe.inputs['Base Color'].default_value, probe.inputs['Roughness'].default_value = (1, 1, 1, 1), 0
def passed(metallic, transmission):  # Mean light the plane passes, its metallic and transmission weight given
    probe.inputs['Metallic'].default_value, probe.inputs['Transmission Weight'].default_value = metallic, transmission
    bpy.ops.render.render(scene=scene.name, write_still=True)
    return numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[24:40, 24:40, :3].mean()
metal, dielectric = passed(1, 0), passed(0, 0.5)
assert abs(passed(0.5, 0.5) - (metal + dielectric) / 2) < 0.02, 'metallic share blends linearly'
# Light sampling finds a dim emitter by the points it lights, a bright light behind them outshining it: at a sample
# every pixel is lit, where picking emitters by their power alone lights next to none
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
scene.camera.data.angle, scene.flex_samples = math.pi / 2, 1
floor = plane('floor', 0, 0, 4)
dim = plane('dim', 0, 0, 1)
dim.inputs['Base Color'].default_value, dim.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
dim.inputs['Emission Strength'].default_value = 1
bpy.data.objects['dim'].location.z, bpy.data.objects['dim'].visible_camera = 0.5, False
add(bpy.data.lights.new('bright', 'POINT'), (0, 0, -1)).data.energy = 1e6
pixels = render()[:56]
assert pixels.sum(2).min() > 0, 'many lights'
# Only the center tile emits: its nonlinear shader has zero emission at the texture's mean, like the dark tile.
mesh = bpy.data.objects['dim'].data
bm = bmesh.new()
bm.from_mesh(mesh)
uv = bm.loops.layers.uv.active
for face in bm.faces:
    for loop in face.loops: loop[uv].uv = (0.75, 0.75)  # The white texel
bmesh.ops.create_grid(bm, size=0.5, matrix=Matrix.Translation((1, 0, 0)))
bm.to_mesh(mesh)
bm.free()
mask = dim.id_data.nodes.new('ShaderNodeMath')
mask.operation, mask.use_clamp = 'SUBTRACT', True
mask.inputs[1].default_value = 0.75
dim.id_data.links.new(dim.id_data.nodes.new('ShaderNodeTexImage').outputs['Color'], mask.inputs[0])
dim.id_data.nodes['Image Texture'].image = texture.image
dim.id_data.links.new(mask.outputs[0], dim.inputs['Emission Color'])
scene.flex_restir = False
pixels = render()[:56]
assert pixels.sum(2).min() > 0, 'textured light sampling'
def mis_render(bounces, reuse):
    scene.flex_bounces, scene.flex_restir = bounces, reuse
    return render()[:56]

# MIS preserves the rough BSDF's energy and adds the smooth dielectric's delta reflection, with and without reuse.
bpy.data.objects['bright'].hide_render = True
dim.id_data.links.remove(dim.inputs['Emission Color'].links[0])
floor.inputs['IOR'].default_value = 1.5
scene.flex_samples = 4096
bounces = scene.flex_bounces
for roughness in (0, 1):
    floor.inputs['Roughness'].default_value = roughness
    direct = mis_render(0, False)
    for reuse in (False, True):
        pixels = mis_render(1, reuse)
        if roughness:
            assert numpy.isclose(pixels.mean(), direct.mean(), rtol=0.01), 'MIS energy'
        else:
            assert 0.03 < (pixels - direct)[28:36, 28:36].mean() < 0.05, 'MIS delta reflection'
# Even with strongly tilted shading normals MIS keeps the BSDF's energy: in a box emitting white the white floor reads
# white, with the light that directions sent to a face's wrong side carry on to, which light sampling cannot reach: it
# finds the lobe's share on the face's side alone, (1 + cos) / 2 of the tilt
scene.camera.data.angle = 0.3
floor.inputs['IOR'].default_value = 1
mesh = bpy.data.objects['floor'].data
mesh.shade_smooth()
mesh.normals_split_custom_set([(0.95, 0, 0.3122499)] * len(mesh.loops))
color = floor.inputs['Base Color'].default_value[:]
floor.inputs['Base Color'].default_value, bpy.data.objects['dim'].hide_render = (1, 1, 1, 1), True
box = shape('box', lambda bm: [bmesh.ops.create_cube(bm, size=4), bmesh.ops.reverse_faces(bm, faces=bm.faces[:])],
    (0, 0, 0))  # Facing in
box.inputs['Base Color'].default_value, box.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
box.inputs['Emission Strength'].default_value, box.inputs['IOR'].default_value = 1, 1  # No specular: it reads 1 alone
for reuse in (False, True):
    assert numpy.isclose(mis_render(1, reuse).mean(), 1, rtol=0.01), 'MIS shading normals'
assert numpy.isclose(mis_render(0, False).mean(), (1 + 0.3122499) / 2, rtol=0.01), 'light sampling shading normals'
floor.inputs['Base Color'].default_value, bpy.data.objects['dim'].hide_render = color, False
bpy.data.objects['box'].hide_render = True
mesh.normals_split_custom_set([(0, 0, 1)] * len(mesh.loops))
scene.camera.data.angle, floor.inputs['IOR'].default_value = math.pi / 2, 1.5
# Every continuous lobe samples lights, including sharp glossy reflection and rough transmission below the face.
scene.camera.data.angle = 0.3
for metallic, transparency, roughness, height in ((1, 0, 0.1, 0.5), (0, 1, 0.6, -0.5)):
    floor.inputs['Metallic'].default_value, floor.inputs['Transmission Weight'].default_value = metallic, transparency
    floor.inputs['Roughness'].default_value, bpy.data.objects['dim'].location.z = roughness, height
    direct = mis_render(0, False)
    assert direct.mean() > 0, 'continuous light sampling'
    for reuse in (False, True):
        pixels = mis_render(1, reuse)
        assert numpy.isclose(pixels.mean(), direct.mean(), rtol=0.02), \
            f'MIS continuous lobes {metallic, transparency, reuse}: {pixels.mean()} vs {direct.mean()}'
floor.inputs['Metallic'].default_value = floor.inputs['Transmission Weight'].default_value = 0
floor.inputs['Roughness'].default_value, bpy.data.objects['dim'].location.z = 1, 0.5
scene.camera.data.angle = math.pi / 2
# Rough IOR-1 transmission has the same masking in shadow visibility and BSDF paths, including partial coverage.
bpy.data.objects['cutout'].hide_render, bpy.data.objects['cutout'].location.z = False, 0.25
cutout.inputs['Base Color'].default_value = (1, 1, 1, 1)
cutout.inputs['Transmission Weight'].default_value, cutout.inputs['Roughness'].default_value = 1, 1
mesh = bpy.data.objects['cutout'].data
mesh.shade_smooth()
mesh.normals_split_custom_set([(0.6, 0, 0.8)] * len(mesh.loops))
direct = mis_render(1, False)
for reuse in (False, True):
    pixels = mis_render(3, reuse)
    assert numpy.isclose(pixels.mean(), direct.mean(), rtol=0.01), 'MIS straight transmission'
# Light sampling passes a half metallic white cutout as a dielectric one of half its color, as the BSDF transmits both
bpy.data.objects['cutout'].visible_camera, cutout.inputs['Metallic'].default_value = False, 0.5
metal = mis_render(0, False)
cutout.inputs['Base Color'].default_value, cutout.inputs['Metallic'].default_value = (0.5, 0.5, 0.5, 1), 0
assert numpy.isclose(mis_render(0, False).mean(), metal.mean(), rtol=0.01), 'metallic straight transmission'
scene.flex_bounces = bounces
scene.flex_restir = True
# Through a slab of white glass of IOR 1 and depth 0.5 under the white sky, a Volume Absorption of the color and density 1
# passes its transmittance over unit distance, exp(color - 1), to the power of depth, as FlexLight's Beer's law
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
scene.camera.data.angle, scene.flex_samples = 0.1, 16
glass = shape('slab', lambda bm: bmesh.ops.create_cube(bm, size=1), (0, 0, 0))
bpy.data.objects['slab'].scale = (4, 4, 0.5)
glass.inputs['Transmission Weight'].default_value, glass.inputs['Roughness'].default_value = 1, 0
glass.inputs['Base Color'].default_value, glass.inputs['IOR'].default_value = (1, 1, 1, 1), 1
absorption = glass.id_data.nodes.new('ShaderNodeVolumeAbsorption')
absorption.inputs['Color'].default_value = (*COLOR, 1)
glass.id_data.links.new(absorption.outputs[0], glass.id_data.nodes['Material Output'].inputs['Volume'])
pixels = render()[24:40, 24:40]
assert numpy.allclose(pixels.mean((0, 1)), numpy.exp(numpy.array(COLOR) - 1) ** 0.5, rtol=0.02), 'absorption'
# From inside the slab, 0.25 above its bottom face, the camera sees the sky through that depth of it, and an emitter in
# the slab 0.15 below it through that depth
scene.camera.location.z = 0
pixels = render()[24:40, 24:40]
assert numpy.allclose(pixels.mean((0, 1)), numpy.exp(numpy.array(COLOR) - 1) ** 0.25, rtol=0.02), 'camera in a volume'
mesh = bpy.data.objects['slab'].data  # Its first face of a material filling no volume, the slab's others still filling it
plain = mesh.materials[0].copy()
plain.node_tree.links.remove(plain.node_tree.nodes['Material Output'].inputs['Volume'].links[0])
mesh.materials.append(plain)
mesh.polygons[0].material_index = 1
pixels = render()[24:40, 24:40]
assert numpy.allclose(pixels.mean((0, 1)), numpy.exp(numpy.array(COLOR) - 1) ** 0.25, rtol=0.02), \
    'camera in a volume of a later slot'
mesh.polygons[0].material_index = 0
inner = plane('inner', 0, 0, 1)
inner.inputs['Base Color'].default_value, inner.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
inner.inputs['Emission Strength'].default_value = 1
bpy.data.objects['inner'].location.z = -0.15
pixels = render()[24:40, 24:40]
assert numpy.allclose(pixels.mean((0, 1)), numpy.exp(numpy.array(COLOR) - 1) ** 0.15, rtol=0.02), \
    'camera in a volume around an emitter'
bpy.data.objects['inner'].hide_render = True
# Scattering instead, the slab passes the white sky's light on whole, a furnace
scatter = glass.id_data.nodes.new('ShaderNodeVolumeScatter')
glass.id_data.links.new(scatter.outputs[0], glass.id_data.nodes['Material Output'].inputs['Volume'])
pixels = render()[24:40, 24:40]
assert abs(pixels.mean() - 1) < 0.02, 'camera in a scattering volume'
scene.camera.location.z = 1
# Colored instead, the slab tints the light by its base color at each of its two sides, by the color squared
glass.id_data.links.remove(glass.id_data.nodes['Material Output'].inputs['Volume'].links[0])
glass.inputs['Base Color'].default_value = (*COLOR, 1)
pixels = render()[24:40, 24:40]
assert numpy.allclose(pixels.mean((0, 1)), numpy.array(COLOR) ** 2, rtol=0.02), 'glass'
# A long glass prism needs repeated total internal reflections to reach the white sky instead of turning black.
bpy.data.objects['slab'].location, bpy.data.objects['slab'].scale = (0, 0, -10), (1, 1, 20)
glass.inputs['Base Color'].default_value, glass.inputs['IOR'].default_value = (1, 1, 1, 1), 1.45
matrix = scene.camera.matrix_world.copy()
scene.camera.location, scene.camera.rotation_euler = (1, 0, 1), (0, math.pi / 4, 0)
pixels = render()[24:40, 24:40]
assert pixels.mean() > 0.9, 'glass internal reflections at default bounces'
# Faceted by noise under smooth normals and short enough for the bounces, it stays clear: directions sampled to the wrong
# side of a face carry on, losing and gaining no light
prism, flat = bpy.data.objects['slab'], bpy.data.objects['slab'].data
prism.data, prism.location, prism.scale = flat.copy(), (0, 0, -2), (1, 1, 4)
bm = bmesh.new()
bm.from_mesh(prism.data)
bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=6, use_grid_fill=True)
noise = numpy.random.default_rng(1)
for vertex in bm.verts: vertex.co = (*(numpy.array(vertex.co) + noise.normal(0, 0.02, 3)),)
bm.to_mesh(prism.data)
prism.data.shade_smooth()
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[24:40, 24:40, :3]
assert (pixels.mean(2) > 0.05).all() and 0.85 < pixels.mean() < 1.01, 'faceted glass internal reflections'
# So does a white metal normal-mapped by noise under the white sky
prism.data, prism.hide_render = flat, True
metal = plane('metal', 0, 0, 2)
metal.inputs['Metallic'].default_value, metal.inputs['Roughness'].default_value = 1, 0.2
relief, mapped = metal.id_data.nodes.new('ShaderNodeTexNoise'), metal.id_data.nodes.new('ShaderNodeNormalMap')
relief.inputs['Scale'].default_value = 8
metal.id_data.links.new(relief.outputs['Color'], mapped.inputs['Color'])
metal.id_data.links.new(mapped.outputs[0], metal.inputs['Normal'])
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[24:40, 24:40, :3]
assert (pixels.mean(2) > 0.05).all() and 0.6 < pixels.mean() < 1.01, 'normal-mapped metal'
bpy.data.objects['metal'].hide_render, prism.hide_render = True, False
scene.camera.matrix_world = matrix
# Both MIS strategies absorb the same light through straight glass, even when hidden from the primary ray.
for ob in scene.objects: ob.hide_render = ob not in (scene.camera, bpy.data.objects['floor'], bpy.data.objects['dim'])
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
scene.camera.data.angle, scene.flex_samples = 0.3, 4096
floor.inputs['IOR'].default_value = 1
clear = mis_render(0, False)
slab = bpy.data.objects['slab']
slab.location.z, slab.scale, slab.hide_render, slab.visible_camera = 0.25, (4, 4, 0.1), False, False
glass.inputs['Base Color'].default_value, glass.inputs['IOR'].default_value = (1, 1, 1, 1), 1
absorption.inputs['Density'].default_value = 8
glass.id_data.links.new(absorption.outputs[0], glass.id_data.nodes['Material Output'].inputs['Volume'])
direct = mis_render(0, False)
ratio = direct.mean((0, 1)) / clear.mean((0, 1))
assert 0 < ratio[2] < ratio[1] < ratio[0] < 0.9, f'shadow absorption: {ratio}'
for reuse in (False, True):
    pixels = mis_render(3, reuse)
    assert numpy.allclose(pixels.mean((0, 1)), direct.mean((0, 1)), rtol=0.01), 'MIS shadow absorption'
scene.flex_bounces = bounces

# Camera controls remain visible with Flex selected; a small emitter on black measures its lens's bokeh.
context = types.SimpleNamespace(engine='FLEX', camera=scene.camera.data)
for name in ('DATA_PT_lens', 'DATA_PT_camera', 'DATA_PT_camera_dof', 'DATA_PT_camera_dof_aperture'):
    assert getattr(bpy.types, name).poll(context), name
panel, subpanel = bpy.types.RENDER_PT_flex, bpy.types.RENDER_PT_flex_restir  # Shown on the render tab
assert getattr(panel, 'bl_context', None) == 'render' and panel.poll(context), 'Flex panel'
assert subpanel.bl_parent_id == 'RENDER_PT_flex' and getattr(subpanel, 'bl_context', None) == 'render', 'ReSTIR panel'
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.render.use_border = False
scene.camera.data.angle, scene.flex_samples = math.pi / 2, 512
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
bokeh = plane('bokeh', 0, size=0.125)
bokeh.inputs['Base Color'].default_value, bokeh.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
bokeh.inputs['Emission Strength'].default_value = 1
dof = scene.camera.data.dof
dof.aperture_fstop = fstop = scene.camera.data.lens * 1e-3  # Radius 0.5, measurable at 64 pixels

def camera_render(**values):  # Image, bokeh variance and skew on each image axis
    for name, value in values.items(): setattr(dof, name, value)
    pixels = render()
    weights = pixels.mean(2) / pixels.mean(2).sum()
    coordinates = numpy.indices(weights.shape)[::-1]
    centered = coordinates - (coordinates * weights).sum((1, 2))[:, None, None]
    variance = (centered ** 2 * weights).sum((1, 2))
    return pixels, variance, (centered ** 3 * weights).sum((1, 2)) / variance ** 1.5

sharp, variance, _ = camera_render(use_dof=False)
assert numpy.allclose(camera_render(use_dof=True, focus_distance=1)[0], sharp, atol=0.01), 'focus plane'
_, spread, _ = camera_render(focus_distance=2)
assert numpy.all(spread > 4 * variance), 'depth of field'
_, stopped, _ = camera_render(aperture_fstop=2 * fstop)
assert numpy.all((stopped / spread > 0.2) & (stopped / spread < 0.45)), 'f-stop'
_, squeezed, _ = camera_render(aperture_fstop=fstop, aperture_ratio=2)
assert squeezed[0] < spread[0] / 2 and abs(squeezed[1] / spread[1] - 1) < 0.1, 'aperture ratio'
_, _, triangle = camera_render(aperture_ratio=1, aperture_blades=3)
_, _, rotated = camera_render(aperture_rotation=math.pi / 2)
assert abs(triangle[0]) > 0.3 and abs(triangle[1]) < 0.15, 'aperture blades'
assert abs(rotated[1]) > 0.3 and abs(rotated[0]) < 0.15, 'aperture rotation'
assert numpy.allclose(camera_render(focus_object=bpy.data.objects['textured'])[0], sharp, atol=0.01), 'focus object'
# Node regressions compared to Cycles through emission, independently of the engines' different BSDFs
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.camera.data.angle, scene.flex_samples, dof.use_dof = 0.1, 16, False
tree = plane('nodes', 0, 0, 100).id_data
emission = tree.nodes.new('ShaderNodeEmission')
tree.links.new(emission.outputs[0], tree.nodes['Material Output'].inputs['Surface'])
scene.cycles.samples, scene.cycles.use_denoising = 16, False
scene.cycles.pixel_filter_type, scene.cycles.filter_width = 'BOX', 1

def node_matches(socket):
    tree.links.new(socket, emission.inputs['Color'])
    colors = []
    for engine in ('FLEX', 'CYCLES'):
        scene.render.engine = engine
        colors.append(render()[24:40, 24:40].mean((0, 1)))
    assert numpy.allclose(*colors, atol=1e-4), (socket.node.name, colors)

noise = tree.nodes.new('ShaderNodeTexNoise')
point = tree.nodes.new('ShaderNodeCombineXYZ')
tree.links.new(point.outputs[0], noise.inputs['Vector'])
noise.inputs['Scale'].default_value, noise.inputs['Detail'].default_value = 1, 3.25
for socket, value in zip(point.inputs, (0.31, -0.27, 0.63)): socket.default_value = value
for dimensions in ('1D', '2D', '4D'):
    noise.noise_dimensions = dimensions
    if dimensions in ('1D', '4D'): noise.inputs['W'].default_value = 0.37
    node_matches(noise.outputs['Fac'])
noise.noise_dimensions = '3D'
for position in ((0.31, -0.27, 0.63), (1e-6, -1.000001, 2.999999)):
    for socket, value in zip(point.inputs, position): socket.default_value = value
    for kind in ('FBM', 'MULTIFRACTAL', 'HETERO_TERRAIN', 'HYBRID_MULTIFRACTAL', 'RIDGED_MULTIFRACTAL'):
        noise.noise_type = kind
        node_matches(noise.outputs['Fac'])
noise.noise_type, noise.normalize, noise.inputs['Detail'].default_value = 'FBM', False, 14
node_matches(noise.outputs['Fac'])
node_matches(noise.outputs['Color'])
wavelength = tree.nodes.new('ShaderNodeWavelength')
for value in (375, 377.5, 380, 447.3, 555, 779.9, 780):
    wavelength.inputs[0].default_value = value
    node_matches(wavelength.outputs[0])
voronoi = tree.nodes.new('ShaderNodeTexVoronoi')
voronoi.inputs['Vector'].default_value = (0.31, -0.27, 0.63)
voronoi.distance, voronoi.normalize = 'MINKOWSKI', True
for dimensions in ('1D', '2D', '3D', '4D'):
    voronoi.voronoi_dimensions = dimensions
    if dimensions in ('1D', '4D'): voronoi.inputs['W'].default_value = 0.37
    for feature in ('F1', 'F2', 'SMOOTH_F1', 'DISTANCE_TO_EDGE', 'N_SPHERE_RADIUS'):
        voronoi.feature = feature
        for socket in voronoi.outputs:
            if socket.enabled: node_matches(socket)
height = tree.nodes.new('ShaderNodeSeparateXYZ')
tree.links.new(tree.nodes.new('ShaderNodeNewGeometry').outputs['Position'], height.inputs[0])
bump = tree.nodes.new('ShaderNodeBump')
bump.inputs['Distance'].default_value = 0.2
positive = tree.nodes.new('ShaderNodeVectorMath')
positive.operation, positive.inputs[1].default_value = 'ADD', (1, 1, 1)
tree.links.new(bump.outputs['Normal'], positive.inputs[0])
for axis in ('X', 'Y'):
    tree.links.new(height.outputs[axis], bump.inputs['Height'])
    for inverted in (False, True):
        bump.invert = inverted
        node_matches(positive.outputs[0])
bump.inputs['Strength'].default_value = 0
node_matches(positive.outputs[0])
zero = tree.nodes.new('ShaderNodeVectorMath')
zero.operation, zero.inputs['Scale'].default_value = 'SCALE', 0
tree.links.new(tree.nodes.new('ShaderNodeTexCoord').outputs['Generated'], zero.inputs[0])
mapped = tree.nodes.new('ShaderNodeMapRange')
mapped.clamp = False
for socket, value in zip(mapped.inputs, (0.2, 0, 0, 2, 4)): socket.default_value = value
node_matches(mapped.outputs[0])
tree.links.new(zero.outputs[0], mapped.inputs['Value'])
node_matches(mapped.outputs[0])
curve = tree.nodes.new('ShaderNodeFloatCurve')
curve.inputs['Factor'].default_value, curve.inputs['Value'].default_value = 0.7, -1.3
curve.mapping.initialize()
curve.mapping.curves[0].points.new(0.3, 0.8)
curve.mapping.update()
node_matches(curve.outputs[0])
rotated = tree.nodes.new('ShaderNodeVectorRotate')
rotated.inputs['Vector'].default_value, rotated.inputs['Angle'].default_value = (0.2, 0.7, 0.4), 0.7
tree.links.new(zero.outputs[0], rotated.inputs['Axis'])
node_matches(rotated.outputs[0])
image = tree.nodes.new('ShaderNodeTexImage')
image.image = bpy.data.images.new('alpha regression', 1, 1, alpha=True, float_buffer=True)
image.image.pixels.foreach_set((0.8, 0.2, 0.1, 0.25))
image.image.alpha_mode, image.extension = 'NONE', 'CLIP'
point = tree.nodes.new('ShaderNodeCombineXYZ')
point.inputs[0].default_value, point.inputs[1].default_value = -0.1, 0.7
tree.links.new(point.outputs[0], image.inputs[0])
node_matches(image.outputs['Alpha'])
image.image.alpha_mode = 'STRAIGHT'
tree.links.new(image.outputs['Alpha'], tree.nodes.new('ShaderNodeMath').inputs[0])  # An unused alpha link
node_matches(image.outputs['Color'])
tree.links.remove(image.outputs['Alpha'].links[0])
point.inputs[0].default_value = 0.5
other = tree.nodes.new('ShaderNodeTexImage')
other.image, other.extension = image.image, image.extension
tree.links.new(point.outputs[0], other.inputs[0])
tree.links.new(other.outputs['Alpha'], emission.inputs['Strength'])
node_matches(image.outputs['Color'])
other.interpolation = 'Closest'
node_matches(image.outputs['Color'])
tree.links.remove(emission.inputs['Strength'].links[0])
normal = tree.nodes.new('ShaderNodeNormalMap')
normal.inputs['Color'].default_value = (0.8, 0.7, 1, 1)
ob = bpy.data.objects['nodes']
ob.rotation_euler, ob.scale = (0.2, 0.3, -0.4), (1.7, 0.6, 1.2)
node_matches(normal.outputs[0])
ob.data.normals_split_custom_set(((0.2, 0.1, 1), (0.8, 0.1, 0.5), (0.1, 0.9, 0.5), (0.1, 0.3, 1)))
node_matches(normal.outputs[0])
normal.inputs['Strength'].default_value = 0
node_matches(normal.outputs[0])
normal.inputs['Strength'].default_value = 1
ob.data.uv_layers.remove(ob.data.uv_layers[0])
node_matches(normal.outputs[0])
ob.data.clear_geometry()
ob.data.from_pydata([(-2, -2, 0), (2, -2, 0), (2, 0, 0), (2, 2, 0), (-2, 2, 0)], [], [(0, 1, 2, 3, 4)])
node_matches(normal.outputs[0])
reference = bpy.data.objects.new('coordinate reference', None)
scene.collection.objects.link(reference)
coordinates = tree.nodes.new('ShaderNodeTexCoord')
coordinates.object = reference
tree.links.new(coordinates.outputs['Object'], emission.inputs['Color'])
bpy.context.view_layer.update()
depsgraph = bpy.context.evaluated_depsgraph_get()
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, depsgraph)
reference.location.x = 1
bpy.context.view_layer.update()
exporter.requests = io.BytesIO()
Viewport.engine.start(exporter, types.SimpleNamespace(scene_eval=depsgraph.scene_eval,
    object_instances=depsgraph.object_instances, updates=[types.SimpleNamespace(id=reference)]))
assert numpy.frombuffer(exporter.requests.getvalue(), 'I', count=1)[0] == flex.SCENE, 'reference coordinates update'
collection = bpy.data.collections.new('instance source')
member = bpy.data.objects.new('instance member', ob.data)
collection.objects.link(member)
instance = bpy.data.objects.new('instancer', None)
scene.collection.objects.link(instance)
instance.instance_type, instance.instance_collection = 'COLLECTION', collection
bpy.context.view_layer.update()
exporter.visible, exporter.requests = (), io.BytesIO()
Viewport.engine.start(exporter, depsgraph)
slot = next(i for i, item in enumerate(depsgraph.object_instances)
    if item.is_instance and item.object.original == member)
first = exporter.slots[slot][0]
before = numpy.frombuffer(exporter.requests.getvalue(), 'f', count=9, offset=16 + 36 * first).copy()
instance.location.x = 1
bpy.context.view_layer.update()
exporter.requests = io.BytesIO()
Viewport.engine.start(exporter, types.SimpleNamespace(scene_eval=depsgraph.scene_eval,
    object_instances=depsgraph.object_instances, updates=[types.SimpleNamespace(id=instance)]))
assert tuple(numpy.frombuffer(exporter.requests.getvalue(), 'I', count=4)) == (flex.UPDATE, 1,
    *exporter.slots[slot][:2]), 'instancer update'
after = numpy.frombuffer(exporter.requests.getvalue(), 'f', count=9, offset=16)
assert numpy.allclose(after.reshape(3, 3), before.reshape(3, 3) + (1, 0, 0)), 'instance motion'
# Twisted, a mesh keeps the generated coordinates of its vertices undeformed, those of a final render, though this
# depsgraph, evaluated for no render as the viewport's first, holds no orco layer
twisted = bpy.data.objects.new('twisted', bpy.data.meshes.new('twisted'))
scene.collection.objects.link(twisted)
bm = bmesh.new()
bmesh.ops.create_grid(bm, x_segments=4, y_segments=4, size=1)
bm.to_mesh(twisted.data)
twist = twisted.modifiers.new('twist', 'SIMPLE_DEFORM')
twist.deform_axis, twist.angle = 'X', 0.6
bpy.context.view_layer.update()
exporter.visible, exporter.requests = (), io.BytesIO()
Viewport.engine.start(exporter, depsgraph)
first, count = exporter.slots[next(i for i, item in enumerate(depsgraph.object_instances)
    if item.object.original == twisted)][:2]
piped = exporter.requests.getvalue()
generated = numpy.frombuffer(piped, 'f', count=9 * count, offset=16 + 36 * (2 * numpy.frombuffer(piped, 'I', count=2)[1]
    + first)).reshape(-1, 3)
mesh = twisted.data
rest = (numpy.array([v.co for v in mesh.vertices]) - mesh.texspace_location) / (2 * numpy.array(mesh.texspace_size)) + 0.5
assert all(numpy.isclose(rest, point, atol=1e-5).all(1).any() for point in generated), 'undeformed generated coordinates'
twisted.hide_render = True
# Curves, text, surfaces and metaballs evaluate to meshes their originals hold no vertices of: their generated
# coordinates are those meshes' orco layers
made = []
for primitive in (bpy.ops.curve.primitive_bezier_curve_add, bpy.ops.object.text_add,
        bpy.ops.surface.primitive_nurbs_surface_surface_add, bpy.ops.object.metaball_add):
    primitive(location=(5, 0, 0))
    made.append(bpy.context.object)
made[0].data.extrude = 0.1
bpy.context.view_layer.update()
exporter.visible, exporter.requests = (), io.BytesIO()
Viewport.engine.start(exporter, depsgraph)
piped, kinds = exporter.requests.getvalue(), set()
for i, item in enumerate(depsgraph.object_instances):
    if item.object.original in made and item.object.type == 'MESH':
        first, count = exporter.slots[i][:2]
        generated = numpy.frombuffer(piped, 'f', count=9 * count, offset=16 + 36 * (2 * numpy.frombuffer(piped, 'I',
            count=2)[1] + first)).reshape(-1, 3)
        mesh, kinds = item.object.to_mesh(), kinds | {item.object.original.type}
        orco = (numpy.array([v.undeformed_co for v in mesh.vertices]) - mesh.texspace_location) / (2 * numpy.array(
            mesh.texspace_size)) + 0.5
        assert all(numpy.isclose(orco, point, atol=1e-5).all(1).any() for point in generated), 'curve generated'
        item.object.to_mesh_clear()
assert kinds == {'CURVE', 'FONT', 'SURFACE', 'META'}, 'curves made meshes'
for ob in made: ob.hide_render = True

# 8 bit sRGB images are filtered in linear light: a black and a white texel magnified read 0.5 halfway between them
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.render.engine = 'FLEX'
scene.camera.location, scene.camera.rotation_euler, scene.camera.data.angle = (0, 0, 1), (0, 0, 0), 0.1
edge = plane('edge', 0, 0, 2)
edge.inputs['Base Color'].default_value, edge.inputs['Emission Strength'].default_value = (0, 0, 0, 1), 1
steps = edge.id_data.nodes.new('ShaderNodeTexImage')
steps.image, steps.interpolation = bpy.data.images.new('steps', 2, 1), 'Linear'
steps.image.pixels.foreach_set((0, 0, 0, 1, 1, 1, 1, 1))
edge.id_data.links.new(steps.outputs['Color'], edge.inputs['Emission Color'])
assert abs(render()[24:40, 24:40].mean() - 0.5) < 0.05, 'linear filtering'

# White furnace: a white metal sphere of roughness 0.5 under a sky of one scatters each ray once, so a pixel it covers
# holds GGX's single-scatter albedo under exact Smith masking at the pixel's view cosines: 0.8801 over those within its
# silhouette, integrated numerically
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.render.engine, scene.flex_restir, scene.flex_samples = 'FLEX', False, 64
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
scene.camera.location, scene.camera.rotation_euler, scene.camera.data.angle = (0, 0, 3), (0, 0, 0), 0.8
furnace = shape('furnace', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=64, v_segments=32, radius=1), (0, 0, 0))
bpy.data.meshes['furnace'].shade_smooth()
furnace.inputs['Base Color'].default_value, furnace.inputs['Metallic'].default_value = (1, 1, 1, 1), 1
furnace.inputs['Roughness'].default_value = 0.5
disk = render().mean(2)
corner = numpy.linspace(-1, 1, SIZE + 1) * math.tan(0.4)  # Pixel corners' rays, as the camera's angle spreads them
x, y = numpy.meshgrid(corner, corner)
inside = 9 * (x * x + y * y) < 0.9801 * (1 + x * x + y * y)  # Within 0.99 of the center, inside the mesh's silhouette
covered = inside[:-1, :-1] & inside[1:, :-1] & inside[:-1, 1:] & inside[1:, 1:]
assert abs(disk[covered].mean() - 0.8801) < 0.003, 'rough metal furnace'

# End-to-end parity test, run by make test: renders a scene of textures, among them one mirrored and interpolated at
# negative coordinates, node programs, an emitter, a point light, glossy metal, glass and a volume under a sky with Flex
# on OptiX and on Vulkan, with ReSTIR and without, and compares the images, which trace the same random numbers.
scene = new('parity')

scene.camera = add(bpy.data.cameras.new('camera'), (0, -3, 2), (math.radians(60), 0, 0))
add(bpy.data.lights.new('light', 'POINT'), (1, -1, 3)).data.energy = 500
floor = shape('floor', lambda bm: bmesh.ops.create_grid(bm, size=2, calc_uvs=True), (0, 0, 0))
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
metal = shape('metal', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=32, v_segments=16, radius=0.5,
    calc_uvs=True), (-0.8, 0, 0.5))
metal.inputs['Metallic'].default_value, metal.inputs['Roughness'].default_value = 1, 0.1
noise = metal.id_data.nodes.new('ShaderNodeTexNoise')
metal.id_data.links.new(noise.outputs['Color'], metal.inputs['Base Color'])
glass = shape('glass', lambda bm: bmesh.ops.create_cube(bm, size=0.8, calc_uvs=True), (0.8, 0, 0.4),
    (0, 0, math.radians(30)))
glass.inputs['Transmission Weight'].default_value, glass.inputs['Roughness'].default_value = 1, 0
glass.inputs['IOR'].default_value = 1.45
absorption = glass.id_data.nodes.new('ShaderNodeVolumeAbsorption')
absorption.inputs['Color'].default_value, absorption.inputs['Density'].default_value = (0.8, 0.4, 0.2, 1), 2
glass.id_data.links.new(absorption.outputs[0], glass.id_data.nodes['Material Output'].inputs['Volume'])
emitter = shape('emitter', lambda bm: bmesh.ops.create_grid(bm, size=0.3, calc_uvs=True), (0, 1, 1),
    (math.radians(90), 0, 0))
emitter.inputs['Emission Strength'].default_value = 5
voronoi = emitter.id_data.nodes.new('ShaderNodeTexVoronoi')
emitter.id_data.links.new(voronoi.outputs['Color'], emitter.inputs['Emission Color'])

engine = bpy.types.RenderEngine.bl_rna_get_subclass_py('FLEX')
preferences = bpy.context.preferences.addons[engine.__module__].preferences
blocks = lambda pixels: pixels.reshape(8, 8, 8, 8, 3).mean((1, 3))  # Of 8 x 8 pixels

def render_on(device):
    preferences.device = device
    return render()

for restir in (False, True):
    scene.flex_restir = restir
    optix, vulkan = render_on('OPTIX'), render_on('VULKAN')
    assert numpy.isfinite(optix).all() and numpy.isfinite(vulkan).all(), f'finite {restir}'
    assert numpy.isclose(vulkan.mean(), optix.mean(), rtol=0.01), f'mean {restir}: {vulkan.mean()} vs {optix.mean()}'
    # Reuse spreads the backends' last bits of difference over the neighborhoods it resamples, so their blocks differ as
    # its noise does, which their means average out
    rtol, atol = (0.1, 0.02) if restir else (0.05, 0.01)
    assert numpy.allclose(blocks(vulkan), blocks(optix), rtol=rtol, atol=atol), \
        f'blocks {restir}: {numpy.abs(blocks(vulkan) - blocks(optix)).max()}'

# Stacked planes of half coverage, coincident or closer than shadow rays used to step over, each let half of the light
# of an emitter so small that light sampling alone carries it through to the floor below them, on both backends
scene = new('layers')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
scene.flex_samples, scene.flex_restir = 1024, False
scene.camera = add(bpy.data.cameras.new('layers'), (0, 0, 0.5))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 1
grid = lambda size: lambda bm: bmesh.ops.create_grid(bm, size=size / 2)
shape('floor', grid(4), (0, 0, 0)).inputs['Roughness'].default_value = 1
light = shape('light', grid(0.01), (0, 0, 2))
for name, value in (('Base Color', (0, 0, 0, 1)), ('Specular IOR Level', 0), ('Emission Color', (1, 1, 1, 1)),
        ('Emission Strength', 20 * 150 ** 2)): light.inputs[name].default_value = value
for i in range(4):
    layer = shape(f'layer {i}', grid(6), (0, 0, 1))
    for name, value in (('Base Color', (0, 0, 0, 1)), ('Specular IOR Level', 0), ('Alpha', 0.5)):
        layer.inputs[name].default_value = value
layers = [bpy.data.objects[f'layer {i}'] for i in range(4)]
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    for ob in layers: ob.hide_render = True
    open_ = render().mean()
    for n, spacing in ((2, 0), (4, 0), (2, 5e-5), (4, 5e-5)):
        for i, ob in enumerate(layers): ob.hide_render, ob.location.z = i >= n, 1 + i * spacing
        assert numpy.isclose(render().mean() / open_, 0.5 ** n, rtol=0.02), f'layers {device} {n} {spacing}'
