# Blender render engine: exports the scene as world-space triangles and path traces it with the bundled OptiX binary.
import addon_utils, bpy, bmesh, concurrent.futures, functools, gpu, math, mmap, numpy, os, struct, subprocess, time, types
from gpu_extras.presets import draw_texture_2d
from mathutils import Color, Matrix, Vector
from mathutils.bvhtree import BVHTree
from bl_ui.properties_data_camera import classes as CAMERA_PANELS
from bpy_extras import anim_utils

SUN_DISTANCE = 1e5
SUN_MIN_ANGLE = 1e-4  # Blender's parallel sun of angle 0 as the smallest disk, which delivers the same irradiance
SPREAD_ZERO = math.radians(5)  # An area light's spread of 0, a parallel beam no light sample meets, as 5 degrees
VIEWPORT_SAMPLES = 4  # Per redraw
RENDER_SAMPLES = 64  # At most, per update of a final render
SLOTS = 32  # Values a program keeps for reuse, as the shader's
LEVELS = numpy.arange(256, dtype='u1')
BINARY = os.path.join(os.path.dirname(__file__), 'renderer')
MODIFIED = os.path.getmtime(__file__)
def logarithm(a, b):  # Of a to the base b, zero where undefined as Blender's
    with numpy.errstate(all='ignore'):
        return numpy.where((a > 0) & (b > 0) & (b != 1), numpy.log(a) / numpy.log(b), 0)

def divide(a, b):  # Zero where undefined, of 3-vectors or rows of them
    return numpy.divide(a, b, out=numpy.zeros(numpy.broadcast_shapes(numpy.shape(a), numpy.shape(b), (3,))),
        where=b != 0)

def dot(a, b):  # Of 3-vectors as numpy's, of rows of them each, kept as a column
    return numpy.dot(a, b) if numpy.ndim(a) < 2 and numpy.ndim(b) < 2 else (a * b).sum(-1, keepdims=True)

def power(a, b):  # Of a to the power of b, zero where undefined as Blender's on the GPU
    with numpy.errstate(all='ignore'):
        return numpy.where(b == 0, 1, numpy.where((a == 0) | (a < 0) & (b != numpy.trunc(b)), 0, numpy.power(a, b)))

def to_hsv(c):  # RGB to HSV, as Cycles'
    c = numpy.resize(c, 3)
    high, delta = max(c), max(c) - min(c)
    if not (high and delta): return numpy.array((0, 0, high))
    d = (high - c) / delta
    h = (d[2] - d[1] if c[0] == high else 2 + d[0] - d[2] if c[1] == high else 4 + d[1] - d[0]) / 6
    return numpy.array((h + (h < 0), delta / high, high))

def from_hsv(c):  # HSV to RGB, as Cycles'
    h, s, v = numpy.resize(c, 3)
    if not s: return numpy.full(3, v)
    i, f = divmod(0 if h == 1 else 6 * h, 1)
    p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    return numpy.array(((v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v))[int(i)] if 0 <= i < 5 else (v, p, q))

def to_hsl(c):  # RGB to HSL, as Cycles'
    c = numpy.resize(c, 3)
    high, low = max(c), min(c)
    l, delta = min(1, (high + low) / 2), high - low
    if not delta: return numpy.array((0, 0, l))
    h = (c[1] - c[2]) / delta + 6 * (c[1] < c[2]) if c[0] == high else (c[2] - c[0]) / delta + 2 if c[1] == high \
        else (c[0] - c[1]) / delta + 4
    return numpy.array((h / 6, delta / (2 - high - low) if l > 0.5 else delta / (high + low), l))

def from_hsl(c):  # HSL to RGB, as Cycles'
    h, s, l = numpy.resize(c, 3)
    n = numpy.clip((abs(h * 6 - 3) - 1, 2 - abs(h * 6 - 2), 2 - abs(h * 6 - 4)), 0, 1)
    return (n - 0.5) * (1 - abs(2 * l - 1)) * s + l

def equirectangular(d):  # Image coordinates of a direction, as Cycles'
    d = numpy.resize(d, 3)
    return numpy.array((0.5 - math.atan2(d[1], d[0]) / (2 * math.pi), 0.5 + math.atan2(d[2], math.hypot(*d[:2]))
        / math.pi, 0))

def mirror_ball(d):  # Image coordinates of a direction on a mirror ball, as Cycles'
    d = numpy.resize(d, 3)
    d = d / (numpy.linalg.norm(d) or 1) - (0, 1, 0)
    d = d / (2 * math.sqrt(max(-0.5 * d[1], 0)) or 1)
    return numpy.array((0.5 * (d[0] + 1), 0.5 * (d[2] + 1), 0))

# Steps of a program in the shader's order, operations named as Blender's with their functions; a surface's end sums its
# emission, and a mark of its specular tint passes it on
OPS = {'END': lambda *surface: numpy.sum(numpy.resize(surface[4], 3)), **dict.fromkeys(('PUSH', 'UV', 'NORMAL', 'IMAGE',
    'ALPHA', 'NORMAL_MAP')), 'ADD': numpy.add, 'SUBTRACT': numpy.subtract, 'MULTIPLY': numpy.multiply,
    'DOT_PRODUCT': dot, 'MAXIMUM': numpy.maximum, 'LOGARITHM': logarithm,
    'MULTIPLY_ADD': lambda a, b, c: a * b + c, **dict.fromkeys(('IMAGE_LINEAR', 'ALPHA_LINEAR')),
    'DIVIDE': divide, 'SNAP': lambda a, b: numpy.floor(divide(a, b)) * b, **dict.fromkeys(('GENERATED', 'NOISE',
    'IMAGE_CUBIC', 'ALPHA_CUBIC')), 'POWER': power, 'EXPONENT': numpy.exp,
    'MINIMUM': numpy.minimum, 'LESS_THAN': lambda a, b: (a < b) * 1.0, 'FLOOR': numpy.floor,
    'MODULO': lambda a, b: numpy.fmod(a, b, out=numpy.zeros(numpy.broadcast_shapes(numpy.shape(a), numpy.shape(b),
        (3,))), where=b != 0), 'SINE': numpy.sin, 'COSINE': numpy.cos,
    'TANGENT': numpy.tan, 'ARCSINE': lambda a: numpy.arcsin(numpy.clip(a, -1, 1)),
    'ARCCOSINE': lambda a: numpy.arccos(numpy.clip(a, -1, 1)), 'ARCTANGENT': numpy.arctan, 'ARCTAN2': numpy.arctan2,
    'SINH': numpy.sinh, 'COSH': numpy.cosh, 'TANH': numpy.tanh, 'CROSS_PRODUCT': numpy.cross, 'RGB_TO_HSV': to_hsv,
    'HSV_TO_RGB': from_hsv, 'RGB_TO_HSL': to_hsl, 'HSL_TO_RGB': from_hsl,
    'ROTATE': lambda v, k, a: v * numpy.cos(a) + numpy.cross(k, v) * numpy.sin(a)
        + k * dot(k, v) * (1 - numpy.cos(a)), 'EQUIRECTANGULAR': equirectangular, 'MIRROR_BALL': mirror_ball,
    **dict.fromkeys(('POSITION', 'INCOMING', 'BACKFACING', 'DIELECTRIC', 'LIGHT_PATH', 'WHITE_NOISE', 'VORONOI',
    'MAGIC', 'BRICK', 'OBJECT', 'VERTEX_COLOR', 'VERTEX_ALPHA', 'OBJECT_INFO', 'CAMERA_POINT', 'WINDOW',
    'TRANSFORM', 'BOX', 'SHIFT', 'SHIFTED', 'BUMP', 'STORE', 'LOAD', 'ANIMATED', 'BAKED')),
    'SPECULAR': lambda tint: tint, 'TRANSLUCENT': lambda color: color, 'SHEEN': lambda color: color, 'INSTANCER': None,
    'ANISOTROPIC': lambda anisotropy: anisotropy, 'MEDIUM': None, 'CURVES': None}  # The last two steps past every
# program's end, of a scene whose media vary from point to point, so the renderer tracks those it fills alone, and of
# one with strands
# Surface: expressions of its normal, albedo, metallic, roughness, emissive, transparency, ior, specular tint, specular
# level, coverage, absorption, density, scattering color, translucent color, sheen color and roughness, and anisotropy,
# its rotation and tangent, the last six of which a program carries only marked
GRAY = [('NORMAL',), 0.8, 0, 0.5, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0.5, 0, 0, 0]
BLACK = [('NORMAL',), 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0.5, 0, 0, 0]
# Of those, the ones shading isn't linear in: normal (bumps, displacement, normal maps), roughness, ior, specular level
# (an ior), absorption, density, scattering color, sheen roughness, anisotropy, its rotation and tangent, whose filtered
# values don't shade as their texels do: read at level 0, as are those of attributes not affine in their reads (curves,
# ramps, powers of a texel), and emission and coverage, which light sampling and shadow rays read with no cone, one
# value for both
UNFILTERED = (0, 3, 4, 6, 8, 9, 10, 11, 12, 15, 16, 17, 18)
# Albedo, metallic, roughness, emissive, its strength, transparency and ior per shader node, each the name of an input
# or a constant; an ior of 1 reflects nothing specularly, as Cycles' diffuse shaders. Volume shaders on surfaces
# reflect nothing, and rays pass through a portal without a position or direction; any other shader is diffuse. The
# Translucent BSDF's color, which its diffuse lobe transmits, is the surface's translucent color, and the Sheen BSDF's
# color its sheen's, over nothing else.
SHADERS = {'BSDF_PRINCIPLED': ('Base Color', 'Metallic', 'Roughness', 'Emission Color', 'Emission Strength',
        'Transmission Weight', 'IOR'), 'BSDF_METALLIC': ('Base Color', 1, 'Roughness', 0, 0, 0, 1.5),
    'EEVEE_SPECULAR': ('Base Color', 0, 'Roughness', 'Emissive Color', 1, 'Transparency', 1.5),
    **dict.fromkeys(('PRINCIPLED_VOLUME', 'VOLUME_ABSORPTION', 'VOLUME_SCATTER', 'VOLUME_COEFFICIENTS'),
        (0, 0, 1, 0, 0, 0, 1)), 'BSDF_RAY_PORTAL': ('Color', 0, 0, 0, 0, 1, 1),
    'BSDF_GLOSSY': ('Color', 1, 'Roughness', 0, 0, 0, 1.5), 'BSDF_GLASS': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'),
    'BSDF_REFRACTION': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'), 'BSDF_TRANSPARENT': ('Color', 0, 0, 0, 0, 1, 1),
    'EMISSION': (0, 0, 1, 'Color', 'Strength', 0, 1), 'BACKGROUND': (0, 0, 1, 'Color', 'Strength', 0, 1),
    'BSDF_TRANSLUCENT': (0, 0, 1, 0, 0, 0, 1), 'BSDF_SHEEN': (0, 0, 1, 0, 0, 0, 1),
    'SUBSURFACE_SCATTERING': ('Color', 0, 'Roughness', 0, 0, 0, 'IOR')}
# Absorption color, density and scattering color per volume shader node; any other absorbs and scatters nothing
VOLUMES = {'VOLUME_ABSORPTION': ('Color', 'Density', 0), 'VOLUME_SCATTER': (1, 'Density', 'Color'),
    'PRINCIPLED_VOLUME': ('Absorption Color', 'Density', 'Color')}
# Luminance of a color and mean of a vector, as Blender converts them to values
WEIGHTS = {'RGBA': numpy.array((0.2126, 0.7152, 0.0722)), 'VECTOR': numpy.full(3, 1 / 3)}
# Blender's panels the engine shows, those whose settings it reads; lights and an object's visibility, which it reads in
# part, it draws in panels of its own. A feature that reads a setting shows its panel.
PANELS = (
    # A material's node tree: its surface, its volume, its displacement under Bump or Both, and its pass index
    'EEVEE_MATERIAL_PT_context_material', 'EEVEE_MATERIAL_PT_surface', 'EEVEE_MATERIAL_PT_volume',
    'EEVEE_MATERIAL_PT_displacement', 'EEVEE_MATERIAL_PT_settings', 'MATERIAL_PT_custom_props', 'MATERIAL_PT_animation',
    'EEVEE_WORLD_PT_surface', 'WORLD_PT_context_world', 'WORLD_PT_animation', 'WORLD_PT_custom_props',  # Its surface
    # A mesh as evaluated: its modifiers' and shape keys' result, UV maps, color attributes and texture space
    'DATA_PT_context_mesh', 'DATA_PT_shape_keys', 'DATA_PT_uv_texture', 'DATA_PT_vertex_colors',
    'DATA_PT_mesh_attributes', 'DATA_PT_texture_space', 'DATA_PT_mesh_animation', 'DATA_PT_custom_props_mesh',
    'DATA_PT_vertex_groups', 'DATA_PT_remesh', 'DATA_PT_customdata',
    'DATA_PT_context_light', 'DATA_PT_light_animation', 'DATA_PT_custom_props_light',
    # The output: its format, file and frames, the compositor's work on it, its color management, and simplify
    'RENDER_PT_format', 'RENDER_PT_output', 'RENDER_PT_frame_range', 'RENDER_PT_post_processing',
    'RENDER_PT_color_management', 'RENDER_PT_color_management_advanced', 'RENDER_PT_color_management_curves',
    'RENDER_PT_color_management_white_balance', 'RENDER_PT_color_management_working_space',
    'RENDER_PT_output_color_management', 'RENDER_PT_simplify', 'RENDER_PT_simplify_render',
    'RENDER_PT_simplify_viewport',
    *(panel.__name__ for panel in CAMERA_PANELS if panel.__name__ != 'DATA_PT_camera_stereoscopy'))  # One view
SCENE, REQUEST, UPDATE, STEPS = range(4)  # Kinds of what the renderer is piped

def span(node):  # Of the points of a curves node's curves
    curves = node.mapping.curves
    return min(curve.points[0].location[0] for curve in curves), max(curve.points[-1].location[0] for curve in curves)

# A curves node's mapping as Blender's tables read its points: rebuilt from them, which sorts them by x, while they're
# in order; once keyed points cross, Blender's tables keep their order, so its table stays as built
def rebuilt(mapping):
    ordered = all(a.location[0] <= b.location[0] for curve in mapping.curves for a, b in zip(curve.points,
        curve.points[1:]))
    mapping.update() if ordered else mapping.initialize()
    return mapping

def table(node):  # Colors of a wavelength, blackbody, ramp or curves node, RGB curves after the combined curve
    if node.type == 'WAVELENGTH': return [(*numpy.array(Color(xyz).from_xyz_d65_to_scene_linear()) / 2.52, 1)
        for xyz in CIE]
    if node.type in ('BLACKBODY', 'PRINCIPLED_VOLUME'):
        return [(*Color(xyz / xyz[1]).from_xyz_d65_to_scene_linear(), 1) for xyz in radiated()]
    if node.type == 'VALTORGB': return [node.color_ramp.evaluate(i / 255) for i in range(256)]
    mapping, curves = rebuilt(node.mapping), [*node.mapping.curves]
    rgb = node.type == 'CURVE_RGB'
    return [[*(mapping.evaluate(curve, mapping.evaluate(curves[3], x) if rgb else x) for curve in (curves * 3)[:3]), 1]
        for x in numpy.linspace(*span(node), 256)]

def decode(srgb):  # sRGB to linear
    return numpy.where(srgb <= 0.04045, srgb / 12.92, ((srgb + 0.055) / 1.055) ** 2.4)

def chunks(n):  # Slices over n values, whole texels, about one per thread
    step = -(-n // os.cpu_count() // 16) * 16
    return [slice(i, i + step) for i in range(0, n, step)]

def counted(levels):  # Counts of each level by channel of RGBA8 texels, sorted in parts in threads
    parts = pool.map(lambda s: [numpy.diff(numpy.sort(levels[s][c::4], kind='stable').searchsorted(LEVELS),
        append=len(levels[s]) // 4) for c in range(4)], chunks(len(levels)))
    return [sum(counts) for counts in zip(*parts)]

# First texel, width, height, its top byte the extension and above it whether RGBA8 and, in bit 29, sRGB, and linear
# mean of an image node's image or of a node's color table, added as linear floats at first use; those Blender reads as
# k / 255 exactly as RGBA8, four texels to a float4, which the shader decodes to the same floats and from sRGB, before
# it filters them
def texture(source, textures, texels):
    if isinstance(source, ImageRead): source = source.node
    if isinstance(source, Bake): return textures[source]
    ramp = source.type not in ('TEX_IMAGE', 'TEX_ENVIRONMENT')
    key = source if ramp else (source.image, getattr(source, 'extension', 'REPEAT'))
    if key not in textures:
        image = source if ramp else source.image
        pixels = numpy.array(table(source), 'f').ravel() if ramp else numpy.empty(len(image.pixels), 'f')
        if not ramp: image.pixels.foreach_get(pixels)
        if not ramp and image.alpha_mode == 'NONE': pixels.reshape(-1, 4)[:, 3] = 1
        width, height = (len(pixels) // 4, 1) if ramp else image.size
        srgb = not (ramp or image.is_float or image.colorspace_settings.is_data)
        straight = not ramp and image.alpha_mode == 'STRAIGHT' and not image.colorspace_settings.is_data
        levels = numpy.empty(len(pixels), 'u1')  # Rounded: read only where they are k / 255 exactly
        list(pool.map(lambda s: numpy.add(pixels[s] * 255, numpy.float32(0.5), out=levels[s], casting='unsafe'),
            chunks(len(pixels))))
        red, green, blue, alphas = counted(levels)
        # Colors associated by alpha, as Cycles keeps them, in linear light: in RGBA8 exactly by alphas of 0 and 1
        # alone, a byte image's texels being k / 255 exactly
        packed = not ramp and (not image.is_float or numpy.array_equal(levels * (numpy.float32(1) / numpy.float32(
            255)), pixels)) and not (straight and alphas[1:255].any())
        if packed:  # Its mean in linear light by the count of each level, decoding no texel
            if straight and alphas[0]:
                levels.reshape(-1, 4)[levels[3::4] == 0, :3] = 0
                red, green, blue, alphas = counted(levels)
            k = numpy.arange(256) / 255
            mean = numpy.array([counts @ (decode(k) if srgb and i < 3 else k) for i, counts in
                enumerate((red, green, blue, alphas))]) / (len(levels) // 4)
        else:
            if srgb: pixels.reshape(-1, 4)[:, :3] = decode(pixels.reshape(-1, 4)[:, :3])
            if straight: pixels.reshape(-1, 4)[:, :3] *= pixels.reshape(-1, 4)[:, 3:]
            mean = pixels.reshape(-1, 4).mean(0)
        textures[key] = (sum(map(len, texels)) // 4, width, height | ('REPEAT', 'EXTEND', 'CLIP', 'MIRROR').index(
            'REPEAT' if ramp else key[1]) << 24 | packed << 26 | (packed and srgb) << 29, mean)
        texels.append(numpy.concatenate((levels, numpy.zeros(-len(levels) % 16, 'u1'))).view('f') if packed else pixels)
    return textures[key]

class Key(tuple):  # An expression's key, of its parts' keys: equal keys made one by a table and each hashed once, as a
    # tuple's hash and compare would walk its parts, which are shared, once per use
    def __new__(cls, parts, table):
        key = tuple.__new__(cls, parts)
        key.hash = tuple.__hash__(key)
        return table.setdefault(key, key)
    def __hash__(self): return self.hash

def interned(key, table):  # A key of another table into this one, its parts first
    if isinstance(key, Key) and key not in table:
        for part in key: interned(part, table)
        table[key] = key

# Recursions over resolve()'s expressions, whose parts are shared, take each part once per outermost call: memo by its
# id, which the parts keep as they outlive the call, made by that call and passed down; keys made one in table, by
# default the memo, which holds each expression with its key, as emit's outlives the expressions it makes
def expression_key(expression, memo=None, table=None):
    memo = {} if memo is None else memo
    if isinstance(expression, tuple):
        if id(expression) not in memo: memo[id(expression)] = expression, Key((expression_key(part, memo, table)
            for part in expression), memo if table is None else table)
        return memo[id(expression)][1]
    if isinstance(expression, ImageRead): return expression.key
    if isinstance(expression, (int, float, numpy.number, numpy.ndarray)):
        return tuple(numpy.resize(expression, 3).astype('f'))
    return expression

class ImageRead:  # Samples Cycles can merge share whether their alpha is read
    def __init__(self, node, point):
        self.node = node
        self.key = (node.image, node.interpolation, node.projection, getattr(node, 'projection_blend', 0),
            getattr(node, 'extension', 'REPEAT'), expression_key(fold(point)))

class Bake:  # Texture the bake pass fills with a unit's value
    pass

READS = ('IMAGE', 'ALPHA', 'IMAGE_LINEAR', 'ALPHA_LINEAR', 'IMAGE_CUBIC', 'ALPHA_CUBIC', 'BAKED')
# Steps affine in their operands, by which of these vary: a unit of them alone commutes with interpolating its reads
AFFINE = {'ADD': lambda a, b: True, 'SUBTRACT': lambda a, b: True, 'MULTIPLY': lambda a, b: not (a and b),
    'DOT_PRODUCT': lambda a, b: not (a and b), 'DIVIDE': lambda a, b: not b, 'UNASSOCIATE': lambda color, alpha: True,
    'MULTIPLY_ADD': lambda a, b, c: not (a and b), 'ROTATE': lambda vector, axis, angle: not (axis or angle)}
POINTS = ('GENERATED', 'UV')  # What units read: undeformed, so no motion bakes them again; the UV alone, over UV space
READ_COSTS = {'IMAGE_LINEAR': 5, 'IMAGE_CUBIC': 17}  # Texel fetches of the reads a unit over UV space may take
# Largest change of an expression of math on the point inputs per unit of one of them, as its derivative halfway along
# all, the noises in it held (their frequencies count of their own); infinite unless it's a function of the inputs
def jacobian(expression, input, around=0.5):
    at = lambda value: lambda e: value if e == (input,) else numpy.full(3, 0.5) if len(e) == 1 and e[0] in POINTS \
        or e[0] == 'NOISE' else None  # The expression at the value, as fold() takes it
    values = [fold(mapped(expression, at(numpy.full(3, around) + 1e-3 * step), {}))
        for step in (*numpy.eye(3), numpy.zeros(3))]
    if any(isinstance(value, tuple) for value in values): return math.inf
    return max(numpy.linalg.norm(numpy.resize(value, 3) - numpy.resize(values[3], 3)) for value in values[:3]) * 1e3

# Largest change of a point input per unit of its triangles' UVs, its corners' values as values and theirs as uvs: of
# its derivative along the UVs, by its Frobenius norm, the 90th percentile over the triangles that have area in UV,
# weighted by that area as their texels are: a sliver's derivative is only as exact as its UVs' last bits, which
# Blender's threads leave to chance, so slivers must not decide it
# Points through an object's transform and normals through its adjugate, normalized, as the renderer expands instances:
# in doubles, term by term in this order, which numpy's products, by BLAS kernels of their own, don't keep to
def transformed(points, matrix):
    p, m = points.reshape(-1, 3).astype('d'), numpy.array(matrix, 'f').astype('d')
    return numpy.stack([p[:, 0] * m[j, 0] + p[:, 1] * m[j, 1] + p[:, 2] * m[j, 2] + m[j, 3] for j in range(3)], 1)

def turned(normals, matrix):
    n, a = normals.reshape(-1, 3).astype('d'), numpy.array(matrix.to_3x3().adjugated(), 'f').astype('d')
    v = numpy.stack([n[:, 0] * a[0, j] + n[:, 1] * a[1, j] + n[:, 2] * a[2, j] for j in range(3)], 1)
    return v / numpy.sqrt(v[:, :1] * v[:, :1] + v[:, 1:2] * v[:, 1:2] + v[:, 2:3] * v[:, 2:3])

def stretch(values, uvs):
    edges = lambda a: numpy.stack((a[:, 1] - a[:, 0], a[:, 2] - a[:, 0]), 2)
    area = numpy.abs(numpy.linalg.det(edges(uvs)))
    flat = area > 1e-12
    norms = numpy.linalg.norm(edges(values)[flat] @ numpy.linalg.inv(edges(uvs)[flat]), axis=(1, 2))
    order = numpy.argsort(norms)
    return flat.any() and norms[order][numpy.searchsorted(numpy.cumsum(area[flat][order]), 0.9 * area[flat].sum())]

# Whether a material's tree is trivial, as Bendik's rule has it, and so bakes nothing: its links only from flat Image
# Textures, Normal Maps, UV Maps, Texture Coordinates' UV, Mappings that change nothing, reroutes and a shader, not a
# group, neither mixing, adding nor coated
def trivial(material):
    return bool(material and material.node_tree) and all(link.is_muted or not link.is_valid or (node := link.from_node)
        .type in ('NORMAL_MAP', 'UVMAP', 'REROUTE') or node.type == 'TEX_IMAGE' and node.projection == 'FLAT'
        or node.type == 'TEX_COORD' and link.from_socket.name == 'UV' or node.type == 'MAPPING' and node.vector_type
        != 'NORMAL' and all(not s.is_linked and tuple(s.default_value) == (float(s.name == 'Scale'),) * 3
        for s in node.inputs[1:] if s.enabled) or link.from_socket.type == 'SHADER' and node.type not in (
        'MIX_SHADER', 'ADD_SHADER', 'GROUP') and not ((coat := node.inputs.get('Coat Weight')) and (coat.is_linked
        or coat.default_value)) for link in material.node_tree.links)

# What an expression is as a unit baked over its object's UVs, its operands' first, into table by its id; for all of a
# surface before its cut, which meets each expression once, by the scales of its point inputs along them (none: no such
# unit): its image reads' kinds, points' keys, sizes and extensions; whether it's affine in them (None: not); its cost
# (None for any other step or input, a specular mark, kept live around what of its tint bakes, or a nearest or
# clipped read, which a unit over UV space can't measure); its point
# inputs; and the texels across the UVs it needs, eight per period of its noises' finest octave of at least a 256th of
# the first's amplitude, as gradient noise holds more than its frequency and distortion adds to it (two left Fog of
# tokyo's 0.1% bright).
def summarize(expression, table, scales):
    if not isinstance(expression, tuple): return set(), False, 1, set(), 0
    if id(expression) in table: return table[id(expression)]  # A part shared, summarized already
    name, *operands = expression
    parts = [summarize(operand, table, scales) for operand in operands]
    read, sub = name in READS and isinstance(operands[-1], ImageRead), parts[:-1] if name in READS else parts
    node, kind = read and operands[-1].node, name.replace('ALPHA', 'IMAGE')
    reads = {(kind, expression_key(operands[0]), tuple(node.image.size), getattr(node, 'extension', 'REPEAT'))} \
        if read else set().union(*(part[0] for part in sub))
    flags = [part[1] for part in sub]
    affine = read or (None if None in flags else any(flags) and (name in AFFINE and AFFINE[name](*flags) or None))
    points = None if name not in (*POINTS, *READS, 'NOISE', 'UNASSOCIATE') and not OPS.get(name) or read and (kind
        not in READ_COSTS or getattr(node, 'extension', '') == 'CLIP') or name in ('SPECULAR', 'TRANSLUCENT', 'SHEEN', \
        'ANISOTROPIC') or any(part[2] is None for part in parts) else READ_COSTS[kind] if read else {'NOISE': 80}.get(name, 1) + sum(
        part[2] for part in parts)
    inputs = ({name} & {*POINTS}).union(*(part[3] for part in parts))
    along = lambda: sum(jacobian(operands[0], input) * scales[input] for input in parts[0][3] & scales.keys())
    need = max([0, *(part[4] for part in parts), *([max(node.image.size) * along()] if scales and read else [])])
    if scales and name == 'NOISE':
        detail, roughness, lacunarity = (0, 1, 1) if isinstance(operands[1], tuple) else numpy.resize(operands[1], 3)
        rate = roughness * lacunarity if 'BUMP' in scales else roughness  # Under a bump of its gradient, at twice the
        octaves = detail if rate >= 1 else min(detail, math.log(1 / 256) / math.log(max(rate, 1e-3)))  # samples
        need = math.inf if isinstance(operands[1], tuple) else max(need, (16 if 'BUMP' in scales else 8) * lacunarity
            ** octaves * along())
    table[id(expression)] = reads, affine, points, inputs, need
    return table[id(expression)]

def channel(expression, k):  # Of an expression, its kth channel when constant whatever its parts that vary: a product
    # with a constant zero there zero, sums of such and constants summed; None otherwise
    if not isinstance(expression, tuple): return float(numpy.resize(expression, 3)[k])
    name, *operands = expression
    if name == 'MULTIPLY' and any(not isinstance(o, tuple) and numpy.resize(o, 3)[k] == 0 for o in operands): return 0.0
    parts = [channel(o, k) for o in operands] if name in ('ADD', 'MULTIPLY') else [None]
    return None if None in parts else sum(parts) if name == 'ADD' else parts[0] * parts[1]

# Of an expression of a medium, the box its value lies in, per channel, the boxes of its point inputs given: by interval
# arithmetic, each read within its texels whatever its point (a ramp's colors, a float image's, bytes' 0 to 1); None
# where no rule bounds it
def image_texels(node):  # Of an image read in a medium, texels its texels' values lie between: a float image's own,
    # read in place, as its list of pixels runs to gigabytes, a byte image's 0 to 1; without an image, black; the alpha
    # of one without 1, as texture() pipes it; clipped, the 0 the renderer reads outside it too
    image = node.image
    texels = numpy.zeros((1, 4)) if not image else numpy.array(((0,) * 4, (1,) * 4), 'd')
    if image and image.is_float: image.pixels.foreach_get(texels := numpy.empty(len(image.pixels), 'f'))
    texels = texels.reshape(-1, 4)
    if image and image.alpha_mode == 'NONE': texels[:, 3] = 1
    return numpy.concatenate((texels, numpy.zeros((1, 4)))) if getattr(node, 'extension', '') == 'CLIP' else texels
def bounds(expression, boxes, memo):
    if not isinstance(expression, tuple):
        value = numpy.resize(numpy.asarray(expression, 'd'), 3)
        return value, value
    if id(expression) in memo: return memo[id(expression)]
    name, *operands = expression
    parts = [] if name in (*READS, 'UNASSOCIATE') or name in boxes else [bounds(o, boxes, memo)
        for o in operands[1:3]] if name == 'NOISE' else [bounds(o, boxes, memo) for o in operands]  # A noise's range
    # whatever its point
    product = lambda a, b: (numpy.min(c := [x * y for x in a for y in b], 0), numpy.max(c, 0))
    if None in parts: box = None
    elif name in boxes: box = boxes[name]
    elif name in READS and name != 'BAKED':
        source = operands[-1]
        if isinstance(source, ImageRead):  # Without an image, black
            texels = image_texels(source.node)
        else: texels = numpy.array(table(source), 'd')
        texels = texels[:, 3:].repeat(3, 1) if name.startswith('ALPHA') else texels[:, :3]
        box = texels.min(0), texels.max(0)
    elif name == 'UNASSOCIATE':  # Its color over its alpha, both filtered by the same weights, none negative (linear's
        # or B-splines'), a blend of the straight colors of texels not clear or 0 where all are, as divide() makes it;
        # or, its alpha unread, as emit() takes it, its color associated, between 0 and those
        texels = image_texels(operands[0][-1].node)
        texels = numpy.concatenate((texels[texels[:, 3] > 0, :3], numpy.zeros((1, 3))))
        box = texels.min(0), texels.max(0)
    elif name == 'ADD': box = parts[0][0] + parts[1][0], parts[0][1] + parts[1][1]
    elif name == 'SUBTRACT': box = parts[0][0] - parts[1][1], parts[0][1] - parts[1][0]
    elif name == 'MULTIPLY': box = product(*parts)
    elif name in ('MAXIMUM', 'MINIMUM'):
        pick = numpy.maximum if name == 'MAXIMUM' else numpy.minimum
        box = pick(parts[0][0], parts[1][0]), pick(parts[0][1], parts[1][1])
    elif name == 'POWER': box = (parts[0][0] ** parts[1][0], parts[0][1] ** parts[1][0]) \
        if (parts[0][0] >= 0).all() and (parts[1][0] == parts[1][1]).all() and (parts[1][0] >= 0).all() else None
    elif name == 'NOISE':  # The renderer's: a blend of its corners' gradients by weights of sum 1, so within the
        # largest a corner's gradient reaches (8 at 1D, 1 + 2 at 2D, 2 at 3D, 3 at 4D, offsets within 1) by its scale;
        # normalized fractal Brownian motion within half of that about 0.5, unnormalized by its octaves' amplitudes
        # summed; its dimensions a constant of vector(w, dimensions, 0) as noise() makes it
        (_, params), (least, extra) = parts
        dims = channel(operands[3], 1)
        dims = int(dims) if dims is not None else None
        kind = int(extra[2])
        bound = (2, 1.985, 1.964, 2.503)[dims - 1] if dims in (1, 2, 3, 4) else None
        roughness, octaves = max(params[1], 0), math.ceil(min(max(params[0], 0), 15)) + 1
        amplitudes = sum(roughness ** k for k in range(octaves))
        box = None if bound is None or least[2] != extra[2] or kind > 1 else tuple(numpy.full(3, v) for v in (
            (0.5 - bound / 2, 0.5 + bound / 2) if kind == 0 else (-bound * amplitudes, bound * amplitudes)))
    elif name == 'DOT_PRODUCT':
        low, high = product(*parts)
        box = numpy.full(3, low.sum()), numpy.full(3, high.sum())
    else: box = None
    memo[id(expression)] = box if box is None or numpy.isfinite(box).all() else None
    return memo[id(expression)]

# Of the volume of a material filling an instance, varying from point to point (any of its absorption, density and
# scattering color not a constant) or emitting, which the renderer gathers tracking it: the largest extinction it
# reaches, (scatter + 1 - absorption) density as the renderer makes it, inside the boxes its point inputs span, 0 for
# one neither; for one no rule bounds, an error naming the material, as the renderer tracks such a volume under that
# bound and no guess; of one emitting, at least as many collisions across its points as GLOW_COLLISIONS, as each
# gathers its emission
GLOW_COLLISIONS = 4
def medium(material, boxes):
    absorption, density, scatter, glow = (fold(part) for part in MEDIA.get(material, (0, 0, 0, 0)))
    if not any(isinstance(part, tuple) for part in (absorption, density, scatter)) and not nonzero(glow): return 0.0
    box = bounds(('MULTIPLY', ('SUBTRACT', ('ADD', scatter, 1), absorption), density), boxes, {})
    if box is None: raise ValueError(f"Flex: the volume of material '{material.name}' varies by steps no bound is "
        'known for, so its density has no largest value to track it under')
    least = GLOW_COLLISIONS / numpy.linalg.norm(boxes['POSITION'][1] - boxes['POSITION'][0]) if nonzero(glow) else 0
    return max(float(box[1].max()), least, 0.0)

BAKE_TOLERANCE = 2 ** -9  # Most a bake over UV space strays from shading live: a fifth of its test's seed floor (0.011)

def texels_of(source, cache):  # An image's or table's texels as the export holds them (read alone in an update,
    # cache[None] None), and what filters texels taken of them as the renderer: linear, associated; once an image
    if (key := source.image if source.type in ('TEX_IMAGE', 'TEX_ENVIRONMENT') else source) not in cache:
        first, width, height, _ = texture(source, *(stores := cache[None] or ({}, [])))
        held = stores[1][numpy.searchsorted(numpy.cumsum([*map(len, stores[1])]) // 4, first, 'right')]
        scale, linear = numpy.float32(1 / 255) if height >> 26 & 1 else 1, decode if height >> 29 & 1 else numpy.asarray
        filtered = lambda c: numpy.concatenate((linear(c[..., :3] * scale), c[..., 3:] * scale), -1)  # RGBA8 as k / 255
        cache[key] = (held.view('u1') if height >> 26 & 1 else held)[:width * (height & 0xFFFFFF) * 4].reshape(
            height & 0xFFFFFF, width, 4), filtered
    return cache[key]

ROWS = ('RGB_TO_HSV', 'HSV_TO_RGB', 'RGB_TO_HSL', 'HSL_TO_RGB', 'EQUIRECTANGULAR', 'MIRROR_BALL')  # Steps of one vector
def shaded(expression, uv, cache, memo):  # Values, as shaded, of math and linear reads of the UV at rows of UVs
    if not isinstance(expression, tuple): return numpy.broadcast_to(numpy.resize(expression, 3), (len(uv), 3))
    if id(expression) not in memo:
        name, *operands = expression
        if name == 'UV': value = numpy.column_stack((uv, numpy.zeros(len(uv))))
        elif name == 'UNASSOCIATE': value = shaded(operands[0], uv, cache, memo)  # As emit() reads it unweighed
        elif name in READS:
            source = operands[-1].node if isinstance(operands[-1], ImageRead) else operands[-1]
            texels, filtered = texels_of(source, cache)
            x, y = (shaded(operands[0], uv, cache, memo)[:, :2] * texels.shape[1::-1] - 0.5).T
            i, j = numpy.floor(x).astype(int), numpy.floor(y).astype(int)
            # Repeated, mirrored over the image and its reflection as the GPU reads it, or extended
            extension = getattr(source, 'extension', 'REPEAT')
            at = lambda k, n: k % n if extension == 'REPEAT' else numpy.minimum(k % (2 * n), 2 * n - 1 - k % (2 * n)) \
                if extension == 'MIRROR' else numpy.clip(k, 0, n - 1)
            c = [filtered(texels[at(j + k // 2, texels.shape[0]), at(i + k % 2, texels.shape[1])]) for k in range(4)]
            x, y = (x - i)[:, None], (y - j)[:, None]
            value = (c[0] * (1 - x) + c[1] * x) * (1 - y) + (c[2] * (1 - x) + c[3] * x) * y
            value = value[:, 3:] if name.startswith('ALPHA') else value[:, :3]
        else:
            parts = [shaded(part, uv, cache, memo) for part in operands]
            value = OPS[name](*parts) if name not in ROWS else [OPS[name](*row) for row in zip(*parts)]
        memo[id(expression)] = numpy.broadcast_to(numpy.asarray(value, 'f8'), (len(uv), 3))
    return memo[id(expression)]

def strays(expression, low, span, size, cache):  # Whether a bake of size texels over the domain, read back linearly,
    q = numpy.random.default_rng(0).random((64, 2)) * size - 0.5  # strays past BAKE_TOLERANCE from shading live, at
    points = [numpy.floor(q) + (k % 2, k // 2) + 0.5 for k in range(4)] + [q + 0.5]  # 64 points: around each the
    c = shaded(expression, low + numpy.concatenate(points) / size * span, cache, {}).reshape(5, 64, 3)  # texels baked
    x, y = (q - numpy.floor(q)).T[..., None]
    return (abs((c[0] * (1 - x) + c[1] * x) * (1 - y) + (c[2] * (1 - x) + c[3] * x) * y - c[4]) > BAKE_TOLERANCE).any()

def uv_domain(expression, uvs, need, cache, keys):  # Of a unit of the UV alone: the low corner, span and texels of
    # the domain its bake covers, and whether it repeats there; aligned, with an odd count of samples a texel, to the
    # texels of the image lattice its reads share, so their filtering's kinks are samples, and as fine as keeps it
    # within BAKE_TOLERANCE of shading live, measured at points of it (noise alone: eight samples per period); None
    # where 4K can't, or noise and reads mix, which can't be measured here
    reads, noise, memo = [], [], {}
    def walk(e):
        if isinstance(e, tuple) and id(e) not in memo:
            memo[id(e)] = (reads if e[0] in READS and isinstance(e[-1], ImageRead) else noise if e[0] == 'NOISE'
                else []).append(e) or [*map(walk, e[1:])]
    if walk(expression) or reads and noise: return None
    low, span, base, repeat = uvs.min(0), numpy.ptp(uvs, 0).clip(1e-6), numpy.full(2, max(64, need)), False
    p = (point := reads and reads[0][1]) and shaded(point, numpy.array(((0, 0), (1, 0), (0, 1))), cache, {})  # At 3 UVs
    o, s = point and p[0, :2], point and numpy.array((p[1, 0], p[2, 1])) - p[0, :2]
    if point and s.all() and len({(tuple(r[-1].node.image.size), expression_key(r[1])) for r in reads}) == 1:
        base = abs(s) * reads[0][-1].node.image.size  # Texels a UV; repeating with the UV where shading shows it
        q = numpy.random.default_rng(1).random((8, 2))
        repeat = (base == numpy.round(base)).all() and all(numpy.allclose(shaded(expression, q, cache, {}), shaded(
            expression, q + d, cache, {})) for d in numpy.eye(2))
        low = -o / s + numpy.floor((low + o / s) * base) / base  # The corner of a texel at or below its UVs
        span = numpy.ones(2) if repeat else numpy.ceil((uvs.max(0) - low) * base).clip(1) / base
    key = 'odd', expression_key(expression, keys)  # Its samples a texel, as measured for another object of it
    for k in [cache[key]] if key in cache else range(1, 9, 2):
        size = numpy.ceil(span * base * (k or 0) - 1e-6).astype(int)
        if not k or (size > 4096).any(): return None
        if noise or key in cache or not strays(expression, low, span, size, cache):
            return cache.setdefault(key, k) and (numpy.r_[cache.setdefault((key, 'low'), low) if repeat else low, 0],
                numpy.r_[span, 1], size, repeat)  # Repeating, at the first object's corner, as it was baked there
    cache[key] = None

def mapped(expression, change, memo):  # The expression, or a surface, its parts changed where change gives a value
    if isinstance(expression, list): return [mapped(part, change, memo) for part in expression]  # (not None), each
    if not isinstance(expression, tuple): return expression  # shared part once and shared still
    if id(expression) not in memo: memo[id(expression)] = changed if (changed := change(expression)) is not None \
        else (expression[0], *(mapped(part, change, memo) for part in expression[1:]))
    return memo[id(expression)]

def moved_to(expression, point, memo, leaf='UV'):  # The expression, or a surface, with its UV (or another leaf) at the
    return mapped(expression, lambda e: point if e[0] == leaf else None, memo)  # point

def alpha_reads(expression, seen=None):  # Image samples whose alpha contributes to the resolved surface, each part
    seen = set() if seen is None else seen  # shared entered once
    if id(expression) in seen: return
    seen.add(id(expression))
    if isinstance(expression, list):
        for part in expression: yield from alpha_reads(part, seen)
    elif isinstance(expression, tuple):
        name, *operands = expression
        if name in ('ALPHA', 'ALPHA_LINEAR', 'ALPHA_CUBIC') and isinstance(operands[-1], ImageRead):
            yield operands[-1].key
        for part in operands[:1] if name == 'UNASSOCIATE' else operands: yield from alpha_reads(part, seen)

def differentiated(expression, seen=None, height=False):  # Images read in a Bump's heights, which it differentiates
    seen = set() if seen is None else seen
    if (id(expression), height) in seen: return
    seen.add((id(expression), height))
    if isinstance(expression, ImageRead) and height: yield expression.node.image
    elif isinstance(expression, (list, tuple)):
        bump = isinstance(expression, tuple) and expression[0] == 'BUMP'
        for k, part in enumerate(expression): yield from differentiated(part, seen, height or bump and 2 <= k <= 4)

def unfiltered(expression, seen):  # Marks the image reads in an expression to read at level 0
    if id(expression) in seen: return
    seen.add(id(expression))
    if isinstance(expression, ImageRead): expression.unfiltered = True
    elif isinstance(expression, (list, tuple)):
        for part in expression: unfiltered(part, seen)

# Appends the steps of an expression to ops, operands first, a surface's seven before an end; returns its value under
# textures of their mean. Without slots it counts in uses each expression met at the point it is read at, a height
# shifted by a bump read at its shift, entering none twice; with them those met again are kept in a slot and loaded.
def marks(expression, name):  # Whether the expression holds an operation of the name
    return isinstance(expression, tuple) and (expression[0] == name or any(marks(x, name) for x in expression[1:]))

# Keys are made once in keys, a memo of expression_key passed down, which both passes of a program share.
def emit(expression, ops, textures, texels, alphas, uses, slots=None, shift=None, keys=None):
    keys = {} if keys is None else keys
    if isinstance(expression, list): expression = 'END', *expression
    if not isinstance(expression, tuple):
        ops.append((1, *numpy.resize(expression, 3).astype('f').view('I')))
        return expression
    name, *operands = expression
    key = shift, expression_key(expression, keys)
    if name != 'SHIFT' and key in (uses if slots is None else slots):
        if slots is None: uses[key][0] += 1
        else: ops.append(([*OPS].index('LOAD'), slots[key], 0, 0))
        return uses[key][1]
    if name == 'UNASSOCIATE':
        return emit(('DIVIDE', *operands) if operands[1][-1].key in alphas else operands[0], ops, textures, texels,
            alphas, uses, slots, shift, keys)
    source = operands[-1] if name in READS else None
    payload = texture(operands.pop(), textures, texels) if name in READS else (0, 0, 0, numpy.ones(4))
    # In bits 20 on of its width, log2 of how far its point moves per unit of the UVs in 64ths, by which its mip level
    # follows the ray's cone; reads not by the UVs or not affine in them, and those of UNFILTERED attributes, at level 0
    if name in ('IMAGE_LINEAR', 'ALPHA_LINEAR') and slots is not None:
        scale = 0 if getattr(source, 'unfiltered', False) or not math.isclose(*(jacobian(operands[0], 'UV', around)
            for around in (0.25, 0.75)), rel_tol=1e-3) else jacobian(operands[0], 'UV')
        payload = (payload[0], payload[1] | (min(max(round(64 * math.log2(scale)), -2047), 2047) if 0 < scale < math.inf
            else -2048) % 4096 << 20, *payload[2:])
    values = [emit(operand, ops, textures, texels, alphas, uses, slots,
        operands[0] if name == 'SHIFTED' and k else shift, keys) for k, operand in enumerate(operands)]
    ops.append(([*OPS].index(name), *payload[:3]))
    if name == 'LIGHT_PATH': return float(values[0] >= 8)  # Of no ray, length and depth one, as light sampling shades
    value = OPS[name](*values) if OPS[name] else numpy.resize(payload[3][3:] if 'ALPHA' in name else payload[3][:3], 3)
    if slots is None: uses[key] = [1, value]
    elif name != 'SHIFT' and uses[key][0] > 1:
        slots[key] = len(slots)
        ops.append(([*OPS].index('STORE'), slots[key], 0, 0))
    return value

def fold(expression, memo=None):  # The expression with its operations on constants alone computed, as the shader would
    memo = {} if memo is None else memo
    if isinstance(expression, list): return [fold(attribute, memo) for attribute in expression]
    if not isinstance(expression, tuple): return expression
    if id(expression) not in memo: memo[id(expression)] = folded(expression, memo)
    return memo[id(expression)]

def folded(expression, memo):
    name, *operands = (fold(part, memo) if isinstance(part, tuple) else part for part in expression)
    if name not in ('UNASSOCIATE', 'SPECULAR', 'TRANSLUCENT', 'SHEEN', 'ANISOTROPIC') and OPS[name] \
        and not any(isinstance(x, tuple) for x in operands):
        return OPS[name](*(numpy.resize(operand, 3) for operand in operands))
    if name in ('ADD', 'SUBTRACT', 'MULTIPLY', 'DIVIDE'):
        for i, value in enumerate(operands):
            if isinstance(value, tuple): continue
            if numpy.all(numpy.asarray(value) == (1 if name in ('MULTIPLY', 'DIVIDE') else 0)) \
                and (name in ('ADD', 'MULTIPLY') or i == 1): return operands[1 - i]
    # A rotation by no angle, as a mapping's at its defaults; a product with zero, and zero divided, zero where
    # undefined as Blender's
    if name == 'ROTATE' and not isinstance(operands[2], tuple) and not numpy.any(operands[2]): return operands[0]
    if name == 'MULTIPLY' and any(not isinstance(value, tuple) and not numpy.any(value) for value in operands) \
            or name == 'DIVIDE' and not isinstance(operands[0], tuple) and not numpy.any(operands[0]):
        return numpy.zeros(3)
    return name, *operands

def unanimated(value, memo=None):  # The expression with its animated values, which its cut keeps from bakes, as
    memo = {} if memo is None else memo  # constants
    return mapped(value, lambda e: unanimated(e[1], memo) if e[0] == 'ANIMATED' else None, memo)

def nonzero(value):  # Whether a value resolved is an expression or a constant not zero, its animated ones as constants
    return isinstance(unanimated(value), tuple) or numpy.any(unanimated(value))

def constant(expression, seen=None):  # Whether it is constant before products of zero fold it, as Blender's nodes see
    if not isinstance(expression, tuple): return True  # it; each part shared once
    seen = {} if seen is None else seen
    if id(expression) not in seen:
        seen[id(expression)] = expression[0] != 'UNASSOCIATE' and bool(OPS[expression[0]]) \
            and all(constant(part, seen) for part in expression[1:])
    return seen[id(expression)]

def coated(a, b):  # Two surfaces, one without a coat given the other's of weight 0, so a coat mixes in by its weight
    return [[*x, [*y[19][:9], 0]] if len(x) < len(y) == 20 else x for x, y in ((a, b), (b, a))]

def mix(a, b, factor):  # Expression of a fading into b, surfaces attribute by attribute
    if isinstance(a, list): return [mix(x, y, factor) for x, y in zip(*coated(a, b))]
    return 'ADD', ('MULTIPLY', a, ('SUBTRACT', 1, factor)), ('MULTIPLY', b, factor)

def clamp(value):
    return 'SUBTRACT', 1, ('MAXIMUM', 0, ('SUBTRACT', 1, ('MAXIMUM', 0, value)))

def absolute(value):
    return 'MAXIMUM', value, ('SUBTRACT', 0, value)

def fraction(value):
    return 'SUBTRACT', value, ('FLOOR', value)

def length(vector):
    return 'POWER', ('DOT_PRODUCT', vector, vector), 0.5

# Instancer attributes the export reads, by name their index; the Attribute node's outputs of one: its color, vector,
# factor and alpha, as Cycles reads them, of the float4 its instance's info names
INSTANCER, IDS = {}, {}  # Of an instancer's levels by its name and their outer ids, its instances' rows by id
def instanced(name, index):
    k = 2 * INSTANCER[name]
    return (('INSTANCER', k), ('INSTANCER', k), ('DOT_PRODUCT', ('INSTANCER', k), numpy.full(3, 1 / 3)),
        ('INSTANCER', k + 1))[index]

def instancer(instance):  # Its instancer attributes, float4 each: each level of geometry nodes' instances, from the
    # outermost, an inner level's overriding an outer's, as Cycles finds the nearest; zeros where none has one
    values, geometry = numpy.zeros((len(INSTANCER), 4), 'f'), instance.parent.evaluated_geometry()
    level = instance.parent.name,
    for i in reversed([i for i in instance.persistent_id[1:] if i != 0x7FFFFFFF]):  # Its mesh first, then outwards
        points = geometry.instances_pointcloud()
        if not points: break
        if level not in IDS:  # Its ids, Blender's of instances of an id attribute, else their indices
            ids = numpy.arange(len(points.points), dtype='i')
            if 'id' in points.attributes: points.attributes['id'].data.foreach_get('value', ids)
            IDS[level] = dict(zip(ids.tolist(), range(len(ids))))
        level, i = (*level, i), IDS[level].get(i)
        if i is None: break
        for name, k in INSTANCER.items():
            if name in points.attributes:
                item = points.attributes[name].data[i]
                v = next(getattr(item, key) for key in ('color', 'vector', 'value') if hasattr(item, key))
                v = [*v] if hasattr(v, '__len__') else [float(v)] * 3
                values[k] = (*(v + [0, 0])[:3], v[3] if len(v) > 3 else 1)
        geometry = geometry.instance_references()[points.attributes['.reference_index'].data[i].value]
        if not isinstance(geometry, bpy.types.GeometrySet): break
    return values

def normalize(vector):  # Zero for zero, as Blender's
    return 'DIVIDE', vector, length(vector)

def refract(a, b, eta):  # Of a through a surface along b, zero under total internal reflection, as Blender's
    n, cosine = normalize(b), ('DOT_PRODUCT', a, normalize(b))
    k = 'SUBTRACT', 1, ('MULTIPLY', ('MULTIPLY', eta, eta), ('SUBTRACT', 1, ('MULTIPLY', cosine, cosine)))
    return 'MULTIPLY', ('SUBTRACT', ('MULTIPLY', a, eta), ('MULTIPLY', n, ('ADD', ('MULTIPLY', eta, cosine),
        ('POWER', ('MAXIMUM', k, 0), 0.5)))), ('SUBTRACT', 1, ('LESS_THAN', k, 0))

def smooth(a, b, c):  # Smooth minimum of a and b by c, as Blender's
    h = 'DIVIDE', ('MAXIMUM', ('SUBTRACT', c, absolute(('SUBTRACT', a, b))), 0), c
    return 'SUBTRACT', ('MINIMUM', a, b), ('MULTIPLY', ('MULTIPLY', ('MULTIPLY', h, h), h), ('MULTIPLY', c, 1 / 6))

# Operations of math and vector math nodes composed of the shader's: their expressions of the operands, as Blender's
COMPOSITES = {'SQRT': lambda a: ('POWER', ('MAXIMUM', a, 0), 0.5),
    'INVERSE_SQRT': lambda a: ('DIVIDE', 1, ('POWER', ('MAXIMUM', a, 0), 0.5)), 'ABSOLUTE': absolute,
    'GREATER_THAN': lambda a, b: ('LESS_THAN', b, a),
    'SIGN': lambda a: ('SUBTRACT', ('LESS_THAN', 0, a), ('LESS_THAN', a, 0)),
    'COMPARE': lambda a, b, c: ('SUBTRACT', 1, ('LESS_THAN', ('MAXIMUM', c, 2 ** -23), absolute(('SUBTRACT', a, b)))),
    'SMOOTH_MIN': smooth, 'SMOOTH_MAX': lambda a, b, c: ('SUBTRACT', 0, smooth(('SUBTRACT', 0, a),
        ('SUBTRACT', 0, b), c)), 'ROUND': lambda a: ('FLOOR', ('ADD', a, 0.5)),
    'CEIL': lambda a: ('SUBTRACT', 0, ('FLOOR', ('SUBTRACT', 0, a))),
    'TRUNC': lambda a: ('SUBTRACT', a, ('MODULO', a, 1)), 'FRACT': fraction, 'FRACTION': fraction,
    'FLOORED_MODULO': lambda a, b: ('MULTIPLY', ('SUBTRACT', a, ('SNAP', a, b)), ('LESS_THAN', 0, absolute(b))),
    'WRAP': lambda a, b, c: ('ADD', c, ('MULTIPLY', ('SUBTRACT', ('SUBTRACT', a, ('SNAP', ('SUBTRACT', a, c),
        ('SUBTRACT', b, c))), c), ('LESS_THAN', 0, absolute(('SUBTRACT', b, c))))),
    'PINGPONG': lambda a, b: absolute(('SUBTRACT', ('MULTIPLY', fraction(('DIVIDE', ('SUBTRACT', a, b),
        ('MULTIPLY', b, 2))), ('MULTIPLY', b, 2)), b)),
    'RADIANS': lambda a: ('MULTIPLY', a, math.pi / 180), 'DEGREES': lambda a: ('MULTIPLY', a, 180 / math.pi),
    'PROJECT': lambda a, b: ('MULTIPLY', b, ('DIVIDE', ('DOT_PRODUCT', a, b), ('DOT_PRODUCT', b, b))),
    'REFLECT': lambda a, b: ('SUBTRACT', a, ('MULTIPLY', normalize(b), ('MULTIPLY', ('DOT_PRODUCT', a, normalize(b)),
        2))), 'REFRACT': refract,
    'FACEFORWARD': lambda a, b, c: ('MULTIPLY', a, ('SUBTRACT', ('MULTIPLY', ('LESS_THAN', ('DOT_PRODUCT', c, b), 0),
        2), 1)), 'DISTANCE': lambda a, b: length(('SUBTRACT', a, b)), 'LENGTH': length,
    'SCALE': lambda a, b: ('MULTIPLY', a, b), 'NORMALIZE': normalize}

def screen(t, a, b):
    return 'SUBTRACT', 1, ('MULTIPLY', ('ADD', ('SUBTRACT', 1, t), ('MULTIPLY', t, ('SUBTRACT', 1, b))),
        ('SUBTRACT', 1, a))

def overlay(t, a, b):
    return mix(screen(t, a, ('SUBTRACT', ('MULTIPLY', b, 2), 1)), ('MULTIPLY', a, ('ADD', ('SUBTRACT', 1, t),
        ('MULTIPLY', ('MULTIPLY', t, 2), b))), ('LESS_THAN', a, 0.5))

def burn(t, a, b):
    tmp = 'ADD', ('SUBTRACT', 1, t), ('MULTIPLY', t, b)
    return 'MULTIPLY', clamp(('SUBTRACT', 1, ('DIVIDE', ('SUBTRACT', 1, a), tmp))), ('LESS_THAN', 0, tmp)

def dodge(t, a, b):
    tmp = 'SUBTRACT', 1, ('MULTIPLY', t, b)
    return 'MULTIPLY', mix(1, ('MINIMUM', ('DIVIDE', a, tmp), 1), ('LESS_THAN', 0, tmp)), ('LESS_THAN', 0, absolute(a))

def saturated(color):  # One where the color has a saturation, else zero
    return 'LESS_THAN', 0, absolute(('DOT_PRODUCT', ('RGB_TO_HSV', color), numpy.eye(3)[1]))

def recolor(color, hsv, mask):  # The color with the components of its HSV the mask selects taken from hsv
    return 'HSV_TO_RGB', mix(('RGB_TO_HSV', color), hsv, mask)

# Blends of color mix nodes besides fading into an operation's result: their expressions of the factor and the colors,
# as Cycles'
BLENDS = {'DARKEN': lambda t, a, b: mix(a, ('MINIMUM', a, b), t),
    'LIGHTEN': lambda t, a, b: mix(a, ('MAXIMUM', a, b), t),
    'DIFFERENCE': lambda t, a, b: mix(a, absolute(('SUBTRACT', a, b)), t),
    'EXCLUSION': lambda t, a, b: ('MAXIMUM', mix(a, ('SUBTRACT', ('ADD', a, b), ('MULTIPLY', ('MULTIPLY', a, b), 2)),
        t), 0), 'SCREEN': screen, 'OVERLAY': overlay,
    'SOFT_LIGHT': lambda t, a, b: mix(a, ('MULTIPLY', a, ('ADD', ('MULTIPLY', ('SUBTRACT', 1, a), b), screen(1, a, b))),
        t), 'LINEAR_LIGHT': lambda t, a, b: ('ADD', a, ('MULTIPLY', t, ('SUBTRACT', ('MULTIPLY', b, 2), 1))),
    'DIVIDE': lambda t, a, b: mix(a, ('ADD', ('DIVIDE', a, b), ('MULTIPLY', a, ('SUBTRACT', 1, ('LESS_THAN', 0,
        absolute(b))))), t), 'BURN': burn, 'DODGE': dodge,
    'HUE': lambda t, a, b: mix(a, mix(a, recolor(a, ('RGB_TO_HSV', b), numpy.eye(3)[0]), t), saturated(b)),
    'COLOR': lambda t, a, b: mix(a, mix(a, recolor(a, ('RGB_TO_HSV', b), numpy.array((1, 1, 0))), t), saturated(b)),
    'SATURATION': lambda t, a, b: mix(a, recolor(a, mix(('RGB_TO_HSV', a), ('RGB_TO_HSV', b), t), numpy.eye(3)[1]),
        saturated(a)),
    'VALUE': lambda t, a, b: recolor(a, mix(('RGB_TO_HSV', a), ('RGB_TO_HSV', b), t), numpy.eye(3)[2])}

def blend(node, inputs, index):  # Of a mix node: its inputs faded into one another or blended as its colors
    kind = getattr(node, 'blend_type', 'MIX') if getattr(node, 'data_type', 'RGBA') == 'RGBA' else 'MIX'
    if kind in BLENDS: return BLENDS[kind](*inputs[:3])
    return mix(inputs[1], (kind, *inputs[1:]) if OPS.get(kind) else inputs[2], inputs[0])

def between(value, a, b):  # Clamped to the range from a to b, either the larger, as Blender's
    return 'MINIMUM', ('MAXIMUM', value, ('MINIMUM', a, b)), ('MAXIMUM', a, b)

# Of a map range node, clamping as a clamp node of the range it maps to, of values from none to zero, as Cycles'
def map_range(node, inputs, index):
    value, low, high, to_low, to_high, *steps = inputs
    t, kind = ('DIVIDE', ('SUBTRACT', value, low), ('SUBTRACT', high, low)), node.interpolation_type
    if kind == 'STEPPED': t = 'MULTIPLY', ('DIVIDE', ('FLOOR', ('MULTIPLY', t, ('ADD', steps[0], 1))), steps[0]), \
        ('LESS_THAN', 0, steps[0])
    if kind in ('SMOOTHSTEP', 'SMOOTHERSTEP'): t = clamp(t)
    if kind == 'SMOOTHSTEP': t = 'MULTIPLY', ('MULTIPLY', t, t), ('SUBTRACT', 3, ('MULTIPLY', t, 2))
    if kind == 'SMOOTHERSTEP': t = 'MULTIPLY', ('MULTIPLY', ('MULTIPLY', t, t), t), ('ADD', ('MULTIPLY', t,
        ('SUBTRACT', ('MULTIPLY', t, 6), 15)), 10)
    value = 'ADD', to_low, ('MULTIPLY', t, ('SUBTRACT', to_high, to_low))
    if node.data_type == 'FLOAT' and not all(map(constant, inputs)):
        value = 'MULTIPLY', value, ('LESS_THAN', 0, absolute(('SUBTRACT', high, low)))
    return between(value, to_low, to_high) if node.clamp else value

def hue_saturation(hue, saturation, value, factor, color):  # Of a hue saturation value node, as Cycles'
    hsv = 'RGB_TO_HSV', color
    hsv = 'ADD', ('ADD', ('MULTIPLY', fraction(('ADD', hsv, ('ADD', hue, 0.5))), numpy.eye(3)[0]),
        ('MULTIPLY', clamp(('MULTIPLY', hsv, saturation)), numpy.eye(3)[1])), ('MULTIPLY', ('MULTIPLY', hsv, value),
        numpy.eye(3)[2])
    return 'MAXIMUM', mix(color, ('HSV_TO_RGB', hsv), factor), 0

# Of a black body at 256 temperatures evenly apart in 1/T, from T unbounded to 800 K, its radiance per wavelength as CIE
# XYZ: by Planck's law, against Rayleigh-Jeans' 1 / wavelength^4 at the first, in scale alone, which colors lose
def radiated():
    wavelengths = numpy.arange(380, 781, 5) * 1e-9
    x = numpy.linspace(0, 1 / 800, 256)[:, None] * RADIATION / wavelengths  # hc / (wavelength k T)
    return numpy.where(x > 0, x / numpy.expm1(numpy.maximum(x, 1e-30)), 1) / wavelengths ** 4 @ numpy.array(CIE)
RADIATION = 6.62607015e-34 * 299792458 / 1.380649e-23  # hc / k in m K, of SI's exact Planck, light and Boltzmann

def blackbody(t, node):  # Of a black body at the temperature, its color in scene linear of luminance 1, 800 K's below
    point = 'ADD', ('MULTIPLY', ('DIVIDE', 800, ('MAXIMUM', t, 800)), 255 / 256), 0.5 / 256  # Along its table in 1/T
    return 'MAXIMUM', ('IMAGE_LINEAR', point, node), 0

# CIE 1931 XYZ color matching functions at 5 nm intervals, 380 to 780 nm, as Cycles'
CIE = ((0.0014, 0.0000, 0.0065), (0.0022, 0.0001, 0.0105), (0.0042, 0.0001, 0.0201),
    (0.0076, 0.0002, 0.0362), (0.0143, 0.0004, 0.0679), (0.0232, 0.0006, 0.1102),
    (0.0435, 0.0012, 0.2074), (0.0776, 0.0022, 0.3713), (0.1344, 0.0040, 0.6456),
    (0.2148, 0.0073, 1.0391), (0.2839, 0.0116, 1.3856), (0.3285, 0.0168, 1.6230),
    (0.3483, 0.0230, 1.7471), (0.3481, 0.0298, 1.7826), (0.3362, 0.0380, 1.7721),
    (0.3187, 0.0480, 1.7441), (0.2908, 0.0600, 1.6692), (0.2511, 0.0739, 1.5281),
    (0.1954, 0.0910, 1.2876), (0.1421, 0.1126, 1.0419), (0.0956, 0.1390, 0.8130),
    (0.0580, 0.1693, 0.6162), (0.0320, 0.2080, 0.4652), (0.0147, 0.2586, 0.3533),
    (0.0049, 0.3230, 0.2720), (0.0024, 0.4073, 0.2123), (0.0093, 0.5030, 0.1582),
    (0.0291, 0.6082, 0.1117), (0.0633, 0.7100, 0.0782), (0.1096, 0.7932, 0.0573),
    (0.1655, 0.8620, 0.0422), (0.2257, 0.9149, 0.0298), (0.2904, 0.9540, 0.0203),
    (0.3597, 0.9803, 0.0134), (0.4334, 0.9950, 0.0087), (0.5121, 1.0000, 0.0057),
    (0.5945, 0.9950, 0.0039), (0.6784, 0.9786, 0.0027), (0.7621, 0.9520, 0.0021),
    (0.8425, 0.9154, 0.0018), (0.9163, 0.8700, 0.0017), (0.9786, 0.8163, 0.0014),
    (1.0263, 0.7570, 0.0011), (1.0567, 0.6949, 0.0010), (1.0622, 0.6310, 0.0008),
    (1.0456, 0.5668, 0.0006), (1.0026, 0.5030, 0.0003), (0.9384, 0.4412, 0.0002),
    (0.8544, 0.3810, 0.0002), (0.7514, 0.3210, 0.0001), (0.6424, 0.2650, 0.0000),
    (0.5419, 0.2170, 0.0000), (0.4479, 0.1750, 0.0000), (0.3608, 0.1382, 0.0000),
    (0.2835, 0.1070, 0.0000), (0.2187, 0.0816, 0.0000), (0.1649, 0.0610, 0.0000),
    (0.1212, 0.0446, 0.0000), (0.0874, 0.0320, 0.0000), (0.0636, 0.0232, 0.0000),
    (0.0468, 0.0170, 0.0000), (0.0329, 0.0119, 0.0000), (0.0227, 0.0082, 0.0000),
    (0.0158, 0.0057, 0.0000), (0.0114, 0.0041, 0.0000), (0.0081, 0.0029, 0.0000),
    (0.0058, 0.0021, 0.0000), (0.0041, 0.0015, 0.0000), (0.0029, 0.0010, 0.0000),
    (0.0020, 0.0007, 0.0000), (0.0014, 0.0005, 0.0000), (0.0010, 0.0004, 0.0000),
    (0.0007, 0.0002, 0.0000), (0.0005, 0.0002, 0.0000), (0.0003, 0.0001, 0.0000),
    (0.0002, 0.0001, 0.0000), (0.0002, 0.0001, 0.0000), (0.0001, 0.0000, 0.0000),
    (0.0001, 0.0000, 0.0000), (0.0001, 0.0000, 0.0000), (0.0000, 0.0000, 0.0000))

def wavelength(node, inputs, index):  # Cycles' spectral color, clamped after interpolation in scene linear
    value = inputs[0]
    point = 'ADD', ('MULTIPLY', clamp(('DIVIDE', ('SUBTRACT', value, 380), 400)), 80 / 81), 0.5 / 81
    colors = numpy.array(table(node))[:, :3]
    color = 'ADD', ('IMAGE_LINEAR', point, node), ('MULTIPLY', ('MINIMUM', ('SUBTRACT', value, 380), 0),
        (colors[1] - colors[0]) / 5)
    return 'MULTIPLY', ('MAXIMUM', color, 0), ('MULTIPLY', ('LESS_THAN', 375, value), ('LESS_THAN', value, 780))

# Conversions of colors from RGB into the modes of separate and combine color nodes and back
MODES = {'RGB': (lambda c: c, lambda c: c), 'HSV': (lambda c: ('RGB_TO_HSV', c), lambda c: ('HSV_TO_RGB', c)),
    'HSL': (lambda c: ('RGB_TO_HSL', c), lambda c: ('HSL_TO_RGB', c))}

def euler(vector, rotation, inverse=False):  # Turned by Blender's XYZ Euler angles, or back
    for k in (2, 1, 0) if inverse else (0, 1, 2):
        angle = 'DOT_PRODUCT', rotation, numpy.eye(3)[k]
        vector = 'ROTATE', vector, numpy.eye(3)[k], ('SUBTRACT', 0, angle) if inverse else angle
    return vector

def mapping(node, inputs, index):  # Of a mapping node, as Cycles'
    vector, *location, rotation, scale = inputs
    if node.vector_type == 'TEXTURE': return 'DIVIDE', euler(('SUBTRACT', vector, *location), rotation, True), scale
    if node.vector_type == 'NORMAL': return normalize(euler(('DIVIDE', vector, scale), rotation))
    vector = euler(('MULTIPLY', vector, scale), rotation)
    return ('ADD', vector, *location) if location else vector

# Of a vector transform node, through the world, normals normalized by every transform, as Cycles'
def vector_transform(node, inputs, index):
    v, kind, spaces = inputs[0], ('POINT', 'VECTOR', 'NORMAL').index(node.vector_type), (node.convert_from,
        node.convert_to)
    camera = lambda v, mode: normalize(('TRANSFORM', v, mode)) if kind == 2 else ('TRANSFORM', v, mode)
    if spaces[0] == 'CAMERA' != spaces[1]: v = camera(v, 8 + min(kind, 1))  # Into the world
    if spaces[0] == 'OBJECT' != spaces[1]: v = 'TRANSFORM', v, kind
    if spaces[1] == 'OBJECT' != spaces[0]: v = 'TRANSFORM', v, 3 + kind  # Out of it
    if spaces[1] == 'CAMERA' != spaces[0]: v = camera(v, 6 + min(kind, 1))
    return v

def vector_rotate(node, inputs, index):  # Of a vector rotate node about its center, as Cycles'
    vector, center, *rotation = inputs
    if node.rotation_type == 'EULER_XYZ':
        return 'ADD', euler(('SUBTRACT', vector, center), rotation[0], node.invert), center
    axis = normalize(rotation[0]) if node.rotation_type == 'AXIS_ANGLE' else numpy.eye(3)['XYZ'.index(
        node.rotation_type[0])]
    angle = ('SUBTRACT', 0, rotation[-1]) if node.invert else rotation[-1]
    if node.rotation_type == 'AXIS_ANGLE': angle = 'MULTIPLY', angle, ('LESS_THAN', 0, length(rotation[0]))
    return 'ADD', ('ROTATE', ('SUBTRACT', vector, center), axis, angle), center

# Of a tangent node, as Cycles': radial about an axis through the middle of the generated points, its sign aside,
# or the active UV map's MikkTSpace tangent; in the world
def tangent(node, inputs, index):
    return ('NORMAL_MAP', numpy.array((1, 0.5, 0.5))) if node.direction_type == 'UV_MAP' else radial(node.axis)

def radial(axis):
    return 'TRANSFORM', ('CROSS_PRODUCT', numpy.eye(3)['XYZ'.index(axis)], ('SUBTRACT', ('GENERATED',), 0.5)), 2

def vector(x, y, z):
    return 'ADD', ('ADD', ('MULTIPLY', x, numpy.eye(3)[0]), ('MULTIPLY', y, numpy.eye(3)[1])), \
        ('MULTIPLY', z, numpy.eye(3)[2])

def hashed(*keys):  # Jenkins' hash of up to three keys in [0, 1], as Cycles'
    v = [(0xdeadbeef + (len(keys) << 2) + 13 + key) & 0xFFFFFFFF for key in (*keys, 0, 0)[:3]]
    for t, s, k in ((2, 1, 14), (0, 2, 11), (1, 0, 25), (2, 1, 16), (0, 2, 4), (1, 0, 14), (2, 1, 24)):
        v[t] = ((v[t] ^ v[s]) - (v[s] << k | v[s] >> 32 - k)) & 0xFFFFFFFF
    return v[2] / 0xFFFFFFFF

# Cycles' random offset of noise of the dimensions by the seed, of its point and W: Jenkins' hash of the seed, with each
# axis but in one dimension, as floats
def offset(seed, dimensions):
    bits = lambda value: struct.unpack('<I', struct.pack('<f', value))[0]
    shifts = [100 + 100 * hashed(bits(seed), *[bits(axis)] * (dimensions > 1)) for axis in range(dimensions)]
    return numpy.array((shifts + [0, 0])[:3]), shifts[3] if dimensions == 4 else 0

def point_of(node, value, default=('GENERATED',)):  # A texture node's point: its vector input's value where linked
    return value if node.inputs[0].is_linked else default

# Of a noise texture node of 1D to 4D points, at the generated point without a vector, as Cycles': its fractal, the
# type of which the renderer numbers, at the point distorted by signed noise, for its color also at two offsets
def noise(node, inputs, index):
    get, dimensions = dict(zip((socket.name for socket in node.inputs if socket.enabled), inputs)).get, \
        int(node.noise_dimensions[0])
    point, w = (vector(get('W'), 0, 0), 0) if dimensions == 1 else (point_of(node, get('Vector')), get('W', 0))
    kind = 'UNNORMALIZED' if node.noise_type == 'FBM' and not node.normalize else node.noise_type
    kind = ('FBM', 'UNNORMALIZED', 'MULTIFRACTAL', 'HETERO_TERRAIN', 'HYBRID_MULTIFRACTAL',
        'RIDGED_MULTIFRACTAL').index(kind)
    fractal = lambda p, w, params=vector(get('Detail'), get('Roughness'), get('Lacunarity')), extra=vector(
        get('Offset', 0), get('Gain', 0), kind): ('NOISE', p, params, extra, vector(w, dimensions, 0))
    at = lambda seed, p, w, *kind: fractal(('ADD', p, offset(seed, dimensions)[0]), ('ADD', w, offset(seed,
        dimensions)[1]), *kind)  # Offset by the seed
    point, w, distortion = ('MULTIPLY', point, get('Scale')), ('MULTIPLY', w, get('Scale')), get('Distortion')
    if nonzero(distortion):
        signed = [at(seed, point, w, numpy.array((0, 0, 1)), numpy.array((0, 0, 1))) for seed in range(dimensions)]
        point = 'ADD', point, ('MULTIPLY', vector(*(signed + [0, 0])[:3]), distortion)
        if dimensions == 4: w = 'ADD', w, ('MULTIPLY', signed[3], distortion)
    if not index: return fractal(point, w)
    return vector(fractal(point, w), at(dimensions, point, w), at(dimensions + 1, point, w))

# Of a white noise texture node, its value or color, as Cycles'
def white_noise(node, inputs, index):
    return 'WHITE_NOISE', inputs[0], vector(int(node.noise_dimensions[0]), index, inputs[1] if len(inputs) > 1 else 0)

# Of a Voronoi texture node's distance, color, position or W, as Cycles' fractal of 1D to 4D points, at the generated
# point without a vector, normalized by the farthest distance its metric makes; or its distance to edges or n-sphere
# radius
def voronoi(node, inputs, index):
    get = dict(zip((socket.name for socket in node.inputs if socket.enabled), inputs)).get
    dimensions = int(node.voronoi_dimensions[0])
    point, w = (vector(get('W'), 0, 0), 0) if dimensions == 1 else (point_of(node, get('Vector')), get('W', 0))
    metric = 0 if dimensions == 1 else ('EUCLIDEAN', 'MANHATTAN', 'CHEBYCHEV', 'MINKOWSKI').index(node.distance)
    feature = ('F1', 'F2', 'SMOOTH_F1', 'DISTANCE_TO_EDGE', 'N_SPHERE_RADIUS').index(node.feature)
    farthest = ('POWER', dimensions, ('DIVIDE', 1, get('Exponent'))) if metric == 3 else (dimensions ** 0.5,
        dimensions, 1)[metric]
    farthest = 'MULTIPLY', ('ADD', 0.5, ('MULTIPLY', 0.5, clamp(get('Randomness')))), ('MULTIPLY', 1 if feature > 2
        else farthest, (2 if feature == 1 else 1) * (node.normalize and feature < 4))
    output = ('Distance', 'Color', 'Position', 'W').index(node.outputs[index].name.replace('Radius', 'Distance'))
    value = ('VORONOI', ('MULTIPLY', point, get('Scale')), vector(feature, metric, get('Exponent', 1)),
        vector(get('Randomness'), get('Smoothness', 0), output), vector(get('Detail', 0),
        get('Roughness', 0), get('Lacunarity', 0)), vector(farthest, ('MULTIPLY', w, get('Scale')), dimensions))
    return ('DIVIDE', value, get('Scale')) if output > 1 else value

def magic(node, inputs, index):  # Of a magic texture node at the generated point without a vector, as Cycles'
    color = 'MAGIC', point_of(node, inputs[0]), vector(inputs[1], node.turbulence_depth, inputs[2])
    return ('DOT_PRODUCT', color, numpy.full(3, 1 / 3)) if index else color

def brick(node, inputs, index):  # Of a brick texture node at the generated point without a vector, as Cycles'
    p, color1, color2, mortar, scale, size, smooth, bias, width, height = inputs
    f = 'BRICK', ('MULTIPLY', point_of(node, p), scale), vector(size, smooth, bias), \
        vector(width, height, node.offset), numpy.array((node.offset_frequency, node.squash, node.squash_frequency))
    tint, factor = ('DOT_PRODUCT', f, numpy.eye(3)[0]), ('DOT_PRODUCT', f, numpy.eye(3)[1])
    return factor if index else mix(mix(color1, color2, tint), mortar, factor)

def gradient(node, inputs, index):  # Of a gradient texture node at the generated point without a vector, as Cycles'
    p = point_of(node, inputs[0])
    x, y = ('DOT_PRODUCT', p, numpy.eye(3)[0]), ('DOT_PRODUCT', p, numpy.eye(3)[1])
    r = 'MAXIMUM', ('SUBTRACT', 0.999999, length(p)), 0
    return clamp({'LINEAR': x, 'QUADRATIC': ('MULTIPLY', ('MAXIMUM', x, 0), ('MAXIMUM', x, 0)),
        'EASING': ('MULTIPLY', ('MULTIPLY', clamp(x), clamp(x)), ('SUBTRACT', 3, ('MULTIPLY', clamp(x), 2))),
        'DIAGONAL': ('MULTIPLY', ('ADD', x, y), 0.5),
        'RADIAL': ('ADD', ('DIVIDE', ('ARCTAN2', y, x), 2 * math.pi), 0.5), 'SPHERICAL': r,
        'QUADRATIC_SPHERE': ('MULTIPLY', r, r)}[node.gradient_type])

def checker(node, inputs, index):  # Of a checker texture node at the generated point without a vector, as Cycles'
    p, color1, color2, scale = inputs
    p = 'MULTIPLY', ('ADD', ('MULTIPLY', point_of(node, p), scale), 1e-6), 0.999999
    factor = absolute(('MODULO', ('DOT_PRODUCT', ('FLOOR', p), numpy.ones(3)), 2))  # Whether the floors' sum is odd
    return factor if index else mix(color2, color1, factor)

def wave(node, inputs, index):  # Of a wave texture node at the generated point without a vector, as Cycles'
    p, scale, distortion, detail, detail_scale, roughness, phase = inputs
    p = 'MULTIPLY', ('ADD', ('MULTIPLY', point_of(node, p), scale), 1e-6), 0.999999
    if node.wave_type == 'BANDS': n = 'DOT_PRODUCT', p, numpy.eye(3)['XYZ'.index(node.bands_direction)] * 20 \
        if node.bands_direction != 'DIAGONAL' else numpy.full(3, 10)
    else: n = 'MULTIPLY', length(('MULTIPLY', p, numpy.ones(3) - numpy.eye(3)['XYZ'.index(node.rings_direction)]
        if node.rings_direction != 'SPHERICAL' else 1)), 20
    n = 'ADD', n, phase
    if nonzero(distortion): n = 'ADD', n, ('MULTIPLY', distortion, ('SUBTRACT',
        ('MULTIPLY', ('NOISE', ('MULTIPLY', p, detail_scale), vector(detail, roughness, 2), numpy.zeros(3),
        numpy.array((0, 3, 0))), 2), 1))
    if node.wave_profile == 'SIN': return 'ADD', 0.5, ('MULTIPLY', 0.5, ('SINE', ('SUBTRACT', n, math.pi / 2)))
    n = 'DIVIDE', n, 2 * math.pi
    return fraction(n) if node.wave_profile == 'SAW' else ('MULTIPLY', absolute(('SUBTRACT', n, ('FLOOR', ('ADD', n,
        0.5)))), 2)

def transform(matrix, point):  # The point by the affine matrix
    return 'ADD', vector(*(('DOT_PRODUCT', point, numpy.array(row[:3])) for row in matrix[:3])), \
        numpy.array(matrix.translation)

def facing(normal):  # Turned toward the incoming direction on the backs of faces, as Cycles' shading normals
    return 'MULTIPLY', normal, ('SUBTRACT', 1, ('MULTIPLY', ('BACKFACING',), 2))

def coordinates(node, inputs, index):  # Of a texture coordinate node, as Cycles'
    if index == 3: return transform(node.object.matrix_world.inverted(), ('POSITION',)) if node.object else ('OBJECT',)
    reflection = 'SUBTRACT', ('MULTIPLY', facing(('NORMAL',)), ('MULTIPLY', ('DOT_PRODUCT', facing(('NORMAL',)),
        ('INCOMING',)), 2)), ('INCOMING',)
    return {0: ('GENERATED',), 1: ('TRANSFORM', facing(('NORMAL',)), 5), 4: ('CAMERA_POINT',), 5: ('WINDOW',),
        6: reflection}.get(index) or resolve(node.outputs[index])

# Of a bump node: the normal bent by the gradient of its height, there and at points along the triangle, whatever
# filter width, as Cycles'
def bump(node, inputs, index):
    strength, distance, _, height, normal = inputs
    return 'BUMP', normal, height, ('SHIFTED', ('SHIFT', 1), height), ('SHIFTED', ('SHIFT', 2), height), \
        vector(strength, ('MULTIPLY', distance, -1 if node.invert else 1), 0)

# Of a light falloff node: its strength by the ray's length to the power of the output's index, smoothed toward the
# ray's start
def light_falloff(node, inputs, index):
    (strength, smooth), squared = inputs, ('MULTIPLY', ('LIGHT_PATH', 8), ('LIGHT_PATH', 8))
    strength = ('MULTIPLY', strength, ('POWER', ('LIGHT_PATH', 8), index)) if index else strength
    return ('MULTIPLY', strength, ('DIVIDE', squared, ('ADD', smooth, squared))) if nonzero(smooth) else strength

def fresnel(node, inputs, index):  # Of a fresnel node, as Cycles'
    eta = 'MAXIMUM', inputs[0], 1e-5
    return 'DIELECTRIC', ('DOT_PRODUCT', ('INCOMING',), facing(inputs[1])), mix(eta, ('DIVIDE', 1, eta),
        ('BACKFACING',))

def layer_weight(node, inputs, index):  # Of a layer weight node, as Cycles'
    blend, cosine = inputs[0], ('DOT_PRODUCT', ('INCOMING',), facing(inputs[1]))
    if not index:
        eta = 'MAXIMUM', ('SUBTRACT', 1, blend), 1e-5
        return 'DIELECTRIC', cosine, mix(('DIVIDE', 1, eta), eta, ('BACKFACING',))
    blend = 'MINIMUM', ('MAXIMUM', blend, 0), 1 - 1e-5
    exponent = mix(('DIVIDE', 0.5, ('SUBTRACT', 1, blend)), ('MULTIPLY', blend, 2), ('LESS_THAN', blend, 0.5))
    return 'SUBTRACT', 1, ('POWER', absolute(cosine), exponent)

def lookup(node, f, k):  # Component k of a curves node's colors f along them, beyond them extended or extrapolated
    inside = 'DOT_PRODUCT', ('IMAGE_LINEAR', ('ADD', ('MULTIPLY', clamp(f), 255 / 256), 0.5 / 256), node), \
        numpy.eye(3)[k]
    if node.mapping.extend != 'EXTRAPOLATED': return inside
    colors = numpy.array(table(node))[:, k]
    below = 'SUBTRACT', colors[0], ('MULTIPLY', f, (colors[0] - colors[1]) * 255)
    above = 'ADD', colors[255], ('MULTIPLY', ('SUBTRACT', f, 1), (colors[255] - colors[254]) * 255)
    return mix(mix(inside, above, ('LESS_THAN', 1, f)), below, ('LESS_THAN', f, 0))

def curves(node, inputs, index):  # Of an RGB, vector or float curves node, each channel along its curve, as Cycles'
    factor, value = inputs
    if node.type == 'CURVE_FLOAT' and not any(isinstance(fold(v), tuple) for v in inputs):
        rebuilt(node.mapping)
        looked = node.mapping.evaluate(node.mapping.curves[0], float(numpy.resize(fold(value), 3)[0]))
        return mix(value, between(looked, node.mapping.clip_min_y, node.mapping.clip_max_y)
            if node.mapping.use_clip else looked, factor)
    low, high = span(node)
    f = 'DIVIDE', ('SUBTRACT', value, low), high - low
    looked = lookup(node, f, 0) if node.type == 'CURVE_FLOAT' else vector(*(lookup(node, ('DOT_PRODUCT', f,
        numpy.eye(3)[k]), k) for k in range(3)))
    return mix(value, looked, factor)

# Of a normal map node, as Cycles': its strength scaling the normal in tangent space, else fading into it
def normal_map(node, inputs, index):
    strength, color = inputs
    if node.space == 'TANGENT':
        if getattr(node, 'convention', 'OPENGL') == 'DIRECTX':  # Its green the other way
            color = 'ADD', ('MULTIPLY', color, numpy.array((1, -1, 1))), numpy.array((0, 1, 0))
        color = 'ADD', ('MULTIPLY', ('SUBTRACT', color, 0.5), vector(strength, strength, clamp(strength))), \
            ('MULTIPLY', ('SUBTRACT', 1, clamp(strength)), numpy.array((0, 0, 0.5)))
        return 'NORMAL_MAP', ('ADD', color, 0.5)
    color = normalize(('MULTIPLY', ('SUBTRACT', ('MULTIPLY', color, 2), 1), numpy.array((1, -1, -1))
        if 'BLENDER' in node.space else 1))
    if 'OBJECT' in node.space: color = 'TRANSFORM', color, 2
    return normalize(mix(('NORMAL',), color, ('MAXIMUM', strength, 0)))

# Color or alpha of an image node at its vector, projected and extended, pink when missing, of an environment node along
# its projected direction, by default its position's from the world's origin, as Blender's. Cycles dissociates colors
# from their alpha where reading it unless the image packs channels, ignores its alpha, which is one then, or holds data.
def image(node, inputs, index):
    if not (node.image and node.image.size[0]): return numpy.array((1, 0, 1))
    source = ImageRead(node, point_of(node, inputs[0], ('UV',)))
    point = point_of(node, inputs[0], ('UV',))
    if node.type == 'TEX_ENVIRONMENT':
        point = node.projection, point_of(node, inputs[0], ('POSITION',))
    elif node.projection in ('SPHERE', 'TUBE'):  # Around the center of the unit cube
        x, y, z = (('DOT_PRODUCT', ('SUBTRACT', ('MULTIPLY', point, 2), 1), axis) for axis in numpy.eye(3))
        around = ('ADD', 0.5, ('DIVIDE', ('ARCTAN2', x, y), -2 * math.pi)), ('ADD', ('MULTIPLY', z, 0.5), 0.5)
        if node.projection == 'SPHERE': around = around[0], ('SUBTRACT', 1, ('DIVIDE', ('ARCCOSINE', ('MULTIPLY', z,
            COMPOSITES['INVERSE_SQRT'](('ADD', ('ADD', ('MULTIPLY', x, x), ('MULTIPLY', y, y)), ('MULTIPLY', z, z))))),
            math.pi))
        point = vector(*around, 0)
    elif node.projection == 'BOX':  # Of a sample along each axis of the object, by Cycles' weights of the normal
        normal = 'TRANSFORM', facing(('NORMAL',)), 5
        weights = 'BOX', normal, node.projection_blend
        x, y, z, nx, ny, nz = (('DOT_PRODUCT', v, axis) for v in (point, normal) for axis in numpy.eye(3))
        flip = lambda c, n, positive: mix(c, ('SUBTRACT', 1, c), ('LESS_THAN', 0, n) if positive
            else ('LESS_THAN', n, 0))
        uvs = (flip(y, nx, False), z), (flip(x, ny, True), z), (flip(y, nz, True), x)
        terms = [('MULTIPLY', ('DOT_PRODUCT', weights, axis), sample(source, index, vector(u, v, 0)))
            for axis, (u, v) in zip(numpy.eye(3), uvs)]
        return 'ADD', ('ADD', terms[0], terms[1]), terms[2]
    return sample(source, index, point)

def sample(source, index, point):  # Of an image node at a point, as Cycles reads images
    node = source.node
    read = lambda name: (name + {'Linear': '_LINEAR', 'Cubic': '_CUBIC', 'Smart': '_CUBIC'}.get(node.interpolation,
        ''), point, source)
    if index or node.image.alpha_mode in (
            'CHANNEL_PACKED', 'NONE') or node.image.colorspace_settings.is_data: return read(('IMAGE', 'ALPHA')[index])
    return 'UNASSOCIATE', read('IMAGE'), read('ALPHA')

# The nodes resolved exactly: the expression of an output by its index, given those of the node's enabled inputs. An
# image is read at the UV without a vector and is pink when missing; mixes blend plainly unless by an operation. Added
# shaders sum their iors' excess over 1, as Cycles sums their reflections. Of UV maps only the active one is known.
NODES = {'NORMAL_MAP': normal_map, 'REROUTE': lambda node, inputs, index: inputs[0],
    'TEX_IMAGE': image,
    'VALTORGB': lambda node, inputs, index: (('ALPHA' if index else 'IMAGE')
        + ('_LINEAR' if node.color_ramp.interpolation != 'CONSTANT' else ''),
        ('ADD', ('MULTIPLY', clamp(inputs[0]), 255 / 256), 0.5 / 256), node),
    'INVERT': lambda node, inputs, index: mix(inputs[1], ('SUBTRACT', 1, inputs[1]), inputs[0]),
    'GAMMA': lambda node, inputs, index: mix(mix(inputs[0], ('POWER', *inputs), ('LESS_THAN', 0, inputs[0])), 1,
        ('SUBTRACT', 1, ('LESS_THAN', 0, absolute(inputs[1])))),  # White for no gamma
    'BRIGHTCONTRAST': lambda node, inputs, index: ('MAXIMUM', ('ADD', ('MULTIPLY', inputs[0], ('ADD', 1, inputs[2])),
        ('SUBTRACT', inputs[1], ('MULTIPLY', inputs[2], 0.5))), 0),
    'RGBTOBW': lambda node, inputs, index: ('DOT_PRODUCT', inputs[0], WEIGHTS['RGBA']),
    'BLACKBODY': lambda node, inputs, index: blackbody(inputs[0], node),
    'WAVELENGTH': wavelength,
    'HUE_SAT': lambda node, inputs, index: hue_saturation(*inputs),
    'SEPARATE_COLOR': lambda node, inputs, index: ('DOT_PRODUCT', MODES[node.mode][0](inputs[0]), numpy.eye(3)[index]),
    'COMBINE_COLOR': lambda node, inputs, index: MODES[node.mode][1](NODES['COMBXYZ'](node, inputs, index)),
    'CURVE_RGB': curves, 'CURVE_VEC': curves, 'CURVE_FLOAT': curves,
    'MIX': blend, 'MAP_RANGE': map_range, 'CLAMP': lambda node, inputs, index: between(*inputs)
        if node.clamp_type == 'RANGE' else ('MINIMUM', ('MAXIMUM', inputs[0], inputs[1]), inputs[2]),
    'ADD_SHADER': lambda node, inputs, index: [mix(a, b, 0.5) if attribute in (2, 3, 7, 8, 10, 12, *range(15, 20))
        else ('SUBTRACT', ('ADD', a, b), 1) if attribute in (6, 9) else ('ADD', a, b)
        for attribute, (a, b) in enumerate(zip(*coated(*inputs)))],
    'MATH': lambda node, inputs, index: (node.operation, *inputs) if OPS.get(node.operation)
        else COMPOSITES[node.operation](*inputs) if node.operation in COMPOSITES else inputs[0],
    'SEPXYZ': lambda node, inputs, index: ('DOT_PRODUCT', inputs[0], numpy.eye(3)[index]),
    'COMBXYZ': lambda node, inputs, index: vector(*inputs),
    'MAPPING': mapping, 'VECTOR_ROTATE': vector_rotate, 'VECT_TRANSFORM': vector_transform, 'TANGENT': tangent,
    'TEX_COORD': coordinates, 'CAMERA': lambda node, inputs, index: (normalize(('CAMERA_POINT',)),
        ('DOT_PRODUCT', ('CAMERA_POINT',), numpy.eye(3)[2]), length(('CAMERA_POINT',)))[index],
    'NEW_GEOMETRY': lambda node, inputs, index: {0: ('POSITION',), 1: facing(('NORMAL',)), 4: ('INCOMING',),
        6: ('BACKFACING',)}.get(index) or resolve(node.outputs[index]),
    'FRESNEL': fresnel, 'LAYER_WEIGHT': layer_weight, 'BUMP': bump, 'LIGHT_FALLOFF': light_falloff,
    'DISPLACEMENT': lambda node, inputs, index: ('MULTIPLY', inputs[3], ('MULTIPLY', ('SUBTRACT', *inputs[:2]),
        inputs[2])),
    'VERTEX_COLOR': lambda node, inputs, index: ('VERTEX_ALPHA',) if index else ('VERTEX_COLOR',),
    'OBJECT_INFO': lambda node, inputs, index: ('OBJECT_INFO', index),
    'ATTRIBUTE': lambda node, inputs, index: instanced(node.attribute_name, index) if node.attribute_type == 'INSTANCER'
        else (('VERTEX_COLOR',), ('VERTEX_COLOR',), ('DOT_PRODUCT', ('VERTEX_COLOR',),
        numpy.full(3, 1 / 3)), ('VERTEX_ALPHA',))[index] if node.attribute_type == 'GEOMETRY' and any(
        node.attribute_name in mesh.color_attributes for mesh in bpy.data.meshes) else resolve(node.outputs[index]),
    'LIGHT_PATH': lambda node, inputs, index: ('LIGHT_PATH', index)
        if index in (0, 1, 2, 3, 5, 6, 8, 9) else resolve(node.outputs[index]),
    'TEX_NOISE': noise, 'TEX_WHITE_NOISE': white_noise, 'TEX_GRADIENT': gradient, 'TEX_CHECKER': checker,
    'TEX_WAVE': wave, 'TEX_VORONOI': voronoi, 'TEX_MAGIC': magic, 'TEX_BRICK': brick}
NODES |= {'TEX_ENVIRONMENT': NODES['TEX_IMAGE'], 'MIX_SHADER': NODES['MIX'], 'MIX_RGB': NODES['MIX'],
    'VECT_MATH': NODES['MATH']}

# Expression of what a socket receives, a surface for a shader: a constant, or a step followed by its operands. groups
# are the group nodes entered on the way; a node that is muted or not resolved exactly passes its input on.
def animated(socket):  # Whether the socket's value is keyframed or driven, which the interpreter runs per frame
    data, path = socket.id_data.animation_data, socket.path_from_id('default_value')
    bag = data and data.action and anim_utils.action_get_channelbag_for_slot(data.action, data.action_slot)
    return bool(data and (data.drivers.find(path) or bag and bag.fcurves.find(path)))

def resolve(socket, groups=()):
    link = next((link for link in socket.links  # Invalid links close a cycle
        if link.is_valid and not (socket.is_output or link.is_muted)), None)
    if not link and socket.type == 'SHADER': return BLACK
    if not link:  # A virtual socket has no value; an animated one is left to the interpreter, never baked
        value = numpy.resize(getattr(socket, 'default_value', 0), 3)
        value = ('ANIMATED', value) if hasattr(socket, 'default_value') and animated(socket) else value
        return {'Normal': ('NORMAL',), 'Coat Normal': ('NORMAL',), 'UV': ('UV',), 'Tangent': radial('Z')}.get(
            socket.name, value)
    node, output = link.from_node, link.from_socket
    index = [*node.outputs].index(output)
    # An input an option hides reads as under the option showing it, the closest Flex renders: Subsurface Scattering's
    # IOR and roughness, which Christensen-Burley and Random Walk (Skin) hide, as Random Walk reads them
    hidden = ('IOR', 'Roughness') if node.type == 'SUBSURFACE_SCATTERING' else ()
    get = lambda name, default=0: next(resolve(input, groups) for input in node.inputs if input.name == name) \
        if name in node.inputs or name in hidden else default
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
        albedo, metallic, roughness, emissive, strength, transparency, ior, absorption, density, scatter = (get(source)
            if isinstance(source, str) else source for source in SHADERS.get(node.type, ('Color', 0, 1, 0, 0, 0, 1))
            + VOLUMES.get(node.type, (1, 0, 0)))
        if node.type == 'BSDF_METALLIC' and node.fresnel_type == 'PHYSICAL_CONDUCTOR':  # Its reflectance at normal
            n, k = get('IOR'), get('Extinction')  # incidence, by its complex IOR
            k = 'MULTIPLY', k, k
            albedo = 'DIVIDE', ('ADD', ('MULTIPLY', ('SUBTRACT', n, 1), ('SUBTRACT', n, 1)), k), \
                ('ADD', ('MULTIPLY', ('ADD', n, 1), ('ADD', n, 1)), k)
        # Principled hair renders as a diffuse of its color: by melanin or absorption, of the color derived from
        # Blender's documented parameters by the formulas Cycles' source reads them with, the absorption of a color at
        # the radial roughness, and melanin's by eumelanin's and pheomelanin's coefficients and the tint's
        if node.type == 'BSDF_HAIR_PRINCIPLED' and node.parametrization != 'COLOR':  # An approximation, as hair's is
            fit, x = 0.245, get('Radial Roughness')
            for c in (5.574, -10.73, 2.532, -0.215, 5.969): fit = 'MULTIPLY_ADD', fit, x, c
            sigma = get('Absorption Coefficient')
            if node.parametrization == 'MELANIN':  # Its amount from the input's perceptually linear one
                tint = 'DIVIDE', ('LOGARITHM', get('Tint'), math.e), fit
                melanin = 'MULTIPLY', -1, ('LOGARITHM', ('MAXIMUM', ('SUBTRACT', 1, get('Melanin')), 1e-4), math.e)
                sigma = 'ADD', ('MULTIPLY', melanin, mix(numpy.array((0.506, 0.841, 1.653)),
                    numpy.array((0.343, 0.733, 1.924)), get('Melanin Redness'))), ('MULTIPLY', tint, tint)
            albedo = 'EXPONENT', ('MULTIPLY', ('POWER', sigma, 0.5), ('MULTIPLY', fit, -1))
        if node.type == 'PRINCIPLED_VOLUME':  # Absorbs what it does not scatter by the absorption color, not its root
            absorption = 'SUBTRACT', 1, ('MULTIPLY', ('SUBTRACT', 1, absorption),
                ('MAXIMUM', 0, ('SUBTRACT', 1, scatter)))
        # In a volume it emits per unit length by its emission and by a black body's radiance at its temperature,
        # STEFAN_BOLTZMANN T^4 / PI, linear in its intensity, by BLACKBODY_UNIT, colored by blackbody(); neither by its
        # density, none at 0 K or below; on a surface nothing
        if node.type == 'PRINCIPLED_VOLUME' and SIDE['volume']:
            emissive, strength, t = get('Emission Color'), get('Emission Strength'), ('MAXIMUM', 0, get('Temperature'))
            if nonzero(intensity := get('Blackbody Intensity')):
                radiance = 'MULTIPLY', STEFAN_BOLTZMANN * BLACKBODY_UNIT / math.pi, ('POWER', t, 4)
                emissive = 'ADD', ('MULTIPLY', emissive, strength), ('MULTIPLY', ('MULTIPLY', get('Blackbody Tint'),
                    blackbody(t, node)), ('MULTIPLY', intensity, radiance))
                strength = 1
        # Subsurface scattering as the medium its share transmitted enters: of mean free path the radius by the scale
        # per channel, the color's albedo by Chiang et al.'s inversion, whose slab reflects that color; on closed meshes
        # alone, as an open one, a leaf, would fill the space behind it, and keeps its diffuse
        subsurface = 1 if node.type == 'SUBSURFACE_SCATTERING' else get('Subsurface Weight')
        if nonzero(subsurface) and sealed():
            sss = node.type == 'SUBSURFACE_SCATTERING'
            path = 'MAXIMUM', 1e-4, ('MULTIPLY', get('Radius' if sss else 'Subsurface Radius'),
                get('Scale' if sss else 'Subsurface Scale'))
            root = 'POWER', ('ADD', 9.59217, ('MULTIPLY', albedo, ('ADD', 41.6808, ('MULTIPLY', 17.7126, albedo)))), 0.5
            single = 'SUBTRACT', 1, ('POWER', ('SUBTRACT', ('ADD', 4.09712, ('MULTIPLY', 4.20863, albedo)), root), 2)
            # FlexKernels tints what refracts by the albedo, which the medium's color carries here alone
            transparency, albedo = mix(transparency, 1, subsurface), mix(albedo, 1, subsurface)
            absorption = 'SUBTRACT', 1, ('DIVIDE', ('SUBTRACT', 1, single), path)
            density, scatter = 1, ('DIVIDE', single, path)
        # The specular level scales the reflectance at normal incidence of the share not transmitted, as Cycles'; a
        # tint or level off Blender's defaults marks the tint, the shader compiling both out for scenes marking none
        tint, factor = get('Specular Tint', 1), get('Specular IOR Level', 0.5)
        level = mix(('MULTIPLY', factor, 2), 1, transparency)
        if any(isinstance(x, tuple) or numpy.any(x != y) for x, y in ((tint, 1), (factor, 0.5))):
            tint = 'SPECULAR', tint
        # Blender's sheen over the base by its weight and tint, or the Sheen BSDF's alone, marked where there is one
        sheen = get('Sheen Weight')
        sheen = ('SHEEN', get('Color')) if node.type == 'BSDF_SHEEN' else nonzero(sheen) and ('SHEEN', ('MULTIPLY',
            sheen, get('Sheen Tint', 1))) or 0
        # Its anisotropy, Principled's and the Metallic BSDF's by their aspect, the Glossy BSDF's mapped onto it, the
        # sign swapping the axes, as Cycles maps both; turned about the normal from the tangent, marked where there is one
        principled = node.type == 'BSDF_PRINCIPLED'
        anisotropy = get('Anisotropic' if principled else 'Anisotropy')
        glossy = between(anisotropy, -0.99, 0.99)
        anisotropy = nonzero(anisotropy) and ('ANISOTROPIC', ('DIVIDE', ('MULTIPLY', glossy, ('SUBTRACT', 2,
            absolute(glossy))), -0.9) if node.type == 'BSDF_GLOSSY' else between(anisotropy, 0, 1)) or 0
        # Transmitting and refracting by the share of the energy not metallic, as Cycles' shaders mix it. A volume
        # shader's Alpha is its Draine phase's α, which covers nothing
        alpha = 1 if hasattr(node, 'phase') else get('Alpha', 1)
        value = [get('Normal', ('NORMAL',)), albedo, metallic, roughness,
            ('MULTIPLY', ('MULTIPLY', emissive, strength), alpha), ('MULTIPLY', transparency, ('SUBTRACT', 1,
            metallic)), ('ADD', 1, ('MULTIPLY', ('SUBTRACT', ior, 1), ('SUBTRACT', 1, metallic))),
            tint, level, alpha, absorption, density, scatter,
            ('TRANSLUCENT', get('Color')) if node.type == 'BSDF_TRANSLUCENT' else 0, sheen,
            get('Roughness' if node.type == 'BSDF_SHEEN' else 'Sheen Roughness', 0.5), anisotropy,
            get('Anisotropic Rotation' if principled else 'Rotation'), get('Tangent')]
        # A coat follows as the surface of a clear dielectric covering by its weight, emitting nothing of its own
        weight = get('Coat Weight')
        if nonzero(weight):
            value.append([get('Coat Normal'), get('Coat Tint'), 0, get('Coat Roughness'), 0, 1, get('Coat IOR'), 1, 1,
                ('MULTIPLY', weight, alpha)])
    if hasattr(output, 'default_value') and animated(output): value = 'ANIMATED', value  # As of a value node
    if socket.type == 'VALUE' and output.type in WEIGHTS: return 'DOT_PRODUCT', value, WEIGHTS[output.type]
    if socket.type == 'SHADER' and not isinstance(value, list): value = [*BLACK[:4], value, *BLACK[5:]]  # Emits it
    return value

def closed(ob, mesh):  # Whether the object is a closed mesh, each edge shared by two faces
    if ob.type != 'MESH': return False
    edges = numpy.empty(len(mesh.loops), 'i')
    mesh.loops.foreach_get('edge_index', edges)
    return bool(numpy.all(numpy.bincount(edges, minlength=len(mesh.edges)) == 2))
# Of the object whose material shade() resolves: whether it is closed, and whether its subsurface scattering asked
SEALING = {'closed': True, 'asked': False}
STEFAN_BOLTZMANN = 5.670374419e-8  # W / (m^2 K^4), CODATA 2018
BLACKBODY_UNIT = 1e-6  # Blender's unit scale of a volume's Blackbody Intensity 1
MEDIA = {}  # Of each material shade() resolved, its volume's absorption, density, scattering color and emission
SIDE = {'volume': False}  # Whether resolve() resolves a material's Volume socket, where volume shaders emit
def sealed():
    SEALING['asked'] = True
    return SEALING['closed']

# The material's surface as rows, one per layer from the top: the row of its surface, filled by its volume, under that
# of a coat emitting in its place; black without an output; passing rays straight through without a surface shader
def shade(material, program):
    output = material.node_tree.get_output_node('CYCLES')
    if not output: return [program(BLACK)]
    surface = resolve(output.inputs['Surface'])  # Its volume, or the medium its subsurface scattering fills
    SIDE['volume'] = True
    filled = resolve(output.inputs['Volume']) if output.inputs['Volume'].is_linked else None
    SIDE['volume'] = False
    volume, glow = (filled[10:13], filled[4]) if filled else (surface[10:13], 0)
    MEDIA[material] = *volume, glow
    if output.inputs['Displacement'].is_linked:  # Onto the normal alone, displacing only as well, as Flex moves no
        height = 'DOT_PRODUCT', resolve(output.inputs['Displacement']), ('NORMAL',)  # geometry: a Bump of the height
        surface = moved_to(surface, ('BUMP', ('NORMAL',), height, *(('SHIFTED', ('SHIFT', k), height) for k in (1, 2)),
            vector(1, 1, 0)), {}, 'NORMAL')  # along it, where the surface reads the normal
    if output.inputs['Volume'].is_linked and not output.inputs['Surface'].is_linked:
        surface = [*BLACK[:9], 0, *BLACK[10:]]
    layers = [surface[:10]] if len(surface) == 19 else [[*surface[19][:4], surface[4], *surface[19][5:]],
        [*surface[:4], 0, *surface[5:10]]]
    # FlexLight's BSDF transmits apart from metallic reflection: its transmission is the share transmitted of the share
    # not metallic, its ior that of the share not metallic
    base = layers[-1]
    metallic, share = base[2], base[5]
    base[5] = 'DIVIDE', share, ('SUBTRACT', 1, metallic)
    base[6] = 'ADD', 1, ('DIVIDE', ('SUBTRACT', base[6], 1), ('SUBTRACT', 1, metallic))
    # The base layer transmits the surface's translucent color diffusely and carries its sheen and anisotropy, a coat
    # over it none; each filled by its volume's emission
    attributes = [[*layer, *volume, *(surface[13:19] if layer is base else (0, 0, 0.5, 0, 0, 0)), glow]
        for layer in layers]
    # Each layer cut first, so the bakes the cuts make come before the rows, whose layers follow each other
    cut = [program(attribute, emitted=False) for attribute in attributes]
    rows = [program(surface, attribute, cut=False) for surface, attribute in zip(cut, attributes)]
    # Light sampling reads the emission alone: the top layer's, its colors associated as in that layer's program
    return [(*rows[0], program([*BLACK[:4], layers[0][4], *BLACK[5:]], [*layers[0], *volume])[1]), *rows[1:]]

def disk(bm, sides, x, y, z):  # Polygon at height z around the ellipse with diameters x, y
    bmesh.ops.create_circle(bm, cap_ends=True, segments=sides, radius=0.5 / math.cos(math.pi / sides),
        matrix=Matrix.Translation((0, 0, z)) @ Matrix.Diagonal((x, y, 1, 1)) @ Matrix.Rotation(math.pi / sides, 4, 'Z'))

BACKENDS = (('OPTIX', ''), ('VULKAN', '-vulkan'))  # The renderer of each, by the suffix of its binary
runnable = ()  # The backends whose renderer starts on this machine, which register finds
def device(): return bpy.context.preferences.addons[__package__].preferences.device

# Whether the point lies in the closed mesh of the BVH: a ray up from it crosses it an odd number of times, stepping a
# float's precision past each crossing
def inside(tree, point):
    crossings = 0
    while (hit := tree.ray_cast(point, (0, 0, 1)))[0] is not None:
        crossings, point = crossings + 1, hit[0] + Vector((0, 0, 1e-5 + 1e-6 * abs(hit[0].z)))
    return crossings % 2 == 1

# The scene's settings of the renderer, in its order, which denoises on OptiX alone; the viewport denoises every result
def settings(scene, viewport, device):
    return scene.flex_restir, scene.flex_decorrelation, scene.flex_neighbors, scene.flex_bounces, scene.flex_paths, \
        scene.flex_denoise * (1 + viewport) * (device == 'OPTIX')

# The scene's samples of a view and of one reusing the last one's reservoirs, then the distance and the cosine of the
# angle its camera moves and turns at most from the last one's to reuse them and continue its denoised sequence; a view
# following none jumps
def sampling(scene, follows):
    reuse = scene.flex_restir and scene.flex_reuse
    return scene.flex_samples, scene.flex_reuse_samples if reuse else scene.flex_samples, \
        scene.flex_jump_distance if follows else -1, math.cos(scene.flex_jump_angle)

def lens(camera):  # Cycles' thin lens: radius in scene units, focus depth, blades, rotation and anamorphic ratio
    if camera is None or camera.type != 'CAMERA' or camera.data.type != 'PERSP' or not camera.data.dof.use_dof:
        return 0, 0, 0, 0, 1
    dof = camera.data.dof
    distance = dof.focus_distance
    target = dof.focus_object
    if target:
        matrix = target.matrix_world
        bone = target.pose and target.pose.bones.get(dof.focus_subtarget)
        if bone: matrix = matrix @ bone.matrix
        distance = abs((camera.matrix_world.normalized().inverted() @ matrix).translation.z)
    return camera.data.lens * 1e-3 / (2 * max(dof.aperture_fstop, 1e-5)), max(distance, 1e-5), \
        dof.aperture_blades if dof.aperture_blades >= 3 else 0, dof.aperture_rotation, dof.aperture_ratio

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'
    bl_use_shading_nodes_custom = False  # The Shader Editor offers Blender's shading nodes, which the engine resolves

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.visible = ()  # Names of the instances the renderer was last started on
        self.slots = {}  # First triangle, triangle count and key of each instance exported, by its index
        self.varying = set()  # Of those, the ones whose volume varies: their bounds, made where they are, made anew
        self.volumes = {}  # Of each instance exported filling a volume, by its index: its triangles' BVH in the world and
        # its first triangle of a material filling it
        self.shape = None  # Of the scene last piped: its steps' codes, rows' programs, opacity and emission, textures
        self.cuts, self.placed, self.piped = {}, [], 0  # Of the scene last piped: what each row was cut over, each
        # unit's place (first texel of tiles, key, texture, program's hint and steps, value); texels piped before bakes
        self.texture = None  # The viewport's view as last traced
        self.memory = (0, 0)  # Renderer allocations: used and peak in MiB
        self.following = None  # The frame after the last one rendered, which reuses its reservoirs in an animation
        self.shared = open(os.memfd_create('flex'), 'rb', 0)  # In memory file the renderer leaves its sums in
        self.spawn()

    # The engine keeps only the renderer's pipes, taken off the Popen, which Python keeps alive while its process runs:
    # once the engine drops them, the renderer reads the end of its input and exits.
    def spawn(self):
        self.device = device()  # That of the renderer, which the preference may change since
        process = subprocess.Popen((BINARY + '-vulkan' * (self.device == 'VULKAN'), str(self.shared.fileno()),
            str(os.getpid())) + ('headless',) * bpy.app.background,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, pass_fds=(self.shared.fileno(),))
        self.requests = process.stdin
        self.answers = process.stdout
        process.stdin = process.stdout = None

    # Starts the renderer on the exported scene when what it renders changed. Blender also reports selection, scene
    # settings and cameras, which need none. Objects that only moved or deformed update their triangles in place, as
    # FlexLight updates the slots of its instances, while they keep their count and the key of their materials: camera
    # visibility, those of their slots and a light's radiance, and its axes if it shapes its light by them.
    def start(self, depsgraph):
        visible = [instance.object.name for instance in depsgraph.object_instances]
        trees = (*bpy.data.node_groups, *(material.node_tree for material in (*bpy.data.materials, *bpy.data.worlds)))
        references = {node.object.name for tree in trees if tree for node in tree.nodes
            if node.type == 'TEX_COORD' and node.object}
        changed = {update.id.name for update in depsgraph.updates}
        same = visible == self.visible and not references & changed
        if same and all(isinstance(update.id, (bpy.types.Scene, bpy.types.Camera))
                or getattr(update.id, 'type', '') == 'CAMERA' for update in depsgraph.updates): return
        moved = same and all(isinstance(update.id, (bpy.types.Scene, bpy.types.Camera, bpy.types.Object,
            bpy.types.Action)) for update in depsgraph.updates) and changed
        # Materials' values alone changed, as an animated one's by frame: the steps go anew, while they keep their shape
        shaded = same and self.shape and len(depsgraph.updates) and not moved and all(not (update.is_updated_geometry
            or update.is_updated_transform or isinstance(update.id, bpy.types.Image)) for update in depsgraph.updates)
        self.visible = visible
        scene = depsgraph.scene_eval
        # Per object, after none for a scene without triangles, in the renderer's order: vertices, normals, texture
        # coordinates (the points in the mesh's texture space), object coordinates (the points in the object's space),
        # UVs, colors of the render color attributes (zero without, as Cycles' missing ones), MikkTSpace tangents and
        # their handedness in object space, and per triangle its material's pass index: once per object's mesh and
        # materials of all its instances, its vertices and normals in object space but of a light's or under an update
        columns = [[numpy.empty((0, *shape), 'f')] for shape in (*[(3, 3)] * 4, (3, 2), (3, 4), (3, 4), ())]
        materials, entries, instances = [], {}, []  # A row per triangle of each mesh, as each object's mesh by its key
        # (its first triangle, count and whether in world space), and per instance its mesh, transform and adjugate and
        # its object's location, color, pass index, random number and axes, as Cycles' object info node tells
        def record(i, instance, ob, entry, light=False, media=((0,) * 6, 0)):  # An instance exported, of the object's
            # mesh entry, and of one filling a volume its texture space and largest extinction, 0 unless it varies
            # Cycles' random number of an object, not instanced, by Jenkins' hash of its name's
            random = instance.random_id / 0xFFFFFFFF if instance.is_instance else hashed(functools.reduce(
                lambda h, c: (h * 37 + c) & 0xFFFFFFFF, ob.name.encode(), 0), 0)
            matrix = instance.matrix_world
            instances.append((*entry, numpy.concatenate((numpy.array(matrix, 'f')[:3].ravel(),
                numpy.array(matrix.to_3x3().adjugated(), 'f').ravel(), [*matrix.translation, *ob.color,
                ob.pass_index, 0, random, *numpy.array(matrix.to_3x3()).T.ravel()],
                numpy.array([attributed(instance)], 'u4').view('f'), numpy.array((*media[0], media[1]), 'f')),
                dtype='f')))
            slots.append((i, entry[1], (ob.visible_camera, [slot.material and slot.material.name
                for slot in ob.material_slots], light)))
        ops, hints = [], {}  # Steps of all programs; the light power hint of each by its first
        aside, tilings = ([], {}), {}  # The bakes' steps and hints, apart, which the renderer frees once baked; tiles
        textures = dict(self.shape[2]) if shaded else {}  # First texel, width, height and mean per image and ramp
        texels = [numpy.ones(4, 'f')]  # Linear floats after a white texel: the renderer loads no empty array
        # Instancer attributes the materials read by name, each instance's float4 of each after a row of zeros for those
        # without: its info names its first
        IDS.clear()
        INSTANCER.clear(), INSTANCER.update((name, k) for k, name in enumerate(sorted({node.attribute_name for tree in
            trees if tree for node in tree.nodes if node.type == 'ATTRIBUTE' and node.attribute_type == 'INSTANCER'})))
        attributes = [numpy.zeros(4 * len(INSTANCER), 'f')]
        def attributed(instance):  # The first of its instancer attributes, the zeros' without
            values = instance.is_instance and INSTANCER and instancer(instance).ravel()
            return values is not False and len(values) and values.any() and (attributes.append(values)
                or len(attributes) - 1) * len(INSTANCER) or 0
        derived = set()  # Images a Bump differentiates, kept floats
        baked, bakes, units, summaries, placed, again = [0], [], {}, {}, [], []  # Texels baked after those piped, each
        # bake's program, each unit's texture, what each expression of the surface the cut takes is as a unit, each
        # unit's place, and the bakes to run again. A unit's texture's steps, and the end before its program with its
        # first texel and size, count from the baked texels, as halves two to a texel, flagged in their height's bit 28.
        images, keys = {None: None if shaded else (textures, texels)}, {}  # Images units over UVs read; parts' keys, a
        # memo of expression_key's for the export, holding its parts as it does, its keys made one with the last's
        current = {}  # Of the object whose materials are shaded: the triangles of the material, their UVs, the scales
        # of its point inputs along them if they lie in [0, 1] without overlap, the bakes made over them
        places = self.placed if shaded else []  # The last export's units, which an update of values keeps in place
        for place in places: interned(place[1][1], keys)  # So a unit kept compares its key in its arity
        def bake(expression, memo=None):  # Each part once per outermost call, as the recursions above
            memo = {} if memo is None else memo
            if id(expression) not in memo: memo[id(expression)] = baking(expression, memo)
            return memo[id(expression)]
        def baking(expression, memo):  # A unit of math, ramps, noise and linear reads on the point inputs, costing two
            # reads, baked up to 4K and read at the UV: of generated points without reads over its object's UVs, as
            # fine as its frequencies need; of the UV alone over UV space as uv_domain() plans it, once for every object
            # where it repeats with the UV. Never affine in one image's read: it would only bake that texture again
            nonlocal ops, hints
            reads, affine, cost, inputs, need = summaries[id(expression)] if isinstance(expression, tuple) \
                else (set(), False, None, set(), 0)
            uvs = current.get('uv', numpy.empty((0, 3, 2))).reshape(-1, 2)
            # An image's read is never one, but a ramp's or curves' lookup, a read of its table, is a step as others
            unit = isinstance(expression, tuple) and expression[0] != 'UNASSOCIATE' and not (expression[0] in READS
                and isinstance(expression[-1], ImageRead)) and not (affine and len(reads) == 1) and (cost or 0) >= 10 \
                and current.get('scales')
            domain = unit and inputs == {'UV'} and len(uvs) > 0 and uv_domain(expression, uvs, need, images, keys)
            size = numpy.array(domain[2]) if domain else numpy.full(2, int(-(-max(64, round(need, 6)) // 16) * 16)) \
                if unit and 'GENERATED' in (current.get('scales') or ()) and not reads and inputs and need else None
            if size is None or (size > 4096).any():
                if isinstance(expression, tuple) and expression[0] == 'BUMP': return bumped(*expression[1:], memo)
                if memo.get('whole'): return expression  # Baked whole or not at all
                if not isinstance(expression, tuple) or summaries[id(expression)][1] is None and len(
                        summaries[id(expression)][0]) == 1:  # Inexact on one image, live whole: baked parts add fetches
                    return expression  # Else as its operands are, but the alpha read an unassociation divides by
                return (expression[0], *(bake(part, memo) for part in expression[1:])) \
                    if expression[0] != 'UNASSOCIATE' else (expression[0], bake(expression[1], memo), expression[2])
            point = ('DIVIDE', ('SUBTRACT', ('UV',), domain[0]), domain[1]) if domain else ('UV',)
            if (key := (None if domain and domain[3] else tuple(numpy.r_[domain[0], domain[1]]) if domain else int(
                    current['triangles'][0]), expression_key(expression, keys))) in units:  # Baked over the same UVs,
                current['made'] += [units[key]] * (key[0] is not None)  # its row the object's own unless repeating
                return 'BAKED', point, units[key]
            t = current['uv'][:0 if domain else None] * size[0]  # Over UV space none: the bake pass takes every texel
            low, high = (numpy.clip((f(1) + d) // 16, 0, size[0] // 16 - 1).astype(int) for f, d in ((t.min, -1),
                (t.max, 1)))  # The 16 x 16 tiles of texels each triangle's UVs reach, a texel off its edges included
            n = (high - low + 1).prod(1)
            k, j = numpy.arange(n.sum()) - numpy.repeat(n.cumsum() - n, n), numpy.repeat(numpy.arange(len(n)), n)
            width = high[j, 0] - low[j, 0] + 1
            tiles = numpy.stack((current['triangles'][j], low[j, 0] + k % width, low[j, 1] + k // width, 0 * j), 1)
            if domain:  # Over UV space the texels' own UVs, the bake pass baking texel by texel
                expression = moved_to(expression, ('ADD', ('MULTIPLY', ('UV',), domain[1]), domain[0]), {})
            # In an update of values the last export's unit, its steps and value again unless its expression changed;
            # its steps and hint among the bakes'
            (ops, hints), outer = aside, (ops, hints)
            tile, last, units[key], steps, value = places[len(bakes)] if len(bakes) < len(places) else (
                sum(map(len, texels)) // 4, None, Bake(), None, None)
            ops.append((0, tile, len(tiles), 0))
            tilings[tile] = tiles.astype('u4').view('f').ravel()  # Its own, though another's empty list starts there
            texels.append(tilings[tile])
            ops.append((0, baked[0], size[0], size[1] | 1 << 28))
            if last == key:
                hints[len(ops)] = steps[0]
                bakes.append(len(ops))
                ops.extend(steps[1])
            else:
                bakes.append(program([GRAY[0], expression, *GRAY[2:]], cut=False)[1])
                value = numpy.resize(emit(expression, [], textures, texels, set(), {}), 3)
                if last: again.append(bakes[-1])
            placed.append((tile, key, units[key], (hints[bakes[-1]], ops[bakes[-1]:]), value))
            current['made'].append(bakes[-1])
            textures[units[key]] = (baked[0], size[0], size[1] | 1 << 28 | bool(domain and domain[3]) << 29,
                numpy.array((*value, 1)))
            baked[0] += -(-size.prod() // 2)
            ops, hints = outer
            return 'BAKED', point, units[key]
        # A Bump's heights as its height's gradient along its one point input, baked whole, at its shifted points, its
        # height at its own point no matter; where no gradient bakes, its height baked on its images' lattice, else all
        def bumped(normal, height, first, second, factors, memo):  # live, as a bake's texels differ none between points
            # a bump shifts by less than one
            inputs = isinstance(height, tuple) and summaries[id(height)][2] is not None and summaries[id(height)][3]
            if inputs and len(inputs) == 1 and (point := next(iter(inputs))) in (current.get('scales') or ()):
                scales = {**current['scales'], 'BUMP': 1}  # Central differences a quarter texel apart
                step = scales[point] / 4 / max(64, summarize(height, {}, scales)[4])
                shifted = lambda d: moved_to(height, ('ADD', (point,), d), {}, point)
                gradient = fold(vector(*(('DIVIDE', ('SUBTRACT', shifted(e * step), shifted(-e * step)), 2 * step)
                    if k < 2 or point != 'UV' else 0 for k, e in enumerate(numpy.eye(3)))))
                summarize(gradient, summaries, scales)
                if (read := bake(gradient, {'whole': True}))[0] == 'BAKED':
                    return 'BUMP', bake(normal, memo), 0, *(('DOT_PRODUCT', read, ('SUBTRACT', ('SHIFTED', ('SHIFT',
                        k), (point,)), (point,))) for k in (1, 2)), bake(factors, memo)
            seen = {}  # Of images alone, its texels' own gradient as live has it: the height baked on their lattice
            noisy = lambda e: isinstance(e, tuple) and (seen[id(e)] if id(e) in seen else seen.setdefault(id(e), e[0] ==
                'NOISE' or any(map(noisy, e[1:]))))
            if isinstance(height, tuple) and summaries[id(height)][0] and not noisy(height):
                return 'BUMP', *(bake(part, memo) for part in (normal, height, first, second, factors))
            return 'BUMP', bake(normal, memo), height, first, second, bake(factors, memo)
        # Counted, then emitted keeping what it uses again, its colors associated as in the surface reads, its units
        def program(surface, reads=None, cut=not moved, emitted=True):  # baked, but in an update of moves: its bakes
            # the last's; with emitted false only cut
            surface, alpha, uses, slots, keyed = fold(surface), set(alpha_reads(reads or surface)), {}, {}, {}
            derived.update(differentiated(surface))
            seen, table = set(), {}  # Reads of attributes shading isn't linear in, or that aren't affine in their reads
            for k, attribute in enumerate(surface):
                if k % len(GRAY) in UNFILTERED or summarize(attribute, table, None)[1] is None:
                    unfiltered(attribute, seen)
            if cut:  # Its expressions as units, all, then its units cut
                summaries.clear()
                for attribute in surface: summarize(attribute, summaries, current.get('scales'))
                surface = [bake(attribute) for attribute in surface]
            if not emitted: return surface
            surface, first = fold(unanimated(surface)), len(ops)
            # Its translucent color, sheen and anisotropy only marked: scenes without them run main's programs, the
            # shader compiling them out
            if len(surface) == 20 and not nonzero(surface[19]): surface = surface[:19]  # Its volume's emission too
            if len(surface) == 19 and not marks(surface[16], 'ANISOTROPIC'): surface = surface[:16]
            if len(surface) == 16 and not marks(surface[14], 'SHEEN'): surface = surface[:14]
            if len(surface) == 14 and not marks(surface[13], 'TRANSLUCENT'): surface = surface[:13]
            emit(surface, [], textures, texels, alpha, uses, keys=keyed)
            store, load = [*OPS].index('STORE'), [*OPS].index('LOAD')
            # Each value kept for reuse takes the lowest slot free from its store to its last load, as the steps run
            # straight through, so a program needs only as many slots as it keeps values at once; while that is more
            # than SLOTS, the value kept longest of those live at the most crowded step is computed again where read
            while True:
                del ops[first:]
                slots.clear()
                emitted = emit(surface, ops, textures, texels, alpha, uses, slots, keys=keyed)
                last, taken, renamed = {op[1]: k for k, op in enumerate(ops[first:], first) if op[0] == load}, set(), {}
                stored, crowded = {}, set()
                for k in range(first, len(ops)):
                    code, slot = ops[k][:2]
                    if code == store: renamed[slot] = min(set(range(len(taken) + 1)) - taken); taken.add(renamed[slot])
                    if code == store: stored[slot] = k
                    if len(taken) > len(crowded): crowded = {s for s in stored if last[s] >= k}
                    if code in (store, load): ops[k] = (code, renamed[slot], 0, 0)
                    if code == load and last[slot] == k: taken.discard(renamed[slot])
                if len(crowded) <= SLOTS: break
                spilled = max(crowded, key=lambda s: last[s] - stored[s])
                uses[next(key for key, slot in slots.items() if slot == spilled)][0] = 1
            # Opaque where it covers and passes nothing whatever the point: coverage 1, and ior not 1 or transparency 0
            scalar = lambda k: None if isinstance(surface[k], tuple) else numpy.float32(numpy.resize(surface[k], 3)[0])
            opaque = scalar(9) == 1 and (scalar(6) not in (None, 1) or scalar(5) == 0)
            hints[first] = max(emitted, 1e-6 if isinstance(surface[4], tuple) else 0)
            return hints[first], first, opaque
        rows = {None: [program(GRAY)]}  # Rows of the surface each material renders; an empty slot renders gray
        subsurface = set()  # Materials whose subsurface scattering asked for their object's closedness: on open objects
        variant = lambda material: (material, None) if material in subsurface and not SEALING['closed'] else material
        def shaded_row(material):  # Its row, apart for the open objects of a material with subsurface scattering
            SEALING['asked'] = False
            row = shade(material, program)
            if SEALING['asked']: subsurface.add(material)
            return row
        slots, volumes = [], {}  # Index, triangle count and key of each instance exported; BVHs of those filling volumes
        varying = set()  # Those whose volume varies, bounded inside where they are: moved, exported anew
        cuts = {}  # What each material of each object was cut over
        members = functools.cache(lambda collection: {name for ob in collection.all_objects for name in (ob.name, *(
            members(ob.instance_collection) if ob.instance_type == 'COLLECTION' and ob.instance_collection else ()))})
        points, segments, hairs, bounds = [numpy.empty((0, 4), 'f')], [], [], []  # Strands: their points in their
        # object's space and radius; per segment its first point and strand, material and bounds
        for i, instance in enumerate(depsgraph.object_instances):
            ob = instance.object
            bm = bmesh.new()
            # Hidden from renders as Blender's are: an object by its setting, though particles' and geometry nodes'
            # instances of it are kept, nested in collection instances too, whose members it isn't; an instancer of
            # particles, vertices or faces unless shown in renders; and the children a vertex or face instancer
            # instances, but as its instances. A curve's, text's, surface's or metaball's own entry: the mesh it
            # evaluates to follows as an instance
            if ob.hide_render and not (instance.is_instance and instance.parent.instance_type not in ('VERTS', 'FACES')
                and not (instance.parent.instance_type == 'COLLECTION' and ob.name in members(
                instance.parent.instance_collection))) or not (instance.is_instance or ob.show_instancer_for_render) \
                and (ob.particle_systems or ob.instance_type in ('VERTS', 'FACES')) or not instance.is_instance \
                and ob.parent and ob.parent.instance_type in ('VERTS', 'FACES') or ob.type not in {'MESH', 'LIGHT'} \
                or moved and ob.name not in moved and not (instance.is_instance and instance.parent.name in moved):
                continue
            if shaded and ob.type != 'LIGHT':  # Its rows alone, cut over its UVs as the last export's
                SEALING['closed'] = closed(ob, ob.data)
                for slot in ob.material_slots:  # Of those the last export cut, not its linked duplicates'
                    if variant(slot.material) in rows or (slot.material, ob.name) in rows \
                        or (slot.material, ob.name) not in self.cuts: continue
                    current.update(self.cuts[(slot.material, ob.name)], made=[])
                    row = shaded_row(slot.material)
                    rows[(slot.material, ob.name) if current['made'] else variant(slot.material)] = row
                current.clear()
                continue
            key = ob.type != 'LIGHT' and not moved and (ob.data and ob.data.as_pointer(), ob.visible_camera,
                tuple(slot.material for slot in ob.material_slots))
            if key in entries:  # Another instance of a mesh, or another object linking it, with the same materials:
                # its mesh and materials piped once
                record(i, instance, ob, entries[key])
                continue
            if ob.type != 'LIGHT':  # Per corner of its triangles: index, vertex, normal (smooth, sharp or custom), UV
                mesh = ob.to_mesh()
                sealing = closed(ob, mesh)  # Read while the evaluated mesh lives
                # Generated coordinates of the undeformed mesh, through the orco layer Cycles reads, which the mesh
                # loses when triangulated; of a mesh its modifiers only deform, the same vertices in the same order,
                # its original's, which a depsgraph evaluated for no render, as the viewport's first, holds no such layer
                # of; of others, which make vertices of their own, that layer, if any
                rest = ob.original.data if ob.original.type == 'MESH' and len(ob.original.data.vertices) \
                    == len(mesh.vertices) else mesh
                orco = numpy.empty(3 * len(mesh.vertices), 'f')
                rest.vertices.foreach_get('co' if rest is not mesh else 'undeformed_co', orco)
                orco = (orco.reshape(-1, 3) - rest.texspace_location) / (2 * numpy.array(rest.texspace_size)) + 0.5
                space = numpy.array(rest.texspace_location), numpy.array(rest.texspace_size)  # Read while it lives
                totals = numpy.empty(len(mesh.polygons), 'i')  # Corners per face, read at once
                mesh.polygons.foreach_get('loop_total', totals)
                if (totals > 4).any():
                    bm.from_mesh(mesh)
                    # By the mesh's own fill, which Cycles triangulates n-gons by, without BMesh's beautify
                    bmesh.ops.triangulate(bm, faces=[face for face in bm.faces if len(face.verts) > 4],
                        ngon_method='EAR_CLIP')
                    bm.to_mesh(mesh)
                loops, index = (numpy.empty(n * len(mesh.loop_triangles), 'i') for n in (3, 1))
                co, vertex = numpy.empty(3 * len(mesh.vertices), 'f'), numpy.empty(len(mesh.loops), 'i')
                normal, uv = numpy.empty(3 * len(mesh.loops), 'f'), numpy.zeros(2 * len(mesh.loops), 'f')
                mesh.loop_triangles.foreach_get('loops', loops)
                mesh.loop_triangles.foreach_get('material_index', index)
                mesh.vertices.foreach_get('co', co)
                mesh.loops.foreach_get('vertex_index', vertex)
                mesh.corner_normals.foreach_get('vector', normal)
                render = next((layer for layer in mesh.uv_layers if layer.active_render), None)  # As Cycles renders
                if render: render.uv.foreach_get('vector', uv)
                else:  # Cycles makes default tangents from spherical coordinates of the mesh's positions
                    p = co.reshape(-1, 3)[vertex]
                    lengths = numpy.linalg.norm(p, axis=1)
                    sphere = numpy.column_stack((numpy.where(numpy.any(p[:, :2], axis=1),
                        0.5 - numpy.arctan2(p[:, 0], p[:, 1]) / (2 * math.pi), 0), numpy.where(lengths > 0,
                        1 - numpy.arccos(numpy.clip(p[:, 2] / numpy.maximum(lengths, 1e-30), -1, 1)) / math.pi, 0)))
                    (render := mesh.uv_layers.new()).uv.foreach_set('vector', sphere.ravel())
                if mesh.polygons:  # Of faces, which curves without a bevel have none of, along the UVs exported
                    mesh.calc_tangents(uvmap=render.name)
                tangent, sign = numpy.empty(3 * len(mesh.loops), 'f'), numpy.empty(len(mesh.loops), 'f')
                mesh.loops.foreach_get('tangent', tangent)
                mesh.loops.foreach_get('bitangent_sign', sign)
                tangent = numpy.column_stack((tangent.reshape(-1, 3), sign))[loops].reshape(-1, 3, 4)
                color = numpy.zeros((len(mesh.loops), 4), 'f')
                if (layer := mesh.color_attributes.render_color_index) >= 0:
                    attribute = mesh.color_attributes[layer]
                    values = numpy.empty((len(attribute.data), 4), 'f')
                    attribute.data.foreach_get('color', values.ravel())
                    color = values[vertex] if attribute.domain == 'POINT' else values
                ob.to_mesh_clear()
                positions = transformed(co.reshape(-1, 3)[vertex[loops]], instance.matrix_world).reshape(-1, 3, 3)
                if (filled := numpy.flatnonzero(numpy.isin(index, [k for k, slot in enumerate(ob.material_slots)
                        if slot.material and (output := slot.material.node_tree.get_output_node('CYCLES'))
                        and output.inputs['Volume'].is_linked]))).size:
                    volumes[i] = BVHTree.FromPolygons(positions.reshape(-1, 3).tolist(),
                        numpy.arange(3 * len(positions)).reshape(-1, 3).tolist()), int(filled[0])
                normals = turned(normal.reshape(-1, 3)[loops], instance.matrix_world)
                uv = uv.reshape(-1, 2)[loops].reshape(-1, 3, 2)
                orco = orco[vertex[loops]].reshape(-1, 3, 3)
                point = co.reshape(-1, 3)[vertex[loops]].reshape(-1, 3, 3)
                color = color[loops].reshape(-1, 3, 4)
                SEALING['closed'] = sealing
                for slot in ob.material_slots:  # Of a material with units baked over this object's UVs, its own row
                    if variant(slot.material) in rows or (slot.material, ob.name) in rows: continue
                    mask = numpy.isin(index, [k for k, other in enumerate(ob.material_slots)
                        if other.material == slot.material])
                    t = uv[mask]
                    flat = numpy.abs((t[:, 1, 0] - t[:, 0, 0]) * (t[:, 2, 1] - t[:, 0, 1]) - (t[:, 1, 1] - t[:, 0, 1])
                        * (t[:, 2, 0] - t[:, 0, 0])).sum() / 2
                    current.update(triangles=sum(slot[1] for slot in slots) + numpy.nonzero(mask)[0], uv=t, made=[],
                        scales=not trivial(slot.material) and {'UV': 1, **(not moved and 0 < flat <= 1 and 0 <= t.min()
                        and t.max() <= 1 and {'GENERATED': stretch(orco[mask], t)} or {})})
                    cuts[(slot.material, ob.name)] = dict(current)
                    row = shaded_row(slot.material)
                    rows[(slot.material, ob.name) if current['made'] else variant(slot.material)] = row
                current.clear()
                shades = [rows.get((slot.material, ob.name), rows.get(variant(slot.material)))
                    for slot in ob.material_slots] or [rows[None]]
            # Emitter faces use material 0, black faces shaping the light material 1; lights shine down -z.
            if ob.type == 'LIGHT':
                light = ob.data
                radius = max(light.shadow_soft_size, 0.01)
                if light.type == 'AREA':  # Back side
                    sides = 4 if light.shape in {'SQUARE', 'RECTANGLE'} else 32
                    size = light.size, light.size_y if light.shape in {'RECTANGLE', 'ELLIPSE'} else light.size
                    disk(bm, sides, *size, 1e-3)
                for face in bm.faces: face.material_index = 1
                if light.type == 'AREA': disk(bm, sides, *size, 0)
                elif light.type == 'SUN':
                    disk(bm, 32, *2 * [2 * SUN_DISTANCE * math.tan(max(light.angle, SUN_MIN_ANGLE) / 2)], SUN_DISTANCE)
                else: bmesh.ops.create_icosphere(bm, subdivisions=3, radius=radius)
            bmesh.ops.triangulate(bm, faces=bm.faces[:])
            bm.transform(instance.matrix_world)
            bm.normal_update()  # Of the faces of lights, which have no corner normals
            if ob.type == 'LIGHT':
                area = sum(face.calc_area() for face in bm.faces if not face.material_index)
                # Sun irradiance, else watts, by the exposure; unless normalized, by Cycles' area of the light as well:
                # a sphere's, 4 of a point; a sun's of its angle, 1 of a parallel one; the area light's
                radiance = light.energy * 2 ** light.exposure \
                    * (SUN_DISTANCE ** 2 if light.type == 'SUN' else 1 / math.pi) / area
                if not light.normalize:
                    radiance *= area if light.type == 'AREA' else (math.pi * math.sin(light.angle / 2) ** 2 or 1) \
                        if light.type == 'SUN' else 4 * math.pi * light.shadow_soft_size ** 2 or 4
                emission = radiance * numpy.array(light.color) \
                    * (numpy.array(light.temperature_color) if light.use_temperature else 1)
                shaped = 1
                # Spot cone and area spread on the direction emitted, as Cycles'; the lights pass, shading no ray, takes
                # the unshaped power, a bound for the cone and exact for the spread, whose mean over the hemisphere is 1
                if light.type == 'SPOT':
                    local = vector(*(('DOT_PRODUCT', ('INCOMING',), numpy.array(row))
                        for row in instance.matrix_world.inverted().to_3x3()))
                    cosine, edge = ('DOT_PRODUCT', normalize(local), -numpy.eye(3)[2]), math.cos(light.spot_size / 2)
                    shaped = 'LESS_THAN', edge, cosine
                    if light.spot_blend:
                        t = clamp(('MULTIPLY', ('SUBTRACT', cosine, edge), 1 / ((1 - edge) * light.spot_blend)))
                        shaped = 'MULTIPLY', ('MULTIPLY', t, t), ('SUBTRACT', 3, ('MULTIPLY', t, 2))
                if light.type == 'AREA' and light.spread < math.pi:
                    half = (light.spread or SPREAD_ZERO) / 2
                    normal = -numpy.array(instance.matrix_world.to_3x3().col[2].normalized())
                    cosine = 'DOT_PRODUCT', ('INCOMING',), normal
                    tangent = 'DIVIDE', length(('CROSS_PRODUCT', ('INCOMING',), normal)), cosine
                    # None behind the light or along its plane, where the tangent turns negative
                    shaped = 'MULTIPLY', ('MAXIMUM', ('MULTIPLY', ('SUBTRACT', math.tan(half), tangent),
                        1 / (math.tan(half) - half) if half > 0.05 else 3 / half ** 3), 0), ('LESS_THAN', 0, cosine)
                if isinstance(shaped, tuple):
                    emission = 'MULTIPLY', emission, mix(1, shaped, ('LESS_THAN', 0, ('LIGHT_PATH', 8)))
                # Black reflects nothing
                shades = [[program([*BLACK[:4], emission, *BLACK[5:]])], [program(BLACK)]]
                positions = numpy.array([[vertex.co for vertex in face.verts] for face in bm.faces], 'f')
                normals = numpy.array([[face.normal] * 3 for face in bm.faces], 'f')
                uv, orco, point, color, tangent = (numpy.zeros((len(bm.faces), 3, n), 'f') for n in (2, 3, 3, 4, 4))
                index = numpy.array([face.material_index for face in bm.faces], 'i')
            passes = numpy.array([slot.material and slot.material.pass_index or 0 for slot in ob.material_slots] or [0])
            world = ob.type == 'LIGHT' or i in volumes  # In world space: a light or filling a volume, kept apart
            entry = (sum(map(len, columns[0])), len(index), world)
            # Triangles, normals turned as the faces turn (by the renderer for those in object space), a material of its
            # row each
            for column, array in zip(columns, (positions if world else point, (normals if world else
                normal.reshape(-1, 3)[loops]).reshape(-1, 3, 3), orco, point, uv, color, tangent,
                passes[numpy.minimum(index, len(passes) - 1)])): column.append(array)
            table = numpy.array([(*row[0][:2], not ob.visible_camera, len(row), any(layer[2] for layer in row),
                row[0][3] if len(row[0]) > 3 else row[0][1]) for row in shades])
            materials.append(table[index])
            if key and not world: entries[key] = entry  # Not under an update, which pipes each mesh moved
            media = ((0,) * 6, 0)
            if i in volumes:  # Its volumes' bound inside its points: in the world, its object and their generated
                # points
                inside = co.reshape(-1, 3).min(0), co.reshape(-1, 3).max(0)
                spaced = [(k - space[0]) / (2 * space[1]) + 0.5 for k in inside]
                kinds = [medium(ob.material_slots[k].material, {'POSITION': (positions.reshape(-1, 3).min(0),
                    positions.reshape(-1, 3).max(0)), 'OBJECT': inside, 'GENERATED': (numpy.minimum(*spaced),
                    numpy.maximum(*spaced))}) for k in sorted(set(index.tolist())) if k < len(ob.material_slots)
                    and ob.material_slots[k].material]
                media = (*space[0], *space[1]), max([0, *kinds])
                if media[1]: varying.add(i)
            record(i, instance, ob, entry, ob.type == 'LIGHT' and (f'{radiance:.4g}', isinstance(shaped, tuple)
                and f'{numpy.array(instance.matrix_world.to_3x3()).round(4)}'), media)
        # Update on stdin: slot count; per slot its first triangle and triangle count, then its arrays as in a scene, its
        # object's info and its transform's rows and adjugate
        if moved:
            if varying or not all(self.slots.get(i, ())[1:] == (count, key) for i, count, key in slots):
                self.visible = None
                return self.start(depsgraph)
            self.volumes.update(volumes)
            self.requests.writelines((struct.pack('<2I', UPDATE, len(slots)), *(array for k, (i, count, _) in
                enumerate(slots) for array in (struct.pack('<2I', self.slots[i][0], count),
                *(column[k + 1].astype('f') for column in columns[:8]), instances[k][3][21:41].astype('f'),
                instances[k][3][:21].astype('f')))))
            return
        world = scene.world and scene.world.node_tree.get_output_node('CYCLES')
        world = program(resolve(world.inputs['Surface']) if world else BLACK)
        materials.append([(*world[:2], 0, 1, 0, world[1])])
        shape = [op[0] for op in ops + aside[0]], [(row[1], row[2], row[0] > 0, *row[3:]) for layers in rows.values()
            for row in layers], textures
        if not shaded:  # The texels the materials' programs read first, then those only bakes read, flagged in bit 30;
            starts = numpy.cumsum([0, *map(len, texels)])[:-1] // 4  # the images they read apart, by their index,
            read = {texel for code, texel, _, height in ops if [*OPS][code] in READS and not height >> 28 & 1}  # in 31
            image = {entry[0]: entry[1:3] for key, entry in textures.items() if isinstance(key, tuple)}  # Width, height
            apart = [1 if k > 0 and first not in read else 2 if first in image and len(entry) else 0  # An empty entry
                for k, (first, entry) in enumerate(zip(starts, texels))]  # shares its first with the next: no image
            def compact(pixels):  # A float image's texture in the smallest format exact for it, or that its read
                words = numpy.rint(pixels * 65535).astype('u2')  # rounds to within an ulp: 16-bit UNORM where Blender
                if numpy.array_equal(words * (numpy.float32(1) / numpy.float32(65535)), pixels): return words, 3  # read
                halves = pixels.astype(numpy.float16)  # k * (1 / 65535), its hardware read the correctly rounded k /
                return (halves, 2) if numpy.array_equal(halves, pixels) else (pixels, 0)  # 65535; halves where exact
            # Filtered in hardware, 16-bit UNORM errs by up to half its ulp and halves round to halves, which a Bump's
            # differences magnify: the images it differentiates keep floats
            derived = {entry[0] for key, entry in textures.items() if isinstance(key, tuple) and key[0] in derived}
            formats = {first: compact(entry) for first, entry, side in zip(starts, texels, apart)  # Bits 26 and 27: 2
                if side == 2 and not image[first][1] >> 26 & 1 and first not in derived}  # halves, 3 16-bit UNORM
            form = lambda first: formats[first][1] << 26 if first in formats else 0
            chained = {texel for code, texel, width, _ in ops if [*OPS][code] in ('IMAGE_LINEAR', 'ALPHA_LINEAR')
                and width >> 20 != 2048}  # Read by a ray's cone at some level: a mip chain, flagged in bit 31 of width
            at, counts = {}, [0, 0, 0]
            for first, entry, side in zip(starts, texels, apart):
                at[first], counts[side] = (counts[side], side), counts[side] + (len(entry) // 4 if side < 2 else 1)
            def relocated(ops):  # Of their reads' and tiles' firsts, those piped apart flagged
                return [(code, at[texel][0], width, height | at[texel][1] << 30 | form(texel))
                    if (code == 0 or [*OPS][code] in READS) and not height >> 28 & 1 else (code, texel, width, height)
                    for code, texel, width, height in ops]
            ops[:], aside[0][:] = relocated(ops), relocated(aside[0])
            placed = [(at[tile][0], key, unit, (hint, relocated(steps)), value)
                for tile, key, unit, (hint, steps), value in placed]
            textures.update({key: (*at[entry[0]][:1], entry[1], entry[2] | at[entry[0]][1] << 30 | form(entry[0]),
                entry[3])
                for key, entry in textures.items() if not isinstance(key, Bake)})
            images = [(numpy.concatenate((formats[first][0], numpy.zeros(-len(entry) % 8, formats[first][0].dtype)))
                .view('f') if form(first) else entry, (image[first][0] | (first in chained) << 31, image[first][1]
                | form(first)))  # 16-bit: two
                for first, entry, side in zip(starts, texels, apart) if side == 2]  # texels to a float4
            texels = [entry for entry, side in zip(texels, apart) if not side] + [
                entry for entry, side in zip(texels, apart) if side == 1]
        piped, rows = self.piped if shaded else counts[0], len(ops)
        bakes, again = [k + rows for k in bakes], [k + rows for k in again]  # The bakes' steps after the materials'
        ops = [(code, texel + piped, width, height & ~(1 << 28)) if (code == 0 or [*OPS][code] in READS)
            and height >> 28 & 1 else (code, texel, width, height) for code, texel, width, height in ops + aside[0]]
        ops += [([*OPS].index('MEDIUM'), 0, 0, 0)] * bool(varying)
        if shaded:  # Steps on stdin: their count, then the steps as in a scene, while their codes, the rows and the
            if self.varying or shape[:2] != self.shape[:2] or len(textures) != len(self.shape[2]) or any(  # textures
                # keep their shape, and no volume varies, whose bounds a value changed may move
                    textures[key][:3] != entry[:3] for key, entry in self.shape[2].items() if isinstance(key, Bake)) \
                    or any(entry[2] >> 26 & 2 for key, entry in textures.items()  # and no image a Bump now
                    if isinstance(key, tuple) and key[0] in derived):  # differentiates stays compacted
                self.visible = None
                return self.start(depsgraph)
            read = {texel for code, texel, *_ in ops if [*OPS][code].startswith(('IMAGE', 'ALPHA'))}  # The tables
            tables = {key: [] for key, entry in textures.items()
                if not isinstance(key, (tuple, Bake)) and entry[0] in read}
            means = {key: texture(key, {}, tables[key])[3] for key in tables}  # read, rebuilt; their means, which the
            if any((means[key] != textures[key][3]).any() for key in tables):  # hints take, as the renderer has them
                self.shape[2].update({key: (*textures[key][:3], means[key]) for key in tables})
                return self.start(depsgraph)
            # Then per table its first texel, width and texels, until a width of 0, those only bakes read flagged in bit
            # 31, and with bakes to run again their images, as piped, and tiles; per program its first step and light
            # power hint, until a first of 2^32 - 1; then the count and programs of the bakes to run again
            def anew(key):  # An image only bakes read, read again as piped
                texture(types.SimpleNamespace(type='TEX_IMAGE', image=key[0], extension=key[1]), {}, data := [])
                return data
            tables = [(entry[0] | (entry[2] >> 30 & 1) << 31, entry[1], tables[key]) for key, entry in textures.items()
                if key in tables] + [(entry[0] | 1 << 31, len(data[0]) // 4, data) for key, entry in textures.items()
                if again and isinstance(key, tuple) and entry[2] >> 30 & 1 for data in [anew(key)]] + [
                (first | 1 << 31, len(tiles) // 4, [tiles]) for first, tiles in tilings.items() if again and len(tiles)]
            self.requests.writelines((struct.pack('<2I', STEPS, len(ops)), numpy.array(ops, 'I'), *(part for first,
                width, data in tables for part in (struct.pack('<2I', first, width), *data)), struct.pack('<2I', 0, 0),
                numpy.array([*hints.items(), (2 ** 32 - 1, 0)], 'u4, f4'), struct.pack('<I', len(again)),
                numpy.array(again, 'I')))
            return
        self.shape = shape
        firsts = numpy.cumsum([0] + [count for _, count, _ in slots])
        self.slots = {i: (int(first), count, key) for (i, count, key), first in zip(slots, firsts)}
        self.volumes, self.varying = volumes, varying
        self.cuts, self.placed, self.piped = cuts, placed, piped
        materials = numpy.concatenate(materials)
        # Scene on stdin: triangle, step, texel, baked texel and bake counts, the steps of the materials' programs and
        # the texels only bakes read, mesh triangle, instance and image counts; the steps of 4 integers, first, as the
        # renderer compiles from them while the rest loads; per instance its mesh's first triangle, count and whether in
        # world space, its 12 transform, 9 adjugate and 19 info floats; per triangle of the meshes 9 vertex, 9 normal, 9
        # generated, 9 object, 6 UV, 12 color and 12 tangent floats, its material's pass index, a material of its
        # emission, program, hidden flag, layer count, opaque flag and emission program (then the world's); of strands
        # the point and segment counts, per point its position and radius, per segment its first point and strand, its
        # bounds and its strand's material; then the texels and the programs of the bakes; then each image's width and
        # height, RGBA8 in its bit 26, and its texels
        self.requests.writelines((struct.pack('<11I', SCENE, firsts[-1], len(ops), piped, baked[0], len(bakes), rows,
            counts[1], sum(map(len, columns[0])), len(instances), counts[2]), numpy.array(ops, 'I'),
            *(part for first, count, world, values in instances for part in (numpy.array((first, count, world), 'I'),
            values)), *(numpy.concatenate(column, dtype='f') for column in columns),
            numpy.hstack((materials[:, :1].astype('f').view('I'), materials[:, 1:].astype('I'))),
            struct.pack('<2I', sum(map(len, points)), sum(map(len, segments))), *points,
            *segments, *bounds, *(
            table[segment[:, 1]] for rows in [numpy.concatenate((numpy.empty((0, 6)), *hairs), dtype='f')] for table in [
            numpy.hstack((rows[:, :1].view('I'), rows[:, 1:].astype('I')))] for segment in segments),
            *texels, numpy.array(bakes, 'I'),
            numpy.array([shape for _, shape in images], 'I'), *(entry for entry, _ in images),
            struct.pack('<I', len(attributes) * len(INSTANCER)), *attributes))

    # Samples launched, then radiance sums and sample count per pixel, rows bottom to top, after up to launches more
    # samples, at most the first of sampling's samples or, reusing the last view's reservoirs, the second, of the view
    # from the camera's matrix through its perspective projection under the settings; none launched if the view already
    # had its samples. A view other than the last starts over.
    def trace(self, width, height, sampling, launches, settings, matrix, projection, camera=None, clip_end=None):
        right = matrix.col[0].xyz
        up = matrix.col[1].xyz
        back = matrix.col[2].xyz
        x = right / projection[0][0]
        y = up / projection[1][1]
        ortho = projection[3][3] == 1  # Orthographic: rays along the view from points across it and its shift; else
        # from the origin, the shift in their direction
        center = (-x * projection[0][3] - y * projection[1][3] if ortho
            else x * projection[0][2] + y * projection[1][2] - back)
        # Rays start on the near plane, at its depth along the view: the clip start, which a viewport's orthographic one
        # has behind the view; and end on the far one, at the clip end: a perspective one's as set, which its matrix
        # holds too coarsely at wide clip ranges
        near, far = (((1 + projection[2][3]) / projection[2][2], (projection[2][3] - 1) / projection[2][2]) if ortho
            else (projection[2][3] / (projection[2][2] - 1), camera.data.clip_end if camera else clip_end))
        # The volume the rays start in: of an instance filling one that a ray up from the near plane's center leaves an
        # odd number of times, its first triangle of a material filling it, or none
        medium = next((self.slots[i][0] + first for i, (tree, first) in self.volumes.items()
            if inside(tree, matrix.translation - back * near)), 2 ** 32 - 1)
        # Request on stdin: sampling, launches, size, settings, the volume the camera is in, the camera's origin and its
        # ray direction per NDC x, per NDC y and at the center (orthographic: the rays' offsets), then the thin lens and
        # whether orthographic, and the near and far planes' depths.
        self.requests.write(struct.pack(f'<3I2f{4 + len(settings)}I20f', REQUEST, *sampling, launches, width, height,
            *settings, medium, *matrix.translation, *x, *y, *center, *lens(camera), ortho, near, far))
        self.requests.flush()
        launched, *self.memory = struct.unpack('<I2f', self.answers.read(12))  # Launches, memory, the view's sums
        sums = mmap.mmap(self.shared.fileno(), 16 * width * height, access=mmap.ACCESS_READ)
        return launched, numpy.frombuffer(sums, 'f').reshape(-1, width, 4)[::-1]

    # Shows the result after ever larger batches of samples, until it has them all or the render is cancelled
    def render(self, depsgraph):
        # The scene as set: with persistent data the evaluated one keeps its first render's values of its properties
        # changed alone, such as Flex's settings, while its camera follows
        scene = depsgraph.scene
        width = self.resolution_x
        height = self.resolution_y
        self.update_progress(0)
        self.update_stats('', f'{scene.name} | Syncing scene')
        self.start(depsgraph)
        evaluated = scene.camera.evaluated_get(depsgraph)
        camera = (evaluated.matrix_world.normalized(),
            evaluated.calc_matrix_camera(depsgraph, x=scene.render.resolution_x, y=scene.render.resolution_y), evaluated)
        result = self.begin_result(0, 0, width, height)  # Blender clips the result to the render border
        border = depsgraph.scene.render
        x = int(border.use_border * border.border_min_x * width)
        y = int(border.use_border * border.border_min_y * height)
        follows = self.is_animation and scene.frame_current == self.following
        self.following = scene.frame_current + scene.frame_step
        started = time.perf_counter()
        count = 0  # Shown none yet: a view that already has its samples is shown once
        while not self.test_break():
            launched, sums = self.trace(width, height, sampling(scene, follows), min(count or 1, RENDER_SAMPLES),
                settings(scene, False, self.device), *camera)
            if count and not launched: break
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

    def view_update(self, context, depsgraph):
        self.start(depsgraph)

    def view_draw(self, context, depsgraph):  # Draws the viewport's view, after a few more samples while it lacks any
        region = context.region
        scene = depsgraph.scene
        camera = context.space_data.camera if context.region_data.view_perspective == 'CAMERA' else None
        launched, sums = self.trace(region.width, region.height, sampling(scene, True), VIEWPORT_SAMPLES,
            settings(scene, True, self.device), context.region_data.view_matrix.inverted(), context.region_data.window_matrix,
            camera.evaluated_get(depsgraph) if camera else None, context.space_data.clip_end)
        if launched:
            pixels = (sums * (1 / sums[0, 0, 3])).ravel()
            self.texture = gpu.types.GPUTexture((region.width, region.height), format='RGBA32F',
                data=gpu.types.Buffer('FLOAT', len(pixels), pixels))
            self.tag_redraw()
        gpu.state.blend_set('ALPHA_PREMULT')
        self.bind_display_space_shader(scene)
        draw_texture_2d(self.texture, (0, 0), region.width, region.height)
        self.unbind_display_space_shader()
        gpu.state.blend_set('NONE')

class FlexPreferences(bpy.types.AddonPreferences):  # The API the renderer traces with
    bl_idname = __package__
    device: bpy.props.EnumProperty(name='Device', items=(('OPTIX', 'OptiX', 'NVIDIA RTX GPUs'),
        ('VULKAN', 'Vulkan', 'GPUs with Vulkan ray queries, without denoising')))

    def draw(self, context):  # Those this machine runs selectable alone
        if not runnable: self.layout.label(text='No backend runs on this machine', icon='ERROR')
        row = self.layout.row()
        for key, _ in BACKENDS:
            button = row.row()
            button.enabled = key in runnable
            button.prop_enum(self, 'device', key)

class RENDER_PT_flex(bpy.types.Panel):  # Render properties of the Flex engine
    bl_label = 'Flex'
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = 'render'

    @classmethod
    def poll(cls, context): return context.engine == Flex.bl_idname

    def draw(self, context):
        self.layout.use_property_split = True
        for name in ('flex_samples', 'flex_bounces', 'flex_paths'): self.layout.prop(context.scene, name)
        denoise = self.layout.row()
        denoise.active = device() == 'OPTIX'
        denoise.prop(context.scene, 'flex_denoise')

class DATA_PT_flex_light(bpy.types.Panel):  # A light's settings the engine reads, of its type
    bl_label = 'Light'
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = 'data'

    @classmethod
    def poll(cls, context): return context.engine == Flex.bl_idname and context.light

    def draw(self, context):
        light = context.light
        self.layout.row().prop(light, 'type', expand=True)
        self.layout.use_property_split = True
        for name in ('color', 'use_temperature', 'temperature', 'energy', 'exposure', 'normalize', *{'POINT':
                ('shadow_soft_size',), 'SPOT': ('shadow_soft_size', 'spot_size', 'spot_blend'), 'SUN': ('angle',),
                'AREA': ('shape', 'size', 'size_y', 'spread')}[light.type]):
            if (name != 'size_y' or light.shape in {'RECTANGLE', 'ELLIPSE'}) \
                and (name != 'temperature' or light.use_temperature): self.layout.prop(light, name)

class OBJECT_PT_flex_visibility(bpy.types.Panel):  # An object's visibility the engine reads
    bl_label = 'Visibility'
    bl_space_type = 'PROPERTIES'
    bl_region_type = 'WINDOW'
    bl_context = 'object'

    @classmethod
    def poll(cls, context): return context.engine == Flex.bl_idname and context.object

    def draw(self, context):
        self.layout.use_property_split = True
        shown = self.layout.column(heading='Show In')
        shown.prop(context.object, 'hide_viewport', text='Viewports', toggle=False, invert_checkbox=True)
        shown.prop(context.object, 'hide_render', text='Renders', toggle=False, invert_checkbox=True)
        self.layout.column(heading='Ray Visibility').prop(context.object, 'visible_camera', text='Camera')

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
        row = column.row(heading='Reuse Samples')
        row.prop(scene, 'flex_reuse', text='')
        samples = row.row()
        samples.active = scene.flex_reuse
        samples.prop(scene, 'flex_reuse_samples', text='')
        header, body = column.panel('RENDER_PT_flex_jump', default_closed=True)
        header.label(text='Camera Jump')
        if body:
            body.active = scene.flex_reuse
            body.prop(scene, 'flex_jump_distance')
            body.prop(scene, 'flex_jump_angle')

PROPERTIES = {
    'flex_samples': bpy.props.IntProperty(name='Max Samples', description='Paths traced per pixel',
        default=1024, min=1),
    'flex_bounces': bpy.props.IntProperty(name='Max Bounces',
        description='Bounces of a path after the surface the camera sees', default=16, min=0, max=16),
    'flex_paths': bpy.props.IntProperty(name='Paths per Sample',
        description='Paths traced per pixel and sample, the initial candidates of ReSTIR', default=1, min=1, max=32),
    'flex_denoise': bpy.props.BoolProperty(name='Denoise',
        description='Denoise the result with the OptiX denoiser'),
    'flex_restir': bpy.props.BoolProperty(name='ReSTIR',
        description='Reuse paths across pixels and samples with ReSTIR PT Enhanced', default=True),
    'flex_decorrelation': bpy.props.BoolProperty(name='Decorrelation', description='Reuse samples '
        'repeated across the neighborhood less over time. Biased: trades correlation artifacts for energy loss'),
    'flex_neighbors': bpy.props.IntProperty(name='Spatial Neighbors',
        description='Pixels each pixel reuses paths from per sample, fewer trade quality for speed', default=3, min=1,
        max=3),
    'flex_reuse': bpy.props.BoolProperty(name='Reuse Samples', description='Trace fewer samples of a '
        'view reusing the last one\'s paths, as an animation\'s frames do after its first and after camera jumps'),
    'flex_reuse_samples': bpy.props.IntProperty(name='Reuse Samples',
        description='Paths traced per pixel of a view reusing the last one\'s', default=128, min=1),
    'flex_jump_distance': bpy.props.FloatProperty(name='Distance', description='Farthest the camera '
        'moves between views to reuse samples, a farther move jumps and traces all of them', default=1, min=0,
        subtype='DISTANCE'),
    'flex_jump_angle': bpy.props.FloatProperty(name='Angle', description='Furthest the camera turns '
        'between views to reuse samples, a further turn jumps and traces all of them', default=math.radians(10), min=0,
        max=math.pi, subtype='ANGLE')}
# Flex keeps its scene from one frame of an animation to the next: Blender keeps an engine and its depsgraph for a job's
# frames only with persistent data, which a Flex render sets as the job starts, for Blender's copy of the settings, and
# gives the user's value back before the first frame, so no file ever saves it; the job done, setting the user's off
# again frees the engine and its renderer, as Blender does when it is switched off
users = {}  # The user's persistent data of each scene whose Flex render set it, until its first frame
@bpy.app.handlers.persistent
def persist(scene, *_):
    if scene.render.engine == Flex.bl_idname:
        users[scene.name], scene.render.use_persistent_data = scene.render.use_persistent_data, True
@bpy.app.handlers.persistent
def restore(scene, *_):
    if scene.name in users: scene.render.use_persistent_data = users.pop(scene.name)
@bpy.app.handlers.persistent
def release(scene, *_):  # Only once the job is done: setting it off frees the depsgraph a job's frames keep
    restore(scene)
    if scene.render.engine == Flex.bl_idname and not scene.render.use_persistent_data:
        scene.render.use_persistent_data = False
HANDLERS = ((bpy.app.handlers.render_init, persist), (bpy.app.handlers.render_pre, restore),
    (bpy.app.handlers.render_complete, release), (bpy.app.handlers.render_cancel, release))
CLASSES = (FlexPreferences, Flex, RENDER_PT_flex, RENDER_PT_flex_restir, DATA_PT_flex_light, OBJECT_PT_flex_visibility)

# Timer: once make install has replaced this build, has Blender unregister, reload and register the extension
def reload():
    if os.path.exists(__file__) and os.path.getmtime(__file__) != MODIFIED:
        bpy.app.timers.register(lambda: addon_utils.enable(__package__) and None)
    return 1

def register():
    for binary in (BINARY, BINARY + '-vulkan'): os.chmod(binary, 0o755)  # Extension installs drop the executable bit
    global pool  # Images' per-texel work, in numpy calls freeing the GIL, until unregistered
    pool = concurrent.futures.ThreadPoolExecutor(os.cpu_count())
    global runnable  # Started without a file, a renderer exits once its device is up, failing without one
    runnable = tuple(key for key, suffix in BACKENDS if not subprocess.run((BINARY + suffix,),
        stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode)
    if 'OPTIX' in runnable and not bpy.app.background:  # Interactive Blender warms OptiX's disk cache with the generic
        subprocess.Popen((BINARY, 'warm', str(os.getpid())), stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
            start_new_session=True)  # module, once per release, a renderer of its own ending with Blender
    bpy.app.timers.register(reload, persistent=True)
    for name, prop in PROPERTIES.items(): setattr(bpy.types.Scene, name, prop)
    for cls in CLASSES: bpy.utils.register_class(cls)
    preferences = bpy.context.preferences.addons[__package__].preferences
    if runnable and preferences.device not in runnable: preferences.device = runnable[0]
    for name in PANELS: getattr(bpy.types, name).COMPAT_ENGINES.add(Flex.bl_idname)
    for handlers, handler in HANDLERS: handlers.append(handler)

def unregister():
    pool.shutdown()
    bpy.app.timers.unregister(reload)
    for handlers, handler in HANDLERS: handlers.remove(handler)
    for name in PANELS: getattr(bpy.types, name).COMPAT_ENGINES.remove(Flex.bl_idname)
    for cls in reversed(CLASSES): bpy.utils.unregister_class(cls)
    for name in PROPERTIES: delattr(bpy.types.Scene, name)
