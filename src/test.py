# End-to-end test, run by make test: renders a lit plane, half colored and half textured, and a textured emitter under a
# sky with Flex through a render border and checks the pixels, then draws the same view through the engine's viewport
# methods and compares.
import bpy, bmesh, bpy_extras.object_utils, gc, gpu, io, math, numpy, os, struct, subprocess, sys, threading, time, types
import weakref, zlib
from mathutils import Color, Matrix, Vector

SIZE = 64
COLOR = (0.8, 0.2, 0.1)
TEXELS = ((1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 1))  # 2x2 texture, bottom row first
SKY = (0.1, 0.2, 0.4)

def new(name, size=SIZE, samples=256, sky=SKY):  # Scene Flex renders into an EXR, size x size pixels, under the sky
    scene = bpy.data.scenes.new(name)
    scene.render.engine = 'FLEX'
    scene.render.resolution_x = scene.render.resolution_y = size
    scene.flex_samples = samples
    scene.render.image_settings.file_format = 'OPEN_EXR'
    scene.render.filepath = bpy.app.tempdir + name + '.exr'
    scene.world = bpy.data.worlds.new('sky')
    scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (*sky, 1)
    return scene

scene = new('test')
scene.render.use_border = True
scene.render.border_max_y = 0.875  # Leaves the top eighth unrendered

def opened(name, sky=SKY):  # A new scene, the window's
    bpy.context.window.scene = made = new(name, sky=sky)
    return made

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
    data.shade_smooth()  # The colored plane's normals slightly off the face
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

def render(rendered=None, size=SIZE):  # The scene rendered, or the one given at its size, its pixels' colors
    rendered = rendered or scene
    bpy.ops.render.render(scene=rendered.name, write_still=True)
    return numpy.array(bpy.data.images.load(rendered.render.filepath).pixels).reshape(size, size, 4)[..., :3]

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
# Reflecting nothing, as in Cycles: to the float noise of its evaluation, under 1e-31 where the sky lights it alone
for y in (2, 10): assert pixels[y:y + 4, 56:60].max() < 1e-20, 'black'
lit = pixels[18:46, 2:30].sum(2)  # Light sampling leaves no pixel of the colored plane dark or far off its neighbors
assert lit.min() > 0.5 * lit.mean() and lit.max() < 2 * lit.mean(), 'lighting'
# Hidden from the camera wherever it sees straight: an emitter of radiance 1 under clear glass of IOR 1, which bends no
# ray, or a cutout reads 1 seen and 0 hidden from the camera
veil = new('veil', 16, 16, (0, 0, 0))
for name, z in (('veiled', 0), ('veil', 0.5)):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=2)
    bm.to_mesh(mesh)
    mesh.materials.append(bpy.data.materials.new(name))
    veil.collection.objects.link(bpy.data.objects.new(name, mesh))
    bpy.data.objects[name].location.z = z
glass = bpy.data.materials['veil'].node_tree.nodes['Principled BSDF']
glass.inputs['Base Color'].default_value, glass.inputs['Transmission Weight'].default_value = (1, 1, 1, 1), 1
glass.inputs['IOR'].default_value, glass.inputs['Roughness'].default_value = 1, 0
glowing = bpy.data.materials['veiled'].node_tree.nodes['Principled BSDF']
glowing.inputs['Base Color'].default_value, glowing.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
glowing.inputs['Emission Strength'].default_value = 1
veil.camera = bpy.data.objects.new('veil camera', bpy.data.cameras.new('veil camera'))
veil.collection.objects.link(veil.camera)
veil.camera.location, veil.camera.data.angle = (0, 0, 1), math.pi / 2
for kind in ('glass', 'cutout'):  # The cutout of alpha 0, which rays pass straight through as well
    if kind == 'cutout': glass.inputs['Transmission Weight'].default_value, glass.inputs['Alpha'].default_value = 0, 0
    for hidden in (False, True):
        bpy.data.objects['veiled'].visible_camera = not hidden
        seen = render(veil, 16)[4:12, 4:12].mean()
        assert abs(seen - (0 if hidden else 1)) < 0.02, ('veil', kind, hidden, seen)
# And past the faces of a volume, scattering nothing: of density 0, or absorbing 1 per unit length over its depth of 0.6,
# where the emitter reads exp(-0.6) seen, along the rays near the middle the window takes, and 0 hidden; at 256
# samples, where Russian roulette spreads the absorber's read by about 0.008
bpy.data.objects['veil'].hide_render = True
mesh = bpy.data.meshes.new('veil box')
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1)
bm.to_mesh(mesh)
mesh.materials.append(fill := bpy.data.materials.new('veil box'))
fill.node_tree.nodes.remove(fill.node_tree.nodes['Principled BSDF'])
absorber = fill.node_tree.nodes.new('ShaderNodeVolumeAbsorption')
absorber.inputs['Color'].default_value = (0, 0, 0, 1)
fill.node_tree.links.new(absorber.outputs[0], fill.node_tree.nodes['Material Output'].inputs['Volume'])
veil.collection.objects.link(box := bpy.data.objects.new('veil box', mesh))
box.location, box.scale = (0, 0, 0.5), (4, 4, 0.6)
veil.flex_samples = 256
for density, passed in ((0, 1), (1, math.exp(-0.6))):
    absorber.inputs['Density'].default_value = density
    for hidden in (False, True):
        bpy.data.objects['veiled'].visible_camera = not hidden
        seen = render(veil, 16)[6:10, 6:10].mean()
        assert abs(seen - (0 if hidden else passed)) < 0.03, ('veil', density, hidden, seen)
# A Volume Coefficients node absorbs by its coefficients per unit length as given: absorbing (1, 2, 3) and scattering
# nothing over the depth of 0.6, the emitter reads exp(-0.6 (1, 2, 3)) per channel
bpy.data.objects['veiled'].visible_camera = True
coefficients = fill.node_tree.nodes.new('ShaderNodeVolumeCoefficients')
coefficients.inputs['Absorption Coefficients'].default_value = (1, 2, 3)
coefficients.inputs['Scatter Coefficients'].default_value = (0, 0, 0)
fill.node_tree.links.new(coefficients.outputs[0], fill.node_tree.nodes['Material Output'].inputs['Volume'])
seen = render(veil, 16)[6:10, 6:10].mean((0, 1))
assert numpy.allclose(seen, numpy.exp(-0.6 * numpy.array((1, 2, 3))), atol=0.03), ('volume coefficients', seen)

class Viewport:  # Stands in for the engine instance Blender creates for a viewport, which background mode has none of
    engine = bpy.types.RenderEngine.bl_rna_get_subclass_py('FLEX')
    start = engine.start
    restart = engine.restart
    trace = engine.trace
    view_update = engine.view_update
    view_draw = engine.view_draw
    visible = ()
    shared = open(os.memfd_create('flex'), 'rb', 0)
    __init__ = engine.spawn
    def tag_redraw(self): self.redraw = True
    def bind_display_space_shader(self, scene): pass
    def unbind_display_space_shader(self): pass

def exported(depsgraph=None):  # An exporter stand-in, the scene piped into its requests from the depsgraph
    exporter = types.SimpleNamespace(visible=(), requests=io.BytesIO())
    Viewport.engine.start(exporter, depsgraph or bpy.context.evaluated_depsgraph_get())
    return exporter

def repiped(exporter, depsgraph):  # The exporter's scene piped anew from the depsgraph, its slots kept
    exporter.visible, exporter.requests = (), io.BytesIO()
    Viewport.engine.start(exporter, depsgraph)

def updated(depsgraph, id, **flags):  # A depsgraph stand-in updating the id alone, moved, unless the flags given say
    return types.SimpleNamespace(scene_eval=depsgraph.scene_eval, object_instances=depsgraph.object_instances,
        updates=[types.SimpleNamespace(id=id, **{'is_updated_geometry': False, 'is_updated_transform': True,
        'is_updated_shading': False, **flags})])

# EEVEE's specular shader resolves to a surface of its base color with a dielectric's specular reflection, not black
specular = bpy.data.materials.new('specular').node_tree
specular.links.new(specular.nodes.new('ShaderNodeEeveeSpecular').outputs[0],
    specular.nodes['Material Output'].inputs['Surface'])
module = Viewport.engine.start.__globals__
surface = module['fold'](module['resolve'](specular.nodes['Material Output'].inputs['Surface']))
assert numpy.any(surface[1]) and numpy.all(surface[6] == 1.5), 'eevee specular'
# One render starts one renderer per engine, though Blender calls an engine's constructor twice
def spawns():  # One renderer per engine
    counts, spawn = {}, Viewport.engine.spawn
    def counted(engine): counts[id(engine)] = counts.get(id(engine), 0) + 1; spawn(engine)
    Viewport.engine.spawn = counted
    made = new('spawns', 4, 1)
    made.collection.objects.link(camera := bpy.data.objects.new('spawns', bpy.data.cameras.new('spawns')))
    made.camera = camera
    render(made, 4)
    Viewport.engine.spawn = spawn
    assert list(counts.values()) == [1], ('renderers per engine', counts)
spawns()
# A varying volume's majorant bounds its extinction everywhere in its box: densities of sines, cosines, a divisor of one
# sign, floors, fractions, comparisons and absolute values of 7 (x + 0.07) at the generated x, against the extinction
# the CPU shades at 10,000 points of the box; of 0.5 (x + 0.07), where sines and cosines have no extremum, by their
# ends alone, as tight as the points reach; a divisor reaching 0 has none, which makes its export raise
bounded = bpy.data.materials.new('bounded').node_tree
x, shifted, scaled, step = (bounded.nodes.new(kind) for kind in ('ShaderNodeSeparateXYZ', *3 * ('ShaderNodeMath',)))
absorber = bounded.nodes.new('ShaderNodeVolumeAbsorption')
for a, b in ((bounded.nodes.new('ShaderNodeTexCoord').outputs['Generated'], x.inputs[0]), (x.outputs[0],
        shifted.inputs[0]), (shifted.outputs[0], scaled.inputs[0]), (scaled.outputs[0], step.inputs[0]),
        (step.outputs[0], absorber.inputs['Density']), (absorber.outputs[0],
        bounded.nodes['Material Output'].inputs['Volume'])):
    bounded.links.new(a, b)
shifted.inputs[1].default_value, scaled.operation = 0.07, 'MULTIPLY'
swapped = lambda e: (('UV',) if e[0] == 'GENERATED' else (e[0], *map(swapped, e[1:]))) if isinstance(e, tuple) else e
uv, boxes = numpy.random.default_rng(0).random((10000, 2)), {'GENERATED': (numpy.zeros(3), numpy.ones(3))}
for operation, by, factor in (('SINE', 1, 7), ('COSINE', 1, 7), ('SINE', 1, 0.5), ('COSINE', 1, 0.5),
        ('DIVIDE', scaled, 7), ('FLOOR', 1, 7), ('FRACT', 1, 7), ('LESS_THAN', 3, 7), ('ABSOLUTE', 1, 7),
        ('DIVIDE', x, 7)):
    step.operation, scaled.inputs[1].default_value = operation, factor
    for link in step.inputs[1].links: bounded.links.remove(link)
    bounded.links.new(by.outputs[0], step.inputs[1]) if by in (scaled, x) else setattr(step.inputs[1], 'default_value',
        by)
    module['SIDE']['volume'] = True
    absorption, density, scatter = module['resolve'](bounded.nodes['Material Output'].inputs['Volume'])[10:13]
    module['SIDE']['volume'] = False
    extinction = 'MULTIPLY', ('SUBTRACT', ('ADD', scatter, 1), absorption), density
    box = module['bounds'](extinction, boxes, {})
    if by is x: assert box is None, 'unbounded divisor'
    else:
        shaded = module['shaded'](swapped(extinction), uv, {None: None}, {})
        assert box is not None and (box[0] <= shaded).all() and (shaded <= box[1]).all(), ('bounded', operation)
        assert factor > 1 or numpy.allclose(box, (shaded.min(0), shaded.max(0)), atol=1e-3), ('ends', operation, box)

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
# zero returns its To Min, as Blender 5.3 does whether its input varies or not
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
assert not isinstance(surface[4], tuple) and numpy.allclose(surface[4], 0.3), 'degenerate range to its To Min'
# Options Flex lacks render as the closest it has: Subsurface Scattering's Burley and Skin as Random Walk, which main
# read with an IOR of 0, as no subsurface; a DirectX normal map as the OpenGL one of its green inverted; a displacement
# alone as its bump. A physical conductor's color is its reflectance at normal incidence, and Principled hair's by
# melanin or absorption its transmittance per hit e^(-2 sigma), sigma by Cycles' source's formulas, at three
# values each
closest = bpy.data.materials.new('closest')
nodes, links, out = closest.node_tree.nodes, closest.node_tree.links, closest.node_tree.nodes['Material Output']
surface_of = lambda node: (links.new(node.outputs[0], out.inputs['Surface']),
    flex.fold(flex.resolve(out.inputs['Surface'])))[1]
scattering = nodes.new('ShaderNodeSubsurfaceScattering')
walk = repr(surface_of(scattering))
for falloff in ('BURLEY', 'RANDOM_WALK_SKIN'):
    scattering.falloff = falloff
    assert repr(surface_of(scattering)) == walk, ('subsurface as random walk', falloff)
diffuse, normal = nodes.new('ShaderNodeBsdfDiffuse'), nodes.new('ShaderNodeNormalMap')
links.new(normal.outputs[0], diffuse.inputs['Normal'])
normal.inputs['Color'].default_value = (0.5, 0.25, 1, 1)
opengl = repr(surface_of(diffuse))
normal.convention, normal.inputs['Color'].default_value = 'DIRECTX', (0.5, 0.75, 1, 1)
assert repr(surface_of(diffuse)) == opengl, 'directx normal map'
links.new(nodes.new('ShaderNodeTexNoise').outputs['Fac'], nodes.new('ShaderNodeDisplacement').inputs['Height'])
links.new(nodes['Displacement'].outputs[0], out.inputs['Displacement'])
links.new(nodes.new('ShaderNodeBsdfDiffuse').outputs[0], out.inputs['Surface'])  # Its normal unmapped, as bumped
programs = [(setattr(closest, 'displacement_method', method), repr(flex.shade(closest, lambda *rows, **marks: (rows,
    marks))))[1] for method in ('BUMP', 'DISPLACEMENT')]
assert 'BUMP' in programs[0] and programs[0] == programs[1], 'displacement as bump'
links.remove(out.inputs['Displacement'].links[0])
metal = nodes.new('ShaderNodeBsdfMetallic')
metal.fresnel_type, metal.inputs['IOR'].default_value, metal.inputs['Extinction'].default_value = \
    'PHYSICAL_CONDUCTOR', (0.2, 1.5, 3), (3.9, 0, 1)
n, k = (numpy.array(metal.inputs[name].default_value) for name in ('IOR', 'Extinction'))
assert numpy.allclose(surface_of(metal)[1], ((n - 1) ** 2 + k ** 2) / ((n + 1) ** 2 + k ** 2)), 'physical conductor'
hair = nodes.new('ShaderNodeBsdfHairPrincipled')
fit = lambda x: ((((0.245 * x + 5.574) * x - 10.73) * x + 2.532) * x - 0.215) * x + 5.969  # As Cycles' source has it
hair.parametrization, hair.inputs['Tint'].default_value = 'MELANIN', (1, 0.5, 0.25, 1)
tint = numpy.array(hair.inputs['Tint'].default_value[:3])
for melanin, redness, roughness in ((0.2, 0, 0.3), (0.5, 0.5, 0.5), (0.8, 1, 0.9)):
    for name, value in (('Melanin', melanin), ('Melanin Redness', redness), ('Radial Roughness', roughness)):
        hair.inputs[name].default_value = value
    m, r, x = (hair.inputs[name].default_value for name in ('Melanin', 'Melanin Redness', 'Radial Roughness'))
    sigma = -numpy.log(max(1 - m, 1e-4)) * ((1 - r) * numpy.array((0.506, 0.841, 1.653)) + r * numpy.array((0.343,
        0.733, 1.924))) + (numpy.log(tint) / fit(x)) ** 2
    assert numpy.allclose(surface_of(hair)[1], numpy.exp(-2 * sigma)), ('hair by melanin', melanin)
hair.parametrization = 'ABSORPTION'
sigma = numpy.array(hair.inputs['Absorption Coefficient'].default_value)
assert numpy.allclose(surface_of(hair)[1], numpy.exp(-2 * sigma)), 'hair by absorption'
# A volume shader's Draine phase reads its α, an input named Alpha, as the phase's alone: the shader covers all of the
# surface, as under Henyey-Greenstein, where main covered a quarter of it
scatter = nodes.new('ShaderNodeVolumeScatter')
henyey = repr(surface_of(scatter))
scatter.phase, scatter.inputs['Alpha'].default_value = 'DRAINE', 0.25
assert repr(surface_of(scatter)) == henyey, 'draine alpha covers nothing'
# A coat mixed or added with a shader without one keeps its coat, of its weight halved, which main dropped
coated = nodes.new('ShaderNodeBsdfPrincipled')
coated.inputs['Coat Weight'].default_value = 0.5
for shader in (nodes.new('ShaderNodeMixShader'), nodes.new('ShaderNodeAddShader')):
    links.new(diffuse.outputs[0], shader.inputs[-2]), links.new(coated.outputs[0], shader.inputs[-1])
    assert numpy.allclose(surface_of(shader)[19][9], 0.25), ('coat mixed', shader.type)
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
# the white one's is
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
    k = width // SIZE
    return render(scene, width)[18 * k:46 * k, 2 * k:30 * k].mean((0, 1))
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
    return render()[24:40, 24:40].mean()
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
bpy.data.meshes['sheet'].normals_split_custom_set([(0.6, 0, 0.8)] * 4)
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
# Light sampling where the estimated diffuse share exceeds 0.04 or roughness exceeds 0.2: metal of roughness 0.3 and
# rough transmission below the face sample lights
scene.camera.data.angle = 0.3
for metallic, transparency, roughness, height in ((1, 0, 0.3, 0.5), (0, 1, 0.6, -0.5)):
    floor.inputs['Metallic'].default_value, floor.inputs['Transmission Weight'].default_value = metallic, transparency
    floor.inputs['Roughness'].default_value, bpy.data.objects['dim'].location.z = roughness, height
    direct = mis_render(0, False)
    assert direct.mean() > 0, 'continuous light sampling'
    for reuse in (False, True):
        pixels = mis_render(1, reuse)
        assert numpy.isclose(pixels.mean(), direct.mean(), rtol=0.02), \
            f'MIS continuous lobes {metallic, transparency, reuse}: {pixels.mean()} vs {direct.mean()}'
# Metal of roughness 0.1 takes no light sample: it gathers its light by its BSDF alone, as much over all bounces as
# light sampling gave it, 0.79955 (16 disjoint images under the former rule; 0.0001 an image)
floor.inputs['Metallic'].default_value, floor.inputs['Transmission Weight'].default_value = 1, 0
floor.inputs['Roughness'].default_value, bpy.data.objects['dim'].location.z = 0.1, 0.5
assert not mis_render(0, False).any(), 'smooth metal samples no light'
gathered = mis_render(bounces, False).mean()
assert abs(gathered - 0.79955) < 0.0005, ('smooth metal by its BSDF', gathered)
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
pixels = render()[24:40, 24:40]
assert (pixels.mean(2) > 0.05).all() and 0.85 < pixels.mean() < 1.01, 'faceted glass internal reflections'
# So does a white metal normal-mapped by noise under the white sky
prism.data, prism.hide_render = flat, True
metal = plane('metal', 0, 0, 2)
metal.inputs['Metallic'].default_value, metal.inputs['Roughness'].default_value = 1, 0.2
relief, mapped = metal.id_data.nodes.new('ShaderNodeTexNoise'), metal.id_data.nodes.new('ShaderNodeNormalMap')
relief.inputs['Scale'].default_value = 8
metal.id_data.links.new(relief.outputs['Color'], mapped.inputs['Color'])
metal.id_data.links.new(mapped.outputs[0], metal.inputs['Normal'])
pixels = render()[24:40, 24:40]
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
# Orthographic, of radius 1 / (2 f-stop): at depth z a circle of radius r |z - F| / F, a disk's variance R^2 / 4 on each
# axis; f-stop 1 and focus 2 blur the emitter 1 away by 0.25, 8 pixels at an ortho scale of 2 over 64
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 2
_, flat, _ = camera_render(use_dof=False, focus_object=None, aperture_blades=0, aperture_rotation=0)
_, blurred, _ = camera_render(use_dof=True, aperture_fstop=1, focus_distance=2)
assert numpy.all(numpy.abs(2 * numpy.sqrt(blurred - flat) / 8 - 1) < 0.1), ('orthographic depth of field', flat, blurred)
scene.camera.data.type = 'PERSP'
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
exporter = exported(depsgraph)
reference.location.x = 1
bpy.context.view_layer.update()
exporter.requests = io.BytesIO()
Viewport.engine.start(exporter, updated(depsgraph, reference))
assert numpy.frombuffer(exporter.requests.getvalue(), 'I', count=1)[0] == flex.SCENE, 'reference coordinates update'
collection = bpy.data.collections.new('instance source')
member = bpy.data.objects.new('instance member', ob.data)
collection.objects.link(member)
instance = bpy.data.objects.new('instancer', None)
scene.collection.objects.link(instance)
instance.instance_type, instance.instance_collection = 'COLLECTION', collection
bpy.context.view_layer.update()
repiped(exporter, depsgraph)
slot = next(i for i, item in enumerate(depsgraph.object_instances)
    if item.is_instance and item.object.original == member)
exporter.requests = io.BytesIO()  # Its transform where it is, as an update pipes it
Viewport.engine.start(exporter, updated(depsgraph, instance))
before = numpy.frombuffer(exporter.requests.getvalue(), 'f')[-21:-9].copy()  # Its transform's rows, before its adjugate
instance.location.x = 1
bpy.context.view_layer.update()
exporter.requests = io.BytesIO()
Viewport.engine.start(exporter, updated(depsgraph, instance))
assert tuple(numpy.frombuffer(exporter.requests.getvalue(), 'I', count=4)) == (flex.UPDATE, 1,
    *exporter.slots[slot][:2]), 'instancer update'
after = numpy.frombuffer(exporter.requests.getvalue(), 'f')[-21:-9]
assert numpy.allclose(after - before, (0, 0, 0, 1) + (0,) * 8), 'instance motion'
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
repiped(exporter, depsgraph)
tables = lambda piped, at: 4 + 44 * int(numpy.frombuffer(piped, 'I', count=1, offset=at)[0])  # Hair's, at at
def generated_of(piped, i):  # Generated coordinates of the mesh entry of instance i, by the scene's instance table
    header, k = numpy.frombuffer(piped, 'I', count=11), [*exporter.slots].index(i)
    instances = 44 + 16 * header[2]  # After the header and the steps, four words each, and the hair tables
    instances += tables(piped, instances)
    first, count = numpy.frombuffer(piped, 'I', count=2, offset=instances + 200 * k)
    return numpy.frombuffer(piped, 'f', count=9 * count, offset=instances + 200 * header[9] + 36 * (2 * header[8]
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
repiped(exporter, depsgraph)
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
# They pipe the triangles Blender renders of them once: those of the meshes they evaluate to, beside which the depsgraph
# lists themselves too
counted = opened('counted')
for ob in made: counted.collection.objects.link(ob)
counting, rendered = bpy.context.evaluated_depsgraph_get(), 0
for item in counting.object_instances:
    if item.object.type == 'MESH':
        rendered += len(item.object.to_mesh().loop_triangles)
        item.object.to_mesh_clear()
repiped(exporter, counting)
assert numpy.frombuffer(exporter.requests.getvalue(), 'I', count=9)[8] == rendered > 0, 'curves piped once'
bpy.context.window.scene = scene
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
exporter = exported(depsgraph := bpy.context.evaluated_depsgraph_get())
bakes = numpy.frombuffer(exporter.requests.getvalue(), 'I', count=6)[5]
assert bakes == len(getattr(exporter, 'placed', ())) > 0, 'bakes'
bpy.data.objects['edge'].location.x, exporter.requests = 0.1, io.BytesIO()
bpy.context.view_layer.update()
Viewport.engine.start(exporter, updated(depsgraph, bpy.data.objects['edge']))
assert numpy.frombuffer(exporter.requests.getvalue(), 'I', count=1)[0] == flex.UPDATE, 'motion bakes nothing'
# A value edited, its linked duplicate beside it, steps go anew: the duplicate's rows are the plane's, as exported,
# where main gave it a row of its own and exported anew
twin, material = bpy.data.objects['edge'].copy(), bpy.data.objects['edge'].active_material
scene.collection.objects.link(twin), bpy.context.view_layer.update()
exporter = exported()
exporter.start, exporter.requests = lambda depsgraph: Viewport.engine.start(exporter, depsgraph), io.BytesIO()
edge.inputs['Roughness'].default_value += 0.1
Viewport.engine.start(exporter, types.SimpleNamespace(scene_eval=depsgraph.scene_eval,
    object_instances=bpy.context.evaluated_depsgraph_get().object_instances, updates=[types.SimpleNamespace(id=material,
    is_updated_geometry=False, is_updated_transform=False)]))
assert numpy.frombuffer(exporter.requests.getvalue(), 'I', count=1)[0] == flex.STEPS, 'linked duplicate updates steps'
edge.inputs['Roughness'].default_value -= 0.1
bpy.data.objects.remove(twin)
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
exporter = exported()  # Exporting anew, not updating values
assert exporter.placed and not any('steps' in str(key) for _, key, *_ in exporter.placed), 'image reads stay live'
# A procedural specular tint bakes inside its mark, which stays live for the shader to keep the tint
links.new(noise.outputs['Color'], edge.inputs['Specular Tint'])
exporter = exported()
assert exporter.placed and not any('SPECULAR' in str(key) for _, key, *_ in exporter.placed), 'specular mark live'
# So does a procedural translucent color, which stays live for the shader to transmit it
through = edge.id_data.nodes.new('ShaderNodeBsdfTranslucent')
output = edge.id_data.nodes['Material Output'].inputs['Surface']
links.new(noise.outputs['Color'], through.inputs['Color']), links.new(through.outputs[0], output)
exporter = exported()
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
    exporter = exported()
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
# A mirrored image's bake, past its edge where the doubled UV reads its reflection, renders as its read live, all but 1%
# of pixels within 0.0018 as above: main planned its bake from an extended read, so it didn't bake once repeating
image.extension, exporter = 'MIRROR', types.SimpleNamespace(visible=(), requests=io.BytesIO())
Viewport.engine.start(exporter, bpy.context.evaluated_depsgraph_get())
assert [key[0] for _, key, *_ in exporter.placed] == [None], 'mirrored image bakes'
baked, module['BAKE_TOLERANCE'] = render(), -1  # Every bake strays
assert numpy.percentile(numpy.abs(render() - baked).max(-1), 99) < 0.0018, 'baked mirror'
image.extension, module['BAKE_TOLERANCE'] = 'REPEAT', tolerance
# A repeating bake read below the corner it was planned at, on both backends as live renders it: a plane before the
# edge, its UVs 1.37 lower, reads the power's bake of an image 1023 texels wide where the camera looks, at points that
# wrap from below zero. NVIDIA's Vulkan driver took a negative dividend's remainder as if unsigned, shifting the read
# 2^32 mod 1023 = 4 texels: Vulkan's 99th percentile was 0.012, OptiX's 0.00023
odd, texels = bpy.data.images.new('odd', 1023, 1023), numpy.random.default_rng(2).random((1023, 1023, 4), 'f')
for axis in (0, 1): texels[..., :3] = sum(numpy.roll(texels[..., :3], k, axis) for k in range(16)) / 16
texels[..., 3] = 1
odd.pixels.foreach_set(texels.ravel())
image.image, mapping.inputs['Scale'].default_value[:2] = odd, (1, 1)
plane('front', 0, 0, 2)
bpy.data.objects['front'].location.z, bpy.data.meshes['front'].materials[0] = 0.01, material
front = bpy.data.meshes['front'].uv_layers.active.data
front_uv = numpy.zeros(2 * len(front), 'f')
front.foreach_get('uv', front_uv), front.foreach_set('uv', front_uv - 1.37)
devices = bpy.context.preferences.addons[flex.__name__].preferences
for device in ('OPTIX', 'VULKAN'):
    devices.device, module['BAKE_TOLERANCE'] = device, tolerance
    baked, module['BAKE_TOLERANCE'] = render(), -1  # Then every bake strays
    assert numpy.percentile(numpy.abs(render() - baked).max(-1), 99) < 0.0018, ('wrapped from below', device)
devices.device, module['BAKE_TOLERANCE'] = 'OPTIX', tolerance
bpy.data.objects.remove(bpy.data.objects['front'])
image.image, mapping.inputs['Scale'].default_value[:2] = detail, (2, 2)
# A ramp over the power, a lookup of its table at the power's value, bakes over UV space as any other step on the UV
# does and renders as live, all but 1% of pixels within 0.0018: a lookup reads a table, not an image, so it may root a
# unit, which main took for an image's read and kept live
ramp = power.nodes.new('ShaderNodeValToRGB')
ramp.color_ramp.elements[0].color, ramp.color_ramp.elements[1].color = (0.1, 0.2, 0.9, 1), (1, 0.6, 0.1, 1)
power.links.new(exponent.outputs[0], ramp.inputs['Fac'])
power.links.new(ramp.outputs['Color'], power.nodes['Principled BSDF'].inputs['Emission Color'])
exporter = exported()
assert [key[0] for _, key, *_ in exporter.placed] == [None], 'ramps bake'
baked, module['BAKE_TOLERANCE'] = render(), -1  # Every bake strays
assert numpy.percentile(numpy.abs(render() - baked).max(-1), 99) < 0.0018, 'baked ramp'
module['BAKE_TOLERANCE'] = tolerance
power.links.new(exponent.outputs[0], power.nodes['Principled BSDF'].inputs['Emission Color'])
alone = resident()
power.links.new(image.outputs['Color'], power.nodes['Principled BSDF'].inputs['Base Color'])
assert (live := resident()) - alone > 3.9, ('bake inputs freed', alone, live)
power.links.remove(power.nodes['Principled BSDF'].inputs['Base Color'].links[0])
# A value of the baked power edited after its bake bakes it again: the update of steps runs the bake again and pipes the
# image only it reads anew, 4 MiB flagged in bit 31 for the renderer's bake pass alone
exporter = exported(depsgraph := bpy.context.evaluated_depsgraph_get())
exponent.inputs[1].default_value, exporter.requests = 2, io.BytesIO()
material.update_tag()  # Its value edited, as Blender's editors tag it, and the scene evaluated with it
depsgraph = bpy.context.evaluated_depsgraph_get()
Viewport.engine.start(exporter, updated(depsgraph, material, is_updated_geometry=False, is_updated_transform=False))
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
exporter = exported()
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
    return render(bumped, 128)
baked, points, module['POINTS'] = shaded(), module['POINTS'], ()  # Live: no unit reads a point
live, module['POINTS'], module['summarize'] = shaded(), points, summarize
assert numpy.percentile(numpy.abs(baked - live).max(-1), 99) < 0.016, 'baked bump'
# Each image the materials read is stored in the smallest format exact for it: a heightmap read from a 16-bit PNG,
# 0.5 + 0.02 sin(16 pi u) over 2048 texels, as 16-bit UNORM, read as the correctly rounded k / 65535 where Blender has
# k * (1 / 65535) (512 of the 65536 codes an ulp apart); floats that are halves as halves; others as floats. Filtered
# in hardware, 16-bit UNORM errs by up to half its ulp and halves round to halves, which a Bump's differences magnify:
# under a Bump of distance 1, sun at 15 degrees, 4 pixels a texel, the heightmap rendered as 16-bit UNORM every pixel
# off its floats, by 0.04 at the median. Images a Bump differentiates keep floats, and render as their floats do
size = 2048
heights = numpy.rint((0.5 + 0.02 * numpy.sin(16 * math.pi * (numpy.arange(size) + 0.5) / size)) * 65535)
rows = numpy.tile(numpy.stack((heights, heights, heights, numpy.full(size, 65535)), -1).astype('>u2'), (size, 1, 1))
chunk = lambda kind, data: struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data))
open(bpy.app.tempdir + 'heights.png', 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', size,
    size, 16, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(b''.join(b'\0' + row.tobytes() for row in rows))) + chunk(
    b'IEND', b''))  # RGBA of 16 bits, its rows unfiltered
sixteen = bpy.data.images.load(bpy.app.tempdir + 'heights.png')
sixteen.colorspace_settings.is_data = True
floats, halves = (bpy.data.images.new(name, size, size, float_buffer=True) for name in ('heights', 'halves'))
floats.colorspace_settings.is_data = halves.colorspace_settings.is_data = True
pixels = numpy.empty(4 * size * size, 'f')
sixteen.pixels.foreach_get(pixels)
pixels.reshape(-1, 4)[:, 3] = 1e5
floats.pixels.foreach_set(pixels)
halves.pixels.foreach_set((numpy.rint(pixels * 1024) / 1024).clip(0, 1).astype('f'))  # Multiples of 2^-10: halves
read = nodes.new('ShaderNodeTexImage')
links.new(read.outputs['Color'], nodes['Principled BSDF'].inputs['Base Color'])
def stored(image):  # The format the export stores the image in, as the materials read it
    read.image, export = image, types.SimpleNamespace(visible=(), requests=io.BytesIO())  # Anew, not an update
    Viewport.engine.start(export, bpy.context.evaluated_depsgraph_get())
    return next(entry for key, entry in export.shape[2].items() if key == (image, read.extension))[2] >> 26 & 3
assert [stored(image) for image in (sixteen, halves, floats)] == [3, 2, 0], '16-bit heights stored'
other = nodes.new('ShaderNodeTexImage')  # The halves under the Bump, then an edit swapping the two images' links: the
other.image, read.image = halves, sixteen  # update starts anew, as an export anew keeps the heightmap floats
links.new(other.outputs['Color'], bump.inputs['Height'])
export = types.SimpleNamespace(visible=(), requests=io.BytesIO())
# As the engine starts anew
export.start = lambda depsgraph, keeping=False: Viewport.engine.start(export, depsgraph, keeping)
Viewport.engine.start(export, bpy.context.evaluated_depsgraph_get())
links.new(read.outputs['Color'], bump.inputs['Height'])
links.new(other.outputs['Color'], nodes['Principled BSDF'].inputs['Base Color'])
depsgraph, export.requests = bpy.context.evaluated_depsgraph_get(), io.BytesIO()
Viewport.engine.start(export, updated(depsgraph, tree, is_updated_geometry=False, is_updated_transform=False))
assert export.shape[2][sixteen, read.extension][2] >> 26 & 3 == 0, '16-bit heights swapped'
assert [stored(image) for image in (sixteen, halves)] == [0, 0], '16-bit heights differentiated'
bump.inputs['Distance'].default_value, bumped.camera.data.ortho_scale, sun.rotation_euler.z = 1, 2 * 32 / size, \
    math.radians(90)
preferences = bpy.context.preferences.addons[module['__name__']].preferences
device = preferences.device
for preferences.device in ('OPTIX', 'VULKAN'):
    read.image = sixteen
    rendered = shaded()
    read.image = floats
    assert numpy.array_equal(rendered, shaded()), ('16-bit heights', preferences.device)
preferences.device = device
bpy.context.window.scene = scene
# An engine persistent data keeps renders on the device the preference changed to since, as a new engine does
scene.render.use_persistent_data, preferences.device = True, 'OPTIX'
optix = numpy.array(shot().pixels)
preferences.device = 'VULKAN'
switched = numpy.array(shot().pixels)
scene.render.use_persistent_data = False
assert numpy.array_equal(switched, numpy.array(shot().pixels)) and not numpy.array_equal(switched, optix), \
    'device switch'
preferences.device = device
# Mips: a diffuse plane of a checker of single texels, 1024 a side over 100 units, under a sky of one, seen 10 degrees
# below the horizon from a unit above at 4 samples. Its far rows, where a pixel spans tens of texels, read its base
# color at the level the ray's cone covers (emission reads level 0): they spread across pixels as the same plane of the
# checker's mean of 0.5 does, by the sky's sampling, within a variance of 0.01 (0.002 measured), which read at level 0
# they exceed by 0.048
mips = new('mips')
mips.flex_samples = 4
mips.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
mesh = bpy.data.meshes.new('ground')
bm = bmesh.new()
bm.loops.layers.uv.new()
bmesh.ops.create_grid(bm, size=50, calc_uvs=True)
bm.to_mesh(mesh)
mips.collection.objects.link(bpy.data.objects.new('ground', mesh))
mesh.materials.append(bpy.data.materials.new('checker'))
nodes, links = mesh.materials[0].node_tree.nodes, mesh.materials[0].node_tree.links
diffuse, checker = nodes.new('ShaderNodeBsdfDiffuse'), nodes.new('ShaderNodeTexImage')
checker.image = bpy.data.images.new('checker', 1024, 1024)
checker.image.pixels.foreach_set(numpy.repeat(numpy.indices((1024, 1024)).sum(0) % 2, 4).clip(
    numpy.tile((0, 0, 0, 1), 1024 * 1024)).astype('f'))  # Opaque
links.new(checker.outputs['Color'], diffuse.inputs['Color'])
links.new(diffuse.outputs[0], nodes['Material Output'].inputs['Surface'])
mips.camera = bpy.data.objects.new('mips camera', bpy.data.cameras.new('mips camera'))
mips.collection.objects.link(mips.camera)
mips.camera.location, mips.camera.rotation_euler, mips.camera.data.angle = (0, -50, 1), (math.radians(80), 0, 0), \
    math.pi / 2
def far():  # Its far rows rendered
    return render(mips)[30:36, :, 0]
for preferences.device in ('OPTIX', 'VULKAN'):
    checked = far()
    links.remove(diffuse.inputs['Color'].links[0])
    diffuse.inputs['Color'].default_value = (0.5, 0.5, 0.5, 1)
    flat = far()
    links.new(checker.outputs['Color'], diffuse.inputs['Color'])
    assert abs(checked.mean() - flat.mean()) < 0.05 and checked.var() - flat.var() < 0.01, ('mips', preferences.device,
        checked.mean(), flat.mean(), checked.var() - flat.var())
preferences.device = device

# A volume varying from point to point: a pure absorber of density 2 at the top of its generated points and 0 at their
# bottom, seen straight down through its depth of 2 against a white sky, passes exp(-2) by its density's integral, where
# the density where it is entered held along the ray would pass exp(-4)
fog = new('fog')
fog.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
mesh = bpy.data.meshes.new('fog')
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=2)
bm.to_mesh(mesh)
fog.collection.objects.link(bpy.data.objects.new('fog', mesh))
mesh.materials.append(bpy.data.materials.new('absorber'))
nodes, links = mesh.materials[0].node_tree.nodes, mesh.materials[0].node_tree.links
nodes.remove(nodes['Principled BSDF'])
absorber, depth, double = (nodes.new(kind) for kind in ('ShaderNodeVolumePrincipled', 'ShaderNodeSeparateXYZ',
    'ShaderNodeMath'))
absorber.inputs['Color'].default_value, double.operation, double.inputs[1].default_value = (0, 0, 0, 1), 'MULTIPLY', 2
links.new(nodes.new('ShaderNodeTexCoord').outputs['Generated'], depth.inputs[0])
links.new(depth.outputs['Z'], double.inputs[0])
links.new(double.outputs[0], absorber.inputs['Density'])
links.new(absorber.outputs[0], nodes['Material Output'].inputs['Volume'])
fog.camera = bpy.data.objects.new('fog camera', bpy.data.cameras.new('fog camera'))
fog.collection.objects.link(fog.camera)
fog.camera.data.type, fog.camera.data.ortho_scale, fog.camera.location = 'ORTHO', 1, (0, 0, 3)
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(fog).mean()
    assert abs(seen / math.exp(-2) - 1) < 0.01, ('varying absorber', preferences.device, seen)
preferences.device = device
# The absorber at a cost a bake takes, of density 2 z + Fac - Fac of a noise, on the cube unwrapped over [0, 1]: read
# live at its points inside, which have no UV, it passes exp(-2) as before; baked over its UVs, every point inside would
# read the one texel at UV (0, 0), which no face of the cube covers. The Fac - Fac pad is there only to put its cost
# past the bake threshold: a change to the costs must keep this density one a bake would take
unwrapped = new('unwrapped')
unwrapped.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
unwrapped.camera = fog.camera
unwrapped.collection.objects.link(fog.camera)
cover = bpy.data.meshes.new('unwrapped')
bm = bmesh.new()
bm.loops.layers.uv.new()
bmesh.ops.create_cube(bm, size=2, calc_uvs=True)
bm.to_mesh(cover)
unwrapped.collection.objects.link(bpy.data.objects.new('unwrapped', cover))
cover.materials.append(costly := mesh.materials[0].copy())
nodes, links = costly.node_tree.nodes, costly.node_tree.links
noise, cancel, padded = nodes.new('ShaderNodeTexNoise'), nodes.new('ShaderNodeMath'), nodes.new('ShaderNodeMath')
cancel.operation, padded.operation = 'SUBTRACT', 'ADD'
links.new(noise.outputs['Fac'], cancel.inputs[0]), links.new(noise.outputs['Fac'], cancel.inputs[1])
links.new(nodes['Math'].outputs[0], padded.inputs[0]), links.new(cancel.outputs[0], padded.inputs[1])
links.new(padded.outputs[0], nodes['Principled Volume'].inputs['Density'])
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(unwrapped).mean()
    assert abs(seen / math.exp(-2) - 1) < 0.01, ('varying absorber over UVs', preferences.device, seen)
preferences.device = device
# The absorber under a modifier making vertices of its own, its generated points those of its evaluated mesh, exports:
# its texture space read while that mesh lives, which the export frees before bounding the volume
shown = bpy.context.window.scene
opened('subdivided fog').collection.objects.link(smooth := bpy.data.objects.new('subdivided fog', mesh))
smooth.modifiers.new('subdivision', 'SUBSURF')
assert len(exported().varying) == 1, 'subdivided varying volume'
# A fog of a varying color absorbing nothing, Principled Volume of density 0.5 colored by a noise mixing two colors,
# tracks under its extinction, 0.5 as the color lies in [0, 1], not under the 1 its scattering and absorption bounded
# apart give, and exactly so: constant and gray, its free flights drawn from it, which its sign tells the renderer
opened('colored fog').collection.objects.link(bpy.data.objects.new('colored fog', tinted := mesh.copy()))
tinted.materials[0] = colored_fog = mesh.materials[0].copy()
nodes, links = colored_fog.node_tree.nodes, colored_fog.node_tree.links
links.remove(nodes['Principled Volume'].inputs['Density'].links[0])
nodes['Principled Volume'].inputs['Density'].default_value = 0.5
mix = nodes.new('ShaderNodeMix')
mix.data_type, mix.inputs['A'].default_value, mix.inputs['B'].default_value = 'RGBA', (1, 0.2, 0, 1), (0, 0.6, 1, 1)
links.new(nodes.new('ShaderNodeTexNoise').outputs['Fac'], mix.inputs['Factor'])
links.new(mix.outputs['Result'], nodes['Principled Volume'].inputs['Color'])
assert len(exported().varying) == 1, 'colored fog'
majorant = flex.medium(colored_fog.evaluated_get(bpy.context.evaluated_depsgraph_get()), {'POSITION': (  # As shaded
    numpy.full(3, -1), numpy.ones(3)), 'GENERATED': (numpy.zeros(3), numpy.ones(3))})
assert majorant == -0.5, ('majorant of a colored fog, exact as negative', majorant)
bpy.context.window.scene = shown
# Light reaching a varying volume through it: the cube scattering all it meets, white, of density 1 + x along x, lit
# by a sun along -x and seen straight down, once. A column at x scatters (1 - exp(-2 (1 + x))) of what reaches it
# through 2 - (1 + x)^2 / 2 of optical depth on its way in from x = 1: the columns over [0.25, 0.75] and [-0.75, -0.25]
# average to 4.2 to one, where light taken through the density at the point it scatters at, as the medium entered has
# it, would give 1.5
haze = new('haze')
haze.flex_samples = 1024  # The bands within 2% at over 8 times their spread across rows
haze.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
haze.flex_bounces, haze.camera = 1, bpy.data.objects.new('haze camera', bpy.data.cameras.new('haze camera'))
haze.collection.objects.link(haze.camera)
haze.camera.data.type, haze.camera.data.ortho_scale, haze.camera.location = 'ORTHO', 2, (0, 0, 3)
haze.collection.objects.link(cube := bpy.data.objects.new('haze', mesh.copy()))
cube.data.materials[0] = scatterer = mesh.materials[0].copy()
scatterer.node_tree.nodes['Principled Volume'].inputs['Color'].default_value = (1, 1, 1, 1)
scatterer.node_tree.links.new(scatterer.node_tree.nodes['Separate XYZ'].outputs['X'],
    scatterer.node_tree.nodes['Math'].inputs[0])
haze.collection.objects.link(sun := bpy.data.objects.new('haze sun', bpy.data.lights.new('haze sun', 'SUN')))
sun.data.angle, sun.rotation_euler = 0, (0, math.pi / 2, 0)
band = lambda low: numpy.mean([(1 - math.exp(-2 * (1 + v))) * math.exp((1 + v) ** 2 / 2 - 2)
    for v in numpy.linspace(low, low + 0.5, 2000)])  # Of the columns over [low, low + 0.5]
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(haze)[8:-8]
    seen = seen.mean((0, 2))
    ratio = seen[5 * SIZE // 8:7 * SIZE // 8].mean() / seen[SIZE // 8:3 * SIZE // 8].mean()
    expected = band(0.25) / band(-0.75)
    assert abs(ratio / expected - 1) < 0.02, ('light through a varying volume', preferences.device, ratio, expected)
preferences.device = device
# A volume of noise bounded by its noise's range: the scatterer of density 2 Fac of a noise over its generated points,
# lit and seen as before, matches itself under a majorant 4 above, of density 2 (Fac + 2 x - 2 x), within 2% at 64
# samples, where 0.3 of its majorant leaves it 6% bright
noisy = new('noisy')
noisy.flex_samples, noisy.flex_bounces, noisy.camera = 64, 1, haze.camera
noisy.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
noisy.collection.objects.link(haze.camera)
noisy.collection.objects.link(sun)
noisy.collection.objects.link(cube := bpy.data.objects.new('noisy', mesh.copy()))
cube.data.materials[0] = noise_fog = scatterer.copy()
nodes, links = noise_fog.node_tree.nodes, noise_fog.node_tree.links
noise, double, zero, padded = (nodes.new(kind) for kind in ('ShaderNodeTexNoise', *('ShaderNodeMath',) * 3))
links.new(nodes['Texture Coordinate'].outputs['Generated'], noise.inputs['Vector'])
links.new(noise.outputs['Fac'], nodes['Math'].inputs[0])
double.operation, double.inputs[1].default_value, zero.operation, padded.operation = 'MULTIPLY', 2, 'SUBTRACT', 'ADD'
links.new(nodes['Separate XYZ'].outputs['X'], double.inputs[0])
links.new(double.outputs[0], zero.inputs[0]), links.new(double.outputs[0], zero.inputs[1])
links.new(noise.outputs['Fac'], padded.inputs[0]), links.new(zero.outputs[0], padded.inputs[1])
seen = {}
for pad in (False, True):
    if pad: links.new(padded.outputs[0], nodes['Math'].inputs[0])
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen[pad, preferences.device] = render(noisy).mean()
for preferences.device in ('OPTIX', 'VULKAN'):
    ratio = seen[False, preferences.device] / seen[True, preferences.device]
    assert abs(ratio - 1) < 0.02, ('volume of noise', preferences.device, ratio)
preferences.device = device
# An area light emits nothing behind it, however far: a disk area light 1 across, of radiance 1 on its front, facing up
# 20 and 50 above a white diffuse floor, which only light sampling reaching past its black back lit, reads 0 there by
# light sampling alone and with a bounce; facing down from 2 above it, the floor beneath its axis reads its irradiance
# over pi, of a power of pi pi (h h + r r) 1
behind = new('behind')
behind.flex_samples, behind.flex_restir, behind.flex_denoise = 64, False, False
behind.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
data = bpy.data.meshes.new('behind floor')
bm = bmesh.new()
bmesh.ops.create_grid(bm, size=500)
bm.to_mesh(data)
data.materials.append(white := bpy.data.materials.new('behind floor'))
white.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (1, 1, 1, 1)
white.node_tree.nodes['Principled BSDF'].inputs['IOR'].default_value = 1
behind.collection.objects.link(bpy.data.objects.new('behind floor', data))
disk_light = bpy.data.lights.new('behind disk', 'AREA')
disk_light.shape, disk_light.size = 'DISK', 1
behind.collection.objects.link(disk_object := bpy.data.objects.new('behind disk', disk_light))
behind.camera = bpy.data.objects.new('behind camera', bpy.data.cameras.new('behind camera'))
behind.collection.objects.link(behind.camera)
behind.camera.data.type = 'ORTHO'
for preferences.device in ('OPTIX', 'VULKAN'):
    disk_object.rotation_euler, disk_light.energy = (math.pi, 0, 0), math.pi * math.pi / 4  # Facing up, radiance 1
    for height in (20, 50):
        disk_object.location.z, behind.camera.location.z = height, height / 2
        behind.camera.data.ortho_scale, behind.camera.data.clip_end = height, height
        for behind.flex_bounces in (0, 1):
            bpy.ops.render.render(scene=behind.name, write_still=True)
            seen = numpy.array(bpy.data.images.load(behind.render.filepath).pixels)
            assert seen.reshape(-1, 4)[:, :3].max() == 0, ('behind an area light', preferences.device, height,
                behind.flex_bounces, seen.reshape(-1, 4)[:, :3].mean())
    disk_object.rotation_euler, disk_object.location.z = (0, 0, 0), 2  # Facing down
    disk_light.energy = math.pi * math.pi * (4 + 0.25)
    behind.camera.location.z, behind.camera.data.ortho_scale, behind.camera.data.clip_end = 1, 0.05, 2
    behind.flex_bounces = 0
    seen = render(behind).mean()
    assert abs(seen - 1) < 0.01, ('in front of an area light', preferences.device, seen)
preferences.device = device

# Light leaving a medium within a surface's margin of its face: the cube scattering all it meets, white, of density
# 1e4, under an angle-0 sun of pi straight down and seen straight down, once, reads (1 - exp(-4e4)) / 8 = 1 / 8 by its
# single scattering, the most from vertices within 1e-4 of the top face, whose shadow rays must leave it there
dense = new('dense')
dense.flex_bounces, dense.camera = 1, haze.camera
dense.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
dense.collection.objects.link(haze.camera)
dense.collection.objects.link(cube := bpy.data.objects.new('dense', mesh.copy()))
cube.data.materials[0] = thick = scatterer.copy()
for link in thick.node_tree.nodes['Principled Volume'].inputs['Density'].links: thick.node_tree.links.remove(link)
thick.node_tree.nodes['Principled Volume'].inputs['Density'].default_value = 1e4
dense.collection.objects.link(overhead := bpy.data.objects.new('dense sun', bpy.data.lights.new('dense sun', 'SUN')))
overhead.data.angle, overhead.data.energy = 0, math.pi
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(dense).mean()
    assert abs(seen * 8 - 1) < 0.02, ('light leaving a dense medium', preferences.device, seen * 8)
preferences.device = device
# A fog of constant gray extinction, its free flights drawn exactly, renders as tracked: Principled Volume of density 1,
# its color and its emission (0.5) of a noise mixing two colors, lit and seen as before over 2 bounces, matches its
# twin of density 1 + Fac - Fac, whose bound spreads so that it tracks under a majorant 2, within 2% on both backends
exact = new('exact fog')
exact.flex_samples, exact.flex_bounces, exact.camera = 256, 2, haze.camera
exact.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
exact.collection.objects.link(haze.camera)
exact.collection.objects.link(sun)
exact.collection.objects.link(cube := bpy.data.objects.new('exact fog', mesh.copy()))
cube.data.materials[0] = bright_fog = colored_fog.copy()
nodes, links = bright_fog.node_tree.nodes, bright_fog.node_tree.links
principled = nodes['Principled Volume']
principled.inputs['Density'].default_value, principled.inputs['Emission Strength'].default_value = 1, 0.5
links.new(nodes['Mix'].outputs['Result'], principled.inputs['Emission Color'])
cancel, padded = nodes.new('ShaderNodeMath'), nodes.new('ShaderNodeMath')
cancel.operation, padded.operation, padded.inputs[0].default_value = 'SUBTRACT', 'ADD', 1
links.new(nodes['Noise Texture'].outputs['Fac'], cancel.inputs[0]), links.new(nodes['Noise Texture'].outputs['Fac'],
    cancel.inputs[1]), links.new(cancel.outputs[0], padded.inputs[1])
seen = {}
for pad in (False, True):
    if pad: links.new(padded.outputs[0], principled.inputs['Density'])
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen[pad, preferences.device] = render(exact).mean(0).mean(0)
for preferences.device in ('OPTIX', 'VULKAN'):
    ratio = seen[False, preferences.device] / seen[True, preferences.device]
    assert numpy.all(abs(ratio - 1) < 0.02), ('exact free flights', preferences.device, ratio)
preferences.device = device
# Shadow rays pass such a fog by its exponential alone: a box of Principled Volume of density 1, colored as the fog,
# 1 deep over a white diffuse floor lit by a sun of pi straight down, seen straight down from under it at 1 sample
# without bounces, reads exp(-1) in every pixel, where tracking reads 0 or 1; the export marks its majorant exact by
# its sign, -1, and a density of the noise tracked, positive
gray = new('gray fog')
gray.flex_samples, gray.flex_bounces, gray.flex_restir, gray.flex_denoise = 1, 0, False, False
gray.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
for name, size, z in (('gray floor', 8, 0), ('gray fog', 4, 2.5)):
    data = bpy.data.meshes.new(name)
    bm = bmesh.new()
    (bmesh.ops.create_grid(bm, size=size / 2) if z == 0 else bmesh.ops.create_cube(bm, size=1))
    bm.to_mesh(data)
    data.materials.append(bpy.data.materials.new(name))
    gray.collection.objects.link(ob := bpy.data.objects.new(name, data))
    ob.location.z, ob.scale = z, (1, 1, 1) if z == 0 else (size, size, 1)
floor_bsdf = bpy.data.materials['gray floor'].node_tree.nodes['Principled BSDF']
floor_bsdf.inputs['Base Color'].default_value, floor_bsdf.inputs['IOR'].default_value = (1, 1, 1, 1), 1
grayed = bpy.data.materials['gray fog'].node_tree
grayed.nodes.remove(grayed.nodes['Principled BSDF'])
volume, grain = grayed.nodes.new('ShaderNodeVolumePrincipled'), grayed.nodes.new('ShaderNodeTexNoise')
volume.inputs['Density'].default_value = 1
shades = grayed.nodes.new('ShaderNodeMix')  # Two colors by the noise, as the colored fog's
shades.data_type, shades.inputs['A'].default_value, shades.inputs['B'].default_value = 'RGBA', (1, 0.2, 0, 1), \
    (0, 0.6, 1, 1)
grayed.links.new(grain.outputs['Fac'], shades.inputs['Factor'])
grayed.links.new(shades.outputs['Result'], volume.inputs['Color'])
grayed.links.new(volume.outputs[0], grayed.nodes['Material Output'].inputs['Volume'])
gray.collection.objects.link(beam := bpy.data.objects.new('gray sun', bpy.data.lights.new('gray sun', 'SUN')))
beam.data.angle, beam.data.energy = 0, math.pi
gray.camera = bpy.data.objects.new('gray camera', bpy.data.cameras.new('gray camera'))
gray.collection.objects.link(gray.camera)
gray.camera.location, gray.camera.data.angle = (0, 0, 1), 0.5
majorants, medium_exported = [], flex.medium
flex.medium = lambda material, boxes: (value := medium_exported(material, boxes), majorants.append(value))[0]
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(gray)
    assert abs(seen.mean() - math.exp(-1)) < 1e-3 and seen.std() / seen.mean() < 1e-3, \
        ('fog passed by its exponential', preferences.device, seen.mean(), seen.std() / seen.mean())
grayed.links.new(grain.outputs['Fac'], volume.inputs['Density'])
bpy.ops.render.render(scene=gray.name, write_still=True)
flex.medium = medium_exported
preferences.device = device
assert majorants[0] == -1 and majorants[-1] > 0, ('exact majorant by its sign', majorants)
# A volume clear at a face bounds it all the same: the absorber of density 2 z over its generated points, clear at its
# bottom face, over a white diffuse floor lit by a sun straight down and seen through it, passes exp(-2) each way, the
# floor reading exp(-4) / pi; a ray taking the absorber past its clear face would gain by its density's negative there
fog.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
floor = bpy.data.meshes.new('fog floor')
bm = bmesh.new()
bmesh.ops.create_grid(bm, size=3)
bm.to_mesh(floor)
fog.collection.objects.link(ob := bpy.data.objects.new('fog floor', floor))
ob.location.z = -1.5
floor.materials.append(white := bpy.data.materials.new('fog floor'))
white.node_tree.nodes.remove(white.node_tree.nodes['Principled BSDF'])
diffuse = white.node_tree.nodes.new('ShaderNodeBsdfDiffuse')
diffuse.inputs['Color'].default_value = (1, 1, 1, 1)
white.node_tree.links.new(diffuse.outputs[0], white.node_tree.nodes['Material Output'].inputs['Surface'])
fog.collection.objects.link(sun := bpy.data.objects.new('fog sun', bpy.data.lights.new('fog sun', 'SUN')))
sun.data.angle, sun.data.energy = 0, 1
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(fog).mean()
    assert abs(seen * math.pi / math.exp(-4) - 1) < 0.02, ('floor through a varying volume', preferences.device, seen)
preferences.device = device
# A camera inside a varying volume: in the absorber at its center, seeing straight down a white sky from its near
# plane at depth c, passes exp(-(1 - c)^2 / 2) of what its density, 1 - s at depth s, takes on the way out
inside = new('inside')
inside.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
inside.collection.objects.link(bpy.data.objects.new('inside', mesh))
inside.camera = bpy.data.objects.new('inside camera', bpy.data.cameras.new('inside camera'))
inside.collection.objects.link(inside.camera)
inside.camera.data.type, inside.camera.data.ortho_scale, inside.camera.data.clip_start = 'ORTHO', 1, 0.01
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(inside).mean()
    assert abs(seen / math.exp(-0.99 ** 2 / 2) - 1) < 0.01, ('camera inside a varying volume', preferences.device, seen)
preferences.device = device
def fogged(name, scale, size=16):  # A black world's scene, no bounces, its camera looking down inside a white scatterer
    made = new(name, size, 1024, (0, 0, 0))
    made.flex_bounces, made.camera = 0, bpy.data.objects.new(name, bpy.data.cameras.new(name))
    made.collection.objects.link(made.camera)
    made.camera.data.type, made.camera.data.ortho_scale, made.camera.data.clip_start = 'ORTHO', 0.1, 0.01
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=2)
    bm.to_mesh(mesh)
    mesh.materials.append(fog := bpy.data.materials.new(name))
    fog.node_tree.nodes.remove(fog.node_tree.nodes['Principled BSDF'])
    scatter = fog.node_tree.nodes.new('ShaderNodeVolumeScatter')
    scatter.inputs['Color'].default_value, scatter.inputs['Density'].default_value = (1, 1, 1, 1), 1
    fog.node_tree.links.new(scatter.outputs[0], fog.node_tree.nodes['Material Output'].inputs['Volume'])
    made.collection.objects.link(cube := bpy.data.objects.new(name, mesh))
    cube.scale = scale
    return made
# The camera's own segment scatters: a sun of 4 pi straight down reaches depth t through 1 + t
murk = fogged('fogged camera', (1, 1, 1))
murk.collection.objects.link(shine := bpy.data.objects.new('fogged sun', bpy.data.lights.new('fogged sun', 'SUN')))
shine.data.angle, shine.data.energy = 0, 4 * math.pi
due = math.exp(-0.99) * (math.exp(-0.02) - math.exp(-2)) / 2  # Of exp(0.01 - t) / (4 pi) 4 pi exp(-1 - t) on [0.01, 1]
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = [render(murk, 16) for murk.flex_restir in (False, True)]
    means, errors = [image.mean() for image in seen], [image.mean(2).std() / 16 for image in seen]
    assert all(abs(mean / due - 1) < 0.01 for mean in means), ('camera in a scattering fog', preferences.device, means)
    assert abs(means[1] - means[0]) < 3 * math.hypot(*errors), ('fog ReSTIR', preferences.device, means, errors)
preferences.device = device
# A camera-hidden light in the fog: seen, its surface adds exp(-0.99) to the light scattered from it, hidden nothing
murk = fogged('hidden in fog', (3, 3, 1), 64)
murk.camera.location.z = 0.5
murk.collection.objects.link(lamp := bpy.data.objects.new('hidden in fog', bpy.data.lights.new('hidden', 'AREA')))
lamp.data.size, lamp.data.energy, lamp.location, lamp.rotation_euler = 2, 4 * math.pi, (0, 0, -0.5), (math.pi, 0, 0)
# Depth t, height h = 1 - t above the square of radiance 1, scatters exp(0.01 - t) / (4 pi) of exp(-r) h / r^3 on it
t = 0.01 + 0.99 * (numpy.arange(100)[:, None, None] + 0.5) / 100
phi = (numpy.arange(400) + 0.5) * math.pi / 200
low = (1 - t) / numpy.hypot(1 / numpy.maximum(abs(numpy.cos(phi)), abs(numpy.sin(phi)))[:, None], 1 - t)
s = low + (1 - low) * (numpy.arange(100) + 0.5) / 100
scattered = (numpy.exp(0.01 - t - (1 - t) / s).mean(2) * (1 - low[..., 0])).mean() * 0.99 / 2
murk.flex_restir = False  # Pixels apart, within 3 of their standard errors
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = {}
    for hidden in (False, True):
        lamp.visible_camera = not hidden
        seen[hidden] = render(murk, 64).mean(2)
        due, error = scattered + (0 if hidden else math.exp(-0.99)), seen[hidden].std() / 64
        assert abs(seen[hidden].mean() - due) < 3 * error, ('hidden light in fog', preferences.device, hidden,
            seen[hidden].mean(), due, error)
    surface = seen[False] - seen[True]  # Of the same random numbers: the surface's term alone
    assert abs(surface.mean() - math.exp(-0.99)) < 3 * surface.std() / 64, ('fog surface', preferences.device,
        surface.mean(), surface.std() / 64)
    murk.flex_restir = True  # Within 0.002: 3 standard errors of its difference from none, 0.00067 at 16 x 16
    reused = render(murk, 64).mean()
    murk.flex_restir = False
    assert abs(reused - seen[True].mean()) < 0.002, ('hidden light in fog ReSTIR', preferences.device, reused,
        seen[True].mean())
preferences.device = device
# A smoke simulation's domain, turned and stretched, of a pure absorber of density 20 times its density grid, seen
# straight down against a white sky: each quarter of the view passes exp(-20 x the grid's integral down it), the grid
# read linearly over the box its evaluated mesh spans, as the CPU reads it here; its smoke over its inflow, the grid x
# fastest; and so again of the adaptive domain, its grid over its active box alone
shown = bpy.context.window.scene
smoke = opened('smoke', (1, 1, 1))
smoke.render.resolution_x = smoke.render.resolution_y = 16
smoke.camera = bpy.data.objects.new('smoke', bpy.data.cameras.new('smoke'))
smoke.collection.objects.link(smoke.camera)
smoke.camera.location.z, smoke.camera.data.type, smoke.camera.data.ortho_scale = 2, 'ORTHO', 4
for name, size in (('smoke domain', 2), ('smoke inflow', 0.4)):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=size)
    bm.to_mesh(cuboid := bpy.data.meshes.new(name))
    smoke.collection.objects.link(bpy.data.objects.new(name, cuboid))
domain, inflow = bpy.data.objects['smoke domain'], bpy.data.objects['smoke inflow']
domain.rotation_euler.z, domain.scale.y, inflow.parent, inflow.location = 0.5, 1.5, domain, (0.5, -0.5, -0.6)
inflow.hide_render = True
settings = domain.modifiers.new('fluid', 'FLUID')
settings.fluid_type = 'DOMAIN'
settings = settings.domain_settings
settings.domain_type, settings.resolution_max, settings.cache_type = 'GAS', 32, 'REPLAY'
flow = inflow.modifiers.new('fluid', 'FLUID')
flow.fluid_type = 'FLOW'
flow.flow_settings.flow_type, flow.flow_settings.flow_behavior = 'SMOKE', 'INFLOW'
domain.data.materials.append(soot := bpy.data.materials.new('smoke'))
nodes = soot.node_tree.nodes
nodes.remove(nodes['Principled BSDF'])
volume = nodes.new('ShaderNodeVolumePrincipled')
volume.inputs['Color'].default_value, volume.inputs['Density'].default_value = (0, 0, 0, 1), 20
volume.inputs['Density Attribute'].default_value = 'density'
soot.node_tree.links.new(volume.outputs[0], nodes['Material Output'].inputs['Volume'])
quarters = lambda image: image.reshape(2, len(image) // 2, 2, len(image) // 2).mean((1, 3))
u = (numpy.arange(32) + 0.5) / 32 * 4 - 2  # Down 32 x 32 points across the view at 200 depths
world = numpy.stack(numpy.broadcast_arrays(u[None, :, None], u[:, None, None], (numpy.arange(200) + 0.5) / 100 - 1), -1)
for settings.use_adaptive_domain in (False, True):
    settings.cache_directory = bpy.app.tempdir + f'smoke {settings.use_adaptive_domain}'
    for frame in range(1, 9): smoke.frame_set(frame)
    evaluated = domain.evaluated_get(bpy.context.evaluated_depsgraph_get())
    inverse = numpy.array(evaluated.matrix_world.inverted())  # Turned and stretched once evaluated
    local = world @ inverse[:3, :3].T + inverse[:3, 3]
    grids = evaluated.modifiers['fluid'].domain_settings
    n = numpy.array(grids.domain_resolution)
    grid = numpy.array(grids.density_grid).reshape(n[::-1])
    low, high = numpy.array(evaluated.bound_box).min(0), numpy.array(evaluated.bound_box).max(0)
    weights = numpy.array([(grid.sum(tuple({0, 1, 2} - {k})) * (numpy.arange(n[2 - k]) + 0.5)).sum() / grid.sum()
        / n[2 - k] for k in (2, 1, 0)])
    centroid = low + weights * (high - low)
    assert abs(centroid[:2] - (0.5, -0.5)).max() < 0.1 and centroid[2] < 0, ('smoke inflow', centroid)
    g = (local - low) / (high - low)  # Read linearly, extended at its faces
    spanned = ((g >= 0) & (g <= 1)).all(-1)
    x = g * n - 0.5
    i = numpy.floor(x).astype(int)
    read = sum(numpy.prod([numpy.where(c >> k & 1, x[..., k] - i[..., k], 1 - x[..., k] + i[..., k]) for k in range(3)],
        0) * grid[tuple(numpy.clip(i[..., k] + (c >> k & 1), 0, n[k] - 1) for k in (2, 1, 0))] for c in range(8))
    due = numpy.exp(-20 * (read * spanned).sum(-1) / 100)
    assert numpy.ptp(quarters(due)) > 0.05, ('smoke quarters', quarters(due))
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = quarters(render(smoke, 16).mean(2))
        assert numpy.abs(seen - quarters(due)).max() < 0.02, ('smoke', settings.use_adaptive_domain,
            preferences.device, seen, quarters(due))
    preferences.device = device
bpy.context.window.scene = shown
# A fire's domain, its inflow of smoke colored (1, 0.5, 0.25) and of fire, seen straight down over the domain, per
# quarter of the view as the CPU reads its grids linearly: through Volume Info's color and density into a Volume
# Absorption of 4 times the density, against a white sky, exp(-4 (1 - color) x density integrated down it) per channel,
# its color unpremultiplied by its density once both are read; against a black sky, Volume Info's flame as a Principled
# Volume's emission strength, the flame integrated down it, and a Principled Volume's blackbody at 1000 K times its
# temperature grid, in luminance sigma T^4 / pi times Blender's 1e-6 integrated down it
def burning():  # Fire through Volume Info
    fire = opened('fire', (1, 1, 1))
    fire.render.resolution_x = fire.render.resolution_y = 16
    fire.flex_samples = 1024
    fire.camera = bpy.data.objects.new('fire', bpy.data.cameras.new('fire'))
    fire.collection.objects.link(fire.camera)  # Over the domain, its inflow in the lower right quarter
    fire.camera.location, fire.camera.data.type, fire.camera.data.ortho_scale = (0, 0, 2), 'ORTHO', 2
    for name, size in (('fire domain', 2), ('fire inflow', 0.4)):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=size)
        bm.to_mesh(mesh := bpy.data.meshes.new(name))
        fire.collection.objects.link(bpy.data.objects.new(name, mesh))
    domain, inflow = bpy.data.objects['fire domain'], bpy.data.objects['fire inflow']
    inflow.parent, inflow.location, inflow.hide_render = domain, (0.4, -0.4, -0.6), True
    settings = domain.modifiers.new('fluid', 'FLUID')
    settings.fluid_type = 'DOMAIN'
    settings = settings.domain_settings
    settings.domain_type, settings.resolution_max, settings.cache_type = 'GAS', 32, 'REPLAY'
    settings.cache_directory = bpy.app.tempdir + 'fire'
    flow = inflow.modifiers.new('fluid', 'FLUID')
    flow.fluid_type = 'FLOW'
    flow.flow_settings.flow_type, flow.flow_settings.flow_behavior = 'BOTH', 'INFLOW'
    flow.flow_settings.smoke_color = (1, 0.5, 0.25)
    for frame in range(1, 9): fire.frame_set(frame)
    evaluated = domain.evaluated_get(bpy.context.evaluated_depsgraph_get())
    grids = evaluated.modifiers['fluid'].domain_settings
    n = numpy.array(grids.domain_resolution)
    low, high = numpy.array(evaluated.bound_box).min(0), numpy.array(evaluated.bound_box).max(0)
    inverse = numpy.array(evaluated.matrix_world.inverted())
    u = (numpy.arange(96) + 0.5) / 96 * 2 - 1  # Down 96 x 96 points across the view at 200 depths, as T^4 needs
    view = numpy.stack(numpy.broadcast_arrays(u[None, :, None], u[:, None, None], (numpy.arange(200) + 0.5) / 100 - 1),
        -1)
    g = (view @ inverse[:3, :3].T + inverse[:3, 3] - low) / (high - low)
    inside = ((g >= 0) & (g <= 1)).all(-1)
    x = g * n - 0.5
    i = numpy.floor(x).astype(int)
    linear = lambda values: sum(numpy.prod([numpy.where(c >> k & 1, x[..., k] - i[..., k], 1 - x[..., k] + i[..., k])
        for k in range(3)], 0) * values.reshape(n[::-1])[tuple(numpy.clip(i[..., k] + (c >> k & 1), 0, n[k] - 1)
        for k in (2, 1, 0))] for c in range(8)) * inside
    rgba = numpy.array(grids.color_grid).reshape(-1, 4)
    alpha = linear(rgba[:, 3])
    color = numpy.stack([numpy.divide(linear(rgba[:, k]), alpha, out=numpy.zeros_like(alpha), where=alpha > 0)
        for k in range(3)], -1)
    density = linear(numpy.array(grids.density_grid))
    temperature = 1000 * numpy.maximum(linear(numpy.array(grids.temperature_grid)), 0)
    dues = {'absorbed': numpy.exp(-4 * ((1 - color) * density[..., None]).sum(2) / 100),
        'flame': linear(numpy.array(grids.flame_grid)).sum(-1)[..., None] / 100,
        'blackbody': (5.670374419e-8 * 1e-6 / math.pi * temperature ** 4).sum(-1)[..., None] / 100}
    for name, due in dues.items():
        domain.data.materials.clear()
        domain.data.materials.append(material := bpy.data.materials.new(name))
        nodes, links = material.node_tree.nodes, material.node_tree.links
        nodes.remove(nodes['Principled BSDF'])
        info, output = nodes.new('ShaderNodeVolumeInfo'), nodes['Material Output'].inputs['Volume']
        if name == 'absorbed':
            absorber, scaled = nodes.new('ShaderNodeVolumeAbsorption'), nodes.new('ShaderNodeMath')
            scaled.operation, scaled.inputs[1].default_value = 'MULTIPLY', 4
            links.new(info.outputs['Color'], absorber.inputs['Color'])
            links.new(info.outputs['Density'], scaled.inputs[0])
            links.new(scaled.outputs[0], absorber.inputs['Density'])
            links.new(absorber.outputs[0], output)
        else:
            volume = nodes.new('ShaderNodeVolumePrincipled')
            volume.inputs['Density'].default_value = 0
            if name == 'flame': links.new(info.outputs['Flame'], volume.inputs['Emission Strength'])
            else:
                volume.inputs['Blackbody Intensity'].default_value = 1
                volume.inputs['Temperature'].default_value = 1000
            links.new(volume.outputs[0], output)
        fire.world.node_tree.nodes['Background'].inputs['Color'].default_value = (*[float(name == 'absorbed')] * 3, 1)
        due = numpy.stack([quarters(due[..., k]) for k in range(due.shape[-1])], -1)
        assert due.max() > 0.01, (name, due)
        for preferences.device in ('OPTIX', 'VULKAN'):
            seen = render(fire, 16)
            seen = numpy.stack([quarters(seen[..., k]) for k in range(3)], -1)
            if name != 'absorbed': seen = (seen @ numpy.array((0.2126, 0.7152, 0.0722)))[..., None]
            tolerance = 0.02 if name == 'absorbed' else 0.04 * due.max()  # Of its transmittance, or of its glow
            assert numpy.abs(seen - due).max() < tolerance, ('fire', name, preferences.device, seen, due)
        preferences.device = device
    bpy.context.window.scene = shown
burning()
# A volume object of a grid its geometry nodes make, a Volume Cube of density 1.5 + x + y / 2 over [-1, 1]^3 at 32^3 in
# renders and 8^3 in the viewport (by Is Viewport: a render reads its own), turned and stretched, a pure absorber of its
# Principled Volume's density 2 times that grid, seen straight down against a white sky: each quarter of the view passes
# exp(-2 x the density's integral down it), which the grid, linear in its voxels, holds exactly; its density extended
# past the outermost voxels' centers out to its bounds
def volumed():  # Volume objects
    made = opened('grid', (1, 1, 1))
    made.render.resolution_x = made.render.resolution_y = 16
    made.camera = bpy.data.objects.new('grid', bpy.data.cameras.new('grid'))
    made.collection.objects.link(made.camera)
    made.camera.location.z, made.camera.data.type, made.camera.data.ortho_scale = 2, 'ORTHO', 4
    made.collection.objects.link(volume := bpy.data.objects.new('grid', bpy.data.volumes.new('grid')))
    volume.rotation_euler.z, volume.scale.y = 0.5, 1.5
    tree = bpy.data.node_groups.new('grid', 'GeometryNodeTree')
    tree.interface.new_socket('Geometry', in_out='OUTPUT', socket_type='NodeSocketGeometry')
    cube, position, field = (tree.nodes.new(kind) for kind in ('GeometryNodeVolumeCube', 'GeometryNodeInputPosition',
        'ShaderNodeVectorMath'))
    field.operation, field.inputs[1].default_value = 'DOT_PRODUCT', (1, 0.5, 0)
    add = tree.nodes.new('ShaderNodeMath')
    add.inputs[1].default_value = 1.5
    tree.links.new(position.outputs[0], field.inputs[0]), tree.links.new(field.outputs['Value'], add.inputs[0])
    tree.links.new(add.outputs[0], cube.inputs['Density'])
    resolution, viewport = tree.nodes.new('GeometryNodeSwitch'), tree.nodes.new('GeometryNodeIsViewport')
    resolution.input_type, resolution.inputs['False'].default_value, resolution.inputs['True'].default_value = 'INT', 32, 8
    tree.links.new(viewport.outputs[0], resolution.inputs['Switch'])
    for k in 'XYZ': tree.links.new(resolution.outputs[0], cube.inputs['Resolution ' + k])
    cube.inputs['Min'].default_value, cube.inputs['Max'].default_value = (-1, -1, -1), (1, 1, 1)
    tree.links.new(cube.outputs[0], (material := tree.nodes.new('GeometryNodeSetMaterial')).inputs['Geometry'])
    tree.links.new(material.outputs[0], tree.nodes.new('NodeGroupOutput').inputs[0])
    volume.modifiers.new('grid', 'NODES').node_group = tree
    material.inputs['Material'].default_value = absorber = bpy.data.materials.new('grid')
    nodes = absorber.node_tree.nodes
    nodes.remove(nodes['Principled BSDF'])
    principled = nodes.new('ShaderNodeVolumePrincipled')
    principled.inputs['Color'].default_value, principled.inputs['Density'].default_value = (0, 0, 0, 1), 2
    principled.inputs['Density Attribute'].default_value = 'density'
    absorber.node_tree.links.new(principled.outputs[0], nodes['Material Output'].inputs['Volume'])
    def caught(change):  # A depsgraph stand-in of the updates the change makes, as Blender tells them
        updates = []
        handler = lambda scene, graph: updates.extend(types.SimpleNamespace(id=u.id, **{k: getattr(u, k) for k in
            ('is_updated_geometry', 'is_updated_transform', 'is_updated_shading')}) for u in graph.updates)
        bpy.app.handlers.depsgraph_update_post.append(handler)
        change(), bpy.context.view_layer.update(), bpy.app.handlers.depsgraph_update_post.remove(handler)
        depsgraph = bpy.context.evaluated_depsgraph_get()
        return types.SimpleNamespace(scene_eval=depsgraph.scene_eval, object_instances=depsgraph.object_instances,
            updates=updates)
    # The viewport's export reads a grid once: not again for the updates its read makes, nor once its volume moved,
    # but once its geometry changed
    reads, read = [], module['lattice']
    module['lattice'] = lambda *args: (reads.append(args[1]), read(*args))[1]
    exporter = exported()
    repiped(exporter, own := caught(lambda: None))
    repiped(exporter, moved := caught(lambda: setattr(volume, 'location', (0, 0, 0.1))))
    assert reads == ['density'] and own.updates and [(u.is_updated_transform, u.is_updated_geometry) for u in
        moved.updates if u.id.original == volume] == [(True, False)], 'grid kept'
    repiped(exporter, caught(lambda: setattr(add.inputs[1], 'default_value', 1.5)))
    module['lattice'], volume.location = read, (0, 0, 0)
    assert reads == ['density'] * 2, ('grid read anew', reads)
    # A grid without an active voxel, a Volume Cube of density 0, reads as one voxel of 0, no medium, leaving nothing
    blank = bpy.data.node_groups.new('grid blank', 'GeometryNodeTree')
    blank.interface.new_socket('Geometry', in_out='OUTPUT', socket_type='NodeSocketGeometry')
    (zero := blank.nodes.new('GeometryNodeVolumeCube')).inputs['Density'].default_value = 0
    blank.links.new(zero.outputs[0], blank.nodes.new('NodeGroupOutput').inputs[0])
    made.collection.objects.link(empty := bpy.data.objects.new('grid blank', bpy.data.volumes.new('grid blank')))
    empty.modifiers.new('grid blank', 'NODES').node_group = blank
    left = lambda: [len(ids) for ids in (bpy.data.scenes, bpy.data.objects, bpy.data.volumes, bpy.data.meshes,
        bpy.data.node_groups, os.listdir(bpy.app.tempdir))]  # IDs and temporary files
    kept = left()
    values, low, size = module['dense'](read(empty.evaluated_get(bpy.context.evaluated_depsgraph_get()), 'density'),
        empty.name, 'density')
    assert values.tolist() == [0] and size.tolist() == [1, 1, 1] and left() == kept, ('empty grid', values, kept, left())
    bpy.data.objects.remove(empty)
    # A grid of two spheres of radius 0.05 6 apart at voxels of 0.01, 609^3 over its active box, stops the render naming
    # its extent before its lattice is made: its few voxels read, their box measured
    wide = bpy.data.node_groups.new('grid wide', 'GeometryNodeTree')
    wide.interface.new_socket('Geometry', in_out='OUTPUT', socket_type='NodeSocketGeometry')
    line, spheres = wide.nodes.new('GeometryNodeMeshLine'), wide.nodes.new('GeometryNodePointsToVolume')
    line.inputs['Count'].default_value, line.inputs['Offset'].default_value = 2, (6, 6, 6)
    spheres.inputs['Resolution Mode'].default_value, spheres.inputs['Voxel Size'].default_value = 'Size', 0.01
    spheres.inputs['Radius'].default_value = 0.05
    wide.links.new(line.outputs[0], spheres.inputs['Points'])
    wide.links.new(spheres.outputs[0], wide.nodes.new('NodeGroupOutput').inputs[0])
    made.collection.objects.link(spread := bpy.data.objects.new('grid wide', bpy.data.volumes.new('grid wide')))
    spread.modifiers.new('grid wide', 'NODES').node_group = wide
    points = read(spread.evaluated_get(bpy.context.evaluated_depsgraph_get()), 'density')
    index = numpy.column_stack((points['x'], points['y'], points['z']))
    message = module['oversized'](spread.name, 'density', (index + points['extent'][:, None]).max(0) - index.min(0))
    assert message and "'grid wide' spans 609 x 609 x 609 voxels" in message, ('wide grid', message)
    bpy.data.objects.remove(spread)
    # A volume object no Volume output fills, of no material or of a surface's, exports as Principled Volume's defaults
    # fill it, byte for byte, its box's surface passing all light
    alone, filled = opened('grid default', (1, 1, 1)), bpy.data.node_groups.new('grid default', 'GeometryNodeTree')
    filled.interface.new_socket('Geometry', in_out='OUTPUT', socket_type='NodeSocketGeometry')
    unit, assigned = filled.nodes.new('GeometryNodeVolumeCube'), filled.nodes.new('GeometryNodeSetMaterial')
    filled.links.new(unit.outputs[0], assigned.inputs['Geometry'])
    filled.links.new(assigned.outputs[0], filled.nodes.new('NodeGroupOutput').inputs[0])
    alone.collection.objects.link(plain := bpy.data.objects.new('grid default', bpy.data.volumes.new('grid default')))
    plain.modifiers.new('grid default', 'NODES').node_group = filled
    default = bpy.data.materials.new('grid default')
    default.node_tree.nodes.remove(default.node_tree.nodes['Principled BSDF'])
    default.node_tree.links.new(default.node_tree.nodes.new('ShaderNodeVolumePrincipled').outputs[0],
        default.node_tree.nodes['Material Output'].inputs['Volume'])
    piped = []
    for material in (None, bpy.data.materials.new('grid surface'), default):
        assigned.inputs['Material'].default_value = material
        piped.append(exported().requests.getvalue())
    assert piped[0] == piped[1] == piped[2], ('default volume', [len(bytes) for bytes in piped])
    bpy.context.window.scene = made
    evaluated = volume.evaluated_get(bpy.context.evaluated_depsgraph_get())
    # The render's 32^3 grid's bounds, half a voxel of 2 / 31 past its outermost centres at ±1, not the viewport's 8^3
    low, high = numpy.full(3, -1 - 1 / 31), numpy.full(3, 1 + 1 / 31)
    inverse = numpy.array(evaluated.matrix_world.inverted())
    u = (numpy.arange(32) + 0.5) / 32 * 4 - 2  # Down 32 x 32 points across the view at 200 depths
    depth = (numpy.arange(200) + 0.5) / 200 * 3 - 1.5
    view = numpy.stack(numpy.broadcast_arrays(u[None, :, None], u[:, None, None], depth), -1)
    local = view @ inverse[:3, :3].T + inverse[:3, 3]
    inside = ((local >= low) & (local <= high)).all(-1)
    clamped = numpy.clip(local, -1, 1)
    due = numpy.exp(-2 * ((1.5 + clamped[..., 0] + clamped[..., 1] / 2) * inside).sum(-1) * 3 / 200)
    assert numpy.ptp(quarters(due)) > 0.1, ('grid quarters', quarters(due))
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = quarters(render(made, 16).mean(2))
        assert numpy.abs(seen - quarters(due)).max() < 0.02, ('volume grid', preferences.device, seen, quarters(due))
    preferences.device = device
    # Clipped at 1, Blender's most, the voxels below it empty: the density at the 32 voxel centres a side, zeroed under
    # 1, bilinear between them (constant in z), which reads apart from the field unclipped
    centre = numpy.linspace(-1, 1, 32)
    kept = 1.5 + centre[None, :] + centre[:, None] / 2
    kept[kept < 1] = 0
    at = (clamped[..., :2] + 1) * 31 / 2
    i, f = numpy.minimum(at.astype(int), 30), at - numpy.minimum(at.astype(int), 30)
    lerp = lambda a, b, t: a + (b - a) * t
    field = lerp(lerp(kept[i[..., 1], i[..., 0]], kept[i[..., 1], i[..., 0] + 1], f[..., 0]),
        lerp(kept[i[..., 1] + 1, i[..., 0]], kept[i[..., 1] + 1, i[..., 0] + 1], f[..., 0]), f[..., 1])
    clipped = numpy.exp(-2 * (field * inside).sum(-1) * 3 / 200)
    assert numpy.abs(quarters(clipped) - quarters(due)).max() > 0.1, ('clipping apart', quarters(clipped))
    volume.data.render.clipping = 1
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = quarters(render(made, 16).mean(2))
        assert numpy.abs(seen - quarters(clipped)).max() < 0.02, ('clipping', preferences.device, seen,
            quarters(clipped))
    preferences.device, volume.data.render.clipping = device, 0.001
    # A vector grid c = (0.5 + 0.4 x, 0.5 - 0.4 y, 0.3) over a 32^3 cube as the one above (of a varying density, as a
    # constant one makes tiles of one value), saved to a .vdb file and rendered from it by its path as the color of a
    # Volume Absorption of density 2: each quarter passes per channel exp(-2 (1 - c) x its depth through the box), c
    # extended past the outermost voxels' centers out to its bounds
    colored = opened('grid color', (1, 1, 1))
    colored.render.resolution_x = colored.render.resolution_y = 16
    colored.camera = made.camera
    colored.collection.objects.link(made.camera)
    painted = bpy.data.node_groups.new('grid color', 'GeometryNodeTree')
    painted.interface.new_socket('Geometry', in_out='OUTPUT', socket_type='NodeSocketGeometry')
    box, density, field, position, scaled, store = (painted.nodes.new(kind) for kind in ('GeometryNodeVolumeCube',
        'GeometryNodeGetNamedGrid', 'GeometryNodeFieldToGrid', 'GeometryNodeInputPosition', 'ShaderNodeVectorMath',
        'GeometryNodeStoreNamedGrid'))
    for k in 'XYZ': box.inputs['Resolution ' + k].default_value = 32
    box.inputs['Min'].default_value, box.inputs['Max'].default_value = (-1, -1, -1), (1, 1, 1)
    density.inputs['Name'].default_value, store.inputs['Name'].default_value = 'density', 'color'
    field.grid_items.new('VECTOR', 'color'), setattr(store, 'data_type', 'VECTOR_FLOAT')
    scaled.operation, scaled.inputs[1].default_value, scaled.inputs[2].default_value = 'MULTIPLY_ADD', (0.4, -0.4, 0), \
        (0.5, 0.5, 0.3)
    for out, to in ((box.outputs[0], density.inputs['Volume']), (density.outputs['Grid'], field.inputs['Topology']),
        (position.outputs[0], scaled.inputs[0]), (scaled.outputs[0], field.inputs[1]),
        (scaled.outputs[0], box.inputs['Density']), (density.outputs['Volume'], store.inputs['Volume']),
        (field.outputs[0], store.inputs['Grid']),
        (store.outputs[0], painted.nodes.new('NodeGroupOutput').inputs[0])): painted.links.new(out, to)
    colored.collection.objects.link(source := bpy.data.objects.new('grid color', bpy.data.volumes.new('grid color')))
    source.modifiers.new('grid color', 'NODES').node_group = painted
    path = os.path.join(bpy.app.tempdir, 'grid color.vdb')
    source.evaluated_get(bpy.context.evaluated_depsgraph_get()).data.grids.save(path)
    bpy.data.objects.remove(source)
    colored.collection.objects.link(loaded := bpy.data.objects.new('grid file', bpy.data.volumes.new('grid file')))
    loaded.data.filepath = path
    loaded.data.materials.append(tinted := bpy.data.materials.new('grid color'))
    nodes = tinted.node_tree.nodes
    nodes.remove(nodes['Principled BSDF'])
    absorbing, attribute = nodes.new('ShaderNodeVolumeAbsorption'), nodes.new('ShaderNodeAttribute')
    attribute.attribute_name, absorbing.inputs['Density'].default_value = 'color', 2
    tinted.node_tree.links.new(attribute.outputs['Color'], absorbing.inputs['Color'])
    tinted.node_tree.links.new(absorbing.outputs[0], nodes['Material Output'].inputs['Volume'])
    v = (numpy.arange(256) + 0.5) / 256 * 4 - 2  # Fine enough that the box's edge falls within a pixel as rendered
    x, y = numpy.clip(v[None, :], -1, 1), numpy.clip(v[:, None], -1, 1)
    inside = (numpy.abs(v[None, :]) <= high[0]) & (numpy.abs(v[:, None]) <= high[1])
    c = numpy.stack(numpy.broadcast_arrays(0.5 + 0.4 * x, 0.5 - 0.4 * y, 0.3), -1)
    due = numpy.stack([quarters(numpy.exp(-2 * (1 - c[..., k]) * 2 * high[2] * inside)) for k in range(3)], -1)
    assert numpy.ptp(due[..., 0] - due[..., 1]) > 0.1, ('grid color', due)  # Its channels apart
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = render(colored, 16)
        seen = numpy.stack([quarters(seen[..., k]) for k in range(3)], -1)
        assert numpy.abs(seen - due).max() < 0.02, ('vector grid', preferences.device, seen, due)
    preferences.device = device
    bpy.context.window.scene = shown
volumed()
# A black body's color, of luminance 1 in scene linear, lies on the Planckian locus within 3e-4 in xy, as Kim et al.
# 2002 fit it, from 4000 K to past 12000 K: a Blackbody node seen on an emitter of strength 1, its table filtered as
# each backend filters it
shown = bpy.context.window.scene
body = opened('black body')
body.world.node_tree.nodes['Background'].inputs['Color'].default_value, body.flex_samples = (0, 0, 0, 1), 4
body.camera = bpy.data.objects.new('black body', bpy.data.cameras.new('black body'))
body.collection.objects.link(body.camera)
body.camera.location.z, body.camera.data.type, body.camera.data.ortho_scale = 2, 'ORTHO', 1  # Filled by the emitter
glowing = bpy.data.meshes.new('black body')
bm = bmesh.new()
bmesh.ops.create_grid(bm, size=2)
bm.to_mesh(glowing)
glowing.materials.append(hot := bpy.data.materials.new('black body'))
emitting, heated = (hot.node_tree.nodes.new(kind) for kind in ('ShaderNodeEmission', 'ShaderNodeBlackbody'))
hot.node_tree.links.new(heated.outputs[0], emitting.inputs['Color'])
hot.node_tree.links.new(emitting.outputs[0], hot.node_tree.nodes['Material Output'].inputs['Surface'])
body.collection.objects.link(portal := bpy.data.objects.new('black body', glowing))
def planckian(temperature):  # The Planckian locus's xy, as Kim et al. 2002 fit it from 4000 K
    kim = -3.0258469e9 / temperature ** 3 + 2.1070379e6 / temperature ** 2 + 0.2226347e3 / temperature + 0.240390
    return kim, 3.0817580 * kim ** 3 - 5.87338670 * kim ** 2 + 3.75112997 * kim - 0.37001483
for temperature in (4000, 6500, 20000):
    heated.inputs['Temperature'].default_value = temperature
    locus = *planckian(temperature), 1
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = render(body)
        xyz = numpy.array(Color(seen.mean((0, 1))).from_scene_linear_to_xyz_d65())
        assert numpy.allclose((*xyz[:2] / xyz.sum(), xyz[1]), locus, atol=3e-4), ('black body', temperature,
            preferences.device, xyz)
preferences.device = device
# An Environment Texture without a vector reads along its position from the world's origin, as in the world along the
# ray: an emitter at (-2, -2, 2.83) seen straight down reads the texel at u 0.875, v 0.75 of a 4 x 2 image, where its
# generated point, a direction of the +x+y+z octant, read u 0.25 to 0.5
body.camera.location = -2, -2, 4.83
portal.location = -2, -2, 2.83
texels = numpy.array([(k / 8, 1 - k / 8, (k % 3) / 2, 1) for k in range(8)], 'f')
(sky := bpy.data.images.new('sky texels', 4, 2, float_buffer=True)).pixels.foreach_set(texels.ravel())
looked = hot.node_tree.nodes.new('ShaderNodeTexEnvironment')
looked.image, looked.interpolation = sky, 'Closest'
hot.node_tree.links.new(looked.outputs[0], emitting.inputs['Color'])
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(body).mean((0, 1))
    assert numpy.allclose(seen, texels[4 + 3, :3], atol=1e-3), ('environment by position', preferences.device, seen)
preferences.device = device
# A light emitting from its back alone, as a window mixing a transparent front by Backfacing, is sampled by its back's
# power: a Lambert floor of albedo 0.8 a unit below a square of half 0.1 emitting 10 blue downward, seen straight down
# through it, reads 0.8 * 10 F within a tenth, F the square's form factor at the floor (Hottel), at 16 samples its
# pixels spread under 0.45 of their mean beside a red square of its power, which shares the light samples with it (main
# 02f9398, counting the back at a thousandth of its power, 0.63)
def backlit():  # The scene: its squares, each a material of its nodes and links without a shader
    lit = opened('back light')
    lit.world.node_tree.nodes['Background'].inputs['Color'].default_value, lit.flex_samples = (0, 0, 0, 1), 16
    lit.camera = bpy.data.objects.new('back light', bpy.data.cameras.new('back light'))
    lit.collection.objects.link(lit.camera)
    lit.camera.location.z, lit.camera.data.type, lit.camera.data.ortho_scale = 2, 'ORTHO', 0.04
    def square(name, half, z):
        bm, mesh = bmesh.new(), bpy.data.meshes.new(name)
        bmesh.ops.create_grid(bm, size=half)
        bm.to_mesh(mesh)
        lit.collection.objects.link(placed := bpy.data.objects.new(name, mesh))
        placed.location.z, made = z, bpy.data.materials.new(name)
        mesh.materials.append(made)
        made.node_tree.nodes.remove(made.node_tree.nodes['Principled BSDF'])
        return made.node_tree.nodes, made.node_tree.links, made.node_tree.nodes['Material Output'].inputs['Surface']
    nodes, links, out = square('back floor', 5, 0)
    links.new((floor := nodes.new('ShaderNodeBsdfDiffuse')).outputs[0], out)
    floor.inputs['Color'].default_value = (0.8, 0.8, 0.8, 1)
    nodes, links, out = square('back light', 0.1, 1)  # Its back emits, its front passes light
    links.new((sides := nodes.new('ShaderNodeMixShader')).outputs[0], out)
    links.new(nodes.new('ShaderNodeNewGeometry').outputs['Backfacing'], sides.inputs[0])
    links.new(nodes.new('ShaderNodeBsdfTransparent').outputs[0], sides.inputs[1])
    links.new((glow := nodes.new('ShaderNodeEmission')).outputs[0], sides.inputs[2])
    glow.inputs['Color'].default_value, glow.inputs['Strength'].default_value = (0, 0, 1, 1), 10
    nodes, links, out = square('back decoy', 0.1, 1)  # Beside it, a red emitter of its power facing down
    links.new((decoy := nodes.new('ShaderNodeEmission')).outputs[0], out)
    decoy.inputs['Color'].default_value, decoy.inputs['Strength'].default_value = (1, 0, 0, 1), 10
    bpy.data.objects['back decoy'].location.x, bpy.data.objects['back decoy'].rotation_euler.x = 0.6, math.pi
    return lit
backlight, form = backlit(), 4 / (2 * math.pi) * 2 * 0.1 / math.sqrt(1.01) * math.atan(0.1 / math.sqrt(1.01))
for preferences.device in ('OPTIX', 'VULKAN'):
    blue = render(backlight)[..., 2]
    assert abs(blue.mean() / (8 * form) - 1) < 0.1 and blue.std() < 0.45 * blue.mean(), ('back light',
        preferences.device, blue.mean() / (8 * form), blue.std() / blue.mean())
preferences.device = device
bpy.context.window.scene = shown
# A Principled Volume's blackbody emits per unit length that color times a black body's radiance at its temperature,
# its exitance 5.670374419e-8 T^4 over PI, by its intensity at Blender's unit scale of 1e-6: at intensity 2 and 1500 K
# 0.18275 times that color; at 0 K nothing, never negative
radiant = bpy.data.materials.new('blackbody').node_tree
radiator = radiant.nodes.new('ShaderNodeVolumePrincipled')
radiant.links.new(radiator.outputs[0], radiant.nodes['Material Output'].inputs['Volume'])
radiator.inputs['Blackbody Intensity'].default_value = 2
for temperature in (1500, 0):
    radiator.inputs['Temperature'].default_value = temperature
    flex.SIDE['volume'] = True
    glow = flex.fold(flex.resolve(radiant.nodes['Material Output'].inputs['Volume']))[4]
    flex.SIDE['volume'] = False
    radiance = 2 * 5.670374419e-8 * temperature ** 4 * 1e-6 / math.pi
    assert not numpy.any(glow) if not radiance else glow[0] == 'MULTIPLY' and repr(glow[1]) == repr(flex.fold(
        flex.blackbody(temperature, radiator))) and numpy.allclose(glow[2], radiance, rtol=1e-6, atol=0), (
        'blackbody radiance', temperature, glow, radiance)
# A volume emitting 0.5 per unit length, unscaled by its density, absorbing by the density 2 z over its
# generated points or by 1, seen straight down against a black world, glows by the integral of its emission times its
# transmittance along its depth of 2: 0.3200 and 0.4323, where its emission dropped would leave it black
glow = new('emitting volume')
glow.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
glow.collection.objects.link(cube := bpy.data.objects.new('emitting volume', mesh.copy()))
cube.data.materials[0] = glowing = mesh.materials[0].copy()
emitter = glowing.node_tree.nodes['Principled Volume']
emitter.inputs['Emission Strength'].default_value, emitter.inputs['Emission Color'].default_value = 0.5, (1, 1, 1, 1)
glow.camera = fog.camera
glow.collection.objects.link(fog.camera)
depth = numpy.linspace(0, 2, 200001)
for optical, density in ((2 * depth - depth * depth / 2, None), (depth, 1)):
    if density: glowing.node_tree.links.remove(emitter.inputs['Density'].links[0])
    if density: emitter.inputs['Density'].default_value = density
    expected = numpy.trapezoid(0.5 * numpy.exp(-optical), depth)
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = render(glow).mean()
        assert abs(seen / expected - 1) < 0.01, ('emitting volume', density, preferences.device, seen, expected)
preferences.device = device
# A camera inside the emitting volume, now of density 1, at its center seeing straight down from its near plane at depth
# 0.01: glows by 0.5 (1 - exp(-0.99)) on its way out, where its own medium's emission dropped would leave it black
lit = new('emitting inside')
lit.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
lit.collection.objects.link(bpy.data.objects.new('emitting inside', cube.data))
lit.camera = inside.camera
lit.collection.objects.link(inside.camera)
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(lit).mean()
    assert abs(seen / (0.5 * (1 - math.exp(-0.99))) - 1) < 0.01, ('camera inside an emitting volume',
        preferences.device, seen)
preferences.device = device
# The same at 4 paths a sample, ReSTIR on and off: each path's glow at its share, no reservoir stored without ReSTIR
lit.flex_paths = 4
for lit.flex_restir in (True, False):
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = render(lit).mean()
        assert abs(seen / (0.5 * (1 - math.exp(-0.99))) - 1) < 0.01, ('camera inside an emitting volume at 4 paths',
            lit.flex_restir, preferences.device, seen)
preferences.device = device
# The absorber of density read from an image of straight alpha, its alpha unread: its colors associated, 0.5 and 0.75
# of white and of three quarters at alphas 0.5 and 1 across x, under its straight colors' bound of 1, seen through its
# depth of 2 at 1024 samples against a white sky again, the floor and sun gone, its halves passing exp(-1) and
# exp(-1.5), within 0.7% over 4 seeds
fog.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
for gone in (ob, sun): fog.collection.objects.unlink(gone)
nodes, links = mesh.materials[0].node_tree.nodes, mesh.materials[0].node_tree.links  # The absorber's again
straight = bpy.data.images.new('straight', 2, 1, alpha=True, float_buffer=True)
straight.pixels.foreach_set((1, 1, 1, 0.5, 0.75, 0.75, 0.75, 1))
fog.flex_samples = 1024
reader = nodes.new('ShaderNodeTexImage')
reader.image, reader.interpolation, straight.alpha_mode = straight, 'Closest', 'STRAIGHT'
links.new(nodes['Texture Coordinate'].outputs['Generated'], reader.inputs['Vector'])
links.new(reader.outputs['Color'], absorber.inputs['Density'])
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(fog).mean((0, 2))
    halves = seen[:SIZE // 2].mean(), seen[SIZE // 2:].mean()
    assert numpy.allclose(halves, numpy.exp((-1, -1.5)), rtol=0.02), ('straight image in a volume', preferences.device,
        halves)
preferences.device = device

# White furnace: a white metal sphere of roughness 0.5 under a sky of one scatters each ray once, so a pixel it covers
# holds GGX's single-scatter albedo under exact Smith masking at the pixel's view cosines, 0.8801 over those within its
# silhouette, times FlexKernels' rebounce there, m = min(1 / (1 - lost), 1 / E_up(mu)) (its pathtracer.slang's fits):
# 0.9858, integrated numerically; and never above 1
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
assert abs(disk[covered].mean() - 0.9858) < 0.003 and disk[covered].mean() <= 1, ('rough metal furnace',
    disk[covered].mean())

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

# Camera rays through three overlapping camera-hidden point lights of radius 1, as the Junkshop scene's, under reuse:
# their spheres cross where two surfaces lie 1e-4 apart, which once held a ray between them forever, on both backends
scene = new('hidden lights')
scene.render.resolution_x, scene.render.resolution_y = 1280, 720
scene.flex_samples, scene.flex_restir, scene.flex_neighbors, scene.flex_bounces = 64, True, 3, 16
scene.camera = add(bpy.data.cameras.new('hidden lights'), (0, 0, 0))
scene.camera.matrix_world = Matrix(((0.776316, 0.127446, 0.617326, 4.49636),
    (0.630344, -0.157011, -0.760272, -8.036633), (3.4e-05, 0.979339, -0.202225, 0.634935), (0, 0, 0, 1)))
scene.camera.data.lens, scene.camera.data.sensor_width = 24.972034, 32
shape('hidden floor', grid(40), (0, 0, -0.5))
for k, x, y in ((0, 1.372625, -1.460703), (1, 1.823639, -1.343166), (2, 1.594032, -1.392367)):
    light = bpy.data.lights.new(f'hidden light {k}', 'POINT')
    light.shadow_soft_size, light.energy = 1, 12
    add(light, (x, y, 0.903875)).visible_camera = False
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    bpy.ops.render.render(scene=scene.name, write_still=True)
    assert numpy.isfinite(bpy.data.images.load(scene.render.filepath).pixels[:]).all(), f'hidden lights {device}'

# A Hosek-Wilkie sky seen straight up through a narrow lens holds the model's zenith radiance: (0.0112, 0.0230, 0.0441)
# by the published formula at turbidity 2.9, ground albedo 0.3 and the sun 18.5 degrees up, as Blender's node scales it
# (by 2 pi / 683), evaluated apart from Flex
scene = new('sky texture', samples=16)
dome = scene.world.node_tree.nodes.new('ShaderNodeTexSky')
dome.sky_type, dome.turbidity, dome.ground_albedo, dome.sun_direction = 'HOSEK_WILKIE', 2.9, 0.3, (-0.946, 0.062, 0.318)
scene.world.node_tree.links.new(dome.outputs['Color'], scene.world.node_tree.nodes['Background'].inputs['Color'])
scene.camera = add(bpy.data.cameras.new('sky texture'), (0, 0, 0), (math.pi, 0, 0))
scene.camera.data.angle = 0.01
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    assert numpy.allclose(render().mean((0, 1)), (0.0112, 0.0230, 0.0441), rtol=0.02), ('zenith sky', device)
# Through RGB curves, the sky's colour chain read as one table of it, the same: the curves at the zenith's colour, as
# Blender's own curve evaluator takes them, the combined curve first
curves = scene.world.node_tree.nodes.new('ShaderNodeRGBCurve')
curves.mapping.curves[3].points.new(0.02, 0.3)
links = scene.world.node_tree.links
links.new(dome.outputs['Color'], curves.inputs['Color'])
links.new(curves.outputs['Color'], scene.world.node_tree.nodes['Background'].inputs['Color'])
curves.mapping.update()
due = [curves.mapping.evaluate(curves.mapping.curves[c], curves.mapping.evaluate(curves.mapping.curves[3], value))
    for c, value in enumerate((0.0112, 0.0230, 0.0441))]
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    assert numpy.allclose(render().mean((0, 1)), due, rtol=0.02), ('folded sky', device, due)
# Grazing the horizon, the same table: a view 0.1 degrees wide, 0.15 degrees up and 94 degrees from a sun 2 degrees up,
# at turbidity 9 and ground albedo 0, holds the formula's mean over the view, (0.0027952, 0.0015028, 0.00047345),
# evaluated apart from Flex
links.new(dome.outputs['Color'], scene.world.node_tree.nodes['Background'].inputs['Color'])
dome.turbidity, dome.ground_albedo, dome.sun_direction = 9, 0, (math.cos(math.radians(2)), 0, math.sin(math.radians(2)))
scene.camera.rotation_euler = (math.pi / 2 + math.radians(0.15), 0, math.radians(4))
scene.camera.data.sensor_width, scene.camera.data.lens = 1, 0.5 / math.tan(math.radians(0.05))
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    assert numpy.allclose(render().mean((0, 1)), (0.0027952, 0.0015028, 0.00047345), rtol=0.02), ('grazing sky', device)
# A value edited in a material whose emission is a folded sky chain pipes steps alone, the chain's table kept, as in a
# material without one, where a table made anew would count as a new texture and export the scene anew; also after
# Blender copied the material anew in between, as new data makes it do, its nodes at new addresses: tables are keyed by
# the original nodes, read from the evaluated
bpy.context.window.scene = scene
glowing, material = plane('glowing', 0), bpy.data.materials['glowing']
glow, gamma = material.node_tree.nodes.new('ShaderNodeTexSky'), material.node_tree.nodes.new('ShaderNodeGamma')
glow.sky_type, gamma.inputs['Gamma'].default_value = 'HOSEK_WILKIE', 2.2
material.node_tree.links.new(glow.outputs['Color'], gamma.inputs['Color'])
material.node_tree.links.new(gamma.outputs['Color'], glowing.inputs['Emission Color'])
def churned(material):  # Of a value edited in the material after Blender copied it anew, the kind piped
    exporter = exported()
    exporter.start, exporter.requests = lambda depsgraph: Viewport.engine.start(exporter, depsgraph), io.BytesIO()
    for group in [bpy.data.node_groups.new(f'churn {k}', 'ShaderNodeTree') for k in range(50)]:
        for _ in range(5): group.nodes.new('ShaderNodeMath')
    material.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value += 0.1
    depsgraph = bpy.context.evaluated_depsgraph_get()
    Viewport.engine.start(exporter, types.SimpleNamespace(scene_eval=depsgraph.scene_eval,
        object_instances=depsgraph.object_instances, updates=[types.SimpleNamespace(id=material,
        is_updated_geometry=False, is_updated_transform=False)]))
    for group in [group for group in bpy.data.node_groups if group.name.startswith('churn')]:
        bpy.data.node_groups.remove(group)
    return numpy.frombuffer(exporter.requests.getvalue(), 'I', count=1)[0]
assert churned(material) == flex.STEPS, 'value beside a folded sky'
# So beside a live color ramp, which the update reads again from the material's evaluated copy
ramped, material = plane('ramped', 0), bpy.data.materials['ramped']
facing, ramp = material.node_tree.nodes.new('ShaderNodeLayerWeight'), material.node_tree.nodes.new('ShaderNodeValToRGB')
ramp.color_ramp.elements[1].color, ramped.inputs['Emission Strength'].default_value = (0.2, 0.5, 0.9, 1), 1
material.node_tree.links.new(facing.outputs['Facing'], ramp.inputs['Fac'])
material.node_tree.links.new(ramp.outputs['Color'], ramped.inputs['Emission Color'])
assert churned(material) == flex.STEPS, 'value beside a color ramp'
assert all(node.id_data.is_evaluated for node in module['SOURCES'].values() if isinstance(node, bpy.types.Node)), \
    'tables read from evaluated nodes'
# A kept engine under two skies, an emitter of one's colour tinted by the other's edited between two F12s with no
# export between, pipes steps alone, which the renderer reads as piped: its second F12 is a new engine's; so a kept
# viewport's draw after the same edit. Steps it can't read leave it waiting: its renderers killed after 60 s, the row
# fails
scene.camera.location, scene.camera.rotation_euler = (0, 0, 3), (0, 0, 0)
scene.camera.data.sensor_width, scene.camera.data.lens = 36, 50
material = bpy.data.materials['glowing']
roughness = material.node_tree.nodes['Principled BSDF'].inputs['Roughness']
tint = material.node_tree.nodes.new('ShaderNodeTexSky')
tint.sky_type, tint.turbidity = 'HOSEK_WILKIE', 5
material.node_tree.links.new(tint.outputs['Color'], material.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
depsgraph = bpy.context.evaluated_depsgraph_get()
context = types.SimpleNamespace(region=region, region_data=types.SimpleNamespace(view_matrix=scene.camera.matrix_world
    .inverted(), window_matrix=scene.camera.calc_matrix_camera(depsgraph, x=SIZE, y=SIZE), view_perspective='CAMERA'),
    space_data=types.SimpleNamespace(camera=scene.camera, clip_end=1000))
def sky_drawn(viewport, updated):  # The viewport's draw to its sample limit once updated by the depsgraph given
    with offscreen.bind():
        gpu.matrix.load_matrix(Matrix.Identity(4))
        gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE, 2 / SIZE, 1, 1)))
        viewport.view_update(context, updated)
        viewport.view_draw(context, bpy.context.evaluated_depsgraph_get())
        while viewport.__dict__.pop('redraw', False): viewport.view_draw(context, bpy.context.evaluated_depsgraph_get())
        return numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0, 'FLOAT').to_list())
def watched(f, *args):  # f(*args), its renderers killed if it takes past 60 s
    watchdog = threading.Timer(60, subprocess.run, (('pkill', '-P', str(os.getpid()), 'renderer'),))
    watchdog.start()
    value = f(*args)
    watchdog.cancel()
    return value
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    scene.render.use_persistent_data, roughness.default_value = True, 0.5
    render()
    roughness.default_value = 0.6
    shown = watched(render)
    scene.render.use_persistent_data = False
    assert numpy.allclose(shown, render(), atol=2e-3), ('kept sky', device)
    roughness.default_value = 0.5
    sky_drawn(kept := Viewport(), bpy.context.evaluated_depsgraph_get())
    roughness.default_value = 0.6
    depsgraph = bpy.context.evaluated_depsgraph_get()
    edit = types.SimpleNamespace(scene_eval=depsgraph.scene_eval, object_instances=depsgraph.object_instances,
        updates=[types.SimpleNamespace(id=material, is_updated_geometry=False, is_updated_transform=False)])
    assert numpy.allclose(watched(sky_drawn, kept, edit), sky_drawn(Viewport(), depsgraph), atol=2e-3), \
        ('kept sky viewport', device)

# A thin slab of a medium scattering 0.01 of what crosses it and absorbing nothing, lit from below by a parallel sun 30
# degrees off the straight-up view of an orthographic camera above, scatters it once: its radiance follows its phase
# function, Henyey-Greenstein's at g 0.6 over the isotropic one's 4 pi p(cos 30 degrees) = 3.52 times, on both backends
scene = new('phase', 16, 1024, (0, 0, 0))
slab = bpy.data.meshes.new('phase slab')
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1)
bm.to_mesh(slab)
slab.materials.append(medium := bpy.data.materials.new('phase slab'))
medium.node_tree.nodes.remove(medium.node_tree.nodes['Principled BSDF'])
scatterer = medium.node_tree.nodes.new('ShaderNodeVolumeScatter')
scatterer.inputs['Density'].default_value = 0.1
medium.node_tree.links.new(scatterer.outputs[0], medium.node_tree.nodes['Material Output'].inputs['Volume'])
add(slab, (0, 0, 0)).scale = (10, 10, 0.1)
scene.camera = add(bpy.data.cameras.new('phase'), (0, 0, 1))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 1
beam = add(bpy.data.lights.new('phase sun', 'SUN'), (0, 0, -1), (math.pi * 5 / 6, 0, 0))  # Shining up 30 degrees off
beam.data.energy, beam.data.angle = 100, 0
due = (1 - 0.6 ** 2) / (1 + 0.6 ** 2 - 2 * 0.6 * math.cos(math.pi / 6)) ** 1.5
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    lit = []
    for g in (0, 0.6):
        scatterer.inputs['Anisotropy'].default_value = g
        lit.append(render(scene, 16).mean())
    assert numpy.isclose(lit[1] / lit[0], due, rtol=0.05), ('henyey-greenstein', device, lit, due)
# Inside a closed emitter of radiance 1 filled by a medium absorbing nothing and scattering forward at g 0.9, every
# pixel reads 1, the furnace's, as the phase function's sampling and its evaluation weigh alike; so at the slider's
# ends, g 1 and -1, which the exporter keeps short of the delta they are
scene = new('phase furnace', 16, 256, (0, 0, 0))
box = bpy.data.meshes.new('phase furnace')
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=2)
bm.to_mesh(box)
box.materials.append(walls := bpy.data.materials.new('phase furnace'))
walls.node_tree.nodes.remove(walls.node_tree.nodes['Principled BSDF'])
thick = walls.node_tree.nodes.new('ShaderNodeVolumeScatter')
thick.inputs['Density'].default_value = 1
walls.node_tree.links.new(walls.node_tree.nodes.new('ShaderNodeEmission').outputs[0],
    walls.node_tree.nodes['Material Output'].inputs['Surface'])
walls.node_tree.links.new(thick.outputs[0], walls.node_tree.nodes['Material Output'].inputs['Volume'])
add(box, (0, 0, 0))
scene.camera, scene.flex_bounces = add(bpy.data.cameras.new('phase furnace'), (0, 0, 0)), 64
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    for thick.inputs['Anisotropy'].default_value in (0.9, 1, -1):
        seen = render(scene, 16)
        assert numpy.isfinite(seen).all() and numpy.isclose(seen.mean(), 1, rtol=0.02), \
            ('phase furnace', device, thick.inputs['Anisotropy'].default_value)

# The world's volume fills a box around the objects, the lights but a sun, and the camera's near plane, BOX_MARGIN m
# of their extent's diagonal past them. Absorbing s = (0.1, 0.2, 0.3) per unit length from the near plane at clip
# start c on:
#   emitter of radiance 1 two units off: exp(-(2 - c) s)
#   sky of 1 past the box's far face, d = 10 + m - c off: exp(-d s), 1 in a channel it leaves clear
#   past a unit of fog of 0.5 per unit length it holds, the world's medium again: exp(-(1 - c) s - 0.5)
#   a view moved out of the box, above it, meets the medium at its face, m past the near plane: exp(-(2 - c + m) s)
# and a world of density 0 renders as one of no volume, exactly
scene = new('world box', 16, 64, (1, 1, 1))
scene.camera = add(bpy.data.cameras.new('world box'), (0, 0, 0))
scene.camera.data.angle = 0.1
target = plane('world target', 0, size=4)
target.inputs['Base Color'].default_value, target.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
target.inputs['Emission Strength'].default_value = 1
bpy.data.objects['world target'].location.z = -2
plane('world far', 0, size=4).inputs['Base Color'].default_value = (0, 0, 0, 1)
bpy.data.objects['world far'].location.z, bpy.data.objects['world far'].visible_camera = -10, False
fog = shape('world fog', lambda bm: bmesh.ops.create_cube(bm, size=1), (0, 0, -1)).id_data
fog.links.remove(fog.nodes['Material Output'].inputs['Surface'].links[0])
absorber = fog.nodes.new('ShaderNodeVolumeAbsorption')
absorber.inputs['Color'].default_value = (0.5, 0.5, 0.5, 1)
fog.links.new(absorber.outputs[0], fog.nodes['Material Output'].inputs['Volume'])
haze = scene.world.node_tree.nodes.new('ShaderNodeVolumeAbsorption')
s, c = numpy.array((0.1, 0.2, 0.3)), scene.camera.data.clip_start
m = flex.BOX_MARGIN * max(numpy.linalg.norm((4, 4, 10 - c)), 1)
d = 10 + m - c
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    bpy.data.objects['world target'].hide_render = bpy.data.objects['world fog'].hide_render = True
    clear = render(scene, 16)
    scene.world.node_tree.links.new(haze.outputs[0], scene.world.node_tree.nodes['World Output'].inputs['Volume'])
    for color, density, shown, due in (((0.9, 0.8, 0.7), 1, ('world target',), numpy.exp(-(2 - c) * s)),
            ((0.9, 0.8, 0.7), 1, (), numpy.exp(-d * s)), ((0, 1, 1), 1, (), (numpy.exp(-d), 1, 1)),
            ((0.9, 0.8, 0.7), 1, ('world target', 'world fog'), numpy.exp(-(1 - c) * s - 0.5)),
            ((0.9, 0.8, 0.7), 0, (), None)):
        haze.inputs['Color'].default_value, haze.inputs['Density'].default_value = (*color, 1), density
        for name in ('world target', 'world fog'): bpy.data.objects[name].hide_render = name not in shown
        seen = render(scene, 16)
        assert numpy.array_equal(seen, clear) if due is None else numpy.allclose(seen.mean((0, 1)), due, atol=0.01), \
            ('world box', device, color, density, shown, seen.mean((0, 1)))
    haze.inputs['Density'].default_value, bpy.data.objects['world target'].hide_render = 1, False
    bpy.context.window.scene = scene
    depsgraph, outside = bpy.context.evaluated_depsgraph_get(), Viewport()
    context = types.SimpleNamespace(region=region, region_data=types.SimpleNamespace(view_matrix=Matrix.Translation(
        (0, 0, -5)), window_matrix=scene.camera.calc_matrix_camera(depsgraph, x=SIZE, y=SIZE),
        view_perspective='CAMERA'), space_data=types.SimpleNamespace(camera=scene.camera, clip_end=1000))
    with offscreen.bind():
        gpu.matrix.load_matrix(Matrix.Identity(4))
        gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE, 2 / SIZE, 1, 1)))
        outside.view_update(context, depsgraph)
        outside.view_draw(context, depsgraph)
        while outside.__dict__.pop('redraw', False): outside.view_draw(context, depsgraph)
        drawn = numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0, 'FLOAT').to_list())
    assert numpy.allclose(drawn[..., :3].mean((0, 1)), numpy.exp(-(2 - c + m) * s), atol=0.01), \
        ('world box outside', device, drawn[..., :3].mean((0, 1)))
    scene.world.node_tree.links.remove(scene.world.node_tree.nodes['World Output'].inputs['Volume'].links[0])

# A viewport whose export raises, of a world's volume that emits, its error caught where Blender catches it, pipes no
# request and draws nothing; the volume emitting nothing, an update of the scene alone exports anew and draws it
preferences.device = 'OPTIX'
glow = scene.world.node_tree.nodes.new('ShaderNodeVolumePrincipled')
glow.inputs['Emission Strength'].default_value = 1
scene.world.node_tree.links.new(glow.outputs[0], scene.world.node_tree.nodes['World Output'].inputs['Volume'])
failing, raised = Viewport(), []
pipes, failing.requests, failing.answers = (failing.requests, failing.answers), io.BytesIO(), io.BytesIO()
def handled(_, graph): raised.append(True), failing.view_update(context, graph)
bpy.app.handlers.depsgraph_update_post.append(handled)
bpy.context.view_layer.update()
bpy.app.handlers.depsgraph_update_post.remove(handled)
with offscreen.bind():
    gpu.state.active_framebuffer_get().clear(color=(0, 0, 0, 0))
    failing.view_draw(context, bpy.context.evaluated_depsgraph_get())
    blank = numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0, 'FLOAT').to_list())
assert raised and failing.visible is None and not failing.requests.getvalue() and not blank.any(), 'failed export'
failing.requests, failing.answers = pipes
scene.world.node_tree.links.remove(glow.outputs[0].links[0])
depsgraph = bpy.context.evaluated_depsgraph_get()
alone = types.SimpleNamespace(scene_eval=depsgraph.scene_eval, object_instances=depsgraph.object_instances,
    scene=depsgraph.scene, mode=depsgraph.mode, updates=[types.SimpleNamespace(id=scene, is_updated_geometry=False,
    is_updated_transform=False, is_updated_shading=False)])
with offscreen.bind():
    gpu.matrix.load_matrix(Matrix.Identity(4))
    gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE, 2 / SIZE, 1, 1)))
    failing.view_update(context, alone)
    failing.view_draw(context, depsgraph)
    while failing.__dict__.pop('redraw', False): failing.view_draw(context, depsgraph)
    drawn = numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0, 'FLOAT').to_list())
assert numpy.allclose(drawn[..., :3].mean((0, 1)), 1, atol=0.01), ('exported anew', drawn[..., :3].mean((0, 1)))

# A camera that moved changes no step, as each request carries it: with a value changed, the update Blender reports
# pipes the steps; with an object parented to it, moved too, the whole scene, as an export anew pipes it; alone, nothing
def cameraed():  # A moved camera's updates
    shown, moving = bpy.context.window.scene, opened('moved camera')
    moving.camera = bpy.data.objects.new('moved camera', bpy.data.cameras.new('moved camera'))
    moving.camera.location.z = 5
    meshes = []
    for name, parent in (('moved cube', None), ('moved child', moving.camera)):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1)
        bm.to_mesh(data := bpy.data.meshes.new(name)), bm.free()
        data.materials.append(bpy.data.materials.new(name))
        meshes.append(bpy.data.objects.new(name, data))
        meshes[-1].parent, meshes[-1].location.z = parent, -2 if parent else 0
    for ob in (moving.camera, *meshes): moving.collection.objects.link(ob)
    color = meshes[0].data.materials[0].node_tree.nodes['Principled BSDF'].inputs['Base Color']
    exporter = exported()
    def piped():  # The kind and bytes start() pipes on the updates Blender reports
        run = lambda _, graph: Viewport.engine.start(exporter, graph)
        exporter.requests = io.BytesIO()
        bpy.app.handlers.depsgraph_update_post.append(run)
        bpy.context.view_layer.update()
        bpy.app.handlers.depsgraph_update_post.remove(run)
        data = exporter.requests.getvalue()
        return struct.unpack('<I', data[:4])[0] if data else None, data
    moving.camera.location.x, color.default_value = 0.5, (0.2, 0.4, 0.6, 1)
    kind, data = piped()
    assert kind == flex.SCENE and data == exported().requests.getvalue(), ('camera and child moved', kind)
    meshes[1].parent = None
    piped()
    moving.camera.location.x, color.default_value = 1, (0.6, 0.4, 0.2, 1)
    assert piped()[0] == flex.STEPS, 'camera moved, a value changed'
    moving.camera.location.x = 1.5
    assert piped()[0] is None, 'camera moved alone'
    bpy.context.window.scene = shown
cameraed()

# A kept engine's rows taken again: of two exporters of the same scene, one taking its last rows again and one shading
# anew, the updates Blender reports pipe the same, byte for byte, whatever changed; an update that changes no material
# shades none, one of one material's value that one alone
def replayed():  # A kept engine's rows taken again
    shown, kept = bpy.context.window.scene, opened('replayed')
    shades, shade = [], flex.shade
    flex.shade = lambda *args: shades.append(args[0]) or shade(*args)
    image = bpy.data.images.new('replayed', 4, 4)
    for name, x in (('replayed noise', -1), ('replayed image', 1)):
        bm = bmesh.new()
        bm.loops.layers.uv.new()
        bmesh.ops.create_grid(bm, size=0.5, calc_uvs=True)
        bm.to_mesh(data := bpy.data.meshes.new(name)), bm.free()
        data.materials.append(material := bpy.data.materials.new(name))
        kept.collection.objects.link(ob := bpy.data.objects.new(name, data))
        ob.location.x, nodes = x, material.node_tree.nodes
        source = nodes.new('ShaderNodeTexNoise' if x < 0 else 'ShaderNodeTexImage')
        if x > 0: source.image = image
        material.node_tree.links.new(source.outputs['Color'], nodes['Principled BSDF'].inputs['Base Color'])
    principled = bpy.data.materials['replayed image'].node_tree.nodes['Principled BSDF']
    class Exporter:  # A kept engine without a renderer: its scene piped into its requests, exported anew by itself
        start, visible, requests = Viewport.engine.start, (), None
    exporters = [Exporter(), Exporter()]
    def piped(change):  # After the change, what each exporter pipes, the second's last rows dropped; the first's shades
        exporters[1].kept, shades[:], first = {}, [], []
        for exporter in exporters: exporter.requests = io.BytesIO()
        def run(_, graph):
            exporters[0].start(graph, True)
            first[:] = shades
            exporters[1].start(graph, True)
        reported = bpy.app.handlers.depsgraph_update_post, bpy.app.handlers.frame_change_post
        for handlers in reported: handlers.append(run)
        change()
        bpy.context.view_layer.update()
        for handlers in reported: handlers.remove(run)
        taken, anew = (exporter.requests.getvalue() for exporter in exporters)
        assert taken and taken == anew, ('rows taken again', change.__name__, len(taken), len(anew))
        return first
    def untouched(): principled.inputs['Roughness'].default_value = principled.inputs['Roughness'].default_value
    piped(untouched)  # The scene's first update, all of it reported
    def value(): principled.inputs['Roughness'].default_value = 0.25
    def linked(): principled.id_data.links.new(principled.id_data.nodes['Image Texture'].outputs['Alpha'],
        principled.inputs['Metallic'])
    def painted(): image.pixels.foreach_set(numpy.full(64, 0.5, 'f')), image.update_tag()
    def unwrapped(): bpy.data.meshes['replayed noise'].uv_layers[0].data[0].uv = (0.1, 0.1)
    def modified(): bpy.data.objects['replayed noise'].modifiers.new('subdivided', 'SUBSURF')
    def sampled(): kept.world.flex_sample_light = False
    assert piped(untouched) == [] and [m.name for m in piped(value)] == ['replayed image'], 'rows shaded'
    for change in (linked, painted, unwrapped, modified, sampled): piped(change)
    for frame, roughness in ((1, 0.3), (2, 0.6)):
        principled.inputs['Roughness'].default_value = roughness
        principled.inputs['Roughness'].keyframe_insert('default_value', frame=frame)
    piped(lambda: kept.frame_set(1))
    assert [m.name for m in piped(lambda: kept.frame_set(2))] == ['replayed image'], 'frame stepped'
    flex.shade, bpy.context.window.scene = shade, shown
replayed()

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
# Under a black roof hidden from shadows, or lit by a sun casting none, as Cycles', the floor holds the same; the roof
# and sun as usual, none (main, of neither setting, reads none all three times)
plane('sun roof', 0, size=4).inputs['Base Color'].default_value = (0, 0, 0, 1)
(roof := bpy.data.objects['sun roof']).location.z = 1.5
for roof.visible_shadow, sun.use_shadow, due in ((False, True, 1), (True, False, 1), (True, True, 0)):
    for device in ('OPTIX', 'VULKAN'):
        preferences.device = device
        assert numpy.isclose(render().mean(), due, rtol=0.01, atol=0.01), ('shadowless', roof.visible_shadow,
            sun.use_shadow, device)
# A mesh and materials linked by the roof and a copy of it, one over the floor and the other far off casting shadows,
# either way round: the floor dark under the one casting them and lit under the one hidden from them, each instance
# masked by its own setting
twin = roof.copy()
scene.collection.objects.link(twin)
for near, far in ((roof, twin), (twin, roof)):
    near.location.x, far.location.x, far.visible_shadow = 0, 100, True
    for near.visible_shadow, due in ((True, 0), (False, 1)):  # Over the floor, casting: dark, so it is there
        for device in ('OPTIX', 'VULKAN'):
            preferences.device = device
            assert numpy.isclose(render().mean(), due, rtol=0.01, atol=0.01), ('shared mesh', near.name,
                near.visible_shadow, device)
bpy.data.objects.remove(twin)
roof.location.x, roof.visible_shadow = 0, True
# An emitter hidden from shadows still meets the roof on its way down, sunless: none (a form testing the emitter itself
# against nothing read 1.58)
(glow := plane('sun glow', 0, size=4)).inputs['Emission Color'].default_value = (1, 1, 1, 1)
glow.inputs['Emission Strength'].default_value = 1
glow = bpy.data.objects['sun glow']
glow.location.z, glow.rotation_euler.x, glow.visible_shadow = 2.5, math.pi, False
(beam := next(ob for ob in bpy.data.objects if ob.data == sun)).hide_render = True  # The camera is the one named sun
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    assert render().mean() < 0.01, ('shadowless glow', device)
# Hidden from shadows, the roof is still seen: lowered between the camera and the floor, black (camera rays skipping
# it read 1)
glow.hide_render, beam.hide_render, roof.location.z, roof.visible_shadow = True, False, 0.5, False
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    assert render().mean() < 0.01, ('shadowless seen', device)
bpy.data.objects.remove(roof), bpy.data.objects.remove(glow)  # The sun alone again, as the shells below take it
# A sphere light occludes nothing, as Cycles' lights: the sun reaches the floor through a camera-hidden point light of
# radius 1 centered 2.5 over it, whose own 0.01 W adds 0.01 / (4 pi^2 2.5^2) there, and through one of no power
# centered 0.5 over it, which the floor and the camera lie within; the floor holds one, as before, on both backends
for height, power in ((2.5, 0.01), (0.5, 0)):
    shell = add(bpy.data.lights.new(f'shell {height}', 'POINT'), (0, 0, height))
    shell.data.shadow_soft_size, shell.data.energy, shell.visible_camera = 1, power, False
    for device in ('OPTIX', 'VULKAN'):
        preferences.device = device
        seen = render().mean()
        assert numpy.isclose(seen, 1 + power / (4 * math.pi ** 2 * height ** 2), rtol=0.01), ('light shell', height,
            device, seen)
    bpy.data.objects.remove(shell)
# A sphere light is a thin shell glowing on both sides at half its radiance L = P / (pi A), the shell the icosphere of
# 320 faces the export draws and A its area: the floor crossing a hidden one of 100 W and radius 1 centered 0.5 over it,
# the sun off, holds L / 2 within it, each way up crossing one face, and without it L / 2 by the projected solid angle
# of the ways up through its faces, met twice, by quadrature over the hemisphere: within 2% both, nowhere dark, seen
# across the rim at 0.866 from the axis
shell = add(bpy.data.lights.new('crossed shell', 'POINT'), (0, 0, 0.5))
shell.data.shadow_soft_size, shell.data.energy, shell.visible_camera = 1, 100, False
sun.energy, scene.flex_samples = 0, 1024
scene.camera.location, scene.camera.data.ortho_scale = (1, 0, 1.6), 2
bmesh.ops.create_icosphere(ico := bmesh.new(), subdivisions=3, radius=1)  # The shell as the export draws it
corners = numpy.array([[v.co for v in face.verts] for face in ico.faces]) + (0, 0, 0.5)
half = 100 / (2 * math.pi * sum(face.calc_area() for face in ico.faces))
ico.free()
theta, phi = ((numpy.arange(n) + 0.5) / n * k for n, k in ((64, math.pi / 2), (128, 2 * math.pi)))
theta, phi = numpy.meshgrid(theta, phi, indexing='ij')
up = numpy.stack((numpy.sin(theta) * numpy.cos(phi), numpy.sin(theta) * numpy.sin(phi), numpy.cos(theta)), -1)
up = up[..., None, :]  # Against each face
along, across = corners[:, 1] - corners[:, 0], corners[:, 2] - corners[:, 0]
def crossed(rho):  # Of a point of the floor at rho from the axis, half the radiance's multiple its irradiance over pi is
    s = numpy.array((rho, 0, 0)) - corners[:, 0]
    h, q = numpy.cross(up, across), numpy.cross(s, along)
    with numpy.errstate(divide='ignore', invalid='ignore'):  # Faces the way up runs along meet it nowhere
        det = (h * along).sum(-1)
        u, v, t = (h * s).sum(-1) / det, (up * q).sum(-1) / det, (across * q).sum(-1) / det
    meets = ((u >= 0) & (v >= 0) & (u + v <= 1) & (t > 0)).sum(-1)  # The faces each way up crosses
    return (meets * numpy.cos(theta) * numpy.sin(theta)).sum() * (2 * math.pi / 128) * (math.pi / 2 / 64) / math.pi
y, x = (numpy.mgrid[:SIZE, :SIZE] + 0.5) / SIZE * 2  # The pixels' points, the axis at y 1, x 0
y = y - 1
rho = numpy.hypot(x, y)
rings = numpy.linspace(0, 2.3, 93)
due = half * numpy.interp(rho, rings, [crossed(r) for r in rings])
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    seen = render().mean(2)
    for name, band in (('inside', rho < 0.8), ('outside', (rho > 0.95) & (rho < 1.4))):
        assert numpy.isclose(seen[band].mean(), due[band].mean(), rtol=0.02), ('crossed shell', name, device,
            seen[band].mean(), due[band].mean())
    assert (seen > 0.5 * due).all(), ('crossed shell dark', device)
bpy.data.objects.remove(shell)

# Blender's lights 2 m over Lambertian 0.8, seen from above: each ring of pixels about the light holds 0.8 / pi of the
# irradiance Cycles' conventions give there, within 3% where above a tenth of the peak and under 1% of the peak where
# none is due. A point of 500 W, unnormalized at exposure 1 and 3000 K too; a spot of 60 degrees blended 0.3; a disk of
# size 1, spread 30 degrees too, and emitting by its nodes a Light Falloff's quadratic, linear and constant output of
# strength 4 and smooth 0.5, and one of a quadratic falloff of strength 20 and smooth 1 colored by a Blackbody of
# 5000 K, its color the Planckian locus's of luminance 1; a sun of 3 W/m^2 turned 30 degrees; on both backends
scene = opened('lights')
scene.flex_samples = 1024  # The spread's narrow beam within 2% of its truth at the ring around its peak
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
scene.camera = add(bpy.data.cameras.new('lights'), (0, 0, 10))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 6
floor = plane('lights floor', 0, size=8)
floor.inputs['Base Color'].default_value, floor.inputs['Roughness'].default_value = (0.8, 0.8, 0.8, 1), 1
x, y = numpy.meshgrid(*[((numpy.arange(SIZE) + 0.5) / SIZE - 0.5) * 6] * 2)
rho, d = numpy.hypot(x, y), numpy.sqrt(x * x + y * y + 4)
r, p = numpy.meshgrid((numpy.arange(24) + 0.5) / 48, (numpy.arange(48) + 0.5) * math.pi / 24)  # Over the disk
def disk(half, falloff=lambda length: 1):  # Its irradiance, by the half angle of its spread, Cycles' soft box, and by
    # what its nodes emit by the length to it
    dx, dy = x[..., None, None] - r * numpy.cos(p), y[..., None, None] - r * numpy.sin(p)
    cosine = 2 / numpy.sqrt(dx * dx + dy * dy + 4)
    spread = numpy.maximum(math.tan(half) - numpy.sqrt(1 - cosine ** 2) / cosine, 0) / (math.tan(half) - half) \
        if half < math.pi / 2 else 1
    return (2000 / math.pi ** 2 * cosine ** 4 / 4 * spread * falloff(2 / cosine) * r / 48 * math.pi / 24).sum((2, 3))
point = 500 / (4 * math.pi) * 2 / d ** 3
t = numpy.clip((2 / d - math.cos(math.pi / 6)) / ((1 - math.cos(math.pi / 6)) * 0.3), 0, 1)
lights = {}
for name, kind, values, irradiance in (('point', 'POINT', dict(shadow_soft_size=0), point),
        ('unnormalized', 'POINT', dict(shadow_soft_size=0.05, exposure=1, use_temperature=True, temperature=3000,
        normalize=False), point * 2 * 4 * math.pi * 0.05 ** 2), ('spot', 'SPOT', dict(shadow_soft_size=0,
        spot_size=math.pi / 3, spot_blend=0.3), point * t * t * (3 - 2 * t)),
        ('disk', 'AREA', dict(shape='DISK', size=1), disk(math.pi / 2)),
        ('spread', 'AREA', dict(shape='DISK', size=1, spread=math.pi / 6), disk(math.pi / 12)),
        *((f'falloff {k}', 'AREA', dict(shape='DISK', size=1, use_nodes=True), disk(math.pi / 2,
        lambda length, k=k: 4 * length ** k * length ** 2 / (0.5 + length ** 2))) for k in range(3)),
        ('ies', 'AREA', dict(shape='DISK', size=1, use_nodes=True), disk(math.pi / 2)),  # Its tree unknown, as main's
        ('blackbody', 'AREA', dict(shape='DISK', size=1, use_nodes=True), disk(math.pi / 2,
        lambda length: 20 * length ** 2 * length ** 2 / (1 + length ** 2))),
        ('turned sun', 'SUN', dict(energy=3, angle=math.radians(1)), numpy.full_like(x, 3 * math.cos(math.pi / 6)))):
    light = bpy.data.lights.new(name, kind)
    light.energy = 500
    for key, value in values.items(): setattr(light, key, value)
    lights[name] = add(light, (0, 0, 2), (0, math.pi / 6 * (kind == 'SUN'), 0)), irradiance[..., None] \
        * numpy.resize(light.temperature_color if light.use_temperature else 1, 3)
    lights[name][0].visible_camera = False
    if name.startswith('falloff'):
        tree, falloff = light.node_tree, light.node_tree.nodes.new('ShaderNodeLightFalloff')
        falloff.inputs['Strength'].default_value, falloff.inputs['Smooth'].default_value = 4, 0.5
        tree.links.new(falloff.outputs[int(name[-1])], tree.nodes['Emission'].inputs['Strength'])
    if name == 'blackbody':  # Falloff into Strength, Blackbody into Color, as classroom's ceiling lamps
        tree, falloff = light.node_tree, light.node_tree.nodes.new('ShaderNodeLightFalloff')
        falloff.inputs['Strength'].default_value, falloff.inputs['Smooth'].default_value = 20, 1
        tree.links.new(falloff.outputs[2], tree.nodes['Emission'].inputs['Strength'])
        (heat := tree.nodes.new('ShaderNodeBlackbody')).inputs['Temperature'].default_value = 5000
        tree.links.new(heat.outputs[0], tree.nodes['Emission'].inputs['Color'])
        x, y = planckian(5000)
        hue = Color((x / y, 1, (1 - x - y) / y)).from_xyz_d65_to_scene_linear()
        lights[name] = lights[name][0], lights[name][1] * hue
    if name == 'ies':  # An IES Texture of strength 0.03 (a form passing it through read 3%)
        (ies := light.node_tree.nodes.new('ShaderNodeTexIES')).inputs['Strength'].default_value = 0.03
        light.node_tree.links.new(ies.outputs[0], light.node_tree.nodes['Emission'].inputs['Strength'])
rings = lambda image: numpy.array([image[(rho >= k * 0.375) & (rho < k * 0.375 + 0.375)].mean(0) for k in range(11)])
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    for name, (ob, irradiance) in lights.items():
        for other, _ in lights.values(): other.hide_render = other != ob
        measured, expected = rings(render()), rings(0.8 / math.pi * irradiance)
        peak = expected.max()
        assert all(abs(measured[expected > 0.1 * peak] / expected[expected > 0.1 * peak] - 1) < 0.03), (name, device)
        assert all(measured[expected == 0] < 0.01 * peak), (name, device, 'none due')
# Beside the point light, each falloff's light shares the light samples by its power a unit away, where every output is
# its strength: at 16 samples its pixels stray from their due as the disk's do beside it, within half again (by no ray's
# length its power is none; far, the linear and constant ones take every sample)
scene.flex_samples, scene.flex_restir = 16, False
def stray(name):  # Relative spread of the pixels about their due, lit by that light and the point one
    for other, _ in lights.values(): other.hide_render = other not in (lights[name][0], lights['point'][0])
    due = 0.8 / math.pi * (lights[name][1] + lights['point'][1]).sum(2)
    return (render().sum(2) / due)[due > 0.1 * due.max()].std()
for preferences.device in ('OPTIX', 'VULKAN'):
    strays = [stray(name) for name in ('disk', 'falloff 0', 'falloff 1', 'falloff 2')]
    assert max(strays[1:]) < 1.5 * strays[0], ('falloff samples', preferences.device, strays)
scene.flex_samples, scene.flex_restir = 1024, True
# Turned, a spot exports anew, as its program holds its cone's axis; moved, it updates in place
spot = lights['spot'][0]
for other, _ in lights.values(): other.hide_render = other != spot
bpy.context.view_layer.update()
exporter = exported(depsgraph := bpy.context.evaluated_depsgraph_get())
# Anew, as an update can
exporter.start = lambda depsgraph, keeping=False: Viewport.engine.start(exporter, depsgraph, keeping)
for vector, kind in ((spot.location, flex.UPDATE), (spot.rotation_euler, flex.SCENE)):
    vector.x, exporter.requests = 0.5, io.BytesIO()
    bpy.context.view_layer.update()
    exporter.start(updated(depsgraph, spot))
    assert numpy.frombuffer(exporter.requests.getvalue(), 'I', count=1)[0] == kind, ('spot update', kind)
# A spread of 0, Blender's parallel beam, renders as 5 degrees: under the footprint, inside its edge by the reach of 5
# degrees and a pixel, the disk's exitance P / A within 5%; past the footprint 5.5% of the light, none past the reach
beam = lights['spread'][0]
beam.data.spread, scene.camera.data.ortho_scale = 0, 2
for other, _ in lights.values(): other.hide_render = other != beam
x, y = numpy.meshgrid(*[((numpy.arange(SIZE) + 0.5) / SIZE - 0.5) * 2] * 2)
rho, reach = numpy.hypot(x, y), 2 * math.tan(math.radians(2.5))
for device in ('OPTIX', 'VULKAN'):
    preferences.device = device
    image = render().mean(-1)
    assert abs(image[rho < 0.5 - reach - 2 / SIZE].mean() / (1600 / math.pi ** 2) - 1) < 0.05, ('parallel beam', device)
    assert 0.03 < image[rho > 0.5].sum() / image.sum() < 0.08, ('parallel beam spill', device)
    assert not image[rho > 0.5 + reach + 2 / SIZE].any(), ('parallel beam reach', device)

# A mesh renders with the UV map marked for rendering, as in Cycles, not the one selected for editing: a plane's render
# map of a quarter everywhere is the one it exports
scene = opened('render uv')
scene.camera = add(bpy.data.cameras.new('render uv'), (0, 0, 2))
plane('render uv', 0, 0)
mesh = bpy.data.meshes['render uv']
quarter = mesh.uv_layers.new(name='render')
quarter.uv.foreach_set('vector', [0.25] * 2 * len(mesh.loops))
quarter.active_render, mesh.uv_layers.active = True, mesh.uv_layers[0]  # The grid's own UVs selected
exporter = exported()
piped = exporter.requests.getvalue()
header = numpy.frombuffer(piped, 'I', count=11)  # Mesh triangles, past the steps, instances and four columns before UVs
assert numpy.all(numpy.frombuffer(piped, 'f', count=6 * header[8], offset=44 + 16 * header[2]
    + tables(piped, 44 + 16 * header[2]) + 200 * header[9]
    + 36 * 4 * header[8])
    == 0.25), 'render uv map'

# A chain of mixes, each multiplying the last into itself at a factor of a half, which keeps it in both of the mix's
# terms, shares the first one's expression 2^20 times: folding, keying and summarizing each shared part once, and
# emitting its steps by keys hashed once, its export takes linear time, not exponential
scene = opened('chain')
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
scene = opened('slots')
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

# Sheen under the white sky, on a sphere seen from 10 away: alone, a Sheen BSDF of roughness 0.5 returns at each
# view cosine its albedo there, by midpoint quadrature over the hemisphere, rising toward the rim where a diffuse stays
# flat; over the Principled BSDF's white diffuse by weight 1, what it receives, held as below
scene = new('sheen')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
scene.camera = add(bpy.data.cameras.new('sheen'), (0, 0, 10))
scene.camera.data.angle = 2 * math.atan(0.12)
sheened = shape('sheened', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=128, v_segments=64, radius=1), (0, 0, 0))
bpy.data.meshes['sheened'].shade_smooth()
sheen = sheened.id_data.nodes.new('ShaderNodeBsdfSheen')
sheen.inputs['Color'].default_value, sheen.inputs['Roughness'].default_value = (1, 1, 1, 1), 0.5
sheened.id_data.links.new(sheen.outputs[0], sheened.id_data.get_output_node('CYCLES').inputs['Surface'])
theta, phi = numpy.meshgrid((numpy.arange(256) + 0.5) / 256 * math.pi / 2, (numpy.arange(512) + 0.5) / 512 * 2 * math.pi)
light = numpy.stack([numpy.sin(theta) * numpy.cos(phi), numpy.sin(theta) * numpy.sin(phi), numpy.cos(theta)], -1)
def albedo(mu):  # Of Charlie's distribution of roughness 0.5 by Ashikhmin's visibility, white
    half = light + (math.sqrt(1 - mu * mu), 0, mu)
    sine = 1 - (half[..., 2] / numpy.linalg.norm(half, axis=-1)) ** 2
    return (4 * sine / (2 * math.pi) / (4 * (light[..., 2] + mu - light[..., 2] * mu)) * light[..., 2]
        * numpy.sin(theta)).sum() * (math.pi / 2 / 256) * (2 * math.pi / 512)
albedos = [albedo(mu) for mu in numpy.linspace(0, 1, 33)]
# Through each pixel's point dx, dy off its centre: the view cosine on the sphere, else 0, and the albedo or sky's 1
def seen(dx, dy):
    u, v = (((numpy.arange(SIZE) + 0.5 + d) / SIZE * 2 - 1) * 0.12 for d in (dx, dy))
    ray = numpy.stack([*numpy.meshgrid(u, v), -numpy.ones((SIZE, SIZE))], -1)
    ray /= numpy.linalg.norm(ray, axis=-1, keepdims=True)
    toward = -10 * ray[..., 2]
    reach = toward ** 2 - 99
    hit = numpy.array((0, 0, 10)) + (toward - numpy.sqrt(numpy.clip(reach, 0, None)))[..., None] * ray
    cosine = numpy.where(reach > 0, -(hit * ray).sum(-1), 0)
    return cosine, numpy.where(reach > 0, numpy.interp(cosine, numpy.linspace(0, 1, 33), albedos), 1)
cosine, offsets = seen(0, 0)[0], (numpy.arange(16) + 0.5) / 16 - 0.5
# Each pixel's albedo over its area, as the renderer's box filter jitters its rays; its ring by its centre's cosine
expected = numpy.mean([seen(dx, dy)[1] for dx in offsets for dy in offsets], 0)
for preferences.device in ('OPTIX', 'VULKAN'):
    pixels = render().mean(-1)
    for low, high in ((0.9, 1), (0.4, 0.6), (0.15, 0.3)):
        ring = (cosine > low) & (cosine <= high)
        print('SHEEN', preferences.device, 'at cosines', low, high, pixels[ring].mean(), 'albedo',
            expected[ring].mean(), flush=True)
        assert numpy.isclose(pixels[ring].mean(), expected[ring].mean(), rtol=0.03), ('sheen albedo',
            preferences.device)
sheened.inputs['Base Color'].default_value, sheened.inputs['IOR'].default_value = (1, 1, 1, 1), 1
sheened.inputs['Sheen Weight'].default_value, sheened.inputs['Sheen Roughness'].default_value = 1, 0.5
sheened.id_data.links.new(sheened.outputs[0], sheened.id_data.get_output_node('CYCLES').inputs['Surface'])
# The furnace twice, sized by 16 independent renders (the sphere alone in a different cell of a 4 x 4 canvas each): with
# ReSTIR, as the scenes render, within 3 SD of one image, 0.014, of 1, which guards against reuse adding or losing
# light; without it, where one image spreads 0.0005, within 0.0015 of the 0.9992 those renders read, which guards
# the lobe's energy itself
for preferences.device in ('OPTIX', 'VULKAN'):
    furnaces = []
    for scene.flex_restir in (True, False): furnaces.append(render().mean(-1)[cosine > 0.15].mean())
    print('SHEEN furnace', preferences.device, 'ReSTIR on and off', furnaces, flush=True)
    assert abs(furnaces[0] - 1) <= 0.014 and abs(furnaces[1] - 0.9992) <= 0.0015, ('sheen furnace',
        preferences.device, furnaces)
scene.flex_restir, preferences.device = True, device
# The Sheen BSDF's Ashikhmin distribution, white on the same sphere: at each view cosine its
# albedo, D G / (4 cos) by midpoint quadrature over the hemisphere, of its roughness s, the node's Roughness;
# at s 0.6 almost none straight on and most of it toward the rim, on both backends; each pixel's over its area, as
# the sheen's, the sky's 1 past the rim; each ring within 3 SD of one image, as 16 independent renders (the sphere
# alone in a different cell of a 4 x 4 canvas each) spread
def velveted():  # The Sheen BSDF's Ashikhmin distribution
    def albedo(mu, s):  # D = exp(-cot² h / s²) / (pi s² sin⁴ h), G = min(1, 2 cos h min(cos v, cos l) / |v·h|)
        view = numpy.array((math.sqrt(1 - mu * mu), 0, mu))
        half = light + view
        half /= numpy.linalg.norm(half, axis=-1, keepdims=True)
        cos2 = half[..., 2] ** 2
        d = numpy.exp(-cos2 / (1 - cos2) / s ** 2) / (math.pi * s ** 2 * (1 - cos2) ** 2)
        g = numpy.minimum(1, 2 * half[..., 2] / numpy.abs(half @ view) * numpy.minimum(mu, light[..., 2]))
        return (d * g / (4 * mu) * numpy.sin(theta)).sum() * (math.pi / 2 / 256) * (2 * math.pi / 512)
    sheen.distribution = 'ASHIKHMIN'
    sheened.id_data.links.new(sheen.outputs[0], sheened.id_data.get_output_node('CYCLES').inputs['Surface'])
    cosines = numpy.maximum(numpy.linspace(0, 1, 33), 1e-3)
    for s in (0.6, 1):
        sheen.inputs['Roughness'].default_value = s
        table = [albedo(mu, s) for mu in cosines]
        due = numpy.mean([numpy.where(c > 0, numpy.interp(c, cosines, table), 1) for c in (seen(dx, dy)[0]
            for dx in offsets for dy in offsets)], 0)
        for preferences.device in ('OPTIX', 'VULKAN'):
            image = render().mean(-1)
            for (low, high), rtol in zip(((0.9, 1), (0.4, 0.6), (0.15, 0.3)), (0.04, 0.025, 0.045)):
                ring = (cosine > low) & (cosine <= high)
                print('VELVET', s, preferences.device, 'at cosines', low, high, image[ring].mean(), 'albedo',
                    due[ring].mean(), flush=True)
                assert numpy.isclose(image[ring].mean(), due[ring].mean(), rtol=rtol), ('velvet albedo', s, low)
    preferences.device = device
velveted()
# A sheen bounce reads Light Path's Is Diffuse Ray and Is Reflection Ray as 1 and Is Glossy Ray as 0, as when the sheen
# rode the diffuse lobe's samples. Its sphere fills the view and the white sky is not light-sampled, so only rays
# leaving the sheen reach the sky: scaled by the first two, max(output, 0), it renders as scaled by max(output, 1),
# bit for bit, the same steps on the same random numbers; scaled by the third, black
def sheen_path():  # Light Path on a sheen bounce
    lit = new('sheen path', sky=(1, 1, 1))
    lit.flex_samples, lit.flex_restir, lit.world.flex_sample_light = 16, False, False
    lit.camera = bpy.data.objects.new('sheen path', bpy.data.cameras.new('sheen path'))
    lit.camera.location, lit.camera.data.type, lit.camera.data.ortho_scale = (0, 0, 3), 'ORTHO', 1
    lit.collection.objects.link(lit.camera)
    lit.collection.objects.link(bpy.data.objects.new('sheen path', bpy.data.meshes['sheened']))
    nodes, links = lit.world.node_tree.nodes, lit.world.node_tree.links
    ray, floor = nodes.new('ShaderNodeLightPath'), nodes.new('ShaderNodeMath')
    floor.operation = 'MAXIMUM'
    links.new(floor.outputs[0], nodes['Background'].inputs['Strength'])
    sheen.distribution, sheen.inputs['Roughness'].default_value = 'MICROFIBER', 0.5
    sheened.id_data.links.new(sheen.outputs[0], sheened.id_data.get_output_node('CYCLES').inputs['Surface'])
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = {}
        for output, least in (('Is Glossy Ray', 1), ('Is Diffuse Ray', 0), ('Is Reflection Ray', 0),
                ('Is Glossy Ray', 0)):
            links.new(ray.outputs[output], floor.inputs[0])
            floor.inputs[1].default_value = least
            seen[output, least] = render(lit)
        whole = seen['Is Glossy Ray', 1]
        assert whole.any() and numpy.array_equal(seen['Is Diffuse Ray', 0], whole) and numpy.array_equal(seen[
            'Is Reflection Ray', 0], whole) and not seen['Is Glossy Ray', 0].any(), ('sheen path', preferences.device,
            {k: v.mean() for k, v in seen.items()})
    preferences.device = device
sheen_path()

# A world reading Light Path lights a glossy sphere alike through its sampled sky and its escaping rays: a white sky of
# strength 1 to diffuse rays and 0.5 to every other, over a white dielectric sphere of roughness 0.4 and IOR 1.5 seen
# whole by an orthographic camera, its disk's mean with Sample World Light within 1% of the mean without, on both
# backends; a sky sample asked the world as the camera sees it lit the diffuse lobe at the camera's 0.5, not 1
def world_by_lobe():  # A sampled sky's world per lobe
    lit = new('world by lobe', sky=(1, 1, 1))
    lit.flex_samples, lit.flex_restir = 256, False
    lit.camera = bpy.data.objects.new('world by lobe', bpy.data.cameras.new('world by lobe'))
    lit.camera.location, lit.camera.data.type, lit.camera.data.ortho_scale = (0, 0, 3), 'ORTHO', 1
    lit.collection.objects.link(lit.camera)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=64, v_segments=32, radius=0.4)
    bm.to_mesh(mesh := bpy.data.meshes.new('world by lobe')), bm.free()
    mesh.shade_smooth()
    mesh.materials.append(glossy := bpy.data.materials.new('world by lobe'))
    bsdf = glossy.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value, bsdf.inputs['Roughness'].default_value = (1, 1, 1, 1), 0.4
    bsdf.inputs['IOR'].default_value = 1.5
    lit.collection.objects.link(bpy.data.objects.new('world by lobe', mesh))
    nodes, links = lit.world.node_tree.nodes, lit.world.node_tree.links
    half = nodes.new('ShaderNodeMath')
    half.operation, half.inputs[1].default_value, half.inputs[2].default_value = 'MULTIPLY_ADD', 0.5, 0.5
    links.new(nodes.new('ShaderNodeLightPath').outputs['Is Diffuse Ray'], half.inputs[0])
    links.new(half.outputs[0], nodes['Background'].inputs['Strength'])
    x, y = numpy.meshgrid(numpy.arange(SIZE) + 0.5, numpy.arange(SIZE) + 0.5)
    disk = numpy.hypot(x - SIZE / 2, y - SIZE / 2) < 0.35 * SIZE  # Inside the sphere's silhouette of radius 0.4
    for preferences.device in ('OPTIX', 'VULKAN'):
        means = []
        for lit.world.flex_sample_light in (True, False):
            means.append(render(lit).mean(2)[disk].mean())
        assert abs(means[0] / means[1] - 1) < 0.01, ('world by lobe', preferences.device, means)
    preferences.device = device
world_by_lobe()

# Rough metal under the white sky gives back what its microfacets lose between them, at most what it receives: a unit
# sphere of white or coloured metal seen from 10 away, its pixels of view cosine above 0.15, reads at most 1 and at
# least the least directional albedo any view of it has (by quadrature of FlexKernels' measured E and its shipped
# factor), each by 3 SD of one image as 16 independent renders spread (the sphere alone in a different cell of a 4 x 4
# canvas each), per channel
def metal_furnace():  # Rough metal's furnace
    lit = new('metal furnace', sky=(1, 1, 1))
    lit.camera = bpy.data.objects.new('metal furnace', bpy.data.cameras.new('metal furnace'))
    lit.camera.location, lit.camera.data.angle = (0, 0, 10), 2 * math.atan(0.12)
    lit.collection.objects.link(lit.camera)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=128, v_segments=64, radius=1)
    bm.to_mesh(mesh := bpy.data.meshes.new('metal furnace'))
    mesh.shade_smooth()
    lit.collection.objects.link(bpy.data.objects.new('metal furnace', mesh))
    mesh.materials.append(material := bpy.data.materials.new('metal furnace'))
    metal = material.node_tree.nodes['Principled BSDF']
    metal.inputs['Metallic'].default_value = 1
    facing = cosine > 0.15  # The sheen rows' view cosines, of the same sphere seen the same way
    least = {((1, 1, 1), 0.25): 0.891, ((1, 1, 1), 0.5): 0.943, ((1, 1, 1), 1): 0.814,
        ((0.9, 0.5, 0.2), 0.25): (0.801, 0.443, 0.176), ((0.9, 0.5, 0.2), 0.5): (0.837, 0.441, 0.17),
        ((0.9, 0.5, 0.2), 1): (0.628, 0.223, 0.07)}
    # 3 SD of one image per channel, as the 16 renders measured
    margin = {((1, 1, 1), 0.25): 0.0133, ((1, 1, 1), 0.5): 0.0267, ((1, 1, 1), 1): 0.0094,
        ((0.9, 0.5, 0.2), 0.25): (0.0141, 0.0078, 0.0031), ((0.9, 0.5, 0.2), 0.5): (0.0204, 0.0109, 0.0042),
        ((0.9, 0.5, 0.2), 1): (0.0082, 0.0029, 0.0009)}
    for preferences.device in ('OPTIX', 'VULKAN'):
        for (color, roughness), low in least.items():
            metal.inputs['Base Color'].default_value, metal.inputs['Roughness'].default_value = (*color, 1), roughness
            seen = render(lit)[facing].mean(0)
            print('METAL furnace', preferences.device, color, roughness, seen, flush=True)
            assert (seen <= 1 + numpy.array(margin[color, roughness])).all() and (seen >= numpy.array(low)
                - margin[color, roughness]).all(), ('metal furnace', preferences.device, color, roughness, seen)
    preferences.device = device
metal_furnace()
# Toon BSDFs, white on the same sphere: the diffuse returns at each view cosine its profile P there, 1 within Size's
# cone, falling across Smooth's and none past it; the glossy its albedo, P about the mirror direction times cos over the
# solid angle P weighs, by midpoint quadrature over the hemisphere; on both backends
def tooned():  # Toon BSDFs
    toon = sheened.id_data.nodes.new('ShaderNodeBsdfToon')
    toon.inputs['Color'].default_value = (1, 1, 1, 1)
    sheened.id_data.links.new(toon.outputs[0], sheened.id_data.get_output_node('CYCLES').inputs['Surface'])
    def profile(t, size, smooth):  # P at the angle t from its axis
        a, w = size * math.pi / 2, smooth * math.pi / 2
        return numpy.where(t < a, 1.0, numpy.clip(1 - (t - a) / w, 0, 1) if w else 0.0)
    def glossy(mu, size, smooth):  # Its albedo at view cosine mu, white
        mirror = numpy.array((-math.sqrt(1 - mu * mu), 0, mu))
        alpha = (numpy.arange(4096) + 0.5) / 4096 * math.pi
        weighed = (profile(alpha, size, smooth) * numpy.sin(alpha)).sum() * math.pi / 4096 * 2 * math.pi
        return (profile(numpy.arccos(numpy.clip(light @ mirror, -1, 1)), size, smooth) * light[..., 2]
            * numpy.sin(theta)).sum() * (math.pi / 2 / 256) * (2 * math.pi / 512) / weighed
    cosines = numpy.linspace(0, 1, 33)
    for component, size, smooth in (('DIFFUSE', 0.5, 0), ('DIFFUSE', 0.5, 0.5), ('GLOSSY', 0.5, 0)):
        toon.component, toon.inputs['Size'].default_value, toon.inputs['Smooth'].default_value = component, size, smooth
        due = profile(numpy.arccos(cosine), size, smooth) if component == 'DIFFUSE' else numpy.interp(cosine, cosines,
            [glossy(mu, size, smooth) for mu in cosines])
        for preferences.device in ('OPTIX', 'VULKAN'):
            seen = render().mean(-1)
            for low, high in ((0.9, 1), (0.4, 0.6), (0.15, 0.3)):
                ring = (cosine > low) & (cosine <= high)
                print('TOON', component, size, smooth, preferences.device, 'at cosines', low, high, seen[ring].mean(),
                    'due', due[ring].mean(), flush=True)
                assert abs(seen[ring].mean() - due[ring].mean()) < 0.02 + 0.03 * due[ring].mean(), ('toon', component,
                    smooth, low)
    preferences.device = device
tooned()

# Anisotropy under the white sky, seen in parallel at cosine 0.3 along x, on two rectangles 1 / 0.3 long along x, so
# that each covers a square of the view: a white metal of roughness 0.5 and Principled Anisotropic 1 about Blender's
# radial tangent returns, where that runs along the view, its albedo of the roughnesses Principled's mapping gives
# along and across it, by midpoint quadrature over the hemisphere, and where it runs across, the other's; a white Glossy
# BSDF of the same roughnesses by its own mapping, along its UV map's tangent turned by a quarter, the other's throughout
scene = new('anisotropic')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
scene.flex_restir = False  # Path traced: the BSDF alone, without reuse between pixels whose tangents differ
scene.camera = add(bpy.data.cameras.new('anisotropic'), (10 * math.sqrt(0.91), 0, 3), (math.acos(0.3), 0, math.pi / 2))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 2.4
stretched = lambda bm: bmesh.ops.scale(bm, vec=(1 / 0.3, 1, 1), verts=bmesh.ops.create_grid(bm, size=0.5,
    calc_uvs=True)['verts'])
radial = shape('radial', stretched, (0, -0.6, 0))
radial.inputs['Base Color'].default_value, radial.inputs['Metallic'].default_value = (1, 1, 1, 1), 1
radial.inputs['Roughness'].default_value, radial.inputs['Anisotropic'].default_value = 0.5, 1
glossy = shape('glossy', stretched, (0, 0.6, 0)).id_data
turned, tangent = glossy.nodes.new('ShaderNodeBsdfGlossy'), glossy.nodes.new('ShaderNodeTangent')
turned.inputs['Color'].default_value, turned.inputs['Roughness'].default_value = (1, 1, 1, 1), 0.5
turned.inputs['Anisotropy'].default_value, turned.inputs['Rotation'].default_value = math.sqrt(0.1) - 1, 0.25
tangent.direction_type = 'UV_MAP'
glossy.links.new(tangent.outputs[0], turned.inputs['Tangent'])
glossy.links.new(turned.outputs[0], glossy.get_output_node('CYCLES').inputs['Surface'])
def anisotropic(ax, ay, mu=0.3):  # Of white GGX metal of the roughnesses along x and y, seen at cosine mu along x
    view = numpy.array((math.sqrt(1 - mu * mu), 0, mu))
    half = light + view
    half /= numpy.linalg.norm(half, axis=-1, keepdims=True)
    d = 1 / (math.pi * ax * ay * ((half[..., 0] / ax) ** 2 + (half[..., 1] / ay) ** 2 + half[..., 2] ** 2) ** 2)
    g1 = lambda w: 2 * w[..., 2] / (w[..., 2] + numpy.sqrt((ax * w[..., 0]) ** 2 + (ay * w[..., 1]) ** 2 + w[..., 2] ** 2))
    return (d * g1(view) * g1(light) / (4 * mu) * numpy.sin(theta)).sum() * (math.pi / 2 / 256) * (2 * math.pi / 512)
along, across = anisotropic(0.25 / math.sqrt(0.1), 0.25 * math.sqrt(0.1)), anisotropic(0.25 * math.sqrt(0.1), 0.25 / math.sqrt(0.1))
# Times FlexKernels' rebounce at the view's cosine 0.3, of its smoother axis's r = sqrt(min alpha):
# m = min(1 / (1 - lost), 1 / E_up), its pathtracer.slang's fits; the same for both, white
smoother, viewed = math.sqrt(0.25 * math.sqrt(0.1)), 0.3
lost = smoother ** 3.6317 * (2.15372 - 0.73285 * smoother ** 2) / (1 + 1.28095 * smoother ** 2)
returned = min(1.000645 - smoother * (0.003755 + viewed * (-0.041334 + viewed * (-0.909385 + viewed * 0.352754)))
    - smoother ** 2 * (0.276028 + viewed * (1.270234 + viewed * 0.0474)) - smoother ** 3 * (0.314529 - viewed
    * 0.348307) + smoother ** 4 * 0.272297, 1)
along, across = (value * min(1 / (1 - lost), 1 / returned) for value in (along, across))
pixels = render().mean(-1)
# Under each pixel the point x = -up / 0.3, y = right of the view, at the radial rectangle's generated point gx, gy
right, up = numpy.meshgrid(*[((numpy.arange(SIZE) + 0.5) / SIZE - 0.5) * 2.4] * 2)
gx, gy = 0.5 - up, right + 1.1
inside = (numpy.abs(gx - 0.5) < 0.45) & (numpy.abs(gy - 0.5) < 0.45) & (numpy.hypot(gx - 0.5, gy - 0.5) > 0.15)
bearing = numpy.arctan2(gx - 0.5, 0.5 - gy)  # Of the radial tangent from x
for name, ring, expected in (('along', inside & (numpy.abs(numpy.cos(bearing)) > math.cos(0.15)), along),
        ('across', inside & (numpy.abs(numpy.sin(bearing)) > math.cos(0.15)), across),
        ('glossy', (numpy.abs(up) < 0.45) & (numpy.abs(right - 0.6) < 0.45), across)):
    print('ANISOTROPIC', name, pixels[ring].mean(), 'of', ring.sum(), 'pixels, albedo', expected, flush=True)
    assert numpy.isclose(pixels[ring].mean(), expected, rtol=0.03) and pixels[ring].mean() <= 1, 'anisotropic albedo'
# A wall flat along its object's x, as Scale X 0 leaves one: its generated x is 1/2, so Blender's radial tangent lies
# along its normal. Seen head-on in parallel, where any tangent gives the same albedo, it returns its roughnesses' at
# cosine 1, finite throughout
scene = new('flatwall')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
scene.flex_restir = False
scene.camera = add(bpy.data.cameras.new('flatwall'), (4, 0, 0), (math.pi / 2, 0, math.pi / 2))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 1.6
wall = shape('flatwall', lambda bm: [setattr(v, 'co', (0, v.co.x, v.co.y))
    for v in bmesh.ops.create_grid(bm, size=1, calc_uvs=True)['verts']], (0, 0, 0))
wall.inputs['Base Color'].default_value, wall.inputs['Metallic'].default_value = (1, 1, 1, 1), 1
wall.inputs['Roughness'].default_value, wall.inputs['Anisotropic'].default_value = 0.5, 0.8
pixels = render().mean(-1)
albedo = anisotropic(0.25 / math.sqrt(0.28), 0.25 * math.sqrt(0.28), 1)
print('ANISOTROPIC flat wall', pixels.mean(), 'albedo', albedo, flush=True)
assert numpy.isfinite(pixels).all() and numpy.isclose(pixels.mean(), albedo, rtol=0.03), 'anisotropic flat wall'

# Flex keeps its scene between an animation's frames, each reaching the renderer as an update of what changed and
# rendering exactly as a fresh export of it does: in three jobs of two frames, as Blender updates whatever is animated
# every frame, two objects' moves, a material's value, then a deformation, a light's change and objects removed and
# added. The user's persistent data reads as it was, during the job too, so saved files never hold Flex's; the engine
# is let go once a job is done or cancelled; and a user's own persistent data stays on
scene = opened('frames')
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
def tapped(self, depsgraph, keeping=False):
    pipe, engines[len(engines):] = self.requests, [weakref.ref(self)]
    self.requests = types.SimpleNamespace(writelines=lambda parts: (kinds.append(struct.unpack('<I', (parts := [
        *parts])[0][:4])[0]), pipe.writelines(parts)))
    start(self, depsgraph, keeping)
    self.requests = pipe
during = []  # The flag as each frame renders, and a file saved then
def saving(scene, *_): during.append(scene.render.use_persistent_data), bpy.data.libraries.write(
    bpy.app.tempdir + 'during.blend', {scene})
for animate, expected in ((lambda: (keys(bpy.data.objects['moving'], 'location', (-0.5, 0.5, 0), (-0.3, 0.5, 0)),
        keys(bpy.data.objects['moving'], 'rotation_euler', (0, 0, 0), (0.3, 0.2, 0.5)),
        keys(bpy.data.objects['moving'], 'scale', (1, 1, 1), (1, 1.5, 1)),
        keys(bpy.data.objects['tinted'], 'location', (0.5, 0.5, 0), (0.6, 0.4, 0))), flex.UPDATE),
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

# An animation's frame reusing the last frame's reservoirs reuses them against the scene they were traced in, its mean
# within 1% of the same frame rendered alone at 256 samples: after a cube moved, reusing them at 192 samples, the
# instances' transforms as they were; after the visible cube switched, a scene of as many triangles numbered anew, not
# reusing them, where reusing them against the new triangles left the whole frame 4% bright
scene = opened('reused')
scene.camera = add(bpy.data.cameras.new('reused'), (0, -4, 3), (0.93, 0, 0))
scene.flex_samples, scene.flex_reuse_samples, scene.flex_reuse, scene.flex_denoise = 256, 192, True, False
scene.frame_start, scene.frame_end = 1, 2
shown = shape('shown', lambda bm: bmesh.ops.create_cube(bm, size=1), (0.8, 0, 0.5))  # Linked before the floor, the
floor = shape('reused floor', lambda bm: bmesh.ops.create_grid(bm, size=3), (0, 0, 0))  # cube after it
hidden = shape('hidden', lambda bm: bmesh.ops.create_cube(bm, size=1), (-0.8, 0, 0.5))
for bsdf, color in ((shown, (0.8, 0.1, 0.1, 1)), (floor, (0.8, 0.8, 0.8, 1)), (hidden, (0.8, 0.1, 0.1, 1))):
    bsdf.inputs['Base Color'].default_value, bsdf.inputs['Roughness'].default_value = color, 1
sun = add(bpy.data.lights.new('reused sun', 'SUN'), (0, 0, 0), (0.8, 0, 0.6))
sun.data.angle, sun.data.energy = 0.05, 3
counts, trace = [], flex.Flex.trace  # The samples each trace of the frames has
flex.Flex.trace = lambda self, *args: (traced := trace(self, *args), counts.append(int(traced[1][0, 0, 3])))[0]
for kept, animate in ((True, lambda: (setattr(bpy.data.objects['shown'], 'hide_render', True), keys(
        bpy.data.objects['hidden'], 'location', (-0.8, 0, 0.5), (0.8, 0, 0.5)))), (False, lambda: (keys(
        bpy.data.objects['shown'], 'hide_render', True, False), keys(bpy.data.objects['hidden'], 'hide_render', False,
        True)))):
    for animated in bpy.data.objects: animated.animation_data_clear()
    animate()
    counts[:] = []
    bpy.ops.render.render(animation=True, scene=scene.name)
    frame = numpy.array(bpy.data.images.load(scene.render.frame_path(frame=2)).pixels).reshape(SIZE, SIZE, 4)[..., :3]
    assert counts[-1] == (192 if kept else 256), ('reused frame', kept, counts)
    scene.frame_set(2)
    alone = render()
    assert abs(frame.mean() / alone.mean() - 1) < 0.01, ('reused frame as alone', kept, frame.mean(), alone.mean())
flex.Flex.trace = trace

# An orthographic view projects in parallel: two unit squares, one 3 units further, cover alike (64 / 3)^2 pixels in a
# final render through an ORTHO camera and in an orthographic viewport, which as in modeling sees behind its pivot too
scene = opened('ortho')
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

# A panoramic camera sees each direction at its u and v: a sphere of radius 0.5 glowing 10 units off, its light's
# centroid within half a pixel of its center's, the white world 1 elsewhere, on OptiX. Equirectangular, u and v
# its longitude to the right and latitude over their ranges; central cylindrical, its angle to the right and the height
# it crosses a cylinder of the radius at over theirs
scene = opened('panorama', (1, 1, 1))
scene.render.resolution_x, scene.render.resolution_y, scene.flex_samples = 128, 64, 16
scene.camera = add(bpy.data.cameras.new('panorama'), (0, 0, 0), (math.pi / 2, 0, 0))  # Forward y, left -x, up z
lens = scene.camera.data
lens.type, lens.longitude_min, lens.longitude_max = 'PANO', -math.pi / 2, math.pi
lens.latitude_min, lens.latitude_max = -math.pi / 4, math.pi / 2
lens.central_cylindrical_range_u_min, lens.central_cylindrical_range_u_max = -2, 2
lens.central_cylindrical_range_v_min, lens.central_cylindrical_range_v_max, lens.central_cylindrical_radius = -0.5, 1, 2
glow = shape('panorama glow', lambda bm: bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.5), (0, 0, 0))
glow.inputs['Base Color'].default_value, glow.inputs['Emission Strength'].default_value = (0, 0, 0, 1), 10
right, up = math.radians(40), math.radians(20)
for kind, d, uv in (('EQUIRECTANGULAR', (math.cos(up) * math.cos(right), -math.cos(up) * math.sin(right),
        math.sin(up)), ((right + math.pi / 2) / (1.5 * math.pi), (up + math.pi / 4) / (0.75 * math.pi))),
        ('CENTRAL_CYLINDRICAL', (math.cos(1), -math.sin(1), 0.15), (3 / 4, 0.8 / 1.5))):
    lens.panorama_type = kind
    bpy.data.objects['panorama glow'].location = 10 * Vector((-d[1], d[0], d[2])).normalized()
    preferences.device = 'OPTIX'
    bpy.ops.render.render(scene=scene.name, write_still=True)
    seen = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(64, 128, 4)[..., :3].mean(2) - 1
    at = numpy.array(uv) * (128, 64)
    x, y = numpy.meshgrid(numpy.arange(128) + 0.5, numpy.arange(64) + 0.5)
    centroid = numpy.array(((seen * x).sum(), (seen * y).sum())) / seen.sum()
    assert numpy.hypot(*(centroid - at)) < 0.5 and abs(seen[numpy.hypot(x - at[0], y - at[1]) > 6]).max() < 1e-5, \
        ('panorama', kind, centroid, at)
# A panorama's every pixel: under a world colored by its direction, 0.5 + 0.5 * direction, each pixel holds that color
# averaged over the directions its area maps to, within 1e-3 on the mean, black where it sees nothing, on OptiX. The
# directions are taken from the camera settings as Blender documents them, apart from Flex, and where the manual leaves
# a convention open, as settled for each type: the camera looks along y, left -x, up z; (x, y) is a point's offset
# from the frame's centre, for equidistant and a mirror ball's disc in its radii across the whole frame on either axis
# (an ellipse on a non-square image), for equisolid and the lens polynomial in millimetres of the sensor, its width or
# height along the side its fit names (the larger by default), the other side by the image's aspect
def frame(lens, width, height):  # A fisheye's frame: its extent across and up, and its circle's radius there
    if lens.panorama_type in ('FISHEYE_EQUIDISTANT', 'MIRRORBALL'): return 2, 2, 1
    across = lens.sensor_fit == 'HORIZONTAL' or lens.sensor_fit == 'AUTO' and width >= height
    fit = lens.sensor_height if lens.sensor_fit == 'VERTICAL' else lens.sensor_width
    return (fit, fit * height / width) if across else (fit * width / height, fit)
def seen_directions(lens, u, v, width, height):  # Local directions, forward, left and up, at u, v of the window; NaN
    u, v = u + lens.shift_x, v + lens.shift_y  # where unseen
    if lens.panorama_type == 'EQUIRECTANGULAR':  # Longitude to the right, latitude up, over their ranges
        right = lens.longitude_min + u * (lens.longitude_max - lens.longitude_min)
        up = lens.latitude_min + v * (lens.latitude_max - lens.latitude_min)
        return numpy.stack((numpy.cos(up) * numpy.cos(right), -numpy.cos(up) * numpy.sin(right), numpy.sin(up)), -1)
    if lens.panorama_type == 'CENTRAL_CYLINDRICAL':  # Angle to the right, the height crossing the cylinder over radius
        right = lens.central_cylindrical_range_u_min + u * (lens.central_cylindrical_range_u_max
            - lens.central_cylindrical_range_u_min)
        height = lens.central_cylindrical_range_v_min + v * (lens.central_cylindrical_range_v_max
            - lens.central_cylindrical_range_v_min)
        d = numpy.stack((numpy.cos(right), -numpy.sin(right), height / lens.central_cylindrical_radius), -1)
        return d / numpy.linalg.norm(d, axis=-1, keepdims=True)
    if lens.panorama_type in ('EQUIANGULAR_CUBEMAP_FACE', 'TANGENT_FACE'):  # A cube's forward face, its angle over u
        right, up = (u - 0.5) * math.pi / 2, (v - 0.5) * math.pi / 2  # and over v even across a right angle each way,
        if lens.panorama_type == 'TANGENT_FACE': right, up = numpy.arctan(2 * u - 1), numpy.arctan(2 * v - 1)  # on
        d = numpy.stack((numpy.ones_like(u), -numpy.tan(right), numpy.tan(up)), -1)  # any image (or, a control, not)
        return d / numpy.linalg.norm(d, axis=-1, keepdims=True)
    across, up = frame(lens, width, height)[:2]
    x, y = (u - 0.5) * across, (v - 0.5) * up
    r = numpy.hypot(x, y)
    if lens.panorama_type == 'MIRRORBALL':  # A mirror ball's disc over the whole frame: backward reflected off the
        c = numpy.sqrt(numpy.where(r <= 1, 1 - r * r, numpy.nan))  # ball whose normal at (x, y) is (c, -x, y), so
        n = numpy.stack((c, -x, y), -1)  # the centre sees forward and the rim straight back
        backward = numpy.array((-1.0, 0, 0))
        return backward - 2 * (n @ backward)[..., None] * n
    if lens.panorama_type == 'FISHEYE_EQUIDISTANT':  # Off forward in proportion to the radius, fov / 2 at the circle
        theta = numpy.where(r <= 1, r * lens.fisheye_fov / 2, numpy.nan)
    elif lens.panorama_type == 'FISHEYE_LENS_POLYNOMIAL':  # The manual's k0 + k1 r + ... + k4 r^4, negated, so that
        theta = -polynomial(lens, r)  # Blender's defaults (k1 < 0) look forward upright; cut at fov / 2
        theta = numpy.where(theta <= lens.fisheye_fov / 2, theta, numpy.nan)
    else:  # Equisolid: a radius of 2 f sin(theta / 2), cut at fov / 2
        theta = 2 * numpy.arcsin(numpy.minimum(r / (2 * lens.fisheye_lens), 1))
        theta = numpy.where((r <= 2 * lens.fisheye_lens) & (theta <= lens.fisheye_fov / 2), theta, numpy.nan)
    s = numpy.where(r > 0, numpy.sin(theta) / numpy.maximum(r, 1e-30), 0)
    return numpy.stack((numpy.cos(theta), -x * s, y * s), -1)
def polynomial(lens, r): return sum(getattr(lens, f'fisheye_polynomial_k{i}') * r ** i for i in range(5))
def circle(lens, width, height):  # A fisheye's frame and the radius on it past which it sees nothing
    across, up = frame(lens, width, height)[:2]
    if lens.panorama_type in ('FISHEYE_EQUIDISTANT', 'MIRRORBALL'): return across, up, 1
    if lens.panorama_type == 'FISHEYE_LENS_POLYNOMIAL':  # Where its angle reaches fov / 2, by bisection
        low, high = 0, 4 * max(across, up)
        for _ in range(100):
            middle = (low + high) / 2
            low, high = (middle, high) if -polynomial(lens, middle) <= lens.fisheye_fov / 2 else (low, middle)
        return across, up, low
    return across, up, 2 * lens.fisheye_lens * math.sin(lens.fisheye_fov / 4)
# Per pixel, bottom row first: its mean color, whether all its area sees and whether none of it does, by the fisheye's
# circle against the pixel's rectangle on the frame: its farthest point inside, or its nearest outside
def expected_panorama(lens, width, height, fine=8):
    v, u = numpy.meshgrid((numpy.arange(height * fine) + 0.5) / (height * fine),
        (numpy.arange(width * fine) + 0.5) / (width * fine), indexing='ij')
    d = seen_directions(lens, u, v, width, height)  # World: forward y, left -x, up z
    color = (0.5 + 0.5 * numpy.stack((-d[..., 1], d[..., 0], d[..., 2]), -1)).reshape(height, fine, width, fine, 3)
    if not lens.panorama_type.startswith('FISHEYE') and lens.panorama_type != 'MIRRORBALL':
        return color.mean((1, 3)), numpy.ones((height, width), bool), numpy.zeros((height, width), bool)
    across, up, radius = circle(lens, width, height)
    x = (numpy.arange(width + 1) / width + lens.shift_x - 0.5) * across
    y = (numpy.arange(height + 1) / height + lens.shift_y - 0.5) * up
    near = lambda e: numpy.where(e[:-1] * e[1:] <= 0, 0, numpy.minimum(abs(e[:-1]), abs(e[1:])))
    far = lambda e: numpy.maximum(abs(e[:-1]), abs(e[1:]))
    nearest, farthest = numpy.hypot(*numpy.meshgrid(near(x), near(y))), numpy.hypot(*numpy.meshgrid(far(x), far(y)))
    return numpy.nan_to_num(color).mean((1, 3)), farthest < radius, nearest > radius
scene = opened('fisheye')
scene.flex_samples, scene.flex_denoise = 1024, False
nodes, links = scene.world.node_tree.nodes, scene.world.node_tree.links
coded = nodes.new('ShaderNodeVectorMath')
coded.operation, coded.inputs[1].default_value, coded.inputs[2].default_value = 'MULTIPLY_ADD', (0.5,) * 3, (0.5,) * 3
links.new(nodes.new('ShaderNodeTexCoord').outputs['Generated'], coded.inputs[0])
links.new(coded.outputs[0], nodes['Background'].inputs['Color'])
scene.camera = add(bpy.data.cameras.new('fisheye'), (0, 0, 0), (math.pi / 2, 0, 0))
lens = scene.camera.data
lens.type = 'PANO'
preferences.device = 'OPTIX'
# Mean abs error on seeing pixels and the most any blind one holds, on a width x height image (64 x 64 by default);
# against another type's directions, or mirrored left to right (flip)
def fisheye_row(kind, against=None, flip=False, width=64, height=64, **settings):
    lens.panorama_type, lens.shift_x, lens.shift_y, lens.sensor_fit = kind, 0, 0, 'AUTO'
    scene.render.resolution_x, scene.render.resolution_y = width, height
    for name, value in settings.items(): setattr(lens, name, value)
    bpy.ops.render.render(scene=scene.name, write_still=True)
    got = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(height, width, 4)[..., :3]
    held = types.SimpleNamespace(panorama_type=against, shift_x=lens.shift_x, shift_y=lens.shift_y) \
        if against == 'TANGENT_FACE' else lens  # A plain perspective over a right angle, which Blender has no type for
    if against and held is lens: lens.panorama_type = against
    color, sees, blind = expected_panorama(held, width, height)
    if flip: color, sees, blind = color[:, ::-1], sees[:, ::-1], blind[:, ::-1]
    return abs(got - color)[sees].mean(), abs(got[blind]).max(initial=0), sees.sum(), blind.sum()
# Positive controls, the panoramas #184 measured by a light's centroid, then the fisheyes at two settings each
for kind, settings in (('EQUIRECTANGULAR', dict(longitude_min=-math.pi / 2, longitude_max=math.pi,
        latitude_min=-math.pi / 4, latitude_max=math.pi / 2)), ('CENTRAL_CYLINDRICAL', dict(
        central_cylindrical_range_u_min=-2, central_cylindrical_range_u_max=2, central_cylindrical_range_v_min=-0.5,
        central_cylindrical_range_v_max=1, central_cylindrical_radius=2)),
        ('FISHEYE_EQUIDISTANT', dict(fisheye_fov=math.pi)),
        ('FISHEYE_EQUIDISTANT', dict(fisheye_fov=3.6, shift_x=0.05, shift_y=-0.03)),
        ('FISHEYE_EQUISOLID', dict(fisheye_lens=10.5, fisheye_fov=math.pi, sensor_width=36)),
        ('FISHEYE_EQUISOLID', dict(fisheye_lens=8, fisheye_fov=2.8, sensor_width=30, shift_x=0.04)),
        ('FISHEYE_EQUIDISTANT', dict(fisheye_fov=math.pi, width=96, height=64)),  # An ellipse across the whole frame
        ('FISHEYE_EQUISOLID', dict(fisheye_lens=10.5, fisheye_fov=math.pi, sensor_width=36, width=96, height=64)),
        ('FISHEYE_LENS_POLYNOMIAL', dict(sensor_width=36, fisheye_fov=math.pi)),  # Blender's default coefficients
        ('FISHEYE_LENS_POLYNOMIAL', dict(fisheye_polynomial_k0=0, fisheye_polynomial_k1=-0.12,
            fisheye_polynomial_k2=0, fisheye_polynomial_k3=-2e-5, fisheye_polynomial_k4=0, shift_y=0.05)),
        ('FISHEYE_LENS_POLYNOMIAL', dict(fisheye_fov=2.0, width=96, height=64)),
        ('MIRRORBALL', dict()), ('MIRRORBALL', dict(shift_x=0.05, shift_y=-0.04)),
        ('MIRRORBALL', dict(width=96, height=64)),  # An ellipse across the whole frame
        ('EQUIANGULAR_CUBEMAP_FACE', dict()), ('EQUIANGULAR_CUBEMAP_FACE', dict(shift_x=-0.06, shift_y=0.03)),
        ('EQUIANGULAR_CUBEMAP_FACE', dict(width=96, height=64))):  # A right angle each way still
    error, stray, sees, blind = fisheye_row(kind, **settings)
    print('PANORAMA ROW', kind, settings, f'error {error:.2e} stray {stray:.2e} seeing {sees} blind {blind}')
    assert error < 1e-3 and stray < 1e-6 and sees > 1000, ('panorama row', kind, settings, error, stray, sees)
# Negative control: an equidistant fisheye held to the equisolid's directions at the same field of view fails
error, stray, *_ = fisheye_row('FISHEYE_EQUIDISTANT', 'FISHEYE_EQUISOLID', fisheye_fov=math.pi, fisheye_lens=10.5,
    sensor_width=36)
print('PANORAMA ROW negative', f'error {error:.2e} stray {stray:.2e}')
assert error > 1e-2 or stray > 0.1, ('panorama negative control', error, stray)
# And a mirror ball held to its own directions mirrored left to right fails: the rows fix its handedness
error, stray, *_ = fisheye_row('MIRRORBALL', flip=True)
print('PANORAMA ROW negative mirrored', f'error {error:.2e} stray {stray:.2e}')
assert error > 1e-2, ('panorama mirrored negative control', error, stray)
# And a cubemap face held to a plain perspective's directions over the same right angle fails: its pixels are even in
# angle, not in the tangent
error, stray, *_ = fisheye_row('EQUIANGULAR_CUBEMAP_FACE', 'TANGENT_FACE')
print('PANORAMA ROW negative tangent', f'error {error:.2e} stray {stray:.2e}')
assert error > 1e-3, ('panorama tangent negative control', error, stray)
preferences.device = device
# On Vulkan a panoramic camera is refused by name: its export raises before a scene is piped, so nothing is traced
preferences.device, traced, trace = 'VULKAN', [], flex.Flex.trace
flex.Flex.trace = lambda self, *args: traced.append(True) or trace(self, *args)
reported, stderr = io.StringIO(), sys.stderr
sys.stderr = reported
try: bpy.ops.render.render(scene=scene.name)
except RuntimeError as error: print(error, file=reported)
sys.stderr, flex.Flex.trace, preferences.device = stderr, trace, device
assert 'Flex: panoramic cameras render on OptiX only, not on Vulkan' in reported.getvalue() and not traced, \
    ('panorama on Vulkan', reported.getvalue()[-300:], traced)

# An animation's frame reusing the last one's reservoirs reprojects them through its panorama: an equirectangular
# camera, a fisheye equidistant, equisolid or lens polynomial one, a mirror ball (back-projected inside its circle) or
# a cubemap face, turned 5 degrees between frames, renders the second within 1% of that frame alone, on OptiX
scene = opened('turned panorama')
scene.flex_samples, scene.flex_reuse_samples, scene.flex_reuse, scene.flex_denoise = 256, 192, True, False
scene.frame_start, scene.frame_end = 1, 2
scene.camera = add(bpy.data.cameras.new('turned panorama'), (0, -4, 3))
scene.camera.data.type, scene.camera.data.fisheye_fov = 'PANO', math.radians(200)
keys(scene.camera, 'rotation_euler', (0.93, 0, 0), (0.93, 0, math.radians(5)))
turned = shape('turned cube', lambda bm: bmesh.ops.create_cube(bm, size=1), (0.8, 0, 0.5))
ground = shape('turned floor', lambda bm: bmesh.ops.create_grid(bm, size=3), (0, 0, 0))
for bsdf, color in ((turned, (0.8, 0.1, 0.1, 1)), (ground, (0.8, 0.8, 0.8, 1))):
    bsdf.inputs['Base Color'].default_value, bsdf.inputs['Roughness'].default_value = color, 1
add(bpy.data.lights.new('turned sun', 'SUN'), (0, 0, 0), (0.8, 0, 0.6)).data.energy = 3
counts, trace = [], flex.Flex.trace
flex.Flex.trace = lambda self, *args: (traced := trace(self, *args), counts.append(int(traced[1][0, 0, 3])))[0]
preferences.device = 'OPTIX'
for kind, height in (('EQUIRECTANGULAR', 32), ('FISHEYE_EQUIDISTANT', 64), ('FISHEYE_EQUISOLID', 64),
        ('FISHEYE_LENS_POLYNOMIAL', 64), ('MIRRORBALL', 64), ('EQUIANGULAR_CUBEMAP_FACE', 64)):
    scene.camera.data.panorama_type, scene.render.resolution_x, scene.render.resolution_y = kind, 64, height
    scene.frame_set(1)
    bpy.ops.render.render(animation=True, scene=scene.name)
    frame = numpy.array(bpy.data.images.load(scene.render.frame_path(frame=2)).pixels).reshape(-1, 4)[:, :3]
    reused = counts[-1]
    scene.frame_set(2)
    bpy.ops.render.render(scene=scene.name, write_still=True)
    alone = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(-1, 4)[:, :3]
    print('PANORAMA TURNED', kind, reused, frame.mean() / alone.mean())
    assert reused == 192 and abs(frame.mean() / alone.mean() - 1) < 0.01, ('turned panorama', kind, reused,
        frame.mean(), alone.mean())
preferences.device, flex.Flex.trace = device, trace

# Flex offers Blender's shading nodes, shows the panels whose settings it reads, hides those it ignores, and draws its
# own of what it reads of a light, of an object's visibility and of a world, each property one the export reads
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
for kind, read in (('POINT', ['shadow_soft_size']), ('SPOT', ['shadow_soft_size', 'spot_size', 'spot_blend']),
        ('SUN', ['angle']), ('AREA', ['shape', 'size', 'size_y', 'spread'])):
    light = bpy.data.lights.new(kind, kind)
    if kind == 'AREA': light.shape = 'RECTANGLE'
    assert drawn(flex.DATA_PT_flex_light, light=light) == ['type', 'color', 'use_temperature', 'energy', 'exposure',
        'normalize', *read, 'use_shadow'], ('light read', kind)
    light.use_temperature = True
    assert 'temperature' in drawn(flex.DATA_PT_flex_light, light=light), ('temperature read', kind)
assert drawn(flex.OBJECT_PT_flex_visibility, object=bpy.data.objects[0]) == ['hide_viewport', 'hide_render',
    'visible_camera', 'visible_shadow'], 'visibility read'
assert drawn(flex.WORLD_PT_flex, world=bpy.data.worlds[0]) == ['flex_sample_light'], 'world read'
# A world of an image is sampled while its switch is on, its grid and SKY step piped; off, its export pipes neither, as
# a constant world's
unsampled = opened('unsampled world')
lookup = unsampled.world.node_tree.nodes.new('ShaderNodeTexEnvironment')
lookup.image = bpy.data.images.new('unsampled world', 4, 2, float_buffer=True)
unsampled.world.node_tree.links.new(lookup.outputs['Color'], unsampled.world.node_tree.nodes['Background'].inputs[0])
for unsampled.world.flex_sample_light, sampled in ((True, (4, 2)), (False, (0, 0))):
    piped = exported().requests.getvalue()
    codes = numpy.frombuffer(piped, '<u4', struct.unpack_from('<11I', piped)[2] * 4, 44)[::4]
    assert struct.unpack('<2I', piped[-8:]) == sampled and ([*flex.OPS].index('SKY') in codes) == (sampled[0] > 0), \
        ('world sampled', unsampled.world.flex_sample_light)

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
preferences.device = 'OPTIX'  # The default again, for the tests below

# Instances of one mesh pipe its arrays once: a collection instanced three times, one of them turned and stretched,
# exports one mesh and three instances, and renders exactly as three copies of their own of it do, which the renderer
# traces alike
scene = opened('instances')
scene.camera = add(bpy.data.cameras.new('instances'), (0, 0, 2))
plane('shared', 0, 0, 0.4)
shared, ob = bpy.data.collections.new('shared'), bpy.data.objects['shared']
scene.collection.objects.unlink(ob), shared.objects.link(ob)
empties = [bpy.data.objects.new(f'instance {x}', None) for x in (-0.5, 0, 0.5)]
for empty, x in zip(empties, (-0.5, 0, 0.5)):
    empty.instance_type, empty.instance_collection, empty.location = 'COLLECTION', shared, (x, 0, 0)
    scene.collection.objects.link(empty)
empties[2].rotation_euler, empties[2].scale = (0.3, 0.2, 0.5), (1, 1.5, 1)
exporter = exported()
header = numpy.frombuffer(exporter.requests.getvalue(), 'I', count=10)
assert header[0] == flex.SCENE and (header[1], header[8], header[9]) == (6, 2, 3), 'mesh piped once'
instanced = render()
# A bake reads its own mesh's UVs past the instances sharing one: a noise baked over a plane after them renders as
# when they're hidden, its plane's mesh then the first; the bottom rows see it alone
baking = plane('baking', 0, -0.5, 0.3)
baking.inputs['Base Color'].default_value, baking.inputs['Emission Strength'].default_value = (0, 0, 0, 1), 1
noise = baking.id_data.nodes.new('ShaderNodeTexNoise')
noise.inputs['Scale'].default_value = 50
baking.id_data.links.new(noise.outputs['Color'], baking.inputs['Emission Color'])
exporter = exported()
baked = render()[:20]
for empty in empties: empty.hide_render = True
alone = render()[:20]
for empty in empties: empty.hide_render = False
assert exporter.placed and numpy.abs(alone - baked).mean() < 0.005, 'bake past shared meshes'
bpy.data.objects['baking'].hide_render = True
for empty in empties:
    copy = bpy.data.objects.new('copy', ob.data.copy())  # Placed as the empty, as the mesh sits at the origin
    copy.location, copy.rotation_euler, copy.scale = empty.location, empty.rotation_euler, empty.scale
    scene.collection.objects.link(copy)
    empty.hide_render = True
assert numpy.array_equal(instanced, render()), 'instances as copies'

# Blender's other instancing pipes a mesh once and renders exactly as copies of their own of its instances do: linked
# duplicates; geometry nodes' Instance on Points of an object, of a collection and of geometry it makes, and of an
# object on a host a collection instances; hair particles of an object; vertex and face instancing. The particles' and
# Object Info's source is hidden, whose instances Blender's renders keep, and a vertex instancer's hidden child stays
# hidden, as there; each case its triangles and instances, geometry nodes' host among them, its own mesh left empty
def instancing(name, build, triangles, count, objects=False):  # Copies of the instances, or of the objects
    global scene
    scene = opened(name)
    scene.camera = add(bpy.data.cameras.new(name), (0, 0, 3))
    plane(f'{name} seed', 0, 0, 0.3)
    build(bpy.data.objects[f'{name} seed'])
    exporter = exported(depsgraph := bpy.context.evaluated_depsgraph_get())
    assert tuple(numpy.frombuffer(exporter.requests.getvalue(), 'I', count=10)[8:]) == (triangles, count), name
    image = render()
    copies = [(x.object.data.copy(), x.matrix_world.copy()) for x in depsgraph.object_instances
        if x.object.type == 'MESH' and x.is_instance != objects]
    for ob in scene.objects: ob.hide_render = True
    placed = [(add(data, (0, 0, 0)), matrix) for data, matrix in copies]
    for ob, matrix in placed: ob.matrix_world = matrix
    bpy.context.view_layer.update()
    copied = render()  # Exactly where an object holds the instance's matrix exactly, else within 1%, as turned below
    exact = all(ob.matrix_world == matrix for ob, matrix in placed)
    assert numpy.array_equal(image, copied) if exact else numpy.isclose(image.mean(), copied.mean(), rtol=0.01) \
        and numpy.allclose(blocks(image), blocks(copied), atol=0.02), f'{name} as copies'
def host(name):  # A plane of 2 of four vertices and one face
    plane(name, 0, 0, 2)
    return bpy.data.objects[name]
def nodes(name, instance):  # Instance on Points at a host's vertices of what instance makes in the tree
    tree, ob = bpy.data.node_groups.new(name, 'GeometryNodeTree'), host(name)
    ob.modifiers.new('instances', 'NODES').node_group = tree
    for direction in ('INPUT', 'OUTPUT'):
        tree.interface.new_socket('Geometry', in_out=direction, socket_type='NodeSocketGeometry')
    on = tree.nodes.new('GeometryNodeInstanceOnPoints')
    tree.links.new(tree.nodes.new('NodeGroupInput').outputs[0], on.inputs['Points'])
    tree.links.new(instance(tree), on.inputs['Instance'])
    tree.links.new(on.outputs[0], tree.nodes.new('NodeGroupOutput').inputs[0])
def info(tree, kind, field, value):  # An object's or a collection's geometry, as instances
    node = tree.nodes.new(kind)
    node.inputs[field].default_value = value
    if 'As Instance' in node.inputs: node.inputs['As Instance'].default_value = True
    return node.outputs['Geometry' if 'Geometry' in node.outputs else 'Instances']
def ico(tree):
    node = tree.nodes.new('GeometryNodeMeshIcoSphere')
    node.inputs['Radius'].default_value, node.inputs['Subdivisions'].default_value = 0.15, 1
    return node.outputs[0]
def collected(seed):
    group = bpy.data.collections.new('seeds')
    scene.collection.objects.unlink(seed), group.objects.link(seed)
    nodes('collected host', lambda tree: info(tree, 'GeometryNodeCollectionInfo', 'Collection', group))
def nested(seed):  # On points of a host a collection instances
    seed.hide_render, group = True, bpy.data.collections.new('hosts')
    nodes('nested host', lambda tree: info(tree, 'GeometryNodeObjectInfo', 'Object', seed))
    ob = bpy.data.objects['nested host']
    scene.collection.objects.unlink(ob), group.objects.link(ob)
    empty = bpy.data.objects.new('hosts', None)
    empty.instance_type, empty.instance_collection = 'COLLECTION', group
    scene.collection.objects.link(empty)
def hair(seed, grouped=False):  # Of the seed, or of a collection of it, which no strands of the emitter's come from
    seed.hide_render, emitter = not grouped, host('hair collection emitter' if grouped else 'hair emitter')
    settings = emitter.modifiers.new('hair', 'PARTICLE_SYSTEM').particle_system.settings
    settings.type, settings.count, settings.emit_from, settings.use_emit_random = 'HAIR', 4, 'VERT', False
    settings.render_type, settings.instance_object, settings.particle_size = 'OBJECT', seed, 1
    if grouped:
        settings.render_type, settings.instance_collection = 'COLLECTION', bpy.data.collections.new('hair seeds')
        scene.collection.objects.unlink(seed), settings.instance_collection.objects.link(seed)
    emitter.show_instancer_for_render = False
def children(kind, seed):  # The seed instanced at the host's vertices or faces, beside a hidden child
    ob = host(f'{kind} host')
    seed.parent, ob.instance_type, ob.show_instancer_for_render = ob, kind, False
    hidden = add(bpy.data.meshes.new(f'{kind} hidden'), (0, 0, 0))
    hidden.parent, hidden.hide_render = ob, True
instancing('linked', lambda seed: [add(seed.data, (x, 0, 0)) for x in (-0.6, 0.6)], 2, 3, True)
# Objects linking one curve, one of them through an array, pipe each the mesh it evaluates to, as copies of it do
scene = opened('linked curves')
curve = bpy.data.curves.new('linked curve', 'CURVE')
curve.bevel_depth, spline = 0.1, curve.splines.new('POLY')
spline.points.add(1)
spline.points[1].co = (1, 0, 0, 1)
linking = [add(curve, (0, y, 0)) for y in (-0.5, 0.5)]
linking[1].modifiers.new('array', 'ARRAY').count = 3
def triangles():  # Of the scene piped
    exporter = exported()
    return numpy.frombuffer(exporter.requests.getvalue(), 'I', count=9)[8]
linked, linking[1].data = triangles(), curve.copy()
assert linked == triangles(), 'linked curves'
instancing('on points', lambda seed: (setattr(seed, 'hide_render', True), nodes('points host',
    lambda tree: info(tree, 'GeometryNodeObjectInfo', 'Object', seed))), 2, 5)
instancing('collected', collected, 2, 5)
instancing('made', lambda seed: (setattr(seed, 'hide_render', True), nodes('made host', ico)), 20, 5)
instancing('nested', nested, 2, 5)
instancing('hair', hair, 2, 4)
instancing('hair collection', lambda seed: hair(seed, True), 2, 4)
instancing('vertex instanced', lambda seed: children('VERTS', seed), 2, 4)
instancing('face instanced', lambda seed: children('FACES', seed), 2, 1)

# Geometry nodes' instance attributes reach the Attribute node of type Instancer per instance, as Cycles reads them: a
# color by each instance's index drives the emission of four planes, and of eight on two levels, where the inner level's
# overrides the outer's; each plane's pixel holds its instance's color, on both backends
def tinted(name, nested):
    global scene
    scene = opened(name, (0, 0, 0))
    scene.camera = add(bpy.data.cameras.new(name), (0, 0, 5))  # Sees [-1.8, 1.8]^2: the nested reach 1.4
    bsdf, seed = plane(f'{name} seed', 0, 0, 0.3), bpy.data.objects[f'{name} seed']
    seed.hide_render, bsdf.inputs['Base Color'].default_value = True, (0, 0, 0, 1)
    bsdf.inputs['Emission Strength'].default_value, read = 1, bsdf.id_data.nodes.new('ShaderNodeAttribute')
    read.attribute_type, read.attribute_name = 'INSTANCER', 'tint'
    bsdf.id_data.links.new(read.outputs['Color'], bsdf.inputs['Emission Color'])
    tree = bpy.data.node_groups.new(name, 'GeometryNodeTree')
    host(f'{name} host').modifiers.new('instances', 'NODES').node_group = tree
    for direction in ('INPUT', 'OUTPUT'):
        tree.interface.new_socket('Geometry', in_out=direction, socket_type='NodeSocketGeometry')
    def level(points, instance, scale):  # Instances on the points, tinted by their index times the scale
        on, tint, color = (tree.nodes.new(kind) for kind in ('GeometryNodeInstanceOnPoints',
            'GeometryNodeStoreNamedAttribute', 'FunctionNodeCombineColor'))
        tree.links.new(points, on.inputs['Points']), tree.links.new(instance, on.inputs['Instance'])
        tint.domain, tint.data_type, tint.inputs['Name'].default_value = 'INSTANCE', 'FLOAT_COLOR', 'tint'
        for k, factor in enumerate(scale):
            times = tree.nodes.new('ShaderNodeMath')
            times.operation, times.inputs[1].default_value = 'MULTIPLY', factor
            tree.links.new(tree.nodes.new('GeometryNodeInputIndex').outputs[0], times.inputs[0])
            tree.links.new(times.outputs[0], color.inputs[k])
        tree.links.new(on.outputs[0], tint.inputs['Geometry']), tree.links.new(color.outputs[0], tint.inputs['Value'])
        return tint.outputs[0]
    instance = info(tree, 'GeometryNodeObjectInfo', 'Object', seed)
    if nested:  # On two points 0.4 apart, inside each outer instance
        grid = tree.nodes.new('GeometryNodeMeshLine')
        grid.inputs['Count'].default_value, grid.inputs['Offset'].default_value = 2, (0.4, 0, 0)
        instance = level(grid.outputs[0], instance, (0.6, 0.1, 0.3))
    tree.links.new(level(tree.nodes.new('NodeGroupInput').outputs[0], instance, (0.2, 0.3, 0.1)),
        tree.nodes.new('NodeGroupOutput').inputs[0])
    devices = bpy.context.preferences.addons[flex.__name__].preferences
    depsgraph = bpy.context.evaluated_depsgraph_get()
    placed = [(x.matrix_world.translation.copy(), x.persistent_id[1]) for x in depsgraph.object_instances
        if x.is_instance]  # Each at its innermost level's index
    assert len(placed) == (8 if nested else 4), name
    for device in ('OPTIX', 'VULKAN'):
        devices.device, pixels = device, render()
        for location, index in placed:
            x, y = (int(c * SIZE) for c in bpy_extras.object_utils.world_to_camera_view(scene, scene.camera,
                location)[:2])
            want = numpy.array((0.6, 0.1, 0.3) if nested else (0.2, 0.3, 0.1)) * index
            assert numpy.allclose(pixels[y, x], want, atol=0.02), (name, device, index, pixels[y, x], want)
    devices.device = 'OPTIX'
tinted('tinted', False)
tinted('nested tint', True)
# Instances of the points Distribute Points on Faces makes, whose ids aren't their indices, each read their own: a tint
# of each one's position reads as where it is
scene = opened('distributed')
plane('distributed seed', 0, 0, 0.05)
tree = bpy.data.node_groups.new('distributed', 'GeometryNodeTree')
host('distributed host').modifiers.new('instances', 'NODES').node_group = tree
for direction in ('INPUT', 'OUTPUT'):
    tree.interface.new_socket('Geometry', in_out=direction, socket_type='NodeSocketGeometry')
spread, on, tint = (tree.nodes.new(kind) for kind in ('GeometryNodeDistributePointsOnFaces',
    'GeometryNodeInstanceOnPoints', 'GeometryNodeStoreNamedAttribute'))
tint.domain, tint.data_type, tint.inputs['Name'].default_value = 'INSTANCE', 'FLOAT_COLOR', 'tint'
for a, b in ((tree.nodes.new('NodeGroupInput').outputs[0], spread.inputs['Mesh']), (spread.outputs['Points'],
        on.inputs['Points']), (info(tree, 'GeometryNodeObjectInfo', 'Object', bpy.data.objects['distributed seed']),
        on.inputs['Instance']), (on.outputs[0], tint.inputs['Geometry']), (tree.nodes.new('GeometryNodeInputPosition'
        ).outputs[0], tint.inputs['Value']), (tint.outputs[0], tree.nodes.new('NodeGroupOutput').inputs[0])):
    tree.links.new(a, b)
module['IDS'].clear(), module['INSTANCER'].clear(), module['INSTANCER'].update(tint=0)
read = [(flex.instancer(x)[0][:3], x.matrix_world.translation.copy()) for x in bpy.context.evaluated_depsgraph_get(
    ).object_instances if x.is_instance and x.object.name == 'distributed seed']
assert len(read) > 10 and all(numpy.allclose(tint, where, atol=1e-5) for tint, where in read), 'distributed tint'

# A leaf card, open and lit only from behind, passes at most a thousandth of what the same panel gives it from the front,
# though its shading normals lean 15 degrees: a bounce arriving behind a shading normal keeps the face's sides
scene = opened('leaf', (0, 0, 0))
scene.camera = add(bpy.data.cameras.new('leaf'), (0, 0, 0.5))
scene.render.resolution_x = scene.render.resolution_y = 128
def lum():  # The scene rendered at its own size, its pixels' mean of the channels
    return render(scene, 128).mean(2)
devices = bpy.context.preferences.addons[flex.__name__].preferences
card = shape('card', lambda bm: bmesh.ops.create_grid(bm, x_segments=8, y_segments=8, size=0.1), (0, 0, 0))
card.inputs['Base Color'].default_value, card.inputs['IOR'].default_value = (0.8, 0.8, 0.8, 1), 1
bpy.data.meshes['card'].shade_smooth()
bpy.data.meshes['card'].normals_split_custom_set([(math.sin(math.pi / 12), 0, math.cos(math.pi / 12))]
    * len(bpy.data.meshes['card'].loops))
panel = shape('panel', lambda bm: bmesh.ops.create_grid(bm, size=0.15), (0, 0, -0.05))
panel.inputs['Base Color'].default_value, panel.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
panel.inputs['Emission Strength'].default_value, bpy.data.objects['panel'].visible_camera = 1, False
lamp = bpy.data.objects['panel']
for device in ('OPTIX', 'VULKAN'):
    devices.device = device
    lamp.location.z, lamp.rotation_euler.x = 0.05, math.pi  # In front, facing the card
    front = lum().mean()
    lamp.location.z, lamp.rotation_euler.x = -0.05, 0
    behind = lum().mean()
    print('LEAF', device, float(front), float(behind))
    assert front > 0.01 and behind < 1e-3 * front, ('leaf card lit through', device, float(front), float(behind))
devices.device = 'OPTIX'
# Rays reach a mesh in its own space through its instance's transform, its normals turned by the adjugate: a smooth
# sphere turned and stretched unevenly under the sun shades as a copy of it with the transform applied to its mesh does,
# on both backends
scene = opened('turned', (0, 0, 0))
scene.camera = add(bpy.data.cameras.new('turned view'), (0, 0, 4))
add(bpy.data.lights.new('turned sun', 'SUN'), (0, 0, 5), (0.5, 0.3, 0)).data.energy = math.pi
shape('turned', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=48, v_segments=24, radius=1), (0, 0, 0),
    (0.4, 0.3, 0.2))
ball = bpy.data.objects['turned']
ball.data.shade_smooth()
ball.scale = (1, 0.5, 0.7)
turned = [render_on(device) for device in ('OPTIX', 'VULKAN')]
ball.data.transform(ball.matrix_world)
ball.matrix_world = Matrix.Identity(4)
for device, before in zip(('OPTIX', 'VULKAN'), turned):
    after = render_on(device)
    assert numpy.isclose(before.mean(), after.mean(), rtol=0.01), f'turned instance {device}'
    assert numpy.allclose(blocks(before), blocks(after), atol=0.02), f'turned instance blocks {device}'
# Mirrored by a negative scale, it shades as its mirrored copy, whose faces flip as applying the scale flips them
ball.scale = (-1, 0.5, 0.7)
mirrored = [render_on(device) for device in ('OPTIX', 'VULKAN')]
ball.data.transform(ball.matrix_world)
ball.data.flip_normals()
ball.matrix_world = Matrix.Identity(4)
for device, before in zip(('OPTIX', 'VULKAN'), mirrored):
    after = render_on(device)
    assert numpy.isclose(before.mean(), after.mean(), rtol=0.01), f'mirrored instance {device}'
    assert numpy.allclose(blocks(before), blocks(after), atol=0.02), f'mirrored instance blocks {device}'
preferences.device = 'OPTIX'

# An object of no triangles adds none: a mesh of points alone, linked before a plane and placed apart from it, leaves
# the render the plane's alone
scene = opened('none')
scene.camera = add(bpy.data.cameras.new('none'), (0, 0, 2))
points = bpy.data.meshes.new('points')
points.from_pydata([(0, 0, 0), (0.1, 0, 0), (0, 0.1, 0)], [], [])
add(points, (0.5, 0, 0))
plane('lone', -0.5, 0, 0.5)
pointed = render()
bpy.data.objects['points'].hide_render = True
assert numpy.array_equal(pointed, render()), 'no triangles, no geometry'

# Strands: a plane growing red particle hair as paths, 40 strands of 20 simple children each, and beside it a curves
# object of 30 green strands, seen from above under the sky at 16 samples. On both backends each covers pixels of its
# color, as many on either within a tenth; the emitter hidden, its hair alone still; hidden, none
scene = opened('hair')
scene.flex_samples, scene.camera = 16, add(bpy.data.cameras.new('hair'), (0, -1.2, 0.9), (math.radians(55), 0, 0))
def colored(name, color):  # A material of the color
    material = bpy.data.materials.new(name)
    material.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (*color, 1)
    return material
ground, bm = bpy.data.meshes.new('hair ground'), bmesh.new()
bmesh.ops.create_grid(bm, size=0.5)
bm.to_mesh(ground)
grown = add(ground, (0, 0, 0))
ground.materials.append(colored('hair ground', (0.2, 0.2, 0.2)))
ground.materials.append(colored('red hair', (0.9, 0.05, 0.05)))
red = ground.materials['red hair'].node_tree.nodes['Principled BSDF'].inputs  # Glowing, too dim to tint the green
red['Emission Color'].default_value, red['Emission Strength'].default_value = (0.9, 0.05, 0.05, 1), 0.02
settings = grown.modifiers.new('hair', 'PARTICLE_SYSTEM').particle_system.settings
settings.type, settings.count, settings.hair_length, settings.child_type = 'HAIR', 40, 0.4, 'SIMPLE'
settings.child_percent = settings.rendered_child_count = 20
settings.root_radius, settings.radius_scale, settings.material = 1, 0.02, 2
curves = bpy.data.hair_curves.new('green hair')
curves.add_curves([4] * 30)
curves.points.foreach_set('position', [c for k in range(30) for z in range(4)
    for c in ((k % 6) * 0.03, (k // 6) * 0.03, z * 0.1)])
(curves.attributes.get('radius') or curves.attributes.new('radius', 'FLOAT', 'POINT')).data.foreach_set('value',
    [0.008] * 120)
curves.attributes.new('surface_uv_coordinate', 'FLOAT2', 'CURVE')  # Read per curve, as the 5.2 splash's fur has it
curves.materials.append(colored('green hair', (0.05, 0.9, 0.05)))
green = add(curves, (0.3, 0, 0))
add(bpy.data.hair_curves.new('no hair'), (0, 0, 0))  # Curves of no curve, piping nothing
hue = lambda pixels, k: int(((pixels[..., k] > 2 * pixels[..., (k + 1) % 3])
    & (pixels[..., k] > 2 * pixels[..., (k + 2) % 3])).sum())  # Pixels of the hue of channel k
haired = [render_on(device) for device in ('OPTIX', 'VULKAN')]
for k in (0, 1):
    assert min(hue(image, k) for image in haired) > 20 and abs(hue(haired[0], k) - hue(haired[1], k)) \
        <= 0.1 * hue(haired[0], k), ('hair', k, [hue(image, k) for image in haired])
grown.show_instancer_for_render = False  # Its hair alone: a scene of no triangle but the lights'
assert all(hue(render_on(device), 0) > 0.5 * hue(haired[0], 0) for device in ('OPTIX', 'VULKAN')), 'hair alone'
grown.modifiers['hair'].show_render, green.hide_render = False, True
assert all(hue(render_on(device), 0) == hue(render_on(device), 1) == 0 for device in ('OPTIX', 'VULKAN')), 'hidden'
preferences.device = 'OPTIX'

# No light gets past faces whose smooth normals tilt off them: a wall whose normals tilt 60 degrees toward a light
# behind it, in the wedge between its face and its shading plane, reads exactly 0 at 256 samples under a black sky, on
# both backends; the light moved in front lights it
scene = opened('leak')
scene.flex_bounces, scene.flex_denoise = 8, False
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
leak_white = bpy.data.materials.new('leak white')
leak_white.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (1, 1, 1, 1)
leak_white.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value = 1
def leak_mesh(name, make, smooth, tilt=None):  # Of the white material, smooth or flat, its normals tilt if given
    data, bm = bpy.data.meshes.new(name), bmesh.new()
    make(bm), bm.to_mesh(data), bm.free()
    for polygon in data.polygons: polygon.use_smooth = smooth
    if tilt: data.normals_split_custom_set([tilt] * len(data.loops))
    data.materials.append(leak_white)
    return add(data, (0, 0, 0))
lamp = add(bpy.data.lights.new('leak light', 'POINT'), (-1, 5, 0))
lamp.data.energy, lamp.data.shadow_soft_size, lamp.visible_camera = 100, 0.05, False
scene.camera = add(bpy.data.cameras.new('leak camera'), (3, 0, 0), (math.radians(90), 0, math.radians(90)))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 2
def grid(bm):  # 2 x 2 in the x = 0 plane, facing +x
    bmesh.ops.create_grid(bm, x_segments=8, y_segments=8, size=1)
    bmesh.ops.rotate(bm, verts=bm.verts, matrix=Matrix.Rotation(math.radians(90), 3, 'Y'))
wall = leak_mesh('leak wall', grid, True, (math.cos(math.radians(60)), math.sin(math.radians(60)), 0))
assert wall.data.polygons[0].normal.x > 0.99, 'leak wall faces +x'
for device in ('OPTIX', 'VULKAN'):
    assert render_on(device).max() == 0, ('wedge wall', device)
lamp.location = (1, 5, 0)
for device in ('OPTIX', 'VULKAN'):
    assert render_on(device).mean() > 0.01, ('wedge wall lit', device)
# Hair in a closed enclosure of radiance 1: one straight white strand (Principled Hair of color white), seen across,
# scatters all it receives, as white Chiang conserves energy, so its pixels read its albedo, 1, whichever way a path
# counts the light: both ways weighed (an emitting shell, bounces on), light sampling alone (the shell, no bounce) and
# bounces alone (a world of 1, which no light sample takes). Weights summing above 1 read more, its own fiber's shadow
# less. Seen 5 and 1 degrees from its axis, with the scales' tilt, each lobe kept whole between the viewer's poles: its
# albedo 1 there too, by every way within 1%
scene = opened('enclosed hair')
scene.flex_denoise, scene.flex_restir = False, False
scene.camera = add(bpy.data.cameras.new('enclosed hair'), (0, -50, 0), (math.pi / 2, 0, 0))
scene.camera.data.type, scene.camera.data.ortho_scale, scene.camera.data.clip_end = 'ORTHO', 1, 200
strand = bpy.data.hair_curves.new('white strand')
strand.add_curves([4])
strand.points.foreach_set('position', [c for z in range(4) for c in (0, 0, 20 * z - 30)])  # 1 of 60 seen at 89
(strand.attributes.get('radius') or strand.attributes.new('radius', 'FLOAT', 'POINT')).data.foreach_set('value',
    [0.1] * 4)
white = bpy.data.materials.new('white strand')
nodes = white.node_tree.nodes
fiber = nodes.new('ShaderNodeBsdfHairPrincipled')
fiber.model, fiber.parametrization, fiber.inputs['Color'].default_value = 'CHIANG', 'COLOR', (1, 1, 1, 1)
fiber.inputs['Coat'].default_value = 0
white.node_tree.links.new(fiber.outputs[0], nodes['Material Output'].inputs['Surface'])
strand.materials.append(white)
held = add(strand, (0, 0, 0))
enclosure = shape('enclosure', lambda bm: [bmesh.ops.create_cube(bm, size=150),
    bmesh.ops.reverse_faces(bm, faces=bm.faces[:])], (0, 0, 0))  # Facing in, black, emitting 1
enclosure.inputs['Base Color'].default_value, enclosure.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1,) * 4
enclosure.inputs['Emission Strength'].default_value, enclosure.inputs['IOR'].default_value = 1, 1
background = scene.world.node_tree.nodes['Background'].inputs['Color']
for seen, offset, roughness, scene.flex_samples in ((0, 0, 0.3, 256), (85, 2, 0.1, 16384), (85, 2, 0.3, 16384),
        (89, 2, 0.1, 16384)):
    # Light sampling noisier at grazing views, its lobes narrow there
    held.rotation_euler.x, fiber.inputs['Offset'].default_value = math.radians(seen), math.radians(offset)
    fiber.inputs['Roughness'].default_value = fiber.inputs['Radial Roughness'].default_value = roughness
    for device in ('OPTIX', 'VULKAN'):
        ways = []
        for bounces, world in ((16, 0), (0, 0), (16, 1)):  # Weighed, light sampling alone, bounces alone
            scene.flex_bounces, background.default_value = bounces, (world,) * 3 + (1,)
            bpy.data.objects['enclosure'].hide_render = bool(world)
            ways.append(render_on(device)[8:56, 28:36].mean())  # Within the strand's 0.2 of the view's 1
        assert max(abs(lit - 1) for lit in ways) < 0.01 and max(ways) - min(ways) < 0.01, \
            ('enclosed hair', seen, roughness, device, ways)
preferences.device = 'OPTIX'

# A thin closed emissive shell lights a wall as its outward faces do: a 4 x 4 sheet shaded smooth, emitting 1 and
# hidden from the camera, solidified 0.05 or 0.2 thick, gives a white diffuse wall 1.5 before it what its front and
# rims send (by quadrature of cos cos / pi r^2 over them), within 2% on both backends. The end of a shadow ray at a
# sampled light is not lifted along the light's smooth normal, which on such a shell carried its back face's light
# through the front, a third over
scene = opened('emissive slab', (0, 0, 0))
scene.flex_denoise = False
def surfaced(name, node):  # A material of the shader node alone
    material = bpy.data.materials.new(name)
    nodes = material.node_tree.nodes
    nodes.remove(nodes['Principled BSDF'])
    shader = nodes.new(node)
    material.node_tree.links.new(shader.outputs[0], nodes['Material Output'].inputs['Surface'])
    return material, shader
def gridded(name, size, material, location, rotation):  # A square of side 2 size, of the material
    data, bm = bpy.data.meshes.new(name), bmesh.new()
    bmesh.ops.create_grid(bm, size=size)
    bm.to_mesh(data), bm.free()
    data.materials.append(material)
    return add(data, location, rotation)
slab = gridded('emissive slab', 2, surfaced('glow', 'ShaderNodeEmission')[0], (0, 0, 0), (-math.pi / 2, 0, 0))
slab.data.shade_smooth()
slab.visible_camera = False  # Its face toward the wall at y = 0, solidified behind it
matte, diffuse = surfaced('matte', 'ShaderNodeBsdfDiffuse')
diffuse.inputs['Color'].default_value = (0.8, 0.8, 0.8, 1)
gridded('slab wall', 6, matte, (0, 1.5, 0), (math.pi / 2, 0, 0))
scene.camera = add(bpy.data.cameras.new('emissive slab'), (0, -3, 0), (math.pi / 2, 0, 0))
scene.camera.data.type, scene.camera.data.ortho_scale = 'ORTHO', 8
c = (numpy.arange(SIZE) + 0.5) / SIZE * 8 - 4
x, z = (a.ravel() for a in numpy.meshgrid(c, c))
wall = numpy.column_stack((x, numpy.full(x.size, 1.5), z))
def sent(t):  # The wall's mean radiance from the slab's faces of radiance 1 facing it, its back face turned away
    faces = [((-2, 0, -2), (4, 0, 0), (0, 0, 4), (0, 1, 0))]
    faces += [(o, u, (0, t, 0), n) for o, u, n in (((2, -t, -2), (0, 0, 4), (1, 0, 0)),
        ((-2, -t, -2), (0, 0, 4), (-1, 0, 0)), ((-2, -t, 2), (4, 0, 0), (0, 0, 1)),
        ((-2, -t, -2), (4, 0, 0), (0, 0, -1)))]
    irradiance = numpy.zeros(len(wall))
    for o, u, v, n in faces:
        s, w = numpy.meshgrid((numpy.arange(32) + 0.5) / 32, (numpy.arange(32) + 0.5) / 32)
        points = numpy.array(o) + s.reshape(-1, 1) * u + w.reshape(-1, 1) * numpy.array(v)
        d = points[None] - wall[:, None]
        r2 = (d * d).sum(2)
        cosines = numpy.maximum(-d[..., 1], 0) * numpy.maximum(-(d @ numpy.array(n)), 0) / r2
        irradiance += (cosines / r2).sum(1) * numpy.linalg.norm(numpy.cross(u, v)) / 32 ** 2
    return 0.8 / math.pi * irradiance.mean()
for thickness in (0.05, 0.2):
    slab.modifiers.clear()
    slab.modifiers.new('solid', 'SOLIDIFY').thickness = thickness
    for device in ('OPTIX', 'VULKAN'):
        wall_mean = render_on(device).mean()
        assert abs(wall_mean / sent(thickness) - 1) < 0.02, ('emissive slab', thickness, device, float(wall_mean),
            sent(thickness))
preferences.device = 'OPTIX'

# A world of an image is sampled by its luminance, ReSTIR off and on: under a constant image of 1 a white diffuse sphere
# filling the view reads 1; under one texel of 1000 of a 64 x 32 image, 8 rows below the zenith's, a diffuse floor of
# albedo 0.5 seen straight down reads its radiance, its blocks spreading as little as sampling the texel leaves them
# theta_0 = 8 * PI / 32, theta_1 = 9 * PI / 32, the texel's polar angles; its azimuths 2 * PI / 64 wide
# E = 1000 * 2 * PI / 64 * (cos(theta_0)^2 - cos(theta_1)^2) / 2
# => radiance = 0.5 * E / PI
def imaged(name, pixels):  # A new scene, the window's, under a world of the float image, read Closest
    made = opened(name)
    h, w = pixels.shape[:2]
    image = bpy.data.images.new(name, w, h, float_buffer=True)
    image.pixels.foreach_set(numpy.concatenate((pixels, numpy.ones((h, w, 1))), 2).astype('f').ravel())
    nodes = made.world.node_tree.nodes
    texture = nodes.new('ShaderNodeTexEnvironment')
    texture.image, texture.interpolation = image, 'Closest'
    made.world.node_tree.links.new(texture.outputs['Color'], nodes['Background'].inputs['Color'])
    return made
def viewed(made, name, make, color, location, rotation):  # With a diffuse mesh, an orthographic camera at location
    data, bm = bpy.data.meshes.new(name), bmesh.new()
    make(bm), bm.to_mesh(data), bm.free()
    material, shader = surfaced(name, 'ShaderNodeBsdfDiffuse')
    shader.inputs['Color'].default_value = (*color, 1)
    data.materials.append(material)
    made.collection.objects.link(bpy.data.objects.new(name, data))
    made.camera = bpy.data.objects.new(name, bpy.data.cameras.new(name))
    made.collection.objects.link(made.camera)
    made.camera.location, made.camera.rotation_euler, made.camera.data.type = location, rotation, 'ORTHO'
    return made
furnace = viewed(imaged('image furnace', numpy.ones((32, 64, 3))), 'image furnace',
    lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=64, v_segments=32, radius=1), (1, 1, 1), (0, -3, 0),
    (math.pi / 2, 0, 0))
furnace.camera.data.ortho_scale, furnace.flex_bounces = 1.2, 64
hot = numpy.zeros((32, 64, 3))
hot[32 - 1 - 8, 10] = 1000  # Rows from the bottom
texel = viewed(imaged('hot texel', hot), 'hot texel', lambda bm: bmesh.ops.create_grid(bm, size=1), (0.5, 0.5, 0.5),
    (0, 0, 1), (0, 0, 0))
texel.camera.data.ortho_scale = 1
E = 1000 * 2 * math.pi / 64 * (math.cos(8 * math.pi / 32) ** 2 - math.cos(9 * math.pi / 32) ** 2) / 2
for preferences.device in ('OPTIX', 'VULKAN'):
    for furnace.flex_restir in (False, True):
        texel.flex_restir = furnace.flex_restir
        seen = render(furnace).mean()
        assert abs(seen - 1) < 0.01, ('image furnace', preferences.device, furnace.flex_restir, seen)
        seen = blocks(render(texel)).mean(2)
        assert abs(seen.mean() / (0.5 * E / math.pi) - 1) < 0.02 and seen.std() / seen.mean() < 0.05, ('hot texel',
            preferences.device, texel.flex_restir, seen.mean(), seen.std() / seen.mean())
preferences.device = 'OPTIX'

# The image of 1, its world sampled by the image's luminance, keeps a white diffuse sphere's light: low-poly and
# smooth-shaded, so its normals leave its faces, the sphere reads 1 inside 0.9 of its radius, ReSTIR off, to 0.002,
# five times the spread of that mean at 256 samples (0.0004)
lowpoly = viewed(imaged('smooth furnace', numpy.ones((32, 64, 3))), 'smooth furnace',
    lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=8, radius=1), (1, 1, 1), (0, -3, 0),
    (math.pi / 2, 0, 0))
bpy.data.meshes['smooth furnace'].shade_smooth()
lowpoly.camera.data.ortho_scale, lowpoly.flex_restir = 2.2, False
centres = (numpy.arange(SIZE) + 0.5) / SIZE * 2.2 - 1.1
within = numpy.hypot(*numpy.meshgrid(centres, centres)) < 0.9
for preferences.device in ('OPTIX', 'VULKAN'):
    seen = render(lowpoly).mean(2)[within].mean()
    assert abs(seen - 1) < 0.002, ('smooth furnace', preferences.device, seen)
preferences.device = 'OPTIX'

# A Script node's value outputs export as the same graph of Math and Vector Math nodes does, byte for byte: its OSL
# compiled by Blender's own compiler, its sockets made from its parameters, its main code run on expressions
def scripted():  # OSL scripts
    shown, osl = bpy.context.window.scene, opened('osl')
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=1, calc_uvs=True)
    bm.to_mesh(mesh := bpy.data.meshes.new('scripted'))
    osl.collection.objects.link(bpy.data.objects.new('scripted', mesh))
    mesh.materials.append(material := bpy.data.materials.new('scripted'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    x = nodes.new('ShaderNodeSeparateXYZ')
    links.new(nodes.new('ShaderNodeTexCoord').outputs['Generated'], x.inputs[0])
    (text := bpy.data.texts.new('ramp.osl')).write('shader ramp(float Fac = 0.5, color A = color(1, 0, 0),\n'
        '    color B = color(0, 0, 1), output color Color = 0) {\n    float t = clamp(Fac * 2 - 0.5, 0, 1);\n'
        '    Color = mix(A, B, t) * pow(t, 2.2) + sin(Fac);\n}\n')
    script = nodes.new('ShaderNodeScript')
    script.script = text
    Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
    assert [s.identifier for s in script.inputs] == ['Fac', 'A', 'B'] and [s.identifier for s in script.outputs] \
        == ['Color'] and script.bytecode, 'script compiled'
    links.new(x.outputs['X'], script.inputs['Fac'])
    links.new(script.outputs['Color'], nodes['Principled BSDF'].inputs['Base Color'])
    piped = exported().requests.getvalue()
    nodes.remove(script)
    def math(operation, a, b, vector=False):  # A Math or Vector Math node's output, its operands linked or set
        node = nodes.new('ShaderNodeVectorMath' if vector else 'ShaderNodeMath')
        node.operation = operation
        for socket, operand in zip(node.inputs, (a, b)):
            if isinstance(operand, bpy.types.NodeSocket): links.new(operand, socket)
            else: socket.default_value = operand
        return node.outputs[0]
    t = math('MAXIMUM', math('MINIMUM', math('SUBTRACT', math('MULTIPLY', x.outputs['X'], 2), 0.5), 1), 0)
    mixed = math('ADD', math('MULTIPLY', (1, 0, 0), math('SUBTRACT', 1, t), True), math('MULTIPLY', (0, 0, 1), t,
        True), True)
    color = math('ADD', math('MULTIPLY', mixed, math('POWER', t, 2.2), True), math('SINE', x.outputs['X'], 0), True)
    links.new(color, nodes['Principled BSDF'].inputs['Base Color'])
    assert exported().requests.getvalue() == piped, 'script as nodes'
    bpy.context.window.scene = shown
scripted()

# A Script node's ifs and loops. An if on a per-hit value chooses per channel between both branches' values by the
# SELECT step, so a branch not taken that overflows leaves no NaN. Seen on an emitting square along its Generated X by
# an orthographic camera, its columns give 2x and 1 - x either side of 0.5 where both branches set the same variable,
# 3/8 and 4/8 where one does, and 1/4 below 0.5, where the other branch, exp(1000 (0.5 - x)) / 2, overflows below 0.41
def branched():  # A Script node's ifs and loops
    shown, chosen, was = bpy.context.window.scene, opened('branched', sky=(0, 0, 0)), preferences.device
    chosen.flex_samples, chosen.flex_restir = 64, False  # Each pixel's own samples
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=0.5, calc_uvs=True)
    bm.to_mesh(mesh := bpy.data.meshes.new('branched'))
    chosen.collection.objects.link(bpy.data.objects.new('branched', mesh))
    mesh.materials.append(material := bpy.data.materials.new('branched'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    x, light = nodes.new('ShaderNodeSeparateXYZ'), nodes.new('ShaderNodeEmission')
    links.new(nodes.new('ShaderNodeTexCoord').outputs['Generated'], x.inputs[0])
    links.new(light.outputs[0], nodes['Material Output'].inputs['Surface'])
    def lit(text):  # The square's light the script's Color of its Generated X, compiled anew
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('branched.osl')
        script.script.write('shader branched(float Fac = 0.5, output color Color = 0) {\n' + text + '}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(x.outputs['X'], script.inputs['Fac'])
        links.new(script.outputs['Color'], light.inputs['Color'])
    lit('    float y = 0, z = 3, w;\n    if (Fac < 0.5) y = 2 * Fac; else { y = 1 - Fac; z = 4; }\n'
        '    if (Fac < 0.5) w = 0.25; else w = exp(1000 * (0.5 - Fac)) / 2;\n    Color = color(y, z / 8, w);\n')
    chosen.camera = bpy.data.objects.new('branched camera', bpy.data.cameras.new('branched camera'))
    chosen.collection.objects.link(chosen.camera)
    chosen.camera.data.type, chosen.camera.data.ortho_scale, chosen.camera.location = 'ORTHO', 1, (0, 0, 1)
    f = (numpy.arange(SIZE) + 0.5) / SIZE
    due = numpy.stack((numpy.where(f < 0.5, 2 * f, 1 - f), numpy.where(f < 0.5, 3 / 8, 4 / 8)), 1)
    left, right = numpy.r_[3:SIZE // 2 - 3], numpy.r_[SIZE // 2 + 3:SIZE - 3]  # Off the edges and the switch
    for preferences.device in ('OPTIX', 'VULKAN'):
        seen = render(chosen)[8:-8]
        columns = seen.mean(0)
        assert numpy.isfinite(seen).all() and numpy.allclose(seen[:, left, 2], 0.25, atol=1e-6) and numpy.allclose(
            columns[numpy.r_[left, right], :2], due[numpy.r_[left, right]], atol=0.002), ('branched',
            preferences.device, columns)
    preferences.device = was
    # Loops whose counts are known at export, unrolled, export as the same script written out, byte for byte: a for
    # skipping a step by continue and leaving by break, a while and a do-while
    nodes.remove(nodes['Script'])
    lit('    float s = 0;\n    for (int i = 3; i < 10; i++) { if (i == 4) continue; if (i == 6) break; '
        's += Fac * i; }\n    int j = 0;\n    while (j < 2) { s += Fac; j++; }\n    do { s *= Fac; } while (--j > 0);\n'
        '    Color = s;\n')
    piped = exported().requests.getvalue()
    nodes.remove(nodes['Script'])
    lit('    float s = 0;\n    s += Fac * 3; s += Fac * 5; s += Fac; s += Fac; s *= Fac; s *= Fac;\n'
        '    Color = s;\n')
    assert exported().requests.getvalue() == piped, 'loops as written out'
    # An int parameter left at its value takes int steps and counts a loop as the same int written in does
    nodes.remove(nodes['Script'])
    lit('    float s = 0;\n    for (int i = 0; i < 6; i++) s += Fac;\n    Color = s;\n')
    piped = exported().requests.getvalue()
    nodes['Script'].script.clear()
    nodes['Script'].script.write('shader counted(float Fac = 0.5, int Count = 3, output color Color = 0) {\n'
        '    float s = 0;\n    int n = Count * 2;\n    for (int i = 0; i < n; i++) s += Fac;\n    Color = s;\n}\n')
    Viewport.engine.update_script_node(types.SimpleNamespace(report=print), nodes['Script'])
    assert exported().requests.getvalue() == piped, 'int parameter'
    # A loop that builds a computation deeper than the exporter takes is refused by name: its export raises in a
    # depsgraph handler, which Blender reports on stderr and goes on from
    nodes.remove(nodes['Script'])
    lit('    for (int i = 0; i < 300; i++) Color += Fac * i;\n')
    reported, stderr, export = io.StringIO(), sys.stderr, lambda _, graph: exported(graph)
    bpy.app.handlers.depsgraph_update_post.append(export)
    sys.stderr = reported
    bpy.context.view_layer.update()
    sys.stderr = stderr
    bpy.app.handlers.depsgraph_update_post.remove(export)
    assert 'a computation deeper than 200 steps' in reported.getvalue(), ('deep script', reported.getvalue())
    bpy.context.window.scene = shown
branched()

# A Script node's globals, attributes and spaces export as the nodes giving the same do, byte for byte: P, N and I as
# the Geometry node's Position, Normal and Incoming turned in, time 0.5, getattribute as the Texture Coordinate and
# Object Info nodes, transform as the Vector Transform node; a global, attribute or space Flex lacks is refused by name
def globaled():  # OSL globals
    shown, osl = bpy.context.window.scene, opened('osl globals')
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=1, calc_uvs=True)
    bm.to_mesh(mesh := bpy.data.meshes.new('globaled'))
    osl.collection.objects.link(bpy.data.objects.new('globaled', mesh))
    mesh.materials.append(material := bpy.data.materials.new('globaled'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    light = nodes.new('ShaderNodeEmission')
    links.new(light.outputs[0], nodes['Material Output'].inputs['Surface'])
    def scripted(body):  # The light's color a script's Color, its export's bytes
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('globaled.osl')
        script.script.write('shader globaled(output color Color = 0) {\n' + body + '}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(script.outputs['Color'], light.inputs['Color'])
        piped = exported().requests.getvalue()
        nodes.remove(script)
        return piped
    def noded(socket):  # The light's color a node's output, its export's bytes
        links.new(socket, light.inputs['Color'])
        return exported().requests.getvalue()
    geometry, coordinates, info = (nodes.new(kind) for kind in ('ShaderNodeNewGeometry', 'ShaderNodeTexCoord',
        'ShaderNodeObjectInfo'))
    turned, moved = nodes.new('ShaderNodeVectorMath'), nodes.new('ShaderNodeVectorTransform')
    turned.operation, turned.inputs['Scale'].default_value = 'SCALE', -1
    links.new(geometry.outputs['Incoming'], turned.inputs[0])
    moved.vector_type, moved.convert_from, moved.convert_to = 'POINT', 'WORLD', 'OBJECT'
    links.new(geometry.outputs['Position'], next(socket for socket in moved.inputs if socket.enabled))
    spaced = {}  # A vector and a normal between two named spaces each
    for kind, source, target in (('VECTOR', 'OBJECT', 'CAMERA'), ('NORMAL', 'OBJECT', 'WORLD')):
        spaced[kind] = nodes.new('ShaderNodeVectorTransform')
        spaced[kind].vector_type, spaced[kind].convert_from, spaced[kind].convert_to = kind, source, target
        links.new(geometry.outputs['Normal'], next(socket for socket in spaced[kind].inputs if socket.enabled))
    for body, socket in (('Color = P;', geometry.outputs['Position']), ('Color = N;', geometry.outputs['Normal']),
            ('Color = I;', turned.outputs['Vector']), ('getattribute("geom:generated", Color);',
            coordinates.outputs['Generated']), ('getattribute("object:random", Color);', info.outputs['Random']),
            ('Color = transform("object", P);', moved.outputs['Vector']),
            ('Color = transform("object", "camera", vector(N));', spaced['VECTOR'].outputs['Vector']),
            ('Color = transform("object", "world", N);', spaced['NORMAL'].outputs['Vector'])):
        assert scripted('    ' + body + '\n') == noded(socket), ('osl global', body)
    links.remove(light.inputs['Color'].links[0])
    light.inputs['Color'].default_value = (0.5, 0.5, 0.5, 1)
    assert scripted('    Color = time;\n') == exported().requests.getvalue(), 'osl time'
    # What Flex lacks raises in the export, which Blender reports on stderr from a depsgraph handler and goes on from
    for body, named in (('Color = Ng;', 'the global Ng'), ('getattribute("geom:name", Color);',
            "getattribute of 'geom:name'"), ('Color = transform("raster", P);', "the space 'raster'")):
        reported, stderr, export = io.StringIO(), sys.stderr, lambda _, graph: exported(graph)
        bpy.app.handlers.depsgraph_update_post.append(export)
        sys.stderr = reported
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('lacking.osl')
        script.script.write('shader lacking(output color Color = 0) {\n    ' + body + '\n}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(script.outputs['Color'], light.inputs['Color'])
        bpy.context.view_layer.update()
        sys.stderr = stderr
        bpy.app.handlers.depsgraph_update_post.remove(export)
        nodes.remove(script)
        assert named in reported.getvalue(), ('osl lacking', body, reported.getvalue())
    bpy.context.window.scene = shown
globaled()

# A Script node's closures export as the nodes drawing them do, byte for byte: weighted by a color as their Color, the
# microfacet by refract as the Glossy, Refraction or Glass BSDF of roughness alpha's root, a sum as the Add Shader; a
# closure Flex lacks, a closure chosen per hit and an anisotropic microfacet are refused by name
def closured():  # OSL closures
    shown, osl = bpy.context.window.scene, opened('osl closures')
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=1, calc_uvs=True)
    bm.to_mesh(mesh := bpy.data.meshes.new('closured'))
    osl.collection.objects.link(bpy.data.objects.new('closured', mesh))
    mesh.materials.append(material := bpy.data.materials.new('closured'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    output = nodes['Material Output'].inputs['Surface']
    nodes.remove(nodes['Principled BSDF'])
    tint = (0.2, 0.4, 0.6, 1)
    def scripted(body):  # The surface a script's BSDF, its export's bytes
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('closured.osl')
        script.script.write('shader closured(color Tint = color(0.2, 0.4, 0.6), output closure color BSDF = 0) {\n'
            '    ' + body + '\n}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(script.outputs['BSDF'], output)
        piped = exported().requests.getvalue()
        nodes.remove(script)
        return piped
    def noded(kind, **inputs):  # A node of the inputs given, its output
        node = nodes.new(kind)
        for name, value in inputs.items(): node.inputs[name].default_value = value
        return node.outputs[0]
    def drawn(socket):  # The surface the node's output, its export's bytes
        links.new(socket, output)
        return exported().requests.getvalue()
    summed = nodes.new('ShaderNodeAddShader')
    links.new(noded('ShaderNodeBsdfDiffuse', Color=tint), summed.inputs[0])
    links.new(noded('ShaderNodeEmission'), summed.inputs[1])
    for body, socket in (('BSDF = Tint * diffuse(N);', noded('ShaderNodeBsdfDiffuse', Color=tint)),
            ('BSDF = Tint * microfacet("ggx", N, 0.25, 1.45, 0);', noded('ShaderNodeBsdfGlossy', Color=tint)),
            ('BSDF = Tint * microfacet("ggx", N, 0.25, 1.45, 1);', noded('ShaderNodeBsdfRefraction', Color=tint,
            Roughness=0.5)), ('BSDF = Tint * microfacet("ggx", N, 0.25, 1.45, 2);', noded('ShaderNodeBsdfGlass',
            Color=tint, Roughness=0.5, IOR=1.45)), ('BSDF = Tint * emission();', noded('ShaderNodeEmission',
            Color=tint)), ('BSDF = transparent();', noded('ShaderNodeBsdfTransparent')),
            ('BSDF = Tint * translucent(N);', noded('ShaderNodeBsdfTranslucent', Color=tint)),
            ('BSDF = Tint * diffuse(N) + emission();', summed.outputs[0])):
        assert scripted(body) == drawn(socket), ('osl closure', body)
    # What Flex lacks raises in the export, which Blender reports on stderr from a depsgraph handler and goes on from
    for body, named in (('BSDF = phong(N, 10);', 'the closure phong'), ('if (P[0] > 0) BSDF = diffuse(N); '
            'else BSDF = emission();', 'closures chosen per hit'), ('BSDF = microfacet("ggx", N, vector(1, 0, 0), '
            '0.1, 0.3, 1.5, 0);', 'an anisotropic microfacet')):
        reported, stderr, export = io.StringIO(), sys.stderr, lambda _, graph: exported(graph)
        bpy.app.handlers.depsgraph_update_post.append(export)
        sys.stderr = reported
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('lacking.osl')
        script.script.write('shader lacking(output closure color BSDF = 0) {\n    ' + body + '\n}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(script.outputs['BSDF'], output)
        bpy.context.view_layer.update()
        sys.stderr = stderr
        bpy.app.handlers.depsgraph_update_post.remove(export)
        nodes.remove(script)
        assert named in reported.getvalue(), ('osl closure lacking', body, reported.getvalue())
    bpy.context.window.scene = shown
closured()

# A Script node's texture() of a file exports as the Image Texture node on the same file does, byte for byte: at the
# point (s, 1 - t), OSL's interp and wrap as the node's interpolation and extension; other options refused by name
def textured():  # OSL texture()
    shown, osl = bpy.context.window.scene, opened('osl texture')
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=1, calc_uvs=True)
    bm.to_mesh(mesh := bpy.data.meshes.new('textured'))
    osl.collection.objects.link(bpy.data.objects.new('textured', mesh))
    mesh.materials.append(material := bpy.data.materials.new('textured'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    light = nodes.new('ShaderNodeEmission')
    links.new(light.outputs[0], nodes['Material Output'].inputs['Surface'])
    made = bpy.data.images.new('osl texture', 4, 4)
    made.pixels = numpy.random.default_rng(7).random(64).tolist()
    made.filepath_raw, made.file_format = os.path.join(bpy.app.tempdir, 'osl texture.png'), 'PNG'
    made.save()
    path = made.filepath_raw
    bpy.data.images.remove(made)
    def scripted(options, piping=True):  # The light's color a script's texture() of the file, its export's bytes
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('textured.osl')
        script.script.write('shader textured(string File = "", output color Color = 0) {\n    point p;\n'
            '    getattribute("geom:uv", p);\n    Color = texture(File, p[0], p[1]' + options + ');\n}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        script.inputs['File'].default_value = path
        links.new(script.outputs['Color'], light.inputs['Color'])
        if not piping: return script
        piped = exported().requests.getvalue()
        nodes.remove(script)
        return piped
    split, combined, flipped = (nodes.new(kind) for kind in ('ShaderNodeSeparateXYZ', 'ShaderNodeCombineXYZ',
        'ShaderNodeMath'))
    links.new(nodes.new('ShaderNodeTexCoord').outputs['UV'], split.inputs[0])
    flipped.operation, flipped.inputs[0].default_value = 'SUBTRACT', 1
    links.new(split.outputs['Y'], flipped.inputs[1])
    links.new(split.outputs['X'], combined.inputs['X']), links.new(flipped.outputs[0], combined.inputs['Y'])
    read = nodes.new('ShaderNodeTexImage')
    read.image = bpy.data.images.load(path, check_existing=True)
    links.new(combined.outputs[0], read.inputs['Vector'])
    for options, interpolation, extension in ((', "interp", "closest", "wrap", "periodic"', 'Closest', 'REPEAT'),
            (', "interp", "linear", "wrap", "black"', 'Linear', 'CLIP'), ('', 'Smart', 'REPEAT')):
        piped = scripted(options)
        read.interpolation, read.extension = interpolation, extension
        links.new(read.outputs['Color'], light.inputs['Color'])
        assert exported().requests.getvalue() == piped, ('osl texture', options)
    # An option Flex lacks raises in the export, which Blender reports on stderr from a depsgraph handler
    reported, stderr, export = io.StringIO(), sys.stderr, lambda _, graph: exported(graph)
    bpy.app.handlers.depsgraph_update_post.append(export)
    sys.stderr = reported
    blurred = scripted(', "blur", 0.1', False)
    bpy.context.view_layer.update()
    nodes.remove(blurred)
    sys.stderr = stderr
    bpy.app.handlers.depsgraph_update_post.remove(export)
    assert 'texture options' in reported.getvalue(), ('osl texture blur', reported.getvalue())
    bpy.context.window.scene = shown
textured()

# Baking past a step of an object's own scalar: MAXIMUM(MIX(noise a, noise b, LESS_THAN(Object Info's Random, 2)),
# noise c) of the UV into the emission, live only for the step, bakes once per step value: two bakes, selected by the
# step live. With Object Info's Color in its place, which stays live, its three noises bake apart (main bakes them apart
# either way). Both steps are 1, so the two render alike, within twice the bake tolerance, on both backends
def stepped():
    shown, made = bpy.context.window.scene, opened('stepped', (0, 0, 0))
    made.render.resolution_x = made.render.resolution_y = 16
    made.camera = bpy.data.objects.new('stepped camera', bpy.data.cameras.new('stepped camera'))
    made.collection.objects.link(made.camera)
    made.camera.location.z, made.camera.data.type, made.camera.data.ortho_scale = 1, 'ORTHO', 1
    surface = plane('stepped', 0, 0)  # Into the test scene, moved to this one
    scene.collection.objects.unlink(ob := bpy.data.objects['stepped']), made.collection.objects.link(ob)
    nodes, links = surface.id_data.nodes, surface.id_data.links
    surface.inputs['Base Color'].default_value, surface.inputs['Emission Strength'].default_value = (0, 0, 0, 1), 1
    uv, info = nodes.new('ShaderNodeTexCoord').outputs['UV'], nodes.new('ShaderNodeObjectInfo')
    noises = [nodes.new('ShaderNodeTexNoise') for _ in range(3)]
    for k, noise in enumerate(noises):
        noise.inputs['Scale'].default_value, noise.inputs['Detail'].default_value = 3 + 2 * k, 1
        links.new(uv, noise.inputs['Vector'])
    step, mix, top = nodes.new('ShaderNodeMath'), nodes.new('ShaderNodeMix'), nodes.new('ShaderNodeMix')
    step.operation, step.inputs[1].default_value, mix.data_type = 'LESS_THAN', 2, 'RGBA'
    top.data_type, top.blend_type, top.inputs['Factor'].default_value = 'RGBA', 'LIGHTEN', 1
    links.new(info.outputs['Random'], step.inputs[0]), links.new(step.outputs[0], mix.inputs['Factor'])
    links.new(noises[0].outputs['Color'], mix.inputs[6]), links.new(noises[1].outputs['Color'], mix.inputs[7])
    links.new(mix.outputs[2], top.inputs[6]), links.new(noises[2].outputs['Color'], top.inputs[7])
    links.new(top.outputs[2], surface.inputs['Emission Color'])
    def bakes(output):
        links.new(info.outputs[output], step.inputs[0])
        return len(getattr(exported(bpy.context.evaluated_depsgraph_get()), 'placed', ()))
    counts = bakes('Color'), bakes('Random')
    assert counts == (3, 2), ('step baked', counts)
    for preferences.device in ('OPTIX', 'VULKAN'):
        links.new(info.outputs['Color'], step.inputs[0])
        live = render(made, 16)
        links.new(info.outputs['Random'], step.inputs[0])
        baked = render(made, 16)
        assert numpy.abs(baked - live).max() < 2 * module['BAKE_TOLERANCE'], ('step baked render', preferences.device,
            numpy.abs(baked - live).max())
    preferences.device, bpy.context.window.scene = device, shown

stepped()

# A Script node's Ng, u, v, dPdu and dPdv are of the hit's triangle: on one triangle, turned and tilted, smooth with its
# normals bent away from its face, seen straight down by an orthographic camera, its light the script's Color reads
# Ng the face's normal toward the camera (not the bent N), u and v the pixel's place along its edges from vertex 0,
# P = v0 + u (v1 - v0) + v (v2 - v0), and dPdu, dPdv those edges, all in the world
def triangled():  # OSL triangle globals
    shown, lit, was = bpy.context.window.scene, opened('osl triangle', sky=(0, 0, 0)), preferences.device
    lit.flex_restir = False
    lit.camera = bpy.data.objects.new('osl triangle camera', bpy.data.cameras.new('osl triangle camera'))
    lit.collection.objects.link(lit.camera)
    lit.camera.data.type, lit.camera.data.ortho_scale, lit.camera.location = 'ORTHO', 2, (0, 0, 5)
    corners = numpy.array(((-0.9, -0.7, 0), (0.8, -0.6, 0), (-0.2, 0.9, 0)))
    mesh = bpy.data.meshes.new('osl triangle')
    mesh.from_pydata(corners.tolist(), [], [(0, 1, 2)])
    mesh.shade_smooth()
    mesh.normals_split_custom_set([(0.6, 0, 0.8), (0, 0.6, 0.8), (-0.6, 0, 0.8)])
    lit.collection.objects.link(ob := bpy.data.objects.new('osl triangle', mesh))
    ob.rotation_euler, ob.scale = (0.4, 0, 0.3), (1.1, 0.9, 1)
    mesh.materials.append(material := bpy.data.materials.new('osl triangle'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    light = nodes.new('ShaderNodeEmission')
    links.new(light.outputs[0], nodes['Material Output'].inputs['Surface'])
    bpy.context.view_layer.update()
    world = numpy.array([ob.matrix_world @ Vector(c) for c in corners])
    face = numpy.cross(world[1] - world[0], world[2] - world[0])
    face *= numpy.sign(face[2]) / numpy.linalg.norm(face)  # Toward the camera above
    f = (numpy.arange(SIZE) + 0.5) / SIZE * 2 - 1
    x, y = numpy.meshgrid(f, f)  # Rows from the bottom, as render() gives them
    # (x, y) = v0 + u (v1 - v0) + v (v2 - v0) in the view's plane, the orthographic view keeping barycentrics
    edges = numpy.stack((world[1, :2] - world[0, :2], world[2, :2] - world[0, :2]), 1)
    u, v = numpy.moveaxis(numpy.linalg.solve(edges, numpy.stack((x - world[0, 0], y - world[0, 1]), 0).reshape(2, -1))
        .reshape(2, SIZE, SIZE), 0, 0)
    inside = (u > 0.05) & (v > 0.05) & (u + v < 0.95)  # Off the edges by a pixel and more
    assert inside.sum() > 400, inside.sum()
    for body, due in (('Color = Ng * 0.5 + 0.5;', numpy.broadcast_to(face * 0.5 + 0.5, (SIZE, SIZE, 3))),
            ('Color = color(u, v, 0);', numpy.stack((u, v, 0 * u), -1)),
            ('Color = dPdu * 0.25 + 0.5;', numpy.broadcast_to((world[1] - world[0]) * 0.25 + 0.5, (SIZE, SIZE, 3))),
            ('Color = dPdv * 0.25 + 0.5;', numpy.broadcast_to((world[2] - world[0]) * 0.25 + 0.5, (SIZE, SIZE, 3)))):
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('triangled.osl')
        script.script.write('shader triangled(output color Color = 0) {\n    ' + body + '\n}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(script.outputs['Color'], light.inputs['Color'])
        for preferences.device in ('OPTIX', 'VULKAN'):
            seen = render(lit)
            assert numpy.abs(seen[inside] - due[inside]).max() < 0.005, ('osl triangle', body, preferences.device,
                numpy.abs(seen[inside] - due[inside]).max())
        nodes.remove(script)
    preferences.device = was
    bpy.context.window.scene = shown
triangled()

# A Script node's noise() renders as Flex's own Noise or White Noise texture of the same point does: "perlin" (snoise)
# as the Noise texture of no detail unnormalized, "uperlin" (noise) normalized, in 1 to 4 dimensions, "hash" as
# the White Noise texture, "cell" as it of the point's floor, a periodic one of the point wrapped by the period, a color
# as the texture's color; on a plane seen straight down, at the same samples, on both backends
def noised():  # OSL noise()
    shown, lit, was = bpy.context.window.scene, opened('osl noise', sky=(0, 0, 0)), preferences.device
    lit.flex_restir, lit.flex_samples = False, 16
    lit.render.resolution_x = lit.render.resolution_y = 32
    lit.camera = bpy.data.objects.new('osl noise camera', bpy.data.cameras.new('osl noise camera'))
    lit.collection.objects.link(lit.camera)
    lit.camera.data.type, lit.camera.data.ortho_scale, lit.camera.location = 'ORTHO', 2, (0, 0, 1)
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=1, calc_uvs=True)
    bm.to_mesh(mesh := bpy.data.meshes.new('osl noise'))
    lit.collection.objects.link(bpy.data.objects.new('osl noise', mesh))
    mesh.materials.append(material := bpy.data.materials.new('osl noise'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    light = nodes.new('ShaderNodeEmission')
    links.new(light.outputs[0], nodes['Material Output'].inputs['Surface'])
    position, x = nodes.new('ShaderNodeNewGeometry').outputs['Position'], nodes.new('ShaderNodeSeparateXYZ')
    links.new(position, x.inputs[0])
    def textured(kind, dimensions, normalize=False, w=0, output=0, at=None):  # A noise texture of the position by 4
        node = nodes.new(kind)
        if kind == 'ShaderNodeTexNoise':
            node.noise_dimensions, node.normalize, node.inputs['Detail'].default_value = dimensions, normalize, 0
            node.inputs['Scale'].default_value = 4
            if dimensions == '4D': node.inputs['W'].default_value = w
        else: node.noise_dimensions = dimensions
        links.new(at or (x.outputs['X'] if dimensions == '1D' else position), node.inputs['W' if dimensions == '1D'
            else 'Vector'])
        return node.outputs[output]
    def calculated(kind, operation, *operands):  # A math node's result of sockets or constants, None left at default
        node = nodes.new(kind)
        node.operation = operation
        for socket, operand in zip(node.inputs, operands):
            if isinstance(operand, bpy.types.NodeSocket): links.new(operand, socket)
            elif operand is not None: socket.default_value = operand
        return node.outputs[0]
    scaled = calculated('ShaderNodeVectorMath', 'SCALE', position, None, None, 4)
    floored = calculated('ShaderNodeVectorMath', 'FLOOR', scaled)
    xy = [calculated('ShaderNodeMath', 'MULTIPLY', x.outputs[axis], 4) for axis in ('X', 'Y')]
    wrapped = nodes.new('ShaderNodeCombineXYZ')
    for axis, period, socket in zip(xy, (3, 2), wrapped.inputs): links.new(calculated('ShaderNodeMath', 'WRAP', axis,
        period, 0), socket)
    for body, socket in (('noise("perlin", P * 4)', textured('ShaderNodeTexNoise', '3D')),
            ('noise(P * 4)', textured('ShaderNodeTexNoise', '3D', True)),
            ('snoise(P[0] * 4)', textured('ShaderNodeTexNoise', '1D')),
            ('noise("perlin", P[0] * 4, P[1] * 4)', textured('ShaderNodeTexNoise', '2D')),
            ('noise("uperlin", P * 4, 0.3 * 4)', textured('ShaderNodeTexNoise', '4D', True, 0.3)),
            ('hashnoise(P)', textured('ShaderNodeTexWhiteNoise', '3D')),
            ('cellnoise(P * 4)', textured('ShaderNodeTexWhiteNoise', '3D', at=floored)),
            ('(color) noise("cell", P[0] * 4)', textured('ShaderNodeTexWhiteNoise', '1D', output=1, at=calculated(
                'ShaderNodeMath', 'FLOOR', xy[0]))),
            ('(color) noise(P * 4)', textured('ShaderNodeTexNoise', '3D', True, output=1)),
            ('(vector) snoise(P * 4, 0.3 * 4)', textured('ShaderNodeTexNoise', '4D', False, 0.3, output=1)),
            ('pnoise("cell", P * 4, point(3, 2, 5))', textured('ShaderNodeTexWhiteNoise', '3D', at=calculated(
                'ShaderNodeVectorMath', 'WRAP', floored, (3, 2, 5), (0, 0, 0)))),
            ('(color) pnoise("hash", P[0] * 4, P[1] * 4, 3, 2)', textured('ShaderNodeTexWhiteNoise', '2D', output=1,
                at=wrapped.outputs[0]))):
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('noised.osl')
        kind, body = body[1:].split(') ', 1) if body[0] == '(' else ('float', body)
        script.script.write(f'shader noised(output color Color = 0) {{\n    {kind} f = {body};\n    Color = f;\n}}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        for preferences.device in ('OPTIX', 'VULKAN'):
            links.new(script.outputs['Color'], light.inputs['Color'])
            seen = render(lit, 32)
            links.new(socket, light.inputs['Color'])
            due = render(lit, 32)
            assert numpy.ptp(due) > 0.01 and numpy.abs(seen - due).max() < 1e-5, ('osl noise', body, preferences.device,
                numpy.abs(seen - due).max())
        nodes.remove(script)
    # A period not a constant whole number of at least 1, a kind Flex lacks and a periodic simplex raise in the
    # export, which Blender reports on stderr from a depsgraph handler and goes on from
    for body, named in (('pnoise("cell", P, 2.5)', 'a period not'), ('pnoise("hash", P, point(1, 0, 1))',
            'a period not'), ('pnoise("cell", P, P[0])', 'a period not'), ('pnoise("perlin", P, 2.5)', 'a period not'),
            ('noise("lattice", P)', 'the noise "lattice"'), ('pnoise("simplex", P, 4)',
            'the noise "simplex" periodic')):
        reported, stderr, export = io.StringIO(), sys.stderr, lambda _, graph: exported(graph)
        bpy.app.handlers.depsgraph_update_post.append(export)
        sys.stderr = reported
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('lacking.osl')
        script.script.write(f'shader lacking(output color Color = 0) {{\n    float f = {body};\n    Color = f;\n}}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(script.outputs['Color'], light.inputs['Color'])
        bpy.context.view_layer.update()
        sys.stderr = stderr
        bpy.app.handlers.depsgraph_update_post.remove(export)
        nodes.remove(script)
        assert named in reported.getvalue(), ('osl noise lacking', body, reported.getvalue())
    preferences.device = was
    bpy.context.window.scene = shown
noised()

# A Script node's periodic noises render as the renderer defines them: periodic "perlin" and "uperlin" as noise()
# where the period exceeds the plane, repeating by the period
def noisier():  # OSL pnoise()
    shown, lit, was = bpy.context.window.scene, opened('osl noisier', sky=(0, 0, 0)), preferences.device
    lit.flex_restir, lit.flex_samples = False, 16
    lit.render.resolution_x = lit.render.resolution_y = 32
    lit.camera = bpy.data.objects.new('osl noisier camera', bpy.data.cameras.new('osl noisier camera'))
    lit.collection.objects.link(lit.camera)
    lit.camera.data.type, lit.camera.data.ortho_scale, lit.camera.location = 'ORTHO', 2, (0, 0, 1)
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, size=1, calc_uvs=True)
    bm.to_mesh(mesh := bpy.data.meshes.new('osl noisier'))
    lit.collection.objects.link(bpy.data.objects.new('osl noisier', mesh))
    mesh.materials.append(material := bpy.data.materials.new('osl noisier'))
    nodes, links = material.node_tree.nodes, material.node_tree.links
    light = nodes.new('ShaderNodeEmission')
    links.new(light.outputs[0], nodes['Material Output'].inputs['Surface'])
    def drawn(body, kind='float'):  # The plane lit by a script's value of the kind
        script = nodes.new('ShaderNodeScript')
        script.script = bpy.data.texts.new('noisier.osl')
        script.script.write(f'shader noisier(output color Color = 0) {{\n    {kind} f = {body};\n    Color = f;\n}}\n')
        Viewport.engine.update_script_node(types.SimpleNamespace(report=print), script)
        links.new(script.outputs['Color'], light.inputs['Color'])
        seen = render(lit, 32)
        nodes.remove(script)
        return seen
    for preferences.device in ('OPTIX', 'VULKAN'):
        for body, due in (('pnoise("perlin", P * 4 + 8, 1000)', 'noise("perlin", P * 4 + 8)'),
                ('pnoise(P * 4 + 8, point(1000, 1000, 1000))', 'noise(P * 4 + 8)'),
                ('pnoise(P[0] * 4 + 8, 1000)', 'noise(P[0] * 4 + 8)'),
                ('psnoise(P * 4 + 8, 0.6, point(1000, 1000, 1000), 1000)', 'snoise(P * 4 + 8, 0.6)'),
                ('pnoise("perlin", P * 4, 2)', 'pnoise("perlin", P * 4 + 2, 2)')):
            seen, wanted = drawn(f'0.5 + 0.5 * {body}', 'float'), drawn(f'0.5 + 0.5 * {due}', 'float')
            assert numpy.ptp(wanted) > 0.01 and numpy.abs(seen - wanted).max() < 1e-5, ('osl pnoise', body,
                preferences.device, numpy.abs(seen - wanted).max())
    preferences.device = was
    bpy.context.window.scene = shown
noisier()

# A Principled coat of IOR 1.5, smooth, over a black base reflecting nothing of its own, on a sphere seen as the sheen
# row sees its own under the white sky: at each view cosine it reflects the dielectric Fresnel there, each pixel over
# its area, the sky 1 past the rim. Over a white diffuse base instead, at 16 bounces, Max Bounces' most, it gives back
# what seven escapes leave: the light the coat lets in returns from the base and leaves through the coat's underside
# but for its internal diffuse reflectance, each round trip two bounces, F + (1 - F)(1 - R^7)
scene = new('coat', sky=(1, 1, 1))
scene.camera = add(bpy.data.cameras.new('coat'), (0, 0, 10))
scene.camera.data.angle, scene.flex_restir, scene.flex_bounces = 2 * math.atan(0.12), False, 16
coat = shape('coat', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=128, v_segments=64, radius=1), (0, 0, 0))
bpy.data.meshes['coat'].shade_smooth()
for name, value in (('Base Color', (0, 0, 0, 1)), ('Specular IOR Level', 0), ('Coat Weight', 1), ('Coat IOR', 1.5),
        ('Coat Roughness', 0)):
    coat.inputs[name].default_value = value
def cosines(dx, dy):  # Of the rays through each pixel's point dx, dy off its centre, the view cosine on the sphere or 0
    u, v = (((numpy.arange(SIZE) + 0.5 + d) / SIZE * 2 - 1) * 0.12 for d in (dx, dy))
    ray = numpy.stack([*numpy.meshgrid(u, v), -numpy.ones((SIZE, SIZE))], -1)
    ray /= numpy.linalg.norm(ray, axis=-1, keepdims=True)
    reach = (10 * ray[..., 2]) ** 2 - 99
    hit = numpy.array((0, 0, 10)) + (-10 * ray[..., 2] - numpy.sqrt(numpy.clip(reach, 0, None)))[..., None] * ray
    return numpy.where(reach > 0, -(hit * ray).sum(-1), 0)
def fresnel(c, eta=1.5):  # Unpolarized, into IOR eta relative, 1 at grazing as the sky past the rim and past TIR
    g2 = eta * eta - 1 + c * c
    g = numpy.sqrt(numpy.maximum(g2, 0))
    return numpy.where(g2 > 0, 0.5 * ((g - c) / (g + c)) ** 2 * (1 + ((c * (g + c) - 1) / (c * (g - c) + 1)) ** 2), 1)
offsets = (numpy.arange(16) + 0.5) / 16 - 0.5
facing, coated = cosines(0, 0), numpy.mean([fresnel(cosines(dx, dy)) for dx in offsets for dy in offsets], 0)
pixels = render().mean(-1)
for low, high in ((0.9, 1), (0.4, 0.6), (0.15, 0.3)):
    ring = (facing > low) & (facing <= high)
    print('COAT at cosines', low, high, pixels[ring].mean(), 'Fresnel', coated[ring].mean(), flush=True)
    assert numpy.isclose(pixels[ring].mean(), coated[ring].mean(), rtol=0.03), 'coat reflectance'
coat.inputs['Base Color'].default_value = (1, 1, 1, 1)
angles = (numpy.arange(4096) + 0.5) / 4096 * math.pi / 2  # The underside's diffuse reflectance, by quadrature
inner = (fresnel(numpy.cos(angles), 1 / 1.5) * numpy.sin(2 * angles)).sum() * math.pi / 2 / 4096
escaped = numpy.mean([(1 - (1 - fresnel(cosines(dx, dy))) * inner ** 7) for dx in offsets for dy in offsets], 0)
furnace = render().mean(-1)[facing > 0.15].mean()
print('COAT furnace', furnace, 'derived', escaped[facing > 0.15].mean(), flush=True)
assert abs(furnace - escaped[facing > 0.15].mean()) < 5e-4, 'coat furnace'  # One image's SD 9e-5
# A Ray Portal BSDF with neither position nor direction linked lets rays on as they were, tinted by its color: in front
# of the white sky it reads that color. The Refraction BSDF renders as the Glass BSDF, with Fresnel reflection, which a
# surface needs to keep the light it does not transmit: a closed sphere of it under the white sky is the glass one
scene = new('portal', samples=64, sky=(1, 1, 1))
scene.camera = add(bpy.data.cameras.new('portal view'), (0, 0, 1))
scene.camera.data.angle, scene.flex_restir = 0.5, False
portal = shape('portal', lambda bm: bmesh.ops.create_grid(bm, size=1), (0, 0, 0)).id_data
gate = portal.nodes.new('ShaderNodeBsdfRayPortal')
gate.inputs['Color'].default_value = (0.8, 0.4, 0.2, 1)
portal.links.new(gate.outputs[0], portal.get_output_node('CYCLES').inputs['Surface'])
assert numpy.allclose(render().mean((0, 1)), (0.8, 0.4, 0.2), rtol=0.01), 'ray portal'
bpy.data.objects['portal'].hide_render, scene.camera.location.z, scene.flex_bounces = True, 4, 16
spheres = shape('refraction', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=64, v_segments=32, radius=1),
    (0, 0, 0)).id_data
bpy.data.meshes['refraction'].shade_smooth()
renders = []
for kind in ('ShaderNodeBsdfRefraction', 'ShaderNodeBsdfGlass'):
    shader = spheres.nodes.new(kind)
    shader.inputs['Roughness'].default_value, shader.inputs['IOR'].default_value = 0, 1.5
    spheres.links.new(shader.outputs[0], spheres.get_output_node('CYCLES').inputs['Surface'])
    renders.append(render())
print('REFRACTION furnace', renders[0][24:40, 24:40].mean(), flush=True)
assert numpy.array_equal(*renders) and 0.99 <= renders[0][24:40, 24:40].mean() <= 1.002, 'refraction as glass'

# Dispersion, k = Scale / Abbe of a Principled BSDF that transmits: none at Scale 0, at an Abbe number of 0 or below or
# without transmission, the scene piping byte for byte as at Blender's defaults, and marked by k otherwise. A clear
# dispersive glass sphere under the white sky, each path one wavelength drawn by FK's signed CIE weights, reads per
# channel what the same sphere without dispersion reads: without ReSTIR within 0.006, 4 SD of one image's channel at
# 1024 samples; with it, whose reuse spreads a wavelength's color over neighbours, in luminance within 0.015, 4 SD
scene = opened('dispersion', sky=(1, 1, 1))
scene.camera = add(bpy.data.cameras.new('dispersion'), (0, 0, 4))
scene.camera.data.angle, scene.flex_samples, scene.flex_bounces = 2 * math.atan(0.3), 1024, 16
spread = shape('dispersive', lambda bm: bmesh.ops.create_uvsphere(bm, u_segments=64, v_segments=32, radius=1),
    (0, 0, 0))
bpy.data.meshes['dispersive'].shade_smooth()
spread.inputs['Base Color'].default_value, spread.inputs['Roughness'].default_value = (1, 1, 1, 1), 0
def piped(scale, abbe, weight):  # The scene's requests at the inputs given
    for name, value in (('Scale', scale), ('Abbe Number', abbe), ('', weight)):
        spread.inputs[f'Transmission {"Dispersion " + name if name else "Weight"}'].default_value = value
    return exported().requests.getvalue()
assert all(piped(*inputs) == piped(0, 20, 1) for inputs in ((0, 5, 1), (1, 0, 1), (1, -5, 1))) and \
    piped(1, 5, 0) == piped(0, 20, 0), 'no dispersion'
dispersive, marked = piped(1, 5, 1), flex.resolve(spread.id_data.nodes['Material Output'].inputs['Surface'])
assert dispersive != piped(0, 20, 1) and len(marked) > 23 and flex.marks(marked[23], 'DISPERSION') and numpy.allclose(
    flex.fold(marked[23])[1], 0.2), 'dispersion marked'
spread.inputs['Transmission Dispersion Abbe Number'].default_value = 5
x = ((numpy.arange(SIZE) + 0.5) / SIZE * 2 - 1) * 0.3  # The pixels whose rays meet the sphere well inside its rim
covered = numpy.hypot(*numpy.meshgrid(x, x)) < 0.8 * math.tan(math.asin(0.25))
for scene.flex_restir in (False, True):
    furnaces = []
    for scale in (0, 1):
        spread.inputs['Transmission Dispersion Scale'].default_value = scale
        furnaces.append(render()[covered].mean(0))
    print('DISPERSION furnace, ReSTIR', scene.flex_restir, furnaces, flush=True)
    luminance = [furnace @ (0.2126, 0.7152, 0.0722) for furnace in furnaces]
    assert numpy.allclose(furnaces[1], furnaces[0], rtol=0.006) if not scene.flex_restir else \
        abs(luminance[1] / luminance[0] - 1) < 0.015, ('dispersion furnace', scene.flex_restir)

# A prism of 60 degrees, IOR 1.5 at the d line and Abbe number 5, turned about its axis so rays along x meet its first
# face at the d line's minimum deviation, casts them onto a strip 10 away across the d line's exit, emitting its own x
# over its width: per channel, over the strip emitting 1, the x they land at is FK's weights' mean by wavelength over
# every path Snell's law and the faces' Fresnel give, reflections inside too, within 0.05 degrees, 6 SD of one image
# without ReSTIR; without dispersion, the d line's alone
scene = opened('prism', sky=(0, 0, 0))
scene.render.resolution_x = scene.render.resolution_y = 32
scene.camera = add(bpy.data.cameras.new('prism'), (-3, 0, 0), (math.pi / 2, 0, -math.pi / 2))
scene.camera.data.type, scene.camera.data.ortho_scale, scene.flex_samples = 'ORTHO', 0.2, 1024
scene.flex_restir, scene.flex_bounces = False, 16
turn, corners = math.asin(0.75) - math.pi / 6, [(0, 3 ** -0.5), (-0.5, -0.5 * 3 ** -0.5), (0.5, -0.5 * 3 ** -0.5)]
def prismed(bm):  # Its x, z corners around the centroid, along y
    v = [bm.verts.new((x, y, z)) for y in (-1, 1) for x, z in corners]
    for face in ((0, 1, 2), (3, 5, 4), *((k, (k + 1) % 3, (k + 1) % 3 + 3, k + 3) for k in range(3))):
        bm.faces.new([v[i] for i in face])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
prism = shape('prism', prismed, (0, 0, 0), (0, turn, 0))
prism.inputs['Base Color'].default_value, prism.inputs['Roughness'].default_value = (1, 1, 1, 1), 0
for name, value in (('Weight', 1), ('Dispersion Scale', 1), ('Dispersion Abbe Number', 5)):
    prism.inputs['Transmission ' + name].default_value = value
apex, left, right = (numpy.array((x * math.cos(turn) + z * math.sin(turn), z * math.cos(turn) - x * math.sin(turn)))
    for x, z in corners)
faces = (apex, left), (apex, right), (left, right)  # Entry, exit and base, as segments in x, z
def met(o, d, skip):  # The nearest face the ray from o along d meets, but the one it leaves: its distance and index
    near = None
    for k, (a, b) in enumerate(faces):
        e, den = b - a, (b - a)[0] * d[1] - (b - a)[1] * d[0]
        t = (e[0] * (a - o)[1] - e[1] * (a - o)[0]) / den if k != skip and den else -1
        if t > 1e-9 and 0 <= (o + t * d - a) @ e / (e @ e) <= 1 and (near is None or t < near[0]): near = t, k
    return near
def split(o, d, n, inside, skip):  # Where it meets a face, its cosine, the direction refracted or None, reflected, F
    t, k = met(o, d, skip)
    e = faces[k][1] - faces[k][0]
    facing = numpy.array((e[1], -e[0])) / math.hypot(*e)
    facing = facing if facing @ d < 0 else -facing
    c, eta = -facing @ d, 1 / n if inside else n
    g = math.sqrt(max(eta * eta - 1 + c * c, 0))
    f = 1 if not g else 0.5 * ((g - c) / (g + c)) ** 2 * (1 + ((c * (g + c) - 1) / (c * (g - c) + 1)) ** 2)
    return o + t * d, k, (d + (c - g) * facing) / eta if g else None, d + 2 * c * facing, f
o, normal = numpy.array((-3.0, 0.0)), numpy.array((1.0, 0.0))  # The d line's direct path, the strip across its exit
for inside in (False, True): o, skip, normal, _, _ = split(o, normal, 1.5, inside, -1 if not inside else skip)
centre, across = o + 10 * normal, numpy.array((-normal[1], normal[0])) * math.tan(math.radians(25)) * 10
ends = centre - across, centre + across
strip = bpy.data.meshes.new('strip')
strip.from_pydata([(x, y, z) for x, z in ends for y in (-2, 2)], [], [(0, 1, 3, 2)])
emitter = bpy.data.materials.new('strip')
strip.materials.append(emitter)
scene.collection.objects.link(bpy.data.objects.new('strip', strip))
nodes = emitter.node_tree.nodes
surface, coordinate = nodes['Principled BSDF'], nodes.new('ShaderNodeSeparateXYZ')
surface.inputs['Base Color'].default_value, surface.inputs['IOR'].default_value = (0, 0, 0, 1), 1
surface.inputs['Emission Color'].default_value = (1, 1, 1, 1)
emitter.node_tree.links.new(nodes.new('ShaderNodeTexCoord').outputs['Generated'], coordinate.inputs[0])
low, high = sorted(e[0] for e in ends)
def landed(o, d, n, inside=False, w=1.0, skip=-1, depth=6):  # Every branch to the strip: its x and weight each
    if met(o, d, skip) is None:
        x = (o + (centre - o) @ normal / (d @ normal) * d - low)[0] / (high - low) if d @ normal > 0 else -1
        return [(x, w)] if not inside and 0 <= x <= 1 else []
    p, k, refracted, reflected, f = split(o, d, n, inside, skip)
    return [] if not depth else (landed(p, refracted, n, not inside, w * (1 - f), k, depth - 1) if refracted is not None
        else []) + landed(p, reflected, n, inside, w * f, k, depth - 1)
text = open(os.path.join(os.path.dirname(__file__), 'shaders', 'flexkernels', 'pathtracer.cuh')).read()
table = text.split('WAVELENGTH_WEIGHTS_0 = { {')[1].split('}')[0]  # FK's signed CIE weights, 5 nm apart from 380 nm
lengths = numpy.linspace(0.38, 0.78, 401)
weights = numpy.stack([numpy.interp(lengths, numpy.linspace(0.38, 0.78, 81), numpy.array([float(w.strip(' \nf'))
    for w in table.split(',')]).reshape(81, 3)[:, c]) for c in range(3)], -1)
heights = ((numpy.arange(32) + 0.5) / 32 - 0.5) * 0.2
for scale in (1, 0):  # FK's IOR by wavelength, Cauchy's through the d line
    prism.inputs['Transmission Dispersion Scale'].default_value = scale
    n = 1.5 + 0.5 * scale / 5 / 1.90962409973144531 * (1 / lengths ** 2 - 2.89662933349609375)
    hits = [[landed(numpy.array((-3.0, z)), numpy.array((1.0, 0.0)), k) for k in n] for z in heights]
    expected = sum(weights[i] * x * w for row in hits for i, paths in enumerate(row) for x, w in paths) / sum(
        weights[i] * w for row in hits for i, paths in enumerate(row) for x, w in paths)
    seen = []
    for linked in (True, False):
        if linked: emitter.node_tree.links.new(coordinate.outputs['X'], surface.inputs['Emission Strength'])
        else: emitter.node_tree.links.remove(surface.inputs['Emission Strength'].links[0])
        surface.inputs['Emission Strength'].default_value = 1
        seen.append(render(size=32).mean((0, 1)))
    print('PRISM scale', scale, seen[0] / seen[1], 'expected', expected, flush=True)
    assert numpy.allclose(seen[0] / seen[1], expected, atol=0.05 * 0.0187), ('prism', scale)  # 0.0187 of x a degree

# The warm-up's renderer, which interactive Blender starts: on a fresh OptiX cache one compiles the generic module while
# a second, finding its lock held, exits at once; the module cached, a third exits at once too
import subprocess, tempfile
with tempfile.TemporaryDirectory() as cache:
    warm = lambda: subprocess.Popen((flex.BINARY, 'warm', str(os.getpid())),
        env={**os.environ, 'OPTIX_CACHE_PATH': cache})
    first = warm()
    time.sleep(1)
    t = time.perf_counter()
    assert warm().wait(30) == 0 and time.perf_counter() - t < 10, 'warm-up twice at once'
    assert first.wait(900) == 0, 'warm-up'
    t = time.perf_counter()
    assert warm().wait(60) == 0 and time.perf_counter() - t < 10, 'warm-up of a cached module'
    # A UI Blender's viewport's first frame, by that cached generic module, matches the headless one's mean
    def tiered():  # A UI Blender's first frame by the generic module
        class Tiered(Viewport):  # As the engine's spawn on OptiX, without the headless argument background mode adds
            def __init__(self):
                self.device = 'OPTIX'
                process = subprocess.Popen((flex.BINARY, str(self.shared.fileno()), str(os.getpid())),
                    stdin=subprocess.PIPE, stdout=subprocess.PIPE, pass_fds=(self.shared.fileno(),),
                    env={**os.environ, 'OPTIX_CACHE_PATH': cache})
                self.requests, self.answers, self.process = process.stdin, process.stdout, process
                process.stdin = process.stdout = None
        lit = opened('generic module')
        lit.camera = bpy.data.objects.new('generic module', bpy.data.cameras.new('generic module'))
        lit.camera.location.z = 2
        lamp = bpy.data.objects.new('generic lamp', bpy.data.lights.new('generic lamp', 'POINT'))
        lamp.location.z, lamp.data.energy = 1, 100
        floor = bpy.data.meshes.new('generic floor')
        bm = bmesh.new()
        bmesh.ops.create_grid(bm, size=1)
        bm.to_mesh(floor)
        for ob in (lit.camera, lamp, bpy.data.objects.new('generic floor', floor)): lit.collection.objects.link(ob)
        depsgraph = bpy.context.evaluated_depsgraph_get()
        offscreen = gpu.types.GPUOffScreen(SIZE, SIZE, format='RGBA32F')
        view = types.SimpleNamespace(region=types.SimpleNamespace(width=SIZE, height=SIZE),
            region_data=types.SimpleNamespace(view_matrix=lit.camera.matrix_world.inverted(),
            window_matrix=lit.camera.calc_matrix_camera(depsgraph, x=SIZE, y=SIZE), view_perspective='CAMERA'),
            space_data=types.SimpleNamespace(camera=lit.camera, clip_end=1000))
        first = []
        for kind in (Viewport, Tiered):
            engine = kind()
            with offscreen.bind():
                gpu.matrix.load_matrix(Matrix.Identity(4))
                gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE,
                    2 / SIZE, 1, 1)))
                engine.view_update(view, depsgraph)
                engine.view_draw(view, depsgraph)
                first.append(numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0,
                    'FLOAT').to_list())[..., :3])
        engine.requests.close()  # Its renderer ended before its cache goes
        engine.process.wait(60)
        means = [frame.mean((0, 1)) for frame in first]  # Which a path flipped by rounding moves within 4 errors
        assert numpy.isfinite(first[1]).all() and first[1].max() > 0 and numpy.allclose(means[1], means[0], rtol=0.05,
            atol=0), ('generic module', means)
    tiered()
    # The cached generic module on content, a baked texture, an image world and a fog volume: a UI viewport's first
    # frame matches the headless one's mean within 4 errors, its spread measured from 8 more frames' 4-sample increments
    def contented():  # The generic module on content
        import shutil
        offscreen = gpu.types.GPUOffScreen(SIZE, SIZE, format='RGBA32F')
        class Spawned(Viewport):  # On OptiX by a copy of the cached generic module, which stands in unless headless
            def __init__(self, headless, copy):
                self.device = 'OPTIX'
                process = subprocess.Popen((flex.BINARY, str(self.shared.fileno()), str(os.getpid()))
                    + ('headless',) * headless, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                    pass_fds=(self.shared.fileno(),), env={**os.environ, 'OPTIX_CACHE_PATH': copy})
                self.requests, self.answers, self.process = process.stdin, process.stdout, process
                process.stdin = process.stdout = None
        def floored(name):  # A floor of 1 with UVs, a lamp 1 above it and a camera 2 above
            made = opened(name)
            made.camera = bpy.data.objects.new(name, bpy.data.cameras.new(name))
            made.camera.location.z = 2
            lamp = bpy.data.objects.new(name + ' lamp', bpy.data.lights.new(name + ' lamp', 'POINT'))
            lamp.location.z, lamp.data.energy = 1, 100
            floor, bm = bpy.data.meshes.new(name + ' floor'), bmesh.new()
            bm.loops.layers.uv.new()
            bmesh.ops.create_grid(bm, size=1, calc_uvs=True)
            bm.to_mesh(floor), bm.free()
            floor.materials.append(bpy.data.materials.new(name + ' floor'))
            for ob in (made.camera, lamp, bpy.data.objects.new(name + ' floor', floor)):
                made.collection.objects.link(ob)
            return made
        def drawn(made, engine, count, update=None):  # Image means of the engine's first count draws of the camera's
            depsgraph = bpy.context.evaluated_depsgraph_get()  # view, 4 samples each, after its view_update
            view = types.SimpleNamespace(region=types.SimpleNamespace(width=SIZE, height=SIZE),
                region_data=types.SimpleNamespace(view_matrix=made.camera.matrix_world.inverted(),
                window_matrix=made.camera.calc_matrix_camera(depsgraph, x=SIZE, y=SIZE), view_perspective='CAMERA'),
                space_data=types.SimpleNamespace(camera=made.camera, clip_end=1000))
            means = []
            with offscreen.bind():
                gpu.matrix.load_matrix(Matrix.Identity(4))
                gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE,
                    2 / SIZE, 1, 1)))
                engine.view_update(view, update or depsgraph)
                for _ in range(count):
                    engine.view_draw(view, depsgraph)
                    frame = numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0,
                        'FLOAT').to_list())[..., :3]
                    assert numpy.isfinite(frame).all(), ('generic content', made.name)
                    means.append(frame.reshape(-1, 3).mean(0))
            return numpy.array(means)
        def errors(means):  # The spread of a 4-sample frame's mean: of the increments of a view's draws past its first
            k = numpy.arange(2, len(means) + 1)[:, None]
            return numpy.std(k * means[1:] - (k - 1) * means[:-1], 0, ddof=1)
        def ended(engine): engine.requests.close(), engine.process.wait(60)
        def copied(label):  # The cache of the generic alone, for the scene's tiered engine to find no module of its own
            copy = os.path.join(cache, label)
            shutil.copytree(cache, copy, ignore=shutil.ignore_patterns('flex-*.lock', 'copy-*'))
            return copy
        def standing(made, label):  # The generic's first frame of the scene against the headless frames of it
            copy = copied(label)
            first = drawn(made, tiered := Spawned(False, copy), 1)[0]
            ended(tiered)
            means = drawn(made, headless := Spawned(True, copy), 9)
            ended(headless)
            assert (abs(first - means[0]) <= 4 * errors(means)).all() and first.max() > 0, (label, first,
                means[0], errors(means))
        def lit_world(name):  # The floor under a world of a float image read Closest, black but one texel of 1000,
            made = floored(name)  # seen orthographically
            hot = numpy.zeros((32, 64, 4), 'f')
            hot[..., 3], hot[23, 10, :3] = 1, 1000
            picture = bpy.data.images.new(name, 64, 32, float_buffer=True)
            picture.pixels.foreach_set(hot.ravel())
            nodes = made.world.node_tree.nodes
            texture = nodes.new('ShaderNodeTexEnvironment')
            texture.image, texture.interpolation = picture, 'Closest'
            made.world.node_tree.links.new(texture.outputs['Color'], nodes['Background'].inputs['Color'])
            made.camera.data.type, made.camera.data.ortho_scale = 'ORTHO', 1
            return made
        baked = floored('generic baked')
        tree = baked.collection.objects['generic baked floor'].data.materials[0].node_tree
        noise = tree.nodes.new('ShaderNodeTexNoise')
        tree.links.new(tree.nodes.new('ShaderNodeTexCoord').outputs['UV'], noise.inputs['Vector'])
        tree.links.new(noise.outputs['Color'], tree.nodes['Principled BSDF'].inputs['Base Color'])
        standing(baked, 'copy-baked')
        standing(lit_world('generic world'), 'copy-world')
        fog = floored('generic fog')
        cube, bm = bpy.data.meshes.new('generic fog cube'), bmesh.new()
        bmesh.ops.create_cube(bm, size=0.6)
        bm.to_mesh(cube), bm.free()
        cube.materials.append(murk := bpy.data.materials.new('generic fog cube'))
        murk.node_tree.nodes.remove(murk.node_tree.nodes['Principled BSDF'])
        murk.node_tree.links.new(murk.node_tree.nodes.new('ShaderNodeVolumePrincipled').outputs[0],
            murk.node_tree.nodes['Material Output'].inputs['Volume'])
        fog.collection.objects.link(held := bpy.data.objects.new('generic fog cube', cube))
        held.location.z = 0.4
        standing(fog, 'copy-fog')
        # The image world's Sample World Light turned off by a second view_update while the generic stands in, an
        # update that keeps the world's light table, against the headless frames of the world with it off
        switched = lit_world('generic switch')
        copy = copied('copy-switch')
        drawn(switched, tiered := Spawned(False, copy), 1)
        switched.world.flex_sample_light = False
        depsgraph = bpy.context.evaluated_depsgraph_get()
        update = types.SimpleNamespace(scene_eval=depsgraph.scene_eval, object_instances=depsgraph.object_instances,
            scene=depsgraph.scene, mode=depsgraph.mode, updates=[types.SimpleNamespace(id=switched.world,
            is_updated_geometry=False, is_updated_transform=False, is_updated_shading=True)])
        first = drawn(switched, tiered, 1, update)[0]
        ended(tiered)
        means = drawn(switched, headless := Spawned(True, copy), 9)
        ended(headless)
        assert (abs(first - means[0]) <= 4 * errors(means)).all() and first.max() > 0, ('generic switch', first,
            means[0], errors(means))
    contented()

# The OptiX denoiser on the fog scene: its F12 finite and its mean within 4 errors of the undenoised 16-sample frame's,
# the errors measured from a headless viewport's 4-sample increments, past the shift it was measured to make; then a
# viewport's draw, a camera nudge within the jump distance and a second draw, both finite
def denoised():  # The OptiX denoiser
    fog = bpy.data.scenes['generic fog']
    bpy.context.window.scene, preferences.device, fog.flex_samples, fog.flex_restir = fog, 'OPTIX', 64, False
    depsgraph = bpy.context.evaluated_depsgraph_get()
    offscreen = gpu.types.GPUOffScreen(SIZE, SIZE, format='RGBA32F')
    def drawn(engine, shifts):  # The engine's frames after a draw at each shift of the camera's view along x
        frames = []
        with offscreen.bind():
            gpu.matrix.load_matrix(Matrix.Identity(4))
            gpu.matrix.load_projection_matrix(Matrix.Translation((-1, -1, 0)) @ Matrix.Diagonal((2 / SIZE, 2 / SIZE,
                1, 1)))
            for shift in shifts:
                view = types.SimpleNamespace(region=types.SimpleNamespace(width=SIZE, height=SIZE),
                    region_data=types.SimpleNamespace(view_matrix=Matrix.Translation((-shift, 0, 0))
                    @ fog.camera.matrix_world.inverted(), window_matrix=fog.camera.calc_matrix_camera(depsgraph,
                    x=SIZE, y=SIZE), view_perspective='CAMERA'), space_data=types.SimpleNamespace(camera=fog.camera,
                    clip_end=1000))
                if not frames: engine.view_update(view, depsgraph)
                engine.view_draw(view, depsgraph)
                frames.append(numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0,
                    'FLOAT').to_list())[..., :3])
        engine.requests.close()
        return frames
    fog.flex_denoise = False
    means = numpy.array([frame.reshape(-1, 3).mean(0) for frame in drawn(Viewport(), [0] * 9)])
    k = numpy.arange(2, len(means) + 1)[:, None]
    errors = numpy.std(k * means[1:] - (k - 1) * means[:-1], 0, ddof=1) / 2  # Of 16 samples, four times 4
    fog.flex_samples = 16
    plain = render(fog, SIZE)
    fog.flex_denoise = True
    smooth = render(fog, SIZE)
    shift = 0.00123  # The denoiser's shift of the mean, relative: the largest over four scenes its lamp moved by 1 mm
    gap = abs(smooth.reshape(-1, 3).mean(0) - plain.reshape(-1, 3).mean(0))
    assert numpy.isfinite(smooth).all() and (gap <= 4 * errors + shift * plain.reshape(-1, 3).mean(0)).all(), (
        'denoiser', gap, errors)
    fog.flex_samples = 64
    nudged = drawn(Viewport(), [0, 0.01 * fog.flex_jump_distance])
    assert all(numpy.isfinite(frame).all() and frame.max() > 0 for frame in nudged), 'denoised viewport'
    preferences.device = device
denoised()
