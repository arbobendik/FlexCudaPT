# Blender render engine: exports the scene as world-space triangles and path traces it with the bundled OptiX binary.
import addon_utils, bpy, bmesh, fcntl, gpu, math, numpy, os, struct, subprocess, time
from gpu_extras.presets import draw_texture_2d
from mathutils import Matrix

SUN_DISTANCE = 1e5
VIEWPORT_SAMPLES = 4  # Per redraw
RENDER_SAMPLES = 64  # At most, per update of a final render
SLOTS = 32  # Values a program keeps for reuse, as the shader's
BINARY = os.path.join(os.path.dirname(__file__), 'renderer')
MODIFIED = os.path.getmtime(__file__)
def logarithm(a, b):  # Of a to the base b, zero where undefined as Blender's
    with numpy.errstate(all='ignore'):
        return numpy.where((a > 0) & (b > 0) & (b != 1), numpy.log(a) / numpy.log(b), 0)

def divide(a, b):
    return numpy.divide(a, b, out=numpy.zeros(3), where=b != 0)

# Steps of a program in the shader's order, operations named as Blender's with their functions; a surface's end sums its
# emission
OPS = {'END': lambda *surface: numpy.sum(numpy.resize(surface[4], 3)), **dict.fromkeys(('PUSH', 'UV', 'NORMAL', 'IMAGE',
    'ALPHA', 'NORMAL_MAP')), 'ADD': numpy.add, 'SUBTRACT': numpy.subtract, 'MULTIPLY': numpy.multiply,
    'DOT_PRODUCT': numpy.dot, 'MAXIMUM': numpy.maximum, 'LOGARITHM': logarithm,
    'MULTIPLY_ADD': lambda a, b, c: a * b + c, **dict.fromkeys(('IMAGE_LINEAR', 'ALPHA_LINEAR')),
    'DIVIDE': divide, 'SNAP': lambda a, b: numpy.floor(divide(a, b)) * b, **dict.fromkeys(('STORE', 'LOAD'))}
# Surface: expressions of its normal, albedo, metallic, roughness, emissive, transparency, ior, specular tint, specular
# level, coverage, absorption and density
GRAY = [('NORMAL',), 0.8, 0, 0.5, 0, 0, 1, 1, 1, 1, 1, 0]
BLACK = [('NORMAL',), 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0]
# Albedo, metallic, roughness, emissive, its strength, transparency and ior per shader node, each the name of an input
# or a constant; an ior of 1 reflects nothing specularly, as Cycles' diffuse shaders. Cycles ignores EEVEE's specular
# shader and volume shaders on surfaces, and passes rays through a portal without a position or direction; any other
# shader is diffuse.
SHADERS = {'BSDF_PRINCIPLED': ('Base Color', 'Metallic', 'Roughness', 'Emission Color', 'Emission Strength',
        'Transmission Weight', 'IOR'), 'BSDF_METALLIC': ('Base Color', 1, 'Roughness', 0, 0, 0, 1.5),
    **dict.fromkeys(('EEVEE_SPECULAR', 'PRINCIPLED_VOLUME', 'VOLUME_ABSORPTION', 'VOLUME_SCATTER',
        'VOLUME_COEFFICIENTS'), (0, 0, 1, 0, 0, 0, 1)), 'BSDF_RAY_PORTAL': ('Color', 0, 0, 0, 0, 1, 1),
    'BSDF_GLOSSY': ('Color', 1, 'Roughness', 0, 0, 0, 1.5), 'BSDF_GLASS': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'),
    'BSDF_REFRACTION': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'), 'BSDF_TRANSPARENT': ('Color', 0, 0, 0, 0, 1, 1),
    'EMISSION': (0, 0, 1, 'Color', 'Strength', 0, 1), 'BACKGROUND': (0, 0, 1, 'Color', 'Strength', 0, 1)}
# Absorption color and density per volume shader node; any other absorbs nothing
VOLUMES = {'VOLUME_ABSORPTION': ('Color', 'Density'), 'PRINCIPLED_VOLUME': ('Absorption Color', 'Density')}
# Luminance of a color and mean of a vector, as Blender converts them to values
WEIGHTS = {'RGBA': numpy.array((0.2126, 0.7152, 0.0722)), 'VECTOR': numpy.full(3, 1 / 3)}
# Blender's material panels the engine shows: the slots, the surface's nodes and the generic ones
PANELS = ('EEVEE_MATERIAL_PT_context_material', 'EEVEE_MATERIAL_PT_surface', 'MATERIAL_PT_custom_props',
    'MATERIAL_PT_animation')

def decode(srgb):  # sRGB to linear
    return numpy.where(srgb <= 0.04045, srgb / 12.92, ((srgb + 0.055) / 1.055) ** 2.4)

# First texel, width, height and mean of an image or of a ramp node's 256 colors, added as linear floats at first use
def texture(source, textures, texels):
    if source not in textures:
        ramp = source.type == 'VALTORGB'
        pixels = numpy.empty(1024 if ramp else len(source.pixels), 'f')
        if ramp: pixels[:] = numpy.ravel([source.color_ramp.evaluate(i / 255) for i in range(256)])
        else: source.pixels.foreach_get(pixels)
        if not (ramp or source.is_float or source.colorspace_settings.is_data):
            pixels.reshape(-1, 4)[:, :3] = decode(pixels.reshape(-1, 4)[:, :3])
        textures[source] = (sum(map(len, texels)) // 4, *((256, 1) if ramp else source.size),
            pixels.reshape(-1, 4).mean(0))
        texels.append(pixels)
    return textures[source]

def expression_key(expression):
    if isinstance(expression, tuple): return tuple(map(expression_key, expression))
    if isinstance(expression, (int, float, numpy.number, numpy.ndarray)):
        return tuple(numpy.resize(expression, 3).astype('f'))
    return expression

# Appends the steps of an expression to ops, operands first, a surface's seven before an end; returns its value under
# textures of their mean. Without slots it counts in uses each expression met, entering none twice; with them those met
# again are kept in a slot and loaded.
def emit(expression, ops, textures, texels, uses, slots=None):
    if isinstance(expression, list): expression = 'END', *expression
    if not isinstance(expression, tuple):
        ops.append((1, *numpy.resize(expression, 3).astype('f').view('I')))
        return expression
    name, *operands = expression
    key = expression_key(expression)
    if key in (uses if slots is None else slots):
        if slots is None: uses[key][0] += 1
        else: ops.append(([*OPS].index('LOAD'), slots[key], 0, 0))
        return uses[key][1]
    payload = texture(operands.pop(), textures, texels) if name in ('IMAGE', 'ALPHA', 'IMAGE_LINEAR',
        'ALPHA_LINEAR') else (0, 0, 0, numpy.ones(4))
    values = [emit(operand, ops, textures, texels, uses, slots) for operand in operands]
    ops.append(([*OPS].index(name), *payload[:3]))
    value = OPS[name](*values) if OPS[name] else numpy.resize(payload[3][3:] if 'ALPHA' in name else payload[3][:3], 3)
    if slots is None: uses[key] = [1, value]
    elif uses[key][0] > 1:
        slots[key] = len(slots)
        ops.append(([*OPS].index('STORE'), slots[key], 0, 0))
    return value

def fold(expression):  # The expression with its operations on constants alone computed, as the shader would
    if isinstance(expression, list): return [fold(attribute) for attribute in expression]
    if not isinstance(expression, tuple): return expression
    name, *operands = (fold(part) if isinstance(part, tuple) else part for part in expression)
    if OPS[name] and not any(isinstance(operand, tuple) for operand in operands):
        return OPS[name](*(numpy.resize(operand, 3) for operand in operands))
    return name, *operands

def mix(a, b, factor):  # Expression of a fading into b, surfaces attribute by attribute
    if isinstance(a, list): return [mix(x, y, factor) for x, y in zip(a, b)]
    return 'ADD', ('MULTIPLY', a, ('SUBTRACT', 1, factor)), ('MULTIPLY', b, factor)

def clamp(value):
    return 'SUBTRACT', 1, ('MAXIMUM', 0, ('SUBTRACT', 1, ('MAXIMUM', 0, value)))

# The nodes resolved exactly: the expression of an output by its index, given those of the node's enabled inputs. An
# image is read at the UV without a vector and is pink when missing; mixes blend plainly unless by an operation; a
# mapping of points scales and moves them without rotating, one of textures undoes that. A normal map bends the normal
# by its strength toward the color's normal in tangent space and keeps it in any other space. Added shaders sum their
# iors' excess over 1, as Cycles sums their reflections.
NODES = {'NORMAL_MAP': lambda node, inputs, index: mix(('NORMAL',), ('NORMAL_MAP', inputs[1]), inputs[0])
        if node.space == 'TANGENT' else ('NORMAL',), 'REROUTE': lambda node, inputs, index: inputs[0],
    'TEX_IMAGE': lambda node, inputs, index: (('ALPHA' if index else 'IMAGE')
        + ('_LINEAR' if node.interpolation == 'Linear' else ''), inputs[0] if node.inputs[0].is_linked
        else ('UV',), node.image) if node.image and node.image.size[0] else numpy.array((1, 0, 1)),
    'VALTORGB': lambda node, inputs, index: (('ALPHA' if index else 'IMAGE')
        + ('_LINEAR' if node.color_ramp.interpolation != 'CONSTANT' else ''),
        ('ADD', ('MULTIPLY', clamp(inputs[0]), 255 / 256), 0.5 / 256), node),
    'MIX': lambda node, inputs, index: mix(inputs[1], (node.blend_type, *inputs[1:])
        if OPS.get(getattr(node, 'blend_type', 0)) else inputs[2], inputs[0]),
    'ADD_SHADER': lambda node, inputs, index: [mix(a, b, 0.5) if attribute in (2, 3, 7, 8, 10)
        else ('SUBTRACT', ('ADD', a, b), 1) if attribute in (6, 9) else ('ADD', a, b)
        for attribute, (a, b) in enumerate(zip(*inputs))],
    'MATH': lambda node, inputs, index: (node.operation, *inputs) if OPS.get(node.operation) else inputs[0],
    'SEPXYZ': lambda node, inputs, index: ('DOT_PRODUCT', inputs[0], numpy.eye(3)[index]),
    'COMBXYZ': lambda node, inputs, index: ('ADD', ('ADD', ('MULTIPLY', inputs[0], numpy.eye(3)[0]),
        ('MULTIPLY', inputs[1], numpy.eye(3)[1])), ('MULTIPLY', inputs[2], numpy.eye(3)[2])),
    'MAPPING': lambda node, inputs, index: ('ADD', ('MULTIPLY', inputs[0], inputs[3]), inputs[1])
        if node.vector_type == 'POINT' else ('DIVIDE', ('SUBTRACT', inputs[0], inputs[1]), inputs[3])
        if node.vector_type == 'TEXTURE' else inputs[0]}
NODES |= {'TEX_ENVIRONMENT': NODES['TEX_IMAGE'], 'MIX_SHADER': NODES['MIX'], 'MIX_RGB': NODES['MIX'],
    'VECT_MATH': NODES['MATH']}

# Expression of what a socket receives, a surface for a shader: a constant, or a step followed by its operands. groups
# are the group nodes entered on the way; a node that is muted or not resolved exactly passes its input on.
def resolve(socket, groups=()):
    link = next((link for link in socket.links  # Invalid links close a cycle
        if link.is_valid and not (socket.is_output or link.is_muted)), None)
    if not link and socket.type == 'SHADER': return BLACK
    if not link:  # A virtual socket has no value
        value = numpy.resize(getattr(socket, 'default_value', 0), 3)
        return {'Normal': ('NORMAL',), 'UV': ('UV',)}.get(socket.name, value)
    node, output = link.from_node, link.from_socket
    index = [*node.outputs].index(output)
    get = lambda name, default=0: resolve(node.inputs[name], groups) if name in node.inputs else default
    if node.type == 'GROUP_INPUT': value = resolve(groups[-1].inputs[index], groups[:-1])
    elif node.mute or not (node.type in NODES or node.type == 'GROUP' or output.type == 'SHADER'):
        value = ([resolve(passed.from_socket, groups) for passed in node.internal_links if passed.to_socket == output]
            or [resolve(output)])[0]
    elif node.type == 'GROUP':
        inner = next(inner for inner in node.node_tree.nodes if inner.type == 'GROUP_OUTPUT' and inner.is_active_output)
        value = resolve(inner.inputs[index], (*groups, node))
    elif node.type in NODES:
        inputs = [resolve(input, groups) for input in node.inputs if input.enabled]
        if node.type == 'MIX_RGB' or node.type == 'MIX' and node.clamp_factor: inputs[0] = clamp(inputs[0])
        value = NODES[node.type](node, inputs, index)
        if node.type in ('MATH', 'MIX_RGB') and node.use_clamp or node.type == 'MIX' and node.clamp_result:
            value = clamp(value)
    else:  # Alpha covers a share of the shader, emitting by it; the rest passes rays straight through, as in Cycles
        albedo, metallic, roughness, emissive, strength, transparency, ior, absorption, density = (get(source)
            if isinstance(source, str) else source for source in SHADERS.get(node.type, ('Color', 0, 1, 0, 0, 0, 1))
            + VOLUMES.get(node.type, (1, 0)))
        # The specular level scales the reflectance at normal incidence of the share not transmitted, as Cycles'
        level = mix(('MULTIPLY', get('Specular IOR Level', 0.5), 2), 1, transparency)
        value = [get('Normal', ('NORMAL',)), albedo, metallic, roughness,
            ('MULTIPLY', ('MULTIPLY', emissive, strength), get('Alpha', 1)), transparency, ior,
            get('Specular Tint', 1), level, get('Alpha', 1), absorption, density]
    if socket.type == 'VALUE' and output.type in WEIGHTS: return 'DOT_PRODUCT', value, WEIGHTS[output.type]
    if socket.type == 'SHADER' and not isinstance(value, list): value = [*BLACK[:4], value, *BLACK[5:]]  # Emits it
    return value

# The material's surface as rows, one or none: the row of its surface, absorbing as its volume, black without an output;
# none for volumes without a surface shader
def shade(material, program):
    output = material.node_tree.get_output_node('CYCLES')
    if not output: return [program(BLACK)]
    if output.inputs['Volume'].is_linked and not output.inputs['Surface'].is_linked:
        return []
    return [program([*resolve(output.inputs['Surface'])[:10], *resolve(output.inputs['Volume'])[10:]])]

def disk(bm, sides, x, y, z):  # Polygon at height z around the ellipse with diameters x, y
    bmesh.ops.create_circle(bm, cap_ends=True, segments=sides, radius=0.5 / math.cos(math.pi / sides),
        matrix=Matrix.Translation((0, 0, z)) @ Matrix.Diagonal((x, y, 1, 1)) @ Matrix.Rotation(math.pi / sides, 4, 'Z'))

def settings(scene):  # The scene's settings of the renderer, in its order
    return scene.flex_restir, scene.flex_decorrelation, scene.flex_neighbors, scene.flex_bounces, scene.flex_paths

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.visible = ()  # Names of the instances the renderer was last started on
        self.texture = None  # The viewport's view as last traced
        self.memory = (0, 0)  # Renderer allocations: used and peak in MiB

    def start(self, depsgraph):  # Starts the renderer on the exported scene
        scene = depsgraph.scene_eval
        vertices = [numpy.empty((0, 3, 3), 'f')]  # Per object, after none for a scene without triangles
        corners = [numpy.empty((0, 3, 3), 'f')]  # Normals
        uvs = [numpy.empty((0, 3, 2), 'f')]
        materials = []
        ops = []  # Steps of all programs
        textures = {}  # First texel, width, height and mean per image and ramp
        texels = [numpy.ones(4, 'f')]  # Linear floats after a white texel: the renderer loads no empty array
        def program(surface):  # Counted, then emitted keeping what it uses again
            surface, first, uses, slots = fold(surface), len(ops), {}, {}
            emit(surface, [], textures, texels, uses)
            emitted = emit(surface, ops, textures, texels, uses, slots)
            assert len(slots) <= SLOTS, 'values a program keeps for reuse'
            return emitted, first
        rows = {None: [program(GRAY)]}  # Rows of the surface each material renders; an empty slot renders gray
        for instance in depsgraph.object_instances:
            ob = instance.object
            bm = bmesh.new()
            if ob.hide_render or ob.type not in {'MESH', 'CURVE', 'SURFACE', 'FONT', 'META', 'LIGHT'}: continue
            if ob.type != 'LIGHT':  # Per corner of its triangles: index, vertex, normal (smooth, sharp or custom), UV
                mesh = ob.to_mesh()
                loops, index = (numpy.empty(n * len(mesh.loop_triangles), 'i') for n in (3, 1))
                co, vertex = numpy.empty(3 * len(mesh.vertices), 'f'), numpy.empty(len(mesh.loops), 'i')
                normal, uv = numpy.empty(3 * len(mesh.loops), 'f'), numpy.zeros(2 * len(mesh.loops), 'f')
                mesh.loop_triangles.foreach_get('loops', loops)
                mesh.loop_triangles.foreach_get('material_index', index)
                mesh.vertices.foreach_get('co', co)
                mesh.loops.foreach_get('vertex_index', vertex)
                mesh.corner_normals.foreach_get('vector', normal)
                if mesh.uv_layers.active: mesh.uv_layers.active.uv.foreach_get('vector', uv)
                ob.to_mesh_clear()
                matrix = numpy.array(instance.matrix_world)
                positions = (co.reshape(-1, 3) @ matrix[:3, :3].T + matrix[:3, 3])[vertex[loops]].reshape(-1, 3, 3)
                normals = normal.reshape(-1, 3)[loops] @ numpy.array(instance.matrix_world.to_3x3().adjugated())
                uv = uv.reshape(-1, 2)[loops].reshape(-1, 3, 2)
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
            bm.normal_update()  # Of the faces of lights, which have no corner normals
            if ob.type == 'LIGHT':
                area = sum(face.calc_area() for face in bm.faces if not face.material_index)
                # Sun irradiance, else watts
                radiance = light.energy * (SUN_DISTANCE ** 2 if light.type == 'SUN' else 1 / math.pi) / area
                # Black reflects nothing
                shades = [[program([*BLACK[:4], radiance * numpy.array(light.color), *BLACK[5:]])], [program(BLACK)]]
                positions = numpy.array([[vertex.co for vertex in face.verts] for face in bm.faces], 'f')
                normals = numpy.array([[face.normal] * 3 for face in bm.faces], 'f')
                uv = numpy.zeros((len(bm.faces), 3, 2), 'f')
                index = numpy.array([face.material_index for face in bm.faces], 'i')
            # Triangles of the surfaces rendered, normals turned as the faces turn, a material of its row each
            rendered = numpy.array([bool(row) for row in shades])[index]
            vertices.append(positions[rendered])
            corners.append(normals.reshape(-1, 3, 3)[rendered])
            uvs.append(uv[rendered])
            table = numpy.array([(*(row or [(0, 0)])[0], not ob.visible_camera) for row in shades])
            materials.append(table[index[rendered]])
        world = scene.world and scene.world.node_tree.get_output_node('CYCLES')
        materials.append([(*program(resolve(world.inputs['Surface']) if world else BLACK), 0)])
        triangles = numpy.concatenate(vertices, dtype='f')
        materials = numpy.concatenate(materials)
        # Cumulative doubled area times summed emission per triangle: the binary picks light samples by it. In doubles,
        # tiny emitters after bright ones keep intervals of their power.
        normals = numpy.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0])
        power = numpy.cumsum(numpy.linalg.norm(normals, axis=1) * materials[:-1, 0])
        # Scene on stdin: triangle, step and texel counts; per triangle 9 vertex, 9 normal and 6 UV floats, a material
        # of its emission, program and hidden flag (then the world's), the power; then the steps of 4 integers and the
        # texels.
        # The engine keeps only the renderer's pipes, taken off the Popen, which Python keeps alive while its process
        # runs: once the engine drops them, the renderer reads the end of its input and exits.
        process = subprocess.Popen(BINARY, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        self.requests = process.stdin
        self.answers = process.stdout
        process.stdin = process.stdout = None
        # Frames arrive slowly and unevenly through the default 64 KiB
        fcntl.fcntl(self.answers, fcntl.F_SETPIPE_SZ, 1 << 20)
        self.requests.writelines((struct.pack('<III', len(power), len(ops), sum(map(len, texels)) // 4), triangles,
            numpy.concatenate(corners, dtype='f'), numpy.concatenate(uvs, dtype='f'),
            numpy.hstack((materials[:, :1].astype('f').view('I'), materials[:, 1:].astype('I'))),
            power.astype('d'), numpy.array(ops, 'I'), *texels))

    # Radiance sums and sample count per pixel, rows bottom to top, after up to launches more samples, samples at most,
    # of the view from the camera's matrix through its perspective projection under the settings; no rows if the view
    # already had its samples. A view other than the last starts over.
    def trace(self, width, height, samples, launches, settings, matrix, projection):
        right = matrix.col[0].xyz
        up = matrix.col[1].xyz
        back = matrix.col[2].xyz
        x = right / projection[0][0]
        y = up / projection[1][1]
        center = x * projection[0][2] + y * projection[1][2] - back
        # Request on stdin: samples, launches, size, settings, the camera's origin and its ray direction per NDC x, per
        # NDC y and at the center.
        self.requests.write(struct.pack(f'<{4 + len(settings)}I12f', samples, launches, width, height, *settings,
            *matrix.translation, *x, *y, *center))
        self.requests.flush()
        launched, *self.memory = struct.unpack('<I2f', self.answers.read(12))  # Launches, memory, then sums if any
        sums = self.answers.read(16 * width * height * bool(launched))
        return numpy.frombuffer(sums, 'f').reshape(-1, width, 4)[::-1]

    # Shows the result after ever larger batches of samples, until it has them all or the render is cancelled
    def render(self, depsgraph):
        scene = depsgraph.scene_eval
        width = self.resolution_x
        height = self.resolution_y
        self.update_progress(0)
        self.update_stats('', f'{scene.name} | Syncing scene')
        self.start(depsgraph)
        camera = (scene.camera.matrix_world.normalized(),
            scene.camera.calc_matrix_camera(depsgraph, x=scene.render.resolution_x, y=scene.render.resolution_y))
        result = self.begin_result(0, 0, width, height)  # Blender clips the result to the render border
        border = depsgraph.scene.render
        x = int(border.use_border * border.border_min_x * width)
        y = int(border.use_border * border.border_min_y * height)
        started = time.perf_counter()
        count = 1
        while (len(sums := self.trace(width, height, scene.flex_samples, min(count, RENDER_SAMPLES), settings(scene),
                *camera)) and not self.test_break()):
            count = int(sums[0, 0, 3])
            pixels = sums[y:y + result.resolution_y, x:x + result.resolution_x] * (1 / count)
            result.layers[0].passes['Combined'].rect.foreach_set(pixels.ravel())
            self.update_result(result)
            self.update_progress(count / scene.flex_samples)
            elapsed = time.perf_counter() - started
            remaining = elapsed * (scene.flex_samples / count - 1)
            self.update_memory_stats(memory_used=self.memory[0], memory_peak=self.memory[1])
            self.update_stats(f'Mem:{self.memory[0]:.2f}M, Peak:{self.memory[1]:.2f}M',
                f'Remaining:{remaining:.1f}s | {scene.name}, {depsgraph.view_layer.name} | '
                f'Sample {count}/{scene.flex_samples} | {count / elapsed:.2f} samples/s')
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
        sums = self.trace(region.width, region.height, scene.flex_samples, VIEWPORT_SAMPLES, settings(scene),
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
        self.layout.prop(context.scene, 'flex_bounces')
        self.layout.prop(context.scene, 'flex_paths')
        for name in ('resolution_x', 'resolution_y', 'resolution_percentage'):
            self.layout.prop(context.scene.render, name)

class RENDER_PT_flex_restir(bpy.types.Panel):  # ReSTIR settings of the Flex engine
    bl_label = 'ReSTIR'
    bl_parent_id = 'RENDER_PT_flex'
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = 'render'

    def draw(self, context):
        scene = context.scene
        self.layout.use_property_split = True
        self.layout.prop(scene, 'flex_restir')
        column = self.layout.column()
        column.active = scene.flex_restir
        column.prop(scene, 'flex_decorrelation')
        if scene.flex_decorrelation:
            column.label(text='Biased: trades correlation artifacts for energy loss', icon='ERROR')
        column.prop(scene, 'flex_neighbors')

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
    bpy.types.Scene.flex_bounces = bpy.props.IntProperty(name='Max Bounces',
        description='Bounces of a path after the surface the camera sees', default=7, min=0, max=16)
    bpy.types.Scene.flex_paths = bpy.props.IntProperty(name='Paths per Sample',
        description='Paths traced per pixel and sample, the initial candidates of ReSTIR', default=1, min=1, max=32)
    bpy.types.Scene.flex_restir = bpy.props.BoolProperty(name='ReSTIR',
        description='Reuse paths across pixels and samples with ReSTIR PT Enhanced', default=True)
    bpy.types.Scene.flex_decorrelation = bpy.props.BoolProperty(name='Decorrelation', description='Reuse samples '
        'repeated across the neighborhood less over time. Biased: trades correlation artifacts for energy loss')
    bpy.types.Scene.flex_neighbors = bpy.props.IntProperty(name='Spatial Neighbors',
        description='Pixels each pixel reuses paths from per sample, fewer trade quality for speed', default=3, min=1,
        max=3)
    bpy.utils.register_class(Flex)
    bpy.utils.register_class(RENDER_PT_flex)
    bpy.utils.register_class(RENDER_PT_flex_restir)
    for name in PANELS: getattr(bpy.types, name).COMPAT_ENGINES.add(Flex.bl_idname)

def unregister():
    bpy.app.timers.unregister(reload)
    for name in PANELS: getattr(bpy.types, name).COMPAT_ENGINES.remove(Flex.bl_idname)
    bpy.utils.unregister_class(RENDER_PT_flex_restir)
    bpy.utils.unregister_class(RENDER_PT_flex)
    bpy.utils.unregister_class(Flex)
    del bpy.types.Scene.flex_samples
    del bpy.types.Scene.flex_bounces
    del bpy.types.Scene.flex_paths
    del bpy.types.Scene.flex_restir
    del bpy.types.Scene.flex_decorrelation
    del bpy.types.Scene.flex_neighbors
