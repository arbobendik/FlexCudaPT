# End-to-end test, run by make test: renders a lit plane, half colored and half textured, and a textured emitter under a
# sky with Flex through a render border and checks the pixels, then draws the same view through the engine's viewport
# methods and compares.
import bpy, bmesh, gpu, math, numpy, types
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
cutout = plane('cutout', 0, 0, 4)  # Not rendered: linked alpha
cutout.id_data.links.new(cutout.id_data.nodes.new('ShaderNodeValue').outputs[0], cutout.inputs['Alpha'])
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
for node in (node for material in bpy.data.materials for node in material.node_tree.nodes if node.type == 'TEX_IMAGE'):
    node.interpolation = 'Closest'  # Whole texels

bpy.ops.render.render(scene=scene.name, write_still=True)
pixels = numpy.array(bpy.data.images.load(scene.render.filepath).pixels).reshape(SIZE, SIZE, 4)[..., :3]

def chroma(x, y, size, color):  # Whether the block of pixels has the color's hue
    mean = pixels[y + 2:y + size - 2, x + 2:x + size - 2].mean((0, 1))
    return numpy.allclose(mean / mean.sum(), numpy.array(color) / sum(color), atol=0.02)

assert numpy.allclose(pixels[:14, :20], SKY, atol=0.01) and numpy.allclose(pixels[50:56], SKY, atol=0.01), 'sky'
assert not pixels[56:].any(), 'border'
assert chroma(0, 16, 32, COLOR), 'color'
for texel, (x, y) in zip(TEXELS, ((32, 16), (48, 16), (32, 32), (48, 32))):
    assert chroma(x, y, 16, texel), f'texture {texel}'
for texel, (x, y) in zip(TEXELS, ((24, 0), (32, 0), (24, 8), (32, 8))):
    assert chroma(x, y, 8, texel), f'emission {texel}'
lit = pixels[18:46, 2:30].sum(2)  # Light sampling leaves no pixel of the colored plane dark or far off its neighbors
assert lit.min() > 0.5 * lit.mean() and lit.max() < 2 * lit.mean(), 'lighting'

class Viewport:  # Stands in for the engine instance Blender creates for a viewport, which background mode has none of
    engine = bpy.types.RenderEngine.bl_rna_get_subclass_py('FLEX')
    start = engine.start
    trace = engine.trace
    view_update = engine.view_update
    view_draw = engine.view_draw
    visible = ()
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
    while viewport.__dict__.pop('redraw', False): viewport.view_draw(context, depsgraph)  # Until the sample limit
    drawn = numpy.array(gpu.state.active_framebuffer_get().read_color(0, 0, SIZE, SIZE, 4, 0, 'FLOAT').to_list())
assert numpy.allclose(drawn[:56, :, :3], pixels[:56], rtol=0.05, atol=0.01), 'viewport'
