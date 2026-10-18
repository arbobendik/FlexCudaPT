# End-to-end test, run by make test: renders a lit plane, half colored and half textured, and a textured emitter under a
# sky with Flex through a render border and checks the pixels, then draws the same view through the engine's viewport
# methods and compares.
import bpy, bmesh, gpu, io, math, numpy, os, sys, types
from mathutils import Matrix

SIZE = 64
COLOR = (0.8, 0.2, 0.1)
TEXELS = ((1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 1))  # 2x2 texture, bottom row first
SKY = (0.1, 0.2, 0.4)

scene = bpy.data.scenes.new('test')
scene.render.engine = 'FLEX'
scene.render.resolution_x = SIZE
scene.render.resolution_y = SIZE
scene.flex_samples = 256
scene.render.image_settings.file_format = 'OPEN_EXR'
scene.render.filepath = bpy.app.tempdir + 'test.exr'
scene.render.use_border = True
scene.render.border_max_y = 0.875  # Leaves the top eighth unrendered
scene.world = bpy.data.worlds.new('sky')
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (*SKY, 1)

def add(data, location):
    ob = bpy.data.objects.new(data.name, data)
    ob.location = location
    scene.collection.objects.link(ob)
    return ob

def plane(name, x, y=0, size=1):  # Square at height 0 with a Principled BSDF, returned
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bm.loops.layers.uv.new()
    bmesh.ops.create_grid(bm, size=size / 2, calc_uvs=True)
    bm.to_mesh(mesh)
    mesh.shade_smooth()  # The colored plane's normals slightly off the face: light sampling leaves it at an offset
    mesh.normals_split_custom_set([(0, 0.01 if name == 'colored' else 0, 1)] * len(mesh.loops))
    mesh.materials.append(bpy.data.materials.new(name))
    add(mesh, (x, y, 0))
    mesh.materials[0].node_tree.nodes['Principled BSDF'].inputs['IOR'].default_value = 1  # Pure colors: no specular
    return mesh.materials[0].node_tree.nodes['Principled BSDF']

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
fog = plane('fog', 0, 0, 4).id_data  # Not rendered: volume only
output = fog.nodes['Material Output']
fog.links.remove(output.inputs['Surface'].links[0])
fog.links.new(fog.nodes.new('ShaderNodeVolumePrincipled').outputs['Volume'], output.inputs['Volume'])
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

STATS = []
def stats(*args): STATS.append(args[0])
bpy.app.handlers.render_stats.append(stats)
bpy.ops.render.render(scene=scene.name, write_still=True)
bpy.app.handlers.render_stats.remove(stats)
progress = [message for message in STATS if ' | Sample ' in message]
counts = [int(message.split('Sample ')[1].split('/')[0]) for message in progress]
assert counts[0] == 1 and counts[-1] == scene.flex_samples and all(
    0 < batch <= 64 for batch in numpy.diff([0, *counts])), 'sample progress'
assert len(counts) <= 10, 'batched progress'
assert all('Remaining:' in message and 'samples/s' in message for message in progress), 'performance stats'
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]

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

gpu.init()
bpy.context.window.scene = scene
depsgraph = bpy.context.evaluated_depsgraph_get()
viewport = Viewport()
offscreen = gpu.types.GPUOffScreen(SIZE, SIZE, format='RGBA32F')
region = types.SimpleNamespace(width=SIZE, height=SIZE)
region_data = types.SimpleNamespace(view_matrix=scene.camera.matrix_world.inverted(),
    window_matrix=scene.camera.calc_matrix_camera(depsgraph, x=SIZE, y=SIZE))
context = types.SimpleNamespace(region=region, region_data=region_data)
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
bpy.ops.render.render(scene=scene.name, write_still=True)
uncut = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]
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
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]
red, green, blue = pixels[18:46, 2:30].mean((0, 1))
assert max(red, green, blue) < 1.02 * min(red, green, blue), 'specular tint'
# A black cutout covering half lets half the light through to the textured plane and half its light back
alpha.image.pixels.foreach_set((0, 0, 0, 0.5))
cutout.inputs['Base Color'].default_value = (0, 0, 0, 1)
bpy.data.objects['cutout'].hide_render = False
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]
assert 0.2 < pixels[18:46, 34:62].mean() / uncut[18:46, 34:62].mean() < 0.32, 'coverage'
for ob in scene.objects: ob.hide_render = ob != scene.camera  # Nothing left to render but the sky
bpy.ops.render.render(scene=scene.name, write_still=True)
empty = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[:56, :, :3]
assert numpy.allclose(empty, SKY, atol=0.01), 'empty'
# A white dielectric under a white sky reflects its light and its diffuse beside its specular, as FlexLight's BSDF
bpy.data.objects['colored'].hide_render = False
colored.inputs['Base Color'].default_value = colored.inputs['Specular Tint'].default_value = (1, 1, 1, 1)
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]
assert abs(pixels[18:46, 2:30].mean() - 1.048) < 0.02, 'furnace'
colored.inputs['Specular Tint'].default_value = (1, 0.08, 0.375, 1)  # Changes nothing, FlexLight's BSDF has no tint
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]
assert abs(pixels[18:46, 2:30].mean() - 1.048) < 0.02, 'tinted furnace'
# Huge, black and turned 60 degrees under the white sky, the colored plane reflects FlexLight's specular albedo at that
# angle
colored.inputs['Base Color'].default_value = (0, 0, 0, 1)
colored.inputs['Specular Tint'].default_value, colored.inputs['Roughness'].default_value = (1, 1, 1, 1), 0.434
bpy.data.objects['colored'].location, bpy.data.objects['colored'].rotation_euler = (0, 0, 0), (math.radians(60), 0, 0)
bpy.data.objects['colored'].scale, scene.camera.data.angle = (100, 100, 1), math.radians(10)
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[:56, :, :3]
assert abs(pixels.mean() - 0.0735) < 0.004, 'grazing specular'
# Light sampling finds a dim emitter by the points it lights, a bright light behind them outshining it: at a sample
# every pixel is lit, where picking emitters by their power alone lights next to none
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (0, 0, 0, 1)
scene.camera.data.angle, scene.flex_samples = math.pi / 2, 1
plane('floor', 0, 0, 4)
dim = plane('dim', 0, 0, 1)
dim.inputs['Base Color'].default_value, dim.inputs['Emission Color'].default_value = (0, 0, 0, 1), (1, 1, 1, 1)
dim.inputs['Emission Strength'].default_value = 1
bpy.data.objects['dim'].location.z, bpy.data.objects['dim'].visible_camera = 0.5, False
add(bpy.data.lights.new('bright', 'POINT'), (0, 0, -1)).data.energy = 1e6
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[:56, :, :3]
assert pixels.sum(2).min() > 0, 'many lights'
# Through a slab of white glass of IOR 1 and depth 0.5 under the white sky, a Volume Absorption of the color and density 1
# passes its transmittance over unit distance, exp(color - 1), to the power of depth, as FlexLight's Beer's law
for ob in scene.objects: ob.hide_render = ob != scene.camera
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (1, 1, 1, 1)
scene.camera.data.angle, scene.flex_samples = 0.1, 16
mesh = bpy.data.meshes.new('slab')
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1)
bm.to_mesh(mesh)
mesh.materials.append(bpy.data.materials.new('slab'))
add(mesh, (0, 0, 0)).scale = (4, 4, 0.5)
glass = mesh.materials[0].node_tree.nodes['Principled BSDF']
glass.inputs['Transmission Weight'].default_value, glass.inputs['Roughness'].default_value = 1, 0
glass.inputs['Base Color'].default_value, glass.inputs['IOR'].default_value = (1, 1, 1, 1), 1
absorption = glass.id_data.nodes.new('ShaderNodeVolumeAbsorption')
absorption.inputs['Color'].default_value = (*COLOR, 1)
glass.id_data.links.new(absorption.outputs[0], glass.id_data.nodes['Material Output'].inputs['Volume'])
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[24:40, 24:40, :3]
assert numpy.allclose(pixels.mean((0, 1)), numpy.exp(numpy.array(COLOR) - 1) ** 0.5, rtol=0.02), 'absorption'
# Colored instead, the slab tints the light by its base color at each of its two sides, by the color squared
glass.id_data.links.remove(glass.id_data.nodes['Material Output'].inputs['Volume'].links[0])
glass.inputs['Base Color'].default_value = (*COLOR, 1)
bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[24:40, 24:40, :3]
assert numpy.allclose(pixels.mean((0, 1)), numpy.array(COLOR) ** 2, rtol=0.02), 'glass'
# Node regressions compared to Cycles through emission, independently of the engines' different BSDFs
for ob in scene.objects: ob.hide_render = ob != scene.camera
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
        bpy.ops.render.render(scene=scene.name, write_still=True)
        colors.append(numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[
            24:40, 24:40, :3].mean((0, 1)))
    assert numpy.allclose(*colors, atol=1e-4), (socket.node.name, colors)

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
image.image.alpha_mode = 'NONE'
node_matches(image.outputs['Alpha'])
image.image.alpha_mode = 'STRAIGHT'
tree.links.new(image.outputs['Alpha'], tree.nodes.new('ShaderNodeMath').inputs[0])  # An unused alpha link
node_matches(image.outputs['Color'])
tree.links.remove(image.outputs['Alpha'].links[0])
other = tree.nodes.new('ShaderNodeTexImage')
other.image, other.extension = image.image, image.extension
tree.links.new(other.outputs['Alpha'], emission.inputs['Strength'])
node_matches(image.outputs['Color'])
other.interpolation = 'Closest'
node_matches(image.outputs['Color'])
tree.links.remove(emission.inputs['Strength'].links[0])
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
