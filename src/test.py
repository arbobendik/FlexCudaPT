# End-to-end test, run by make test: renders a lit plane, half colored and half textured, and a textured emitter under a
# sky with Flex through a render border and checks the pixels, then draws the same view through the engine's viewport
# methods and compares.
import bpy, bmesh, gc, gpu, io, math, numpy, os, struct, sys, time, types, weakref
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
    space_data=types.SimpleNamespace(camera=scene.camera, clip_end=1000))
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
# A black dielectric reflects its reflectance at normal incidence tinted by its Specular Tint and scaled by its Specular
# IOR Level, as Blender's Principled defines them, the exporter folding level 1 into a factor of 2 and marking the tint
# off their defaults, unmarked at them for the shader to compile both out
colored.id_data.links.remove(colored.inputs['Base Color'].links[0])
colored.inputs['Base Color'].default_value = (0, 0, 0, 1)
colored.inputs['IOR'].default_value = 1.5
colored.inputs['Specular IOR Level'].default_value = 1
colored.inputs['Specular Tint'].default_value = (0, 1, 0, 1)
flex = sys.modules[Viewport.engine.__module__]
surface = flex.fold(flex.resolve(colored.outputs[0].links[0].to_socket))
assert surface[7][0] == 'SPECULAR' and numpy.allclose(numpy.array((surface[6], surface[7][1], surface[8])),
    ((1.5,) * 3, (0, 1, 0), (2,) * 3)), 'specular level'
# A mapping at its defaults turns no point: an image read through it folds to its read at the UV, as a noise times zero
# folds to zero, and transmitting nothing under a textured metallic, opaque; a degenerate map range of the noise times
# zero stays guarded to zero, as Blender sees its input vary
identities = bpy.data.materials.new('identities').node_tree
bsdf, (mapping, image, product, ranged) = identities.nodes['Principled BSDF'], (identities.nodes.new(kind) for kind in
    ('ShaderNodeMapping', 'ShaderNodeTexImage', 'ShaderNodeMath', 'ShaderNodeMapRange'))
image.image, product.operation, product.inputs[1].default_value = texture.image, 'MULTIPLY', 0
ranged.inputs['From Min'].default_value = ranged.inputs['From Max'].default_value = 0.5
ranged.inputs['To Min'].default_value, ranged.clamp = 0.3, False
identities.links.new(identities.nodes.new('ShaderNodeTexCoord').outputs['UV'], mapping.inputs['Vector'])
identities.links.new(mapping.outputs['Vector'], image.inputs['Vector'])
for output, target in ((image.outputs['Color'], bsdf.inputs['Base Color']), (image.outputs['Color'],
        bsdf.inputs['Metallic']), (identities.nodes.new('ShaderNodeTexNoise').outputs['Fac'], product.inputs[0]),
        (product.outputs[0], bsdf.inputs['Roughness']), (product.outputs[0], ranged.inputs['Value']),
        (ranged.outputs['Result'], bsdf.inputs['Emission Strength'])):
    identities.links.new(output, target)
surface = flex.fold(flex.resolve(identities.nodes['Material Output'].inputs['Surface']))
assert 'ROTATE' not in str(surface[1]) and not any(isinstance(surface[k], tuple) for k in (3, 5)), 'identities fold'
assert not isinstance(surface[4], tuple) and not numpy.any(surface[4]), 'degenerate range guarded'
pixels = render()
red, green, blue = pixels[18:46, 2:30].mean((0, 1))
assert green > 50 * max(red, blue), 'specular tint'
colored.inputs['Specular Tint'].default_value = (1, 1, 1, 1)
reflected = []  # At level 1, 0.5 and 0: doubled, plain and none
for level in (1, 0.5, 0):
    colored.inputs['Specular IOR Level'].default_value = level
    reflected.append(render()[18:46, 2:30].mean())
assert 1.95 < reflected[0] / reflected[1] < 2.05 and reflected[2] < 1e-3 * reflected[1], 'specular level reflectance'
colored.inputs['Specular IOR Level'].default_value = 0.5
assert not isinstance(flex.fold(flex.resolve(colored.outputs[0].links[0].to_socket))[7], tuple), 'specular defaults'
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
# numerically; without ReSTIR, whose reuse it would measure besides the BSDF
bpy.data.objects['colored'].hide_render = False
colored.inputs['Base Color'].default_value = colored.inputs['Specular Tint'].default_value = (1, 1, 1, 1)
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
scene.flex_restir = False
pixels = render()
assert abs(pixels[18:46, 2:30].mean() - 0.9903) < 0.002, 'furnace'
# Tinted, at its level and doubled, it returns in each channel what its tinted reflection and the diffuse of what that
# leaves do, never more than it receives: each channel its single-scatter directional albedo, derived numerically as
# 'furnace' is
colored.inputs['Specular Tint'].default_value = (1, 0.08, 0.375, 1)
for level, derived in ((0.5, (0.9903, 0.9936, 0.9926)), (1, (0.9863, 0.9929, 0.9908))):
    colored.inputs['Specular IOR Level'].default_value = level
    assert numpy.allclose(render()[18:46, 2:30].mean((0, 1)), derived, atol=0.002), f'tinted furnace at level {level}'
colored.inputs['Specular IOR Level'].default_value, scene.flex_restir = 0.5, True
# ReSTIR keeps the furnace's light: white and tinted, the plane's block with ReSTIR minus without, over independent
# realizations (the same part of the plane at widths whose pixels draw other seeds), is zero within five standard
# errors per channel. A guard against lost or broken reuse weights (dropping the canonical sample's MIS weight takes
# 90%), not a precision test of unbiasedness: it detects shifts above about 0.24% white and 0.48% tinted red, and a
# change that only reshuffles the noise fails it with odds of about 1.6%
REALIZATIONS = tuple(SIZE * k for k in range(1, 7))
def block(width):  # Mean color of the furnace block at width pixels, the same part of the plane at each
    scene.render.resolution_x = scene.render.resolution_y = width
    bpy.ops.render.render(scene=scene.name, write_still=True)
    k = width // SIZE
    image = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(width, width, 4)
    return image[18 * k:46 * k, 2 * k:30 * k, :3].mean((0, 1))
for tint in ((1, 1, 1, 1), (1, 0.08, 0.375, 1)):
    colored.inputs['Specular Tint'].default_value = tint
    shifts = []
    for width in REALIZATIONS:
        scene.flex_restir = False
        without = block(width)
        scene.flex_restir = True
        shifts.append(block(width) - without)
    shifts = numpy.array(shifts)
    assert (abs(shifts.mean(0)) < 5 * shifts.std(0, ddof=1) / len(shifts) ** 0.5).all(), f'restir furnace {tint}'
scene.render.resolution_x = scene.render.resolution_y = SIZE
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
# Blender's Translucent BSDF transmits diffusely: a white sheet lit only by an emitter of radiance 1 below it reads, by
# light sampling alone and beside BSDF hits, that emitter's view factor through its back, where reflecting it read none,
# and mixed half with a white diffuse half of it; inside a box emitting white it reads white from either side, its
# shading normals strongly tilted
shown = [ob for ob in scene.objects if not ob.hide_render]
for ob in shown: ob.hide_render = ob != scene.camera
sheet = shape('sheet', lambda bm: bmesh.ops.create_grid(bm, size=2, calc_uvs=True), (0, 0, 0))
nodes, links = sheet.id_data.nodes, sheet.id_data.links
translucent, diffuse, both = (nodes.new(kind) for kind in ('ShaderNodeBsdfTranslucent', 'ShaderNodeBsdfDiffuse',
    'ShaderNodeMixShader'))
translucent.inputs['Color'].default_value = diffuse.inputs['Color'].default_value = (1, 1, 1, 1)
links.new(diffuse.outputs[0], both.inputs[1]), links.new(translucent.outputs[0], both.inputs[2])
lamp = shape('lamp', lambda bm: bmesh.ops.create_grid(bm, size=2, calc_uvs=True), (0, 0, -0.25))
lamp.inputs['Base Color'].default_value, lamp.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
lamp.inputs['Emission Strength'].default_value, lamp.inputs['IOR'].default_value = 1, 1
s = 2 / math.hypot(2, 0.25)
view = 4 / math.pi * s * math.atan(s)  # Of the lamp's square from the sheet's center
# Only a translucent color marks its program, through a mix too, so the shader compiles it out of other scenes
assert not isinstance(flex.fold(flex.resolve(nodes['Material Output'].inputs['Surface']))[13], tuple), 'opaque unmarked'
for shader, share in ((translucent, 1), (both, 0.5)):
    links.new(shader.outputs[0], nodes['Material Output'].inputs['Surface'])
    assert flex.marks(flex.fold(flex.resolve(nodes['Material Output'].inputs['Surface']))[13], 'TRANSLUCENT'), 'marked'
    for depth in (0, 1):
        assert numpy.isclose(mis_render(depth, False).mean(), share * view, rtol=0.02), 'translucent from behind'
    # Reused too: ReSTIR's connections through the sheet are the diffuse lobe's, refracting
    assert numpy.isclose(mis_render(1, True).mean(), share * view, rtol=0.02), 'translucent from behind, reused'
bpy.data.objects['lamp'].hide_render = True
shell = shape('shell', lambda bm: [bmesh.ops.create_cube(bm, size=6), bmesh.ops.reverse_faces(bm, faces=bm.faces[:])],
    (0, 0, 0))  # Facing in
shell.inputs['Base Color'].default_value, shell.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
shell.inputs['Emission Strength'].default_value, shell.inputs['IOR'].default_value = 1, 1
bpy.data.meshes['sheet'].shade_smooth()
bpy.data.meshes['sheet'].normals_split_custom_set([(0.95, 0, 0.3122499)] * 4)
for shader in (translucent, both):
    links.new(shader.outputs[0], nodes['Material Output'].inputs['Surface'])
    for side in (1, -1):
        scene.camera.location.z, scene.camera.rotation_euler.x = side, math.pi * (side < 0)
        assert numpy.isclose(mis_render(1, False).mean(), 1, rtol=0.01), 'translucent furnace'
        assert numpy.isclose(mis_render(1, True).mean(), 1, rtol=0.01), 'translucent furnace, reused'
scene.camera.location.z, scene.camera.rotation_euler.x = 1, 0
# One-layer white rough glass there returns at most what it receives: light sampling, without a light normal on a
# transmitting surface, counts a light point only on the side the lifted start sees it, as BSDF sampling reaches it
sheet.inputs['Base Color'].default_value, sheet.inputs['Transmission Weight'].default_value = (1, 1, 1, 1), 1
sheet.inputs['IOR'].default_value, sheet.inputs['Roughness'].default_value = 1.5, 0.3
links.new(sheet.outputs[0], nodes['Material Output'].inputs['Surface'])
bpy.data.meshes['sheet'].normals_split_custom_set([(0.6, 0, 0.8)] * 4)
assert mis_render(1, False).mean() <= 1, 'glass furnace'
# White subsurface scattering of mean free path 0.1 fills a closed slab 0.05 thick, lit from behind by the lamp, which
# glows through it, while the open sheet of the same material keeps its diffuse; a closed sphere of it in the emitting
# box returns at most what it receives, short by the walks the bounces cut
sss = shape('sss', lambda bm: bmesh.ops.create_cube(bm, size=1), (0, 0, 0))
bpy.data.objects['sss'].scale = (4, 4, 0.05)
sss.inputs['Subsurface Weight'].default_value, sss.inputs['Subsurface Scale'].default_value = 1, 0.1
sss.inputs['Base Color'].default_value, sss.inputs['Subsurface Radius'].default_value = (1, 1, 1, 1), (1, 1, 1)
links.new(sss.outputs[0], nodes['Material Output'].inputs['Surface'])  # The sheet's too
bpy.data.meshes['sheet'].materials[0] = bpy.data.objects['sss'].active_material
for name, hidden in (('shell', True), ('lamp', False), ('sheet', True)): bpy.data.objects[name].hide_render = hidden
through = mis_render(bounces, False).mean()
print('SUBSURFACE through', through, flush=True)
assert through > 0.05, 'subsurface through a closed slab'
bpy.data.objects['sss'].hide_render, bpy.data.objects['sheet'].hide_render = True, False
print('SUBSURFACE open sheet', mis_render(bounces, False).mean(), flush=True)
assert mis_render(bounces, False).mean() < 0.01, 'open subsurface diffuse'
bpy.data.objects['sheet'].modifiers.new('solid', 'SOLIDIFY').thickness = 0.05  # Closed by a modifier, it fills
solid = mis_render(bounces, False).mean()
print('SUBSURFACE solidified sheet', solid, flush=True)
assert solid > 0.05, 'subsurface through a sheet a modifier closes'
bpy.data.objects['sheet'].modifiers.clear()
bpy.data.objects['sheet'].hide_render, bpy.data.objects['lamp'].hide_render = True, True
bpy.data.objects['shell'].hide_render, bpy.data.objects['sss'].hide_render = False, False
bpy.data.objects['sss'].scale, bpy.data.objects['sss'].location.z = (1, 1, 1), -0.6  # A cube, its top 0.1 below
furnace = mis_render(bounces, False).mean()
print('SUBSURFACE furnace', furnace, flush=True)
assert furnace <= 1.005, 'subsurface furnace'
for ob in scene.objects: ob.hide_render = ob not in shown
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
# the slab 0.15 below it through that depth: its rays start at its clip start, made short of those
scene.camera.location.z, scene.camera.data.clip_start = 0, 1e-3
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
scene.camera.location.z, scene.camera.data.clip_start = 1, 0.1
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

def node_matches(socket, atol=1e-4):
    tree.links.new(socket, emission.inputs['Color'])
    colors = []
    for engine in ('FLEX', 'CYCLES'):
        scene.render.engine = engine
        colors.append(render()[24:40, 24:40].mean((0, 1)))
    assert numpy.allclose(*colors, atol=atol), (socket.node.name, colors)

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
node_matches(image.outputs['Alpha'], 2 ** -8)  # Filtered in hardware, of weights of 8 bits
image.image.alpha_mode = 'STRAIGHT'
tree.links.new(image.outputs['Alpha'], tree.nodes.new('ShaderNodeMath').inputs[0])  # An unused alpha link
node_matches(image.outputs['Color'], 2 ** -8)
tree.links.remove(image.outputs['Alpha'].links[0])
point.inputs[0].default_value = 0.5
other = tree.nodes.new('ShaderNodeTexImage')
other.image, other.extension = image.image, image.extension
tree.links.new(point.outputs[0], other.inputs[0])
tree.links.new(other.outputs['Alpha'], emission.inputs['Strength'])
node_matches(image.outputs['Color'], 2 ** -8)
other.interpolation = 'Closest'
node_matches(image.outputs['Color'], 2 ** -8)
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
exporter.requests = io.BytesIO()  # Its triangles where they are, as an update pipes them
Viewport.engine.start(exporter, types.SimpleNamespace(scene_eval=depsgraph.scene_eval,
    object_instances=depsgraph.object_instances, updates=[types.SimpleNamespace(id=instance)]))
before = numpy.frombuffer(exporter.requests.getvalue(), 'f', count=9, offset=16).copy()
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
def generated_of(piped, i):  # Generated coordinates of the mesh entry of instance i, by the scene's instance table
    header, k = numpy.frombuffer(piped, 'I', count=11), [*exporter.slots].index(i)
    first, count = numpy.frombuffer(piped, 'I', count=2, offset=44 + 172 * k)
    return numpy.frombuffer(piped, 'f', count=9 * count, offset=44 + 172 * header[9] + 36 * (2 * header[8]
        + first)).reshape(-1, 3)
generated = generated_of(exporter.requests.getvalue(), next(i for i, item in enumerate(depsgraph.object_instances)
    if item.object.original == twisted))
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
        generated = generated_of(piped, i)
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
# A unit's bake scale holds still under the noise Blender's threads leave in the last bits of UVs: eight triangles of a
# tenth of the UV square, their generated points stretched 1 to 8 times along them, and two slivers a millionth wide
# stretched 9 and 10 times, whose derivatives are only as exact as their UVs; two ulps of noise move it under 1e-4
uv = numpy.array([[(0.1 * k, 0.5), (0.1 * k + 0.1, 0.5), (0.1 * k, 0.6)] for k in range(8)]
    + [[(x, 0.8), (x + 0.1, 0.8), (x + 0.05, 0.8 + 1e-6)] for x in (0.2, 0.5)], 'f')
points = numpy.concatenate((uv, numpy.zeros((10, 3, 1), 'f')), 2) * numpy.arange(1, 11, dtype='f')[:, None, None]
noise = numpy.random.default_rng(0)
scales = [flex.stretch(points, (uv + noise.integers(-2, 3, uv.shape) * numpy.spacing(uv)).astype('f'))
    for _ in range(20)]
assert max(scales) - min(scales) < 1e-4 * flex.stretch(points, uv), 'scale of slivers'
# A noise of the generated point with detail at its bake's texel scale (scale 50, 2272 texels across) bakes over the
# plane's UVs and renders as it does live, its UVs moved off [0, 1], where nothing bakes: at 256 samples and two
# pixels a texel all but 1% of pixels within 0.0018, three times the live render's seed floor there, the bake at half
# that, a bake a texel off or at half its resolution past twice it; moving the plane bakes nothing again
noise = edge.id_data.nodes.new('ShaderNodeTexNoise')
noise.inputs['Scale'].default_value = 50
edge.id_data.links.new(noise.outputs['Color'], edge.inputs['Emission Color'])
depsgraph, exporter = bpy.context.evaluated_depsgraph_get(), types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, depsgraph)
bakes = numpy.frombuffer(exporter.requests.getvalue(), 'I', count=6)[5]
assert bakes == len(getattr(exporter, 'placed', ())) > 0, 'bakes'
bpy.data.objects['edge'].location.x, exporter.requests = 0.1, io.BytesIO()
bpy.context.view_layer.update()
Viewport.engine.start(exporter, types.SimpleNamespace(scene_eval=depsgraph.scene_eval,
    object_instances=depsgraph.object_instances, updates=[types.SimpleNamespace(id=bpy.data.objects['edge'])]))
assert numpy.frombuffer(exporter.requests.getvalue(), 'I', count=1)[0] == flex.UPDATE, 'motion bakes nothing'
bpy.data.objects['edge'].location.x, scene.flex_samples, scene.camera.data.angle = 0, 256, 0.03
baked, uvs = render(), bpy.data.meshes['edge'].uv_layers.active.data
uv = numpy.zeros(2 * len(uvs), 'f')
uvs.foreach_get('uv', uv), uvs.foreach_set('uv', uv + 1)
assert numpy.percentile(numpy.abs(render() - baked).max(-1), 99) < 0.0018, 'baked noise'
# An image read at the generated point stays live beside the noise, affine in it, its alpha unread: baked over UVs and
# read back, its texels would be interpolated twice
links, product = edge.id_data.links, edge.id_data.nodes.new('ShaderNodeMix')
product.data_type, product.blend_type, product.inputs['Factor'].default_value = 'RGBA', 'MULTIPLY', 1
links.new(edge.id_data.nodes.new('ShaderNodeTexCoord').outputs['Generated'], steps.inputs['Vector'])
links.new(noise.outputs['Color'], product.inputs[6]), links.new(steps.outputs['Color'], product.inputs[7])
links.new(product.outputs[2], edge.inputs['Emission Color'])
steps.image.alpha_mode = 'CHANNEL_PACKED'
uvs.foreach_set('uv', uv)
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())  # Exporting anew, not updating values
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert exporter.placed and not any('steps' in str(key) for _, key, *_ in exporter.placed), 'image reads stay live'
# A procedural specular tint bakes inside its mark, which stays live for the shader to keep the tint
links.new(noise.outputs['Color'], edge.inputs['Specular Tint'])
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert exporter.placed and not any('SPECULAR' in str(key) for _, key, *_ in exporter.placed), 'specular mark live'
# So does a procedural translucent color, which stays live for the shader to transmit it
through = edge.id_data.nodes.new('ShaderNodeBsdfTranslucent')
output = edge.id_data.nodes['Material Output'].inputs['Surface']
links.new(noise.outputs['Color'], through.inputs['Color']), links.new(through.outputs[0], output)
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert exporter.placed and not any('TRANSLUCENT' in str(key) for _, key, *_ in exporter.placed), 'translucent mark live'
links.new(edge.outputs[0], output)
links.remove(edge.inputs['Specular Tint'].links[0])
# Coated, the plane's base layer bakes its noise and renders under the coat as live, within the seed floor there,
# 0.0082 of its mean: its bake comes before both layers' rows, which follow each other
edge.inputs['Emission Strength'].default_value, edge.inputs['Coat Weight'].default_value = 0, 0.5
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (*SKY, 1)  # Its light alone
links.new(noise.outputs['Color'], edge.inputs['Base Color'])
baked = render()
uvs.foreach_set('uv', uv + 1)
live = render()
assert numpy.abs(live - baked).mean() < 0.0082 * live.mean(), 'coated base bakes'
# An image read at the UV straight into a base color bakes nothing: a bake would add a fetch and remove none
plain = bpy.data.materials.new('plain')
plain.node_tree.nodes.new('ShaderNodeTexImage').image = steps.image
plain.node_tree.links.new(plain.node_tree.nodes['Image Texture'].outputs['Color'],
    plain.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
bpy.data.meshes['edge'].materials[0], exporter = plain, types.SimpleNamespace(visible=(), requests=io.BytesIO())
uvs.foreach_set('uv', uv)
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert not exporter.placed, 'plain images bake nothing'
# Each image the materials read goes apart from the texels, in its own array, read by its index: flagged in bit 31
entries = [entry for key, entry in exporter.shape[2].items() if isinstance(key, tuple) and not entry[2] >> 30 & 1]
assert entries and all(entry[2] >> 31 for entry in entries) and sorted(entry[0] for entry in entries) == [
    *range(len(entries))] == [*range(struct.unpack('<11I', exporter.requests.getvalue()[:44])[10])], 'images apart'
# A power of an image read through a mapping that scales the UV twice bakes over UV space only where it can within the
# bake tolerance: white noise, whose kinks a bake rounds off, stays live; a smooth image bakes once, repeating with
# the UV, its samples on the image's texels, and renders as live, at a tolerance below 0: at 256 samples and two
# pixels an image texel all but 1% of pixels within 0.0018, the live render's seed floor there, the bake at three
# quarters of it, a bake a texel off, on a grid half a texel off or of zeros past five times it; at half its
# resolution it would stray too far, so it isn't baked
detail, material = bpy.data.images.new('detail', 1024, 1024), bpy.data.materials.new('power')
power, texels = material.node_tree, numpy.random.default_rng(1).random((1024, 1024, 4), 'f')
texels[..., 3] = 1
mapping, image, exponent = (power.nodes.new(kind) for kind in ('ShaderNodeMapping', 'ShaderNodeTexImage',
    'ShaderNodeMath'))
mapping.inputs['Scale'].default_value[:2], image.image, image.interpolation = (2, 2), detail, 'Linear'
exponent.operation, exponent.inputs[1].default_value = 'POWER', 2.2
for output, target in ((power.nodes.new('ShaderNodeTexCoord').outputs['UV'], mapping.inputs['Vector']),
        (mapping.outputs['Vector'], image.inputs['Vector']), (image.outputs['Color'], exponent.inputs[0]),
        (exponent.outputs[0], power.nodes['Principled BSDF'].inputs['Emission Color'])):
    power.links.new(output, target)
power.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0, 0, 0, 1)
power.nodes['Principled BSDF'].inputs['Emission Strength'].default_value = 1
bpy.data.meshes['edge'].materials[0] = material
for smooth in (False, True):
    if smooth:  # Detail over 16 texels, spread over the whole range
        for axis in (0, 1): texels[..., :3] = sum(numpy.roll(texels[..., :3], k, axis) for k in range(16)) / 16
        texels[..., :3] = (texels[..., :3] - texels[..., :3].min()) / numpy.ptp(texels[..., :3])
    detail.pixels.foreach_set(texels.ravel())
    exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
    Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
    assert [key[0] for _, key, *_ in exporter.placed] == ([None] if smooth else []), 'uv bakes within tolerance'
baked, tolerance, module['BAKE_TOLERANCE'] = render(), module['BAKE_TOLERANCE'], -1  # Every bake strays
assert numpy.percentile(numpy.abs(render() - baked).max(-1), 99) < 0.0018, 'baked uv'
# Once baked, what only bakes read is freed: the image the power reads through its bake alone isn't among the texels the
# renderer keeps, but read live as well, as a base color, its 4 MiB of RGBA8 are
def resident():  # The texels the export pipes for the renderer to keep once baked, in MiB, of the scene: those with
    bpy.context.window.scene, exporter = scene, types.SimpleNamespace(visible=(), requests=io.BytesIO())  # the steps
    scene.update_tag()  # Its settings as last set; and each image's apart, four RGBA8 texels a float4
    Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
    images = sum(-(-width * (height & 0xFFFFFF) // (4 if height >> 26 & 1 else 1)) for key, (_, width, height, _) in
        exporter.shape[2].items() if isinstance(key, tuple) and height >> 31)
    return (struct.unpack('<11I', exporter.requests.getvalue()[:44])[3] + images) * 16 / 2 ** 20
module['BAKE_TOLERANCE'] = tolerance  # As the planner has it again
alone = resident()
power.links.new(image.outputs['Color'], power.nodes['Principled BSDF'].inputs['Base Color'])
assert (live := resident()) - alone > 3.9, ('bake inputs freed', alone, live)
power.links.remove(power.nodes['Principled BSDF'].inputs['Base Color'].links[0])
# A value of the baked power edited after its bake bakes it again: the update of steps runs the bake again and pipes the
# image only it reads anew, 4 MiB flagged in bit 31 for the renderer's bake pass alone
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, depsgraph := bpy.context.evaluated_depsgraph_get())
exponent.inputs[1].default_value, exporter.requests = 2, io.BytesIO()
material.update_tag()  # Its value edited, as Blender's editors tag it, and the scene evaluated with it
depsgraph = bpy.context.evaluated_depsgraph_get()
Viewport.engine.start(exporter, types.SimpleNamespace(scene_eval=depsgraph.scene_eval,
    object_instances=depsgraph.object_instances, updates=[types.SimpleNamespace(id=material, is_updated_geometry=False,
    is_updated_transform=False)]))
steps = exporter.requests.getvalue()
count = struct.unpack('<2I', steps[:8])[1]
first, width = struct.unpack('<2I', steps[8 + 16 * count:16 + 16 * count])
assert struct.unpack('<I', steps[:4])[0] == flex.STEPS and first >> 31 and width * 16 >= 4 << 20, 'rebake after freeing'
# The image alone, scaled by an emission strength, only restates it: no unit bakes it again
power.links.new(image.outputs['Color'], power.nodes['Principled BSDF'].inputs['Emission Color'])
power.nodes['Principled BSDF'].inputs['Emission Strength'].default_value = 1.8
module['BAKE_TOLERANCE'], exporter = tolerance, types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert not exporter.placed, 'an image scaled bakes nothing'
# A trivial tree, its image read at the UV into Transmission, which the export makes math of the image, bakes nothing
power.links.new(power.nodes['Texture Coordinate'].outputs['UV'], image.inputs['Vector'])
power.links.new(image.outputs['Color'], power.nodes['Principled BSDF'].inputs['Transmission Weight'])
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert not exporter.placed, 'trivial trees bake nothing'
# Light Falloff's linear output, smoothed, emits as its strength by the ray's length, by the length squared over itself
# plus the smoothing, built of Light Path's ray length and math; a material's displacement by bump alone bends its
# normal as a Bump node of the height at the displacement's scale does, its midlevel no slope
falloff = bpy.data.materials.new('falloff')
nodes, links = falloff.node_tree.nodes, falloff.node_tree.links
bsdf, light = nodes['Principled BSDF'], nodes.new('ShaderNodeLightFalloff')
bsdf.inputs['Base Color'].default_value, bsdf.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
light.inputs['Strength'].default_value, light.inputs['Smooth'].default_value = 3, 0.5
links.new(light.outputs['Linear'], bsdf.inputs['Emission Strength'])
bpy.data.meshes['edge'].materials[0] = falloff
by_node = render()
def operated(operation, a, b):  # A math node's output of two operands, each a socket or a value
    step = nodes.new('ShaderNodeMath')
    step.operation = operation
    for socket, operand in zip(step.inputs, (a, b)):
        if isinstance(operand, bpy.types.NodeSocket): links.new(operand, socket)
        else: socket.default_value = operand
    return step.outputs[0]
length = nodes.new('ShaderNodeLightPath').outputs['Ray Length']
squared = operated('MULTIPLY', length, length)
ratio = operated('DIVIDE', squared, operated('ADD', squared, 0.5))
links.new(operated('MULTIPLY', operated('MULTIPLY', length, 3), ratio), bsdf.inputs['Emission Strength'])
assert numpy.allclose(render(), by_node, atol=1e-4), 'light falloff'
displaced = bpy.data.materials.new('displaced')
nodes, links = displaced.node_tree.nodes, displaced.node_tree.links
height, displacement = nodes.new('ShaderNodeTexNoise'), nodes.new('ShaderNodeDisplacement')
height.inputs['Scale'].default_value = 4  # Of the position, which no bake reads: both shade it live, the same steps
links.new(nodes.new('ShaderNodeNewGeometry').outputs['Position'], height.inputs['Vector'])
displacement.inputs['Midlevel'].default_value, displacement.inputs['Scale'].default_value = 0.5, 2  # Exact in float
links.new(height.outputs['Fac'], displacement.inputs['Height'])
links.new(displacement.outputs[0], nodes['Material Output'].inputs['Displacement'])
displaced.displacement_method = 'BUMP'
bpy.data.meshes['edge'].materials[0] = displaced
by_displacement, bump = render(), nodes.new('ShaderNodeBump')
bump.inputs['Distance'].default_value = 2
links.new(height.outputs['Fac'], bump.inputs['Height'])
links.new(bump.outputs['Normal'], nodes['Principled BSDF'].inputs['Normal'])
links.remove(nodes['Material Output'].inputs['Displacement'].links[0])
assert numpy.allclose(render(), by_displacement, atol=1e-4), 'displacement by bump'

# A bump bakes its height's gradient along its point, central differences a quarter texel apart, the Bump's heights
# its dot products with its shifted points' offsets: of a sine of the generated x, exactly its derivative's
bumps, summarize = [], module['summarize']
def summarized(expression, table, scales, depth=[0]):  # The top expressions summarized under a bump: height, gradient
    if 'BUMP' in (scales or ()) and not depth[0]: bumps.append(expression)
    depth[0] += 1
    value = summarize(expression, table, scales)
    depth[0] -= 1
    return value
bumped = bpy.data.scenes.new('bumped')
bumped.render.engine, bumped.flex_samples = 'FLEX', 256
bumped.render.resolution_x = bumped.render.resolution_y = 128
bumped.render.image_settings.file_format, bumped.render.filepath = 'OPEN_EXR', bpy.app.tempdir + 'bumped.exr'
bumped.world = bpy.data.worlds.new('dark')
bumped.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
data, bm = bpy.data.meshes.new('bumped'), bmesh.new()
bm.loops.layers.uv.new(), bmesh.ops.create_grid(bm, size=1, calc_uvs=True), bm.to_mesh(data)
bumped.collection.objects.link(bpy.data.objects.new('bumped', data))
nodes, links = (tree := bpy.data.materials.new('bumped')).node_tree.nodes, tree.node_tree.links
data.materials.append(tree)
axis, sine, bump = (nodes.new(kind) for kind in ('ShaderNodeSeparateXYZ', 'ShaderNodeMath', 'ShaderNodeBump'))
links.new(nodes.new('ShaderNodeTexCoord').outputs['Generated'], axis.inputs[0])
links.new(axis.outputs['X'], sine.inputs[0]), links.new(sine.outputs[0], bump.inputs['Height'])
links.new(bump.outputs['Normal'], nodes['Principled BSDF'].inputs['Normal'])
sine.operation, module['summarize'] = 'SINE', summarized
sine_scaled = nodes.new('ShaderNodeMath')
sine_scaled.operation, sine_scaled.inputs[1].default_value = 'MULTIPLY', 10
links.new(axis.outputs['X'], sine_scaled.inputs[0]), links.new(sine_scaled.outputs[0], sine.inputs[0])
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
bpy.context.window.scene = bumped
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert len(bumps) == 2, 'bump gradient'  # Its height's and its gradient's
at = numpy.array((0.3, 0.6, 0.5))
gradient = flex.fold(flex.moved_to(bumps[1], at, {}, 'GENERATED'))
assert numpy.allclose(gradient, (10 * math.cos(10 * at[0]), 0, 0), rtol=1e-3, atol=1e-3), ('gradient', gradient)
# A noise bump at grazing light (scale 0.15, detail 5, roughness 0.25, lacunarity 4, distance 50), its gradient baked
# at 16 samples a period of its finest octave, 3488 texels, as both its octaves' gradients and the period ask, renders
# as live does within 0.016 (p99 of 128 x 128 pixels over 64 texels at 256 samples): baked 0.0124, against a seed
# floor of 0.0053. Live's own one-sided step errs: on a stand-in fBm of this structure, against a float64 derivative,
# live's gradient is 1% off (p99) and the bake's 0.5%, so most of what is left is likely live's. At 8 samples a period
# it was 0.0246, at the height's octave cutoff 0.0815, and a baked height read at the Bump's shifted points, as before,
# 1.36
noise = nodes.new('ShaderNodeTexNoise')
for name, value in (('Scale', 0.15), ('Detail', 5), ('Roughness', 0.25), ('Lacunarity', 4)):
    noise.inputs[name].default_value = value
links.new(noise.outputs['Fac'], bump.inputs['Height'])
bump.inputs['Distance'].default_value = 50
bumped.camera = bpy.data.objects.new('bumped camera', bpy.data.cameras.new('bumped camera'))
bumped.collection.objects.link(bumped.camera)
bumped.camera.location, bumped.camera.data.type, bumped.camera.data.ortho_scale = (0.1, 0.1, 1), 'ORTHO', 2 * 64 / 3488
sun = bpy.data.objects.new('bumped sun', bpy.data.lights.new('bumped sun', 'SUN'))
bumped.collection.objects.link(sun)
sun.data.energy, sun.rotation_euler = 5, (math.radians(75), 0, math.radians(30))
exporter.requests = io.BytesIO()
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert [exporter.shape[2][unit][1] for _, key, unit, *_ in exporter.placed] == [3488], 'bump bakes its gradient'
def shaded():  # The bumped scene rendered, its pixels
    bpy.ops.render.render(scene=bumped.name, write_still=True)
    return numpy.array(bpy.data.images.load(bumped.render.filepath).pixels).reshape(128, 128, 4)[..., :3]
baked, points, module['POINTS'] = shaded(), module['POINTS'], ()  # Live: no unit reads a point
live, module['POINTS'], module['summarize'] = shaded(), points, summarize
assert numpy.percentile(numpy.abs(baked - live).max(-1), 99) < 0.016, 'baked bump'
bpy.context.window.scene = scene

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

# A sun of angle 0 is Blender's parallel light: straight down at pi W/m^2 on white Lambertian diffuse, each pixel holds
# its irradiance over pi, one, on both backends
scene = new('sun')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
scene.flex_samples = 64
scene.camera = add(bpy.data.cameras.new('sun'), (0, 0, 1))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 1
floor = plane('sun floor', 0, size=4)
floor.inputs['Base Color'].default_value, floor.inputs['Roughness'].default_value = (1, 1, 1, 1), 1
sun = add(bpy.data.lights.new('sun', 'SUN'), (0, 0, 2)).data
sun.energy, sun.angle = math.pi, 0
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    assert numpy.isclose(render().mean(), 1, rtol=0.01), f'parallel sun {device}'

# A mesh renders with the UV map marked for rendering, as in Cycles, not the one selected for editing: a plane's render
# map of a quarter everywhere is the one it exports
scene = new('render uv')
bpy.context.window.scene = scene
scene.camera = add(bpy.data.cameras.new('render uv'), (0, 0, 2))
plane('render uv', 0, 0)
mesh = bpy.data.meshes['render uv']
quarter = mesh.uv_layers.new(name='render')
quarter.uv.foreach_set('vector', [0.25] * 2 * len(mesh.loops))
quarter.active_render, mesh.uv_layers.active = True, mesh.uv_layers[0]  # The grid's own UVs selected
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
piped = exporter.requests.getvalue()
header = numpy.frombuffer(piped, 'I', count=11)  # Mesh triangles, after the instances and four columns before UVs
assert numpy.all(numpy.frombuffer(piped, 'f', count=6 * header[8], offset=44 + 172 * header[9] + 36 * 4 * header[8])
    == 0.25), 'render uv map'

# A chain of mixes, each multiplying the last into itself at a factor of a half, which keeps it in both of the mix's
# terms, shares the first one's expression 2^20 times: folding, keying and summarizing each shared part once, and
# emitting its steps by keys hashed once, its export takes linear time, not exponential
scene = new('chain')
bpy.context.window.scene = scene
scene.camera = add(bpy.data.cameras.new('chain'), (0, 0, 2))
chain = plane('chain', 0, 0)
last = chain.id_data.nodes.new('ShaderNodeTexNoise').outputs['Color']
for _ in range(20):
    mix = chain.id_data.nodes.new('ShaderNodeMix')  # Its color sockets: A 6, B 7, the result 2
    mix.data_type, mix.blend_type, mix.inputs[7].default_value = 'RGBA', 'MULTIPLY', (0.9, 0.8, 0.7, 1)
    mix.inputs['Factor'].default_value = 0.5  # 1 by default, whose fold leaves the last in one term alone
    chain.id_data.links.new(last, mix.inputs[6])
    last = mix.outputs[2]
chain.id_data.links.new(last, chain.inputs['Base Color'])
start = time.perf_counter()
Viewport.engine.start(types.SimpleNamespace(visible=(), requests=io.BytesIO()), bpy.context.evaluated_depsgraph_get())
assert time.perf_counter() - start < 1, 'shared expressions once'
# An image read at a point of such a chain on the UV: measuring how fast the point moves along the UV, its parts
# taken at a UV each once and shared still, its export takes linear time too
read = plane('read', 2, 0)
last = read.id_data.nodes.new('ShaderNodeTexCoord').outputs['UV']
for _ in range(20):
    mix = read.id_data.nodes.new('ShaderNodeMix')
    mix.data_type, mix.blend_type, mix.inputs[7].default_value = 'RGBA', 'MULTIPLY', (0.9, 0.8, 0.7, 1)
    mix.inputs['Factor'].default_value = 0.5
    read.id_data.links.new(last, mix.inputs[6])
    last = mix.outputs[2]
image = read.id_data.nodes.new('ShaderNodeTexImage')
image.image = texture.image
read.id_data.links.new(last, image.inputs['Vector'])
read.id_data.links.new(image.outputs['Color'], read.inputs['Base Color'])
start = time.perf_counter()
Viewport.engine.start(types.SimpleNamespace(visible=(), requests=io.BytesIO()), bpy.context.evaluated_depsgraph_get())
assert time.perf_counter() - start < 1, 'shared points once'

# Classroom's schoolDesk_wood rebuilt: one image three times under mappings and curves, mixed by the object's random
# number, overlaid with a color attribute and bumping its diffuse shader by the mix. It keeps 37 values for reuse but
# never more than 6 at once, so its slots are taken again as their last loads pass, and it exports and renders
scene = new('slots')
bpy.context.window.scene = scene
scene.camera = add(bpy.data.cameras.new('slots'), (0, 0, 2))
desk = plane('desk', 0, 0)
tree, mesh = desk.id_data, bpy.data.objects['desk'].data
tree.nodes.remove(desk)
mesh.color_attributes.new('Col', 'BYTE_COLOR', 'CORNER').data.foreach_set('color',
    numpy.random.default_rng(1).uniform(0, 1, 4 * len(mesh.loops)).astype('f'))
wood = bpy.data.images.new('wood', 8, 8)
wood.pixels.foreach_set(numpy.random.default_rng(2).uniform(0, 1, 4 * 64).astype('f'))
node = tree.nodes.new
link = lambda a, b: tree.links.new(a, b)
uv, info = node('ShaderNodeTexCoord').outputs['UV'], node('ShaderNodeObjectInfo').outputs['Random']
curves = []
for location, rotation, scale, points in (((0, 0, 0), (0, 0, 0), 0.9, ((0.518, 0.556), None, (0.527, 0.456), None)),
        ((0, 1.6, 0), (0, 0, 0), 0.8, ((0.518, 0.55), None, (0.523, 0.512), None)),
        ((0.7, 0, 0), (0.0349, 0, 0), 0.85, ((0.518, 0.556), None, (0.523, 0.512), (0.455, 0.425)))):
    mapping, image, curve = node('ShaderNodeMapping'), node('ShaderNodeTexImage'), node('ShaderNodeRGBCurve')
    mapping.vector_type, image.image, curve.inputs['Fac'].default_value = 'TEXTURE', wood, 0.9
    mapping.inputs['Location'].default_value, mapping.inputs['Rotation'].default_value = location, rotation
    mapping.inputs['Scale'].default_value = (scale, scale, 1)
    for k, point in enumerate(points):
        if point: curve.mapping.curves[k].points.new(*point)
    curve.mapping.update()
    link(uv, mapping.inputs['Vector']), link(mapping.outputs['Vector'], image.inputs['Vector'])
    link(image.outputs['Color'], curve.inputs['Color']), curves.append(curve.outputs['Color'])
mixes = []  # Of the mixes' color sockets: A 6, B 7, the result 2
for operation, threshold, a, b in (('LESS_THAN', 0.33, curves[0], curves[1]), ('GREATER_THAN', 0.66, None, curves[2])):
    math_, mix = node('ShaderNodeMath'), node('ShaderNodeMix')
    math_.operation, math_.inputs[1].default_value, mix.data_type = operation, threshold, 'RGBA'
    link(info, math_.inputs[0]), link(math_.outputs[0], mix.inputs['Factor'])
    link(a or mixes[-1], mix.inputs[6]), link(b, mix.inputs[7])
    mixes.append(mix.outputs[2])
overlay, attribute, bump, diffuse = (node(kind) for kind in ('ShaderNodeMix', 'ShaderNodeAttribute', 'ShaderNodeBump',
    'ShaderNodeBsdfDiffuse'))
overlay.data_type, overlay.blend_type, overlay.inputs['Factor'].default_value = 'RGBA', 'OVERLAY', 0.5
attribute.attribute_name, bump.inputs['Distance'].default_value = 'Col', 0.1
link(mixes[1], overlay.inputs[6]), link(attribute.outputs['Color'], overlay.inputs[7])
link(mixes[1], bump.inputs['Strength']), link(overlay.outputs[2], diffuse.inputs['Color'])
link(bump.outputs['Normal'], diffuse.inputs['Normal'])
link(diffuse.outputs['BSDF'], tree.get_output_node('CYCLES').inputs['Surface'])
Viewport.engine.start(types.SimpleNamespace(visible=(), requests=io.BytesIO()), bpy.context.evaluated_depsgraph_get())
pixels = render()
assert numpy.isfinite(pixels).all() and pixels.mean() > 0, 'values a program keeps for reuse'

# Values kept past the slots: 32 parts of a noise of the camera's point, which nothing bakes, summed into a height
# displacing by bump and summed again, the other way round, into the base color, live from the normal's bump, emitted
# first, to the base color: more at once than the slots hold. Those kept longest are computed again where read, so it
# exports, and renders as its sums folded, the noise
spill = plane('spill', 3, 0)
tree = spill.id_data
bpy.data.objects['spill'].active_material.displacement_method = 'BUMP'
noise, displacement = tree.nodes.new('ShaderNodeTexNoise'), tree.nodes.new('ShaderNodeDisplacement')
tree.links.new(tree.nodes.new('ShaderNodeTexCoord').outputs['Camera'], noise.inputs['Vector'])
noise = noise.outputs['Fac']
tree.links.new(displacement.outputs[0], tree.get_output_node('CYCLES').inputs['Displacement'])
def total(sockets):  # Their sum, in their order
    for socket in sockets[1:]:
        part = tree.nodes.new('ShaderNodeMath')
        tree.links.new(sockets[0], part.inputs[0]), tree.links.new(socket, part.inputs[1])
        sockets = [part.outputs[0]]
    return sockets[0]
parts = []
for k in range(1, 33):
    part = tree.nodes.new('ShaderNodeMath')
    part.operation, part.inputs[1].default_value = 'MULTIPLY', k / 528  # Summing to the noise
    tree.links.new(noise, part.inputs[0]), parts.append(part.outputs[0])
tree.links.new(total(parts), displacement.inputs['Height'])
tree.links.new(total(parts[::-1]), spill.inputs['Base Color'])
scene.camera.location.x = 3
kept = render()
tree.links.new(noise, displacement.inputs['Height']), tree.links.new(noise, spill.inputs['Base Color'])
folded = render()
assert numpy.allclose(kept, folded, atol=2e-3), ('values computed again past the slots',
    float(abs(kept - folded).max()))

# Flex keeps its scene between an animation's frames, each reaching the renderer as an update of what changed and
# rendering exactly as a fresh export of it does: in three jobs of two frames, as Blender updates whatever is animated
# every frame, a move, a material's value, then a deformation, a light's change and objects removed and added. The
# user's persistent data reads as it was, during the job too, so saved files never hold Flex's; the engine is let go
# once a job is done or cancelled; and a user's own persistent data stays on
scene = new('frames')
bpy.context.window.scene = scene
scene.camera = add(bpy.data.cameras.new('frames'), (0, 0, 2))
scene.flex_samples, scene.flex_restir, scene.flex_denoise = 16, False, False  # No reservoirs carried between frames
scene.frame_start, scene.frame_end = 1, 2
bpy.context.preferences.edit.keyframe_new_interpolation_type = 'CONSTANT'
tinted = [plane(name, x, y, 0.8) for name, x, y in (('moving', -0.5, 0.5), ('tinted', 0.5, 0.5),
    ('bending', -0.5, -0.5), ('leaving', 0.5, -0.5), ('arriving', 0.5, -0.5))][1]
lamp = add(bpy.data.lights.new('lamp', 'POINT'), (0, 0, 1))
sealed = plane('sealed', 0, 0, 0.4)  # Subsurface on a sheet a modifier closes, filled as a fresh export fills it
bpy.data.objects['sealed'].location.z = 0.2
bpy.data.objects['sealed'].modifiers.new('solid', 'SOLIDIFY').thickness = 0.1
sealed.inputs['Subsurface Weight'].default_value, sealed.inputs['Subsurface Scale'].default_value = 1, 0.1
bent = bpy.data.objects['bending']
bent.shape_key_add(name='basis'), bent.shape_key_add(name='bent')
for point in bent.data.shape_keys.key_blocks['bent'].data: point.co.z = 0.3 * point.co.x
bpy.data.objects['arriving'].hide_render = True
def keys(owner, name, *values):  # Its value at the job's two frames
    for frame, value in enumerate(values, 1):
        setattr(owner, name, value)
        owner.keyframe_insert(name, frame=frame)
kinds, engines, start = [], [], flex.Flex.start  # The kind of each message an export pipes, and the engines exporting
def tapped(self, depsgraph):
    pipe, engines[len(engines):] = self.requests, [weakref.ref(self)]
    self.requests = types.SimpleNamespace(writelines=lambda parts: (kinds.append(struct.unpack('<I', (parts := [
        *parts])[0][:4])[0]), pipe.writelines(parts)))
    start(self, depsgraph)
    self.requests = pipe
during = []  # The flag as each frame renders, and a file saved then
def saving(scene, *_): during.append(scene.render.use_persistent_data), bpy.data.libraries.write(
    bpy.app.tempdir + 'during.blend', {scene})
for animate, expected in ((lambda: (keys(bpy.data.objects['moving'], 'location', (-0.5, 0.5, 0), (-0.3, 0.5, 0)),
        keys(bpy.data.objects['moving'], 'rotation_euler', (0, 0, 0), (0.3, 0.2, 0.5)),
        keys(bpy.data.objects['moving'], 'scale', (1, 1, 1), (1, 1.5, 1))), flex.UPDATE),
        (lambda: keys(tinted.inputs['Base Color'], 'default_value', (0.8, 0.2, 0.1, 1),
        (0.1, 0.6, 0.2, 1)), flex.STEPS), (lambda: keys(sealed.inputs['Base Color'], 'default_value',
        (0.8, 0.8, 0.8, 1), (0.3, 0.6, 0.9, 1)), flex.STEPS), (lambda: (keys(bent.data.shape_keys.key_blocks['bent'],
        'value', 0, 1),
        keys(lamp.data, 'energy', 20, 40), keys(lamp.data, 'color', (1, 1, 1), (1, 0.5, 0.2)),
        keys(bpy.data.objects['leaving'], 'hide_render', False, True),
        keys(bpy.data.objects['arriving'], 'hide_render', True, False)), flex.SCENE)):
    for animated in (*bpy.data.objects, *bpy.data.materials, *bpy.data.lights, *bpy.data.shape_keys):
        animated.animation_data_clear()  # The last job's values held, unanimated
    animate()
    fresh = []  # Each frame exported anew, its own job, which nothing persists without the handler that sets it
    bpy.app.handlers.render_init.remove(flex.persist)
    for frame in (1, 2):
        scene.frame_set(frame)
        fresh.append(render())
    bpy.app.handlers.render_init.append(flex.persist)
    kinds[:], engines[:], during[:], flex.Flex.start = [], [], [], tapped
    bpy.app.handlers.render_post.append(saving)
    bpy.ops.render.render(animation=True, scene=scene.name)
    bpy.app.handlers.render_post.remove(saving)
    flex.Flex.start = start
    frames = [numpy.array(bpy.data.images.load(scene.render.frame_path(frame=frame)).pixels).reshape(SIZE, SIZE,
        4)[..., :3] for frame in (1, 2)]
    assert kinds == [flex.SCENE, expected] and len({engine() for engine in engines}) == 1, f'frames kept {expected}'
    assert all(map(numpy.array_equal, frames, fresh)), f'frames as exported anew {expected}'
    with bpy.data.libraries.load(bpy.app.tempdir + 'during.blend') as (_, saved): saved.scenes = [scene.name]
    assert during == [False] * 2 and not any(s.render.use_persistent_data for s in (scene, saved.scenes[0])), \
        f'user persistent data {expected}'
    gc.collect()
    assert not engines[0](), f'engine released {expected}'
flex.persist(scene)
for handler in bpy.app.handlers.render_cancel: handler(scene)
assert not scene.render.use_persistent_data and flex.release in bpy.app.handlers.render_cancel, 'cancel restores'
scene.render.use_persistent_data, engines[:], flex.Flex.start = True, [], tapped
render()
flex.Flex.start = start
gc.collect()
assert scene.render.use_persistent_data and engines[0](), 'user persistent data kept'
scene.render.use_persistent_data = False

# An orthographic view projects in parallel: two unit squares, one 3 units further, cover alike (64 / 3)^2 pixels in a
# final render through an ORTHO camera and in an orthographic viewport, which as in modeling sees behind its pivot too
scene = new('ortho')
bpy.context.window.scene = scene
scene.camera = add(bpy.data.cameras.new('ortho'), (0, 0, 2))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 3
for name, location, size in (('near', (-0.6, 0, 0), 1), ('far', (0.6, 0, -3), 1), ('behind', (0, 0.9, 3), 0.4)):
    square = plane(name, 0, 0, size)
    square.inputs['Base Color'].default_value, square.inputs['Emission Strength'].default_value = (0, 0, 0, 1), 1
    bpy.data.objects[name].location = location
def lit(image):  # Pixels of the near and the far square, rows from the bottom below the one behind, and of that one
    bright = image[..., :3].mean(-1) > 0.5
    return int(bright[:45, :SIZE // 2].sum()), int(bright[:45, SIZE // 2:].sum()), int(bright[45:].sum())
area = (SIZE / 3) ** 2
final = lit(render())
assert all(abs(n - area) < 0.1 * area for n in final[:2]), f'ortho camera {final}'
bpy.context.view_layer.update()
depsgraph, viewport = bpy.context.evaluated_depsgraph_get(), Viewport()
near, far = -50, 100  # A viewport's orthographic clip range, its start behind the view
window = Matrix(((2 / 3, 0, 0, 0), (0, 2 / 3, 0, 0), (0, 0, -2 / (far - near), -(far + near) / (far - near)),
    (0, 0, 0, 1)))
context = types.SimpleNamespace(region=region, region_data=types.SimpleNamespace(view_matrix=Matrix.Translation(
    (0, 0, -2)), window_matrix=window, view_perspective='ORTHO'),
    space_data=types.SimpleNamespace(camera=None, clip_end=1000))
with offscreen.bind():
    gpu.matrix.load_matrix(Matrix.Identity(4))
    gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE, 2 / SIZE, 1, 1)))
    viewport.view_update(context, depsgraph)
    viewport.view_draw(context, depsgraph)
    while viewport.__dict__.pop('redraw', False): viewport.view_draw(context, depsgraph)
    drawn = numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0, 'FLOAT').to_list())
drawn = lit(drawn)
assert all(abs(n - area) < 0.1 * area for n in drawn[:2]) and drawn[2] > 0.5 * (0.4 * SIZE / 3) ** 2, \
    f'ortho viewport {drawn}'

# Flex offers Blender's shading nodes, shows the panels whose settings it reads, hides those it ignores, and draws its
# own of what it reads of a light and of an object's visibility, each property one the export reads
assert getattr(flex.Flex, 'bl_use_shading_nodes_custom', True) is False, 'shading nodes offered'
shown = lambda name: flex.Flex.bl_idname in getattr(bpy.types, name).COMPAT_ENGINES
assert all(map(shown, ('RENDER_PT_format', 'RENDER_PT_color_management', 'RENDER_PT_post_processing',
    'RENDER_PT_simplify', 'DATA_PT_uv_texture', 'DATA_PT_shape_keys', 'EEVEE_MATERIAL_PT_volume',
    'EEVEE_WORLD_PT_surface', 'DATA_PT_context_light'))), 'panels shown'
assert not any(map(shown, ('RENDER_PT_stereoscopy', 'DATA_PT_camera_stereoscopy', 'RENDER_PT_stamp',
    'RENDER_PT_time_stretching', 'MATERIAL_PT_preview', 'NODE_PT_texture_mapping', 'DATA_PT_EEVEE_light'))), 'hidden'
class Layout(types.SimpleNamespace):  # Records the properties a panel draws
    def __getattr__(self, name): return (lambda *args, **kwargs: self.drawn.append(args[1])) if name == 'prop' \
        else lambda *args, **kwargs: self
def drawn(panel, **context):
    panel.draw(types.SimpleNamespace(layout=(layout := Layout(drawn=[]))), types.SimpleNamespace(**context))
    return layout.drawn
for kind, read in (('POINT', ['shadow_soft_size']), ('SPOT', ['shadow_soft_size', 'spot_size']), ('SUN', ['angle']),
        ('AREA', ['shape', 'size', 'size_y'])):
    light = bpy.data.lights.new(kind, kind)
    if kind == 'AREA': light.shape = 'RECTANGLE'
    assert drawn(flex.DATA_PT_flex_light, light=light) == ['type', 'color', 'energy', *read], ('light read', kind)
assert drawn(flex.OBJECT_PT_flex_visibility, object=bpy.data.objects[0]) == ['hide_viewport', 'hide_render',
    'visible_camera'], 'visibility read'

# Camera rays start at the clip start: an emitter shows through a perspective camera past a black plane nearer than it.
# And they start in the volume there, not the camera's: in an absorbing cube with the near plane below it, through
# either camera, a floor shines unattenuated. And they end at the clip end: the emitter past it vanishes from either,
# and past a perspective one's at a clip range as wide as 1e6. On both backends
scene = new('clip')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
scene.flex_samples = 64
scene.camera = add(bpy.data.cameras.new('clip'), (0, 0, 2))
plane('wall', 0, 0, 4).inputs['Base Color'].default_value = (0, 0, 0, 1)
glow = plane('glow', 0, 0, 8)
glow.inputs['Base Color'].default_value, glow.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
glow.inputs['Emission Strength'].default_value = 1
murk = shape('murk', lambda bm: bmesh.ops.create_cube(bm, size=2), (0, 0, 0)).id_data
murk.nodes.remove(murk.nodes['Principled BSDF'])
absorb = murk.nodes.new('ShaderNodeVolumeAbsorption')
absorb.inputs['Color'].default_value, absorb.inputs['Density'].default_value = (0.2, 0.2, 0.2, 1), 2
murk.links.new(absorb.outputs[0], murk.nodes['Material Output'].inputs['Volume'])
wall, glow, cube, camera = (bpy.data.objects[name] for name in ('wall', 'glow', 'murk', 'clip'))
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    wall.location.z, wall.hide_render, glow.location.z, cube.hide_render = 1.5, False, -1, True
    camera.location.z, camera.data.type, camera.data.clip_start, camera.data.clip_end = 2, 'PERSP', 1, 100
    assert abs(render().mean() - 1) < 0.05, f'clip start {device}'
    wall.hide_render, glow.location.z, cube.hide_render = True, -2, False
    camera.location.z, camera.data.clip_start = 0.9, 2
    for kind in ('ORTHO', 'PERSP'):
        camera.data.type = kind
        assert abs(render().mean() - 1) < 0.05, f'medium at the near plane {kind} {device}'
    glow.location.z, cube.hide_render = -1, True
    camera.location.z, camera.data.clip_start, camera.data.clip_end = 2, 0.1, 2
    for kind in ('ORTHO', 'PERSP'):
        camera.data.type = kind
        assert render().mean() < 0.05, f'clip end {kind} {device}'
    camera.data.clip_start, camera.data.clip_end, glow.location.z, glow.scale = 1e-3, 1000, -1018, (100, 100, 1)
    assert render().mean() < 0.05, f'clip end of a wide range {device}'
    glow.scale = (1, 1, 1)

# Instances of one mesh pipe its arrays once: a collection instanced three times, one of them turned and stretched,
# exports one mesh and three instances, and renders exactly as three copies of their own of it do, which the renderer
# expands alike
scene = new('instances')
bpy.context.window.scene = scene
scene.camera = add(bpy.data.cameras.new('instances'), (0, 0, 2))
plane('shared', 0, 0, 0.4)
shared, ob = bpy.data.collections.new('shared'), bpy.data.objects['shared']
scene.collection.objects.unlink(ob), shared.objects.link(ob)
empties = [bpy.data.objects.new(f'instance {x}', None) for x in (-0.5, 0, 0.5)]
for empty, x in zip(empties, (-0.5, 0, 0.5)):
    empty.instance_type, empty.instance_collection, empty.location = 'COLLECTION', shared, (x, 0, 0)
    scene.collection.objects.link(empty)
empties[2].rotation_euler, empties[2].scale = (0.3, 0.2, 0.5), (1, 1.5, 1)
exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
header = numpy.frombuffer(exporter.requests.getvalue(), 'I', count=10)
assert header[0] == flex.SCENE and (header[1], header[8], header[9]) == (6, 2, 3), 'mesh piped once'
instanced = render()
for empty in empties:
    copy = bpy.data.objects.new('copy', ob.data.copy())  # Placed as the empty, as the mesh sits at the origin
    copy.location, copy.rotation_euler, copy.scale = empty.location, empty.rotation_euler, empty.scale
    scene.collection.objects.link(copy)
    empty.hide_render = True
assert numpy.array_equal(instanced, render()), 'instances as copies'
