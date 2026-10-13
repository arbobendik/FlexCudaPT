# Blender render engine: exports the scene as world-space triangles and path traces it with the bundled OptiX binary.
import addon_utils, bpy, bmesh, fcntl, gpu, math, numpy, os, struct, subprocess
from gpu_extras.presets import draw_texture_2d
from mathutils import Matrix

SUN_DISTANCE = 1e5
VIEWPORT_SAMPLES = 4  # Per redraw
RENDER_SAMPLES = 64  # At most, per update of a final render
BINARY = os.path.join(os.path.dirname(__file__), 'renderer')
MODIFIED = os.path.getmtime(__file__)
# Steps of a program in the shader's order, operations named as Blender's with their functions; a surface's end sums its
# emission
OPS = {'END': lambda *surface: numpy.sum(numpy.resize(surface[4], 3)), **dict.fromkeys(('PUSH', 'UV', 'NORMAL', 'IMAGE',
    'ALPHA')), 'ADD': numpy.add, 'SUBTRACT': numpy.subtract, 'MULTIPLY': numpy.multiply, 'DOT_PRODUCT': numpy.dot}
# Surface: expressions of its normal, albedo, metallic, roughness, emissive, transparency and ior
GRAY = [('NORMAL',), 0.8, 0, 0.5, 0, 0, 1.5]
BLACK = [('NORMAL',), 0, 0, 1, 0, 0, 1.5]
LUMINANCE = numpy.array((0.2126, 0.7152, 0.0722))

def encode(linear):  # Linear to sRGB
    return numpy.where(linear <= 0.0031308, linear * 12.92, 1.055 * linear.clip(0, 1) ** (1 / 2.4) - 0.055)

# First texel, width and height of an image or of a ramp node's 256 colors, added to the texels as sRGB at first use
def texture(source, textures, texels):
    if source not in textures:
        ramp = source.type == 'VALTORGB'
        pixels = numpy.empty(1024 if ramp else len(source.pixels), 'f')
        if ramp: pixels[:] = numpy.ravel([source.color_ramp.evaluate(i / 255) for i in range(256)])
        else: source.pixels.foreach_get(pixels)
        if ramp or source.is_float or source.colorspace_settings.is_data: pixels = encode(pixels)
        else: pixels[3::4] = encode(pixels[3::4])  # Alpha as well
        textures[source] = sum(map(len, texels)) // 4, *((256, 1) if ramp else source.size)
        texels.append((pixels * 255 + 0.5).clip(0, 255).astype('B'))
    return textures[source]

# Appends the steps of an expression to ops, operands first, a surface's seven before an end; returns its value under
# white textures
def emit(expression, ops, textures, texels):
    if isinstance(expression, list): expression = 'END', *expression
    if not isinstance(expression, tuple):
        ops.append((1, *numpy.resize(expression, 3).astype('f').view('I')))
        return expression
    name, *operands = expression
    payload = texture(operands.pop(), textures, texels) if name in ('IMAGE', 'ALPHA') else (0, 0, 0)
    values = [emit(operand, ops, textures, texels) for operand in operands]
    ops.append(([*OPS].index(name), *payload))
    return OPS[name](*values) if OPS[name] else numpy.ones(3)

# Expression of the socket's color: its constant, or the image linked to it read at the UV, directly or through a color
# ramp at its luminance
def tint(socket):
    nodes = [link.from_node for link in socket.links]
    ramps = [node for node in nodes if node.type == 'VALTORGB']
    feeds = [link.from_node for ramp in ramps for link in ramp.inputs['Fac'].links] or nodes
    for image in [node.image for node in feeds if hasattr(node, 'image') and node.image and node.image.size[0]]:
        color = 'IMAGE', ('UV',), image
        for ramp in ramps:
            color = 'IMAGE', ('ADD', ('MULTIPLY', ('DOT_PRODUCT', color, LUMINANCE), 255 / 256), 0.5 / 256), ramp
        return color
    return numpy.resize(socket.default_value, 3)

# The material's surface as rows, one or none: the row of its Principled BSDF's base color and emission, gray without
# one; none for volumes without a surface shader and for textured alpha
def shade(material, program):
    output = material.node_tree.get_output_node('ALL')
    shaders = [node for node in material.node_tree.nodes if node.type == 'BSDF_PRINCIPLED'][:1]
    if not (output and output.inputs['Surface'].is_linked) or any(node.inputs['Alpha'].is_linked for node in shaders):
        return []
    for node in shaders:
        emissive = 'MULTIPLY', tint(node.inputs['Emission Color']), node.inputs['Emission Strength'].default_value
        return [program([('NORMAL',), tint(node.inputs['Base Color']), 0, 0.5, emissive, 0, 1.5])]
    return [program(GRAY)]

def disk(bm, sides, x, y, z):  # Polygon at height z around the ellipse with diameters x, y
    bmesh.ops.create_circle(bm, cap_ends=True, segments=sides, radius=0.5 / math.cos(math.pi / sides),
        matrix=Matrix.Translation((0, 0, z)) @ Matrix.Diagonal((x, y, 1, 1)) @ Matrix.Rotation(math.pi / sides, 4, 'Z'))

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.visible = ()  # Names of the instances the renderer was last started on
        self.texture = None  # The viewport's view as last traced

    def start(self, depsgraph):  # Starts the renderer on the exported scene
        scene = depsgraph.scene_eval
        vertices = []
        uvs = []
        materials = []
        ops = []  # Steps of all programs
        textures = {}  # First texel, width, height per image and ramp
        texels = [numpy.full(4, 255, 'B')]  # sRGB bytes after a white texel: the renderer loads no empty array
        program = lambda surface: [len(ops), emit(surface, ops, textures, texels)][::-1]
        rows = {None: [program(GRAY)]}  # Rows of the surface each material renders; an empty slot renders gray
        for instance in depsgraph.object_instances:
            ob = instance.object
            bm = bmesh.new()
            if ob.hide_render: continue
            if ob.type in {'MESH', 'CURVE', 'SURFACE', 'FONT', 'META'}:
                bm.from_mesh(ob.to_mesh())
                ob.to_mesh_clear()
                for slot in ob.material_slots:
                    if slot.material not in rows: rows[slot.material] = shade(slot.material, program)
                shades = [rows[slot.material] for slot in ob.material_slots] or [rows[None]]
            # Emitter faces use material 0, black faces shaping the light material 1; lights shine down -z.
            if ob.type == 'LIGHT':
                light = ob.data
                radius = max(light.shadow_soft_size, 0.01)
                # Cone tangent to the emitter, rim 6 radii wide on the spot cone: soft edge centered on spot_size
                if light.type == 'SPOT':
                    angle = min(light.spot_size / 2, 1.5)
                    apex = radius / math.sin(angle - math.asin(math.sin(angle) / 6))
                    depth = apex + 6 * radius / math.tan(angle)
                    bmesh.ops.create_cone(bm, segments=32, radius1=6 * radius / math.cos(math.pi / 32), radius2=0,
                        depth=depth, matrix=Matrix.Translation((0, 0, apex - depth / 2)))
                if light.type == 'AREA':  # Back side
                    sides = 4 if light.shape in {'SQUARE', 'RECTANGLE'} else 32
                    size = light.size, light.size_y if light.shape in {'RECTANGLE', 'ELLIPSE'} else light.size
                    disk(bm, sides, *size, 1e-3)
                for face in bm.faces: face.material_index = 1
                if light.type == 'AREA': disk(bm, sides, *size, 0)
                elif light.type == 'SUN':
                    disk(bm, 32, *2 * [2 * SUN_DISTANCE * math.tan(light.angle / 2)], SUN_DISTANCE)
                else: bmesh.ops.create_icosphere(bm, subdivisions=3, radius=radius)
            bmesh.ops.triangulate(bm, faces=bm.faces[:])
            bm.transform(instance.matrix_world)
            if ob.type == 'LIGHT':
                area = sum(face.calc_area() for face in bm.faces if not face.material_index)
                # Sun irradiance, else watts
                radiance = light.energy * (SUN_DISTANCE ** 2 if light.type == 'SUN' else 1 / math.pi) / area
                # Black reflects nothing
                shades = [[program([*BLACK[:4], radiance * numpy.array(light.color), *BLACK[5:]])], [program(BLACK)]]
            uv = bm.loops.layers.uv.verify()
            for face in bm.faces:
                for row in shades[face.material_index]:  # No row for a surface that is not rendered
                    vertices.extend(c for vertex in face.verts for c in vertex.co)
                    uvs.extend(c for loop in face.loops for c in loop[uv].uv)
                    materials.extend((*row, not ob.visible_camera))
        world = BLACK
        for node in scene.world.node_tree.nodes if scene.world else ():
            if node.type == 'BACKGROUND':
                emissive = 'MULTIPLY', tint(node.inputs['Color']), node.inputs['Strength'].default_value
                world = [*BLACK[:4], emissive, *BLACK[5:]]
        materials.extend((*program(world), 0))
        triangles = numpy.array(vertices, 'f').reshape(-1, 3, 3)
        materials = numpy.array(materials).reshape(-1, 3)
        texels = numpy.concatenate(texels)
        # Cumulative doubled area times summed emission per triangle: the binary picks light samples by it. In doubles,
        # tiny emitters after bright ones keep intervals of their power.
        normals = numpy.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0])
        power = numpy.cumsum(numpy.linalg.norm(normals, axis=1) * materials[:-1, 0])
        # Scene on stdin: triangle, step and texel counts; per triangle 9 vertex floats, 6 UV floats, a material of its
        # emission, program and hidden flag (then the world's), the power; then the steps of 4 integers and the texels.
        # The engine keeps only the renderer's pipes, taken off the Popen, which Python keeps alive while its process
        # runs: once the engine drops them, the renderer reads the end of its input and exits.
        process = subprocess.Popen(BINARY, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        self.requests = process.stdin
        self.answers = process.stdout
        process.stdin = process.stdout = None
        # Frames arrive slowly and unevenly through the default 64 KiB
        fcntl.fcntl(self.answers, fcntl.F_SETPIPE_SZ, 1 << 20)
        self.requests.write(b''.join((struct.pack('<III', len(power), len(ops), len(texels) // 4), triangles.tobytes(),
            numpy.array(uvs, 'f').tobytes(),
            numpy.hstack((materials[:, :1].astype('f').view('I'), materials[:, 1:].astype('I'))).tobytes(),
            power.astype('d').tobytes(), numpy.array(ops, 'I').tobytes(), texels.tobytes())))

    # Radiance sums and sample count per pixel, rows bottom to top, after up to launches more samples, samples at most,
    # of the view from the camera's matrix through its perspective projection; no rows if the view already had its
    # samples. A view other than the last starts over.
    def trace(self, width, height, samples, launches, matrix, projection):
        right = matrix.col[0].xyz
        up = matrix.col[1].xyz
        back = matrix.col[2].xyz
        x = right / projection[0][0]
        y = up / projection[1][1]
        center = x * projection[0][2] + y * projection[1][2] - back
        # Request on stdin: samples, launches, size, the camera's origin and its ray direction per NDC x, per NDC y and
        # at the center.
        self.requests.write(struct.pack('<4I12f', samples, launches, width, height, *matrix.translation,
            *x, *y, *center))
        self.requests.flush()
        launched, = struct.unpack('I', self.answers.read(4))  # Answer: samples launched, then the sums if any were
        sums = self.answers.read(16 * width * height * bool(launched))
        return numpy.frombuffer(sums, 'f').reshape(-1, width, 4)[::-1]

    # Shows the result after ever larger batches of samples, until it has them all or the render is cancelled
    def render(self, depsgraph):
        scene = depsgraph.scene_eval
        width = self.resolution_x
        height = self.resolution_y
        self.start(depsgraph)
        camera = (scene.camera.matrix_world.normalized(),
            scene.camera.calc_matrix_camera(depsgraph, x=scene.render.resolution_x, y=scene.render.resolution_y))
        result = self.begin_result(0, 0, width, height)  # Blender clips the result to the render border
        border = depsgraph.scene.render
        x = int(border.use_border * border.border_min_x * width)
        y = int(border.use_border * border.border_min_y * height)
        count = 1
        while (len(sums := self.trace(width, height, scene.flex_samples, min(count, RENDER_SAMPLES), *camera))
                and not self.test_break()):
            count = int(sums[0, 0, 3])
            pixels = sums[y:y + result.resolution_y, x:x + result.resolution_x] * (1 / count)
            result.layers[0].passes['Combined'].rect.foreach_set(pixels.ravel())
            self.update_result(result)
            self.update_progress(count / scene.flex_samples)
        self.end_result(result)

    # Restarts the renderer when what it renders changed. Blender also reports selection, scene settings and cameras
    # here, which need none.
    def view_update(self, context, depsgraph):
        visible = [instance.object.name for instance in depsgraph.object_instances]
        if visible != self.visible or any(not isinstance(update.id, (bpy.types.Scene, bpy.types.Camera))
                and getattr(update.id, 'type', '') != 'CAMERA' for update in depsgraph.updates):
            self.visible = visible
            self.start(depsgraph)

    def view_draw(self, context, depsgraph):  # Draws the viewport's view, after a few more samples while it lacks any
        region = context.region
        scene = depsgraph.scene
        sums = self.trace(region.width, region.height, scene.flex_samples, VIEWPORT_SAMPLES,
            context.region_data.view_matrix.inverted(), context.region_data.window_matrix)
        if len(sums):
            pixels = (sums * (1 / sums[0, 0, 3])).ravel()
            self.texture = gpu.types.GPUTexture((region.width, region.height), format='RGBA32F',
                data=gpu.types.Buffer('FLOAT', len(pixels), pixels))
            self.tag_redraw()
        gpu.state.blend_set('ALPHA_PREMULT')
        self.bind_display_space_shader(scene)
        draw_texture_2d(self.texture, (0, 0), region.width, region.height)
        self.unbind_display_space_shader()
        gpu.state.blend_set('NONE')

class RENDER_PT_flex(bpy.types.Panel):  # Render properties of the Flex engine
    bl_label = 'Flex'
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = 'render'

    @classmethod
    def poll(cls, context): return context.engine == Flex.bl_idname

    def draw(self, context):
        self.layout.use_property_split = True
        self.layout.prop(context.scene, 'flex_samples')
        for name in ('resolution_x', 'resolution_y', 'resolution_percentage'):
            self.layout.prop(context.scene.render, name)

# Timer: once make install has replaced this build, has Blender unregister, reload and register the extension
def reload():
    if os.path.exists(__file__) and os.path.getmtime(__file__) != MODIFIED:
        bpy.app.timers.register(lambda: addon_utils.enable(__package__) and None)
    return 1

def register():
    os.chmod(BINARY, 0o755)  # Extension installs drop the executable bit
    bpy.app.timers.register(reload, persistent=True)
    bpy.types.Scene.flex_samples = bpy.props.IntProperty(name='Max Samples', description='Paths traced per pixel',
        default=1024, min=1)
    bpy.utils.register_class(Flex)
    bpy.utils.register_class(RENDER_PT_flex)

def unregister():
    bpy.app.timers.unregister(reload)
    bpy.utils.unregister_class(RENDER_PT_flex)
    bpy.utils.unregister_class(Flex)
    del bpy.types.Scene.flex_samples
