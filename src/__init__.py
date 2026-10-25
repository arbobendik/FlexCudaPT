# Blender render engine: exports the scene as world-space triangles and path traces it with the bundled OptiX binary.
import addon_utils, bpy, bmesh, functools, gpu, math, mmap, numpy, os, struct, subprocess, time
from gpu_extras.presets import draw_texture_2d
from mathutils import Color, Matrix, Vector
from mathutils.bvhtree import BVHTree
from bl_ui.properties_data_camera import classes as CAMERA_PANELS
from bpy_extras import anim_utils

SUN_DISTANCE = 1e5
SUN_MIN_ANGLE = 1e-4  # Blender's parallel sun of angle 0 as the smallest disk, which delivers the same irradiance
VIEWPORT_SAMPLES = 4  # Per redraw
RENDER_SAMPLES = 64  # At most, per update of a final render
SLOTS = 32  # Values a program keeps for reuse, as the shader's
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
    'SPECULAR': lambda tint: tint, 'TRANSLUCENT': lambda color: color}
# Surface: expressions of its normal, albedo, metallic, roughness, emissive, transparency, ior, specular tint, specular
# level, coverage, absorption, density, scattering color and translucent color, which a program carries only marked
GRAY = [('NORMAL',), 0.8, 0, 0.5, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0]
BLACK = [('NORMAL',), 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0]
# Albedo, metallic, roughness, emissive, its strength, transparency and ior per shader node, each the name of an input
# or a constant; an ior of 1 reflects nothing specularly, as Cycles' diffuse shaders. Volume shaders on surfaces
# reflect nothing, and rays pass through a portal without a position or direction; any other shader is diffuse. The
# Translucent BSDF's color, which its diffuse lobe transmits, is the surface's translucent color.
SHADERS = {'BSDF_PRINCIPLED': ('Base Color', 'Metallic', 'Roughness', 'Emission Color', 'Emission Strength',
        'Transmission Weight', 'IOR'), 'BSDF_METALLIC': ('Base Color', 1, 'Roughness', 0, 0, 0, 1.5),
    'EEVEE_SPECULAR': ('Base Color', 0, 'Roughness', 'Emissive Color', 1, 'Transparency', 1.5),
    **dict.fromkeys(('PRINCIPLED_VOLUME', 'VOLUME_ABSORPTION', 'VOLUME_SCATTER', 'VOLUME_COEFFICIENTS'),
        (0, 0, 1, 0, 0, 0, 1)), 'BSDF_RAY_PORTAL': ('Color', 0, 0, 0, 0, 1, 1),
    'BSDF_GLOSSY': ('Color', 1, 'Roughness', 0, 0, 0, 1.5), 'BSDF_GLASS': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'),
    'BSDF_REFRACTION': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'), 'BSDF_TRANSPARENT': ('Color', 0, 0, 0, 0, 1, 1),
    'EMISSION': (0, 0, 1, 'Color', 'Strength', 0, 1), 'BACKGROUND': (0, 0, 1, 'Color', 'Strength', 0, 1),
    'BSDF_TRANSLUCENT': (0, 0, 1, 0, 0, 0, 1)}
# Absorption color, density and scattering color per volume shader node; any other absorbs and scatters nothing
VOLUMES = {'VOLUME_ABSORPTION': ('Color', 'Density', 0), 'VOLUME_SCATTER': (1, 'Density', 'Color'),
    'PRINCIPLED_VOLUME': ('Absorption Color', 'Density', 'Color')}
# Luminance of a color and mean of a vector, as Blender converts them to values
WEIGHTS = {'RGBA': numpy.array((0.2126, 0.7152, 0.0722)), 'VECTOR': numpy.full(3, 1 / 3)}
# Blender's material and camera panels the engine shows
PANELS = ('EEVEE_MATERIAL_PT_context_material', 'EEVEE_MATERIAL_PT_surface', 'MATERIAL_PT_custom_props',
    'MATERIAL_PT_animation', *(panel.__name__ for panel in CAMERA_PANELS))
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

def table(node):  # Colors of a wavelength, ramp or curves node, RGB curves after the combined curve
    if node.type == 'WAVELENGTH': return [(*numpy.array(Color(xyz).from_xyz_d65_to_scene_linear()) / 2.52, 1)
        for xyz in CIE]
    if node.type == 'VALTORGB': return [node.color_ramp.evaluate(i / 255) for i in range(256)]
    mapping, curves = rebuilt(node.mapping), [*node.mapping.curves]
    rgb = node.type == 'CURVE_RGB'
    return [[*(mapping.evaluate(curve, mapping.evaluate(curves[3], x) if rgb else x) for curve in (curves * 3)[:3]), 1]
        for x in numpy.linspace(*span(node), 256)]

def decode(srgb):  # sRGB to linear
    return numpy.where(srgb <= 0.04045, srgb / 12.92, ((srgb + 0.055) / 1.055) ** 2.4)

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
        levels = numpy.rint(pixels * 255).astype('u1')
        alphas = numpy.bincount(levels[3::4], minlength=256)  # Colors associated by alpha, as Cycles keeps them, in
        packed = not ramp and numpy.array_equal(levels * (numpy.float32(1) / numpy.float32(255)), pixels) and not (
            straight and alphas[1:255].any())  # linear light: in RGBA8 exactly by alphas of 0 and 1 alone
        if packed:  # Its mean in linear light by the count of each level, decoding no texel
            if straight and alphas[0]: levels.reshape(-1, 4)[levels[3::4] == 0, :3] = 0
            k = numpy.arange(256) / 255
            mean = numpy.array([numpy.bincount(c, minlength=256) @ (decode(k) if srgb and i < 3 else k)
                for i, c in enumerate(levels.reshape(-1, 4).T)]) / (len(levels) // 4)
        else:
            if srgb: pixels.reshape(-1, 4)[:, :3] = decode(pixels.reshape(-1, 4)[:, :3])
            if straight: pixels.reshape(-1, 4)[:, :3] *= pixels.reshape(-1, 4)[:, 3:]
            mean = pixels.reshape(-1, 4).mean(0)
        textures[key] = (sum(map(len, texels)) // 4, width, height | ('REPEAT', 'EXTEND', 'CLIP', 'MIRROR').index(
            'REPEAT' if ramp else key[1]) << 24 | packed << 26 | (packed and srgb) << 29, mean)
        texels.append(numpy.concatenate((levels, numpy.zeros(-len(levels) % 16, 'u1'))).view('f') if packed else pixels)
    return textures[key]

# Recursions over resolve()'s expressions, whose parts are shared, take each part once per outermost call: memo by its
# id, which the parts keep as they outlive the call, made by that call and passed down
def expression_key(expression, memo=None):
    memo = {} if memo is None else memo
    if isinstance(expression, tuple):
        if id(expression) not in memo: memo[id(expression)] = tuple(expression_key(part, memo) for part in expression)
        return memo[id(expression)]
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
    'DOT_PRODUCT': lambda a, b: not (a and b), 'DIVIDE': lambda a, b: not b,
    'MULTIPLY_ADD': lambda a, b, c: not (a and b), 'ROTATE': lambda vector, axis, angle: not (axis or angle)}
POINTS = ('GENERATED',)  # What a unit baked over its object's UVs reads: undeformed, no motion bakes it again
BUDGET = 1 << 24  # Texel slots of 16 bytes, two half texels each, baked at most (256 MiB); units over UVs past it stay
# Largest change of an expression of math on the point inputs per unit of one of them, as its derivative halfway along
# all, the noises in it held (their frequencies count of their own); infinite unless it's a function of the inputs
def jacobian(expression, input):
    at = lambda e, value: (value if e == (input,) else numpy.full(3, 0.5) if len(e) == 1 and e[0] in POINTS
        or e[0] == 'NOISE'
        else (e[0], *(at(operand, value) for operand in e[1:]))) if isinstance(e, tuple) else e
    values = [fold(at(expression, numpy.full(3, 0.5) + 1e-3 * step)) for step in (*numpy.eye(3), numpy.zeros(3))]
    if any(isinstance(value, tuple) for value in values): return math.inf
    return max(numpy.linalg.norm(numpy.resize(value, 3) - numpy.resize(values[3], 3)) for value in values[:3]) * 1e3

# Largest change of a point input per unit of its triangles' UVs, its corners' values as values and theirs as uvs: of
# its derivative along the UVs, by its Frobenius norm, the 90th percentile over the triangles that have area in UV,
# weighted by that area as their texels are: a sliver's derivative is only as exact as its UVs' last bits, which
# Blender's threads leave to chance, so slivers must not decide it
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
# (None for any other step or input, a specular mark, kept live around what of its tint bakes, or an image read:
# baked over UVs and read back, the image's texels would be interpolated twice, rounding off their kinks); its point
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
    points = None if name not in (*POINTS, *READS, 'NOISE') and not OPS.get(name) or read \
        or name in ('SPECULAR', 'TRANSLUCENT') or any(part[2] is None for part in parts) \
        else {'NOISE': 80}.get(name, 1) + sum(part[2] for part in parts)
    inputs = ({name} & {*POINTS}).union(*(part[3] for part in parts))
    along = lambda: sum(jacobian(operands[0], input) * scales[input] for input in parts[0][3] & scales.keys())
    need = max([0, *(part[4] for part in parts)])
    if scales and name == 'NOISE':
        detail, roughness, lacunarity = (0, 1, 1) if isinstance(operands[1], tuple) else numpy.resize(operands[1], 3)
        octaves = detail if roughness >= 1 else min(detail, math.log(1 / 256) / math.log(max(roughness, 1e-3)))
        need = math.inf if isinstance(operands[1], tuple) else max(need, 8 * lacunarity ** octaves * along())
    table[id(expression)] = reads, affine, points, inputs, need
    return table[id(expression)]

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

# Appends the steps of an expression to ops, operands first, a surface's seven before an end; returns its value under
# textures of their mean. Without slots it counts in uses each expression met at the point it is read at, a height
# shifted by a bump read at its shift, entering none twice; with them those met again are kept in a slot and loaded.
def marks(expression, name):  # Whether the expression holds an operation of the name
    return isinstance(expression, tuple) and (expression[0] == name or any(marks(x, name) for x in expression[1:]))

def emit(expression, ops, textures, texels, alphas, uses, slots=None, shift=None):
    if isinstance(expression, list): expression = 'END', *expression
    if not isinstance(expression, tuple):
        ops.append((1, *numpy.resize(expression, 3).astype('f').view('I')))
        return expression
    name, *operands = expression
    key = shift, expression_key(expression)
    if name != 'SHIFT' and key in (uses if slots is None else slots):
        if slots is None: uses[key][0] += 1
        else: ops.append(([*OPS].index('LOAD'), slots[key], 0, 0))
        return uses[key][1]
    if name == 'UNASSOCIATE':
        return emit(('DIVIDE', *operands) if operands[1][-1].key in alphas else operands[0], ops, textures, texels,
            alphas, uses, slots, shift)
    payload = texture(operands.pop(), textures, texels) if name in READS else (0, 0, 0, numpy.ones(4))
    values = [emit(operand, ops, textures, texels, alphas, uses, slots,
        operands[0] if name == 'SHIFTED' and k else shift) for k, operand in enumerate(operands)]
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
    if name not in ('UNASSOCIATE', 'SPECULAR', 'TRANSLUCENT') and OPS[name] \
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
    # constants
    memo = {} if memo is None else memo
    if isinstance(value, list): return [unanimated(part, memo) for part in value]
    if not isinstance(value, tuple): return value
    if id(value) not in memo: memo[id(value)] = unanimated(value[1], memo) if value[0] == 'ANIMATED' else (
        value[0], *(unanimated(part, memo) for part in value[1:]))
    return memo[id(value)]

def nonzero(value):  # Whether a value resolved is an expression or a constant not zero, its animated ones as constants
    return isinstance(unanimated(value), tuple) or numpy.any(unanimated(value))

def constant(expression, seen=None):  # Whether it is constant before products of zero fold it, as Blender's nodes see
    if not isinstance(expression, tuple): return True  # it; each part shared once
    seen = {} if seen is None else seen
    if id(expression) not in seen:
        seen[id(expression)] = expression[0] != 'UNASSOCIATE' and bool(OPS[expression[0]]) \
            and all(constant(part, seen) for part in expression[1:])
    return seen[id(expression)]

def mix(a, b, factor):  # Expression of a fading into b, surfaces attribute by attribute
    if isinstance(a, list): return [mix(x, y, factor) for x, y in zip(a, b)]
    return 'ADD', ('MULTIPLY', a, ('SUBTRACT', 1, factor)), ('MULTIPLY', b, factor)

def clamp(value):
    return 'SUBTRACT', 1, ('MAXIMUM', 0, ('SUBTRACT', 1, ('MAXIMUM', 0, value)))

def absolute(value):
    return 'MAXIMUM', value, ('SUBTRACT', 0, value)

def fraction(value):
    return 'SUBTRACT', value, ('FLOOR', value)

def length(vector):
    return 'POWER', ('DOT_PRODUCT', vector, vector), 0.5

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

# Cycles' fit of blackbody colors in Rec.709 from each temperature on: a / t + b t + c for red and green and
# ((a t + b) t + c) t + d for blue, constant below and above the fit
BLACKBODY = ((0, (5.413294490189271, -0.20319390035873933, -0.0822535242887164)),
    (800, (1.61919106e+03, -2.05010916e-03, 5.02995757e+00), (-4.88999748e+02, 6.04330754e-04, -7.55807526e-02),
        (5.96945309e-11, -4.85742887e-08, -9.70622247e-05, -4.07936148e-03)),
    (965, (2.48845471e+03, -1.11330907e-03, 3.22621544e+00), (-7.55994277e+02, 3.16730098e-04, 4.78306139e-01),
        (2.40430366e-11, 5.55021075e-08, -1.98503712e-04, 2.89312858e-02)),
    (1167, (3.34143193e+03, -4.86551192e-04, 1.76486769e+00), (-1.02363977e+03, 1.20223470e-04, 9.36662319e-01),
        (-1.40949732e-11, 1.89878968e-07, -3.56632824e-04, 9.10767778e-02)),
    (1449, (4.09461742e+03, -1.27446582e-04, 7.25731635e-01), (-1.26571316e+03, 4.87340896e-06, 1.27054498e+00),
        (-3.61460868e-11, 2.84822009e-07, -4.93211319e-04, 1.56723440e-01)),
    (1902, (4.67028036e+03, 2.91258199e-05, 1.26703442e-01), (-1.42529332e+03, -4.01150431e-05, 1.43972784e+00),
        (-1.97075738e-11, 1.75359352e-07, -2.50542825e-04, -2.22783266e-02)),
    (3315, (4.59509185e+03, 2.87495649e-05, 1.50345020e-01), (-1.17554822e+03, -2.16378048e-05, 1.30408023e+00),
        (-1.61997957e-13, -1.64216008e-08, 3.86216271e-04, -7.38077418e-01)),
    (6365, (3.78717450e+03, 9.35907826e-06, 3.99075871e-01), (-5.00799571e+02, -4.59832026e-06, 1.09098763e+00),
        (6.72650283e-13, -2.73078809e-08, 4.24098264e-04, -7.52335691e-01)),
    (12000, (0.8262954810464208, 0.9945080501520986, 1.566307710274283)))

def blackbody(t):  # Cycles' color of a blackbody at the temperature, for scene linear Rec.709
    def fit(r, g, b):
        rg = 'ADD', ('ADD', ('MULTIPLY', numpy.array((r[0], g[0], 0)), ('DIVIDE', 1, t)),
            ('MULTIPLY', numpy.array((r[1], g[1], 0)), t)), numpy.array((r[2], g[2], 0))
        cubic = 'ADD', ('MULTIPLY', ('ADD', ('MULTIPLY', ('ADD', ('MULTIPLY', b[0], t), b[1]), t), b[2]), t), b[3]
        return 'ADD', rg, ('MULTIPLY', cubic, numpy.eye(3)[2])
    colors = [numpy.array(fits[0]) if len(fits) == 1 else fit(*fits) for _, *fits in BLACKBODY]
    color = colors[0]
    for (low, *_), before, after in zip(BLACKBODY[1:], colors, colors[1:]):
        color = 'ADD', color, ('MULTIPLY', ('SUBTRACT', 1, ('LESS_THAN', t, low)), ('SUBTRACT', after, before))
    return 'MAXIMUM', color, 0

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

# Of a noise texture node of 1D to 4D points, at the generated point without a vector, as Cycles': its fractal, the
# type of which the renderer numbers, at the point distorted by signed noise, for its color also at two offsets
def noise(node, inputs, index):
    get, dimensions = dict(zip((socket.name for socket in node.inputs if socket.enabled), inputs)).get, \
        int(node.noise_dimensions[0])
    point = get('Vector') if get('Vector') is not None and node.inputs['Vector'].is_linked else ('GENERATED',)
    point, w = (vector(get('W'), 0, 0), 0) if dimensions == 1 else (point, get('W', 0))
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
    point = get('Vector') if get('Vector') is not None and node.inputs['Vector'].is_linked else ('GENERATED',)
    point, w = (vector(get('W'), 0, 0), 0) if dimensions == 1 else (point, get('W', 0))
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
    color = 'MAGIC', inputs[0] if node.inputs[0].is_linked else ('GENERATED',), vector(inputs[1], node.turbulence_depth,
        inputs[2])
    return ('DOT_PRODUCT', color, numpy.full(3, 1 / 3)) if index else color

def brick(node, inputs, index):  # Of a brick texture node at the generated point without a vector, as Cycles'
    p, color1, color2, mortar, scale, size, smooth, bias, width, height = inputs
    f = 'BRICK', ('MULTIPLY', p if node.inputs[0].is_linked else ('GENERATED',), scale), vector(size, smooth, bias), \
        vector(width, height, node.offset), numpy.array((node.offset_frequency, node.squash, node.squash_frequency))
    tint, factor = ('DOT_PRODUCT', f, numpy.eye(3)[0]), ('DOT_PRODUCT', f, numpy.eye(3)[1])
    return factor if index else mix(mix(color1, color2, tint), mortar, factor)

def gradient(node, inputs, index):  # Of a gradient texture node at the generated point without a vector, as Cycles'
    p = inputs[0] if node.inputs[0].is_linked else ('GENERATED',)
    x, y = ('DOT_PRODUCT', p, numpy.eye(3)[0]), ('DOT_PRODUCT', p, numpy.eye(3)[1])
    r = 'MAXIMUM', ('SUBTRACT', 0.999999, length(p)), 0
    return clamp({'LINEAR': x, 'QUADRATIC': ('MULTIPLY', ('MAXIMUM', x, 0), ('MAXIMUM', x, 0)),
        'EASING': ('MULTIPLY', ('MULTIPLY', clamp(x), clamp(x)), ('SUBTRACT', 3, ('MULTIPLY', clamp(x), 2))),
        'DIAGONAL': ('MULTIPLY', ('ADD', x, y), 0.5),
        'RADIAL': ('ADD', ('DIVIDE', ('ARCTAN2', y, x), 2 * math.pi), 0.5), 'SPHERICAL': r,
        'QUADRATIC_SPHERE': ('MULTIPLY', r, r)}[node.gradient_type])

def checker(node, inputs, index):  # Of a checker texture node at the generated point without a vector, as Cycles'
    p, color1, color2, scale = inputs
    p = 'MULTIPLY', ('ADD', ('MULTIPLY', p if node.inputs[0].is_linked else ('GENERATED',), scale), 1e-6), 0.999999
    factor = absolute(('MODULO', ('DOT_PRODUCT', ('FLOOR', p), numpy.ones(3)), 2))  # Whether the floors' sum is odd
    return factor if index else mix(color2, color1, factor)

def wave(node, inputs, index):  # Of a wave texture node at the generated point without a vector, as Cycles'
    p, scale, distortion, detail, detail_scale, roughness, phase = inputs
    p = 'MULTIPLY', ('ADD', ('MULTIPLY', p if node.inputs[0].is_linked else ('GENERATED',), scale), 1e-6), 0.999999
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
        color = 'ADD', ('MULTIPLY', ('SUBTRACT', color, 0.5), vector(strength, strength, clamp(strength))), \
            ('MULTIPLY', ('SUBTRACT', 1, clamp(strength)), numpy.array((0, 0, 0.5)))
        return 'NORMAL_MAP', ('ADD', color, 0.5)
    color = normalize(('MULTIPLY', ('SUBTRACT', ('MULTIPLY', color, 2), 1), numpy.array((1, -1, -1))
        if 'BLENDER' in node.space else 1))
    if 'OBJECT' in node.space: color = 'TRANSFORM', color, 2
    return normalize(mix(('NORMAL',), color, ('MAXIMUM', strength, 0)))

# Color or alpha of an image node at its vector, projected and extended, pink when missing, of an environment node along
# its projected direction. Cycles dissociates colors from their alpha where reading it unless the image packs channels,
# ignores its alpha, which is one then, or holds data.
def image(node, inputs, index):
    if not (node.image and node.image.size[0]): return numpy.array((1, 0, 1))
    source = ImageRead(node, inputs[0] if node.inputs[0].is_linked else ('UV',))
    point = inputs[0] if node.inputs[0].is_linked else ('UV',)
    if node.type == 'TEX_ENVIRONMENT':
        point = node.projection, inputs[0] if node.inputs[0].is_linked else ('GENERATED',)
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
    'BLACKBODY': lambda node, inputs, index: blackbody(inputs[0]),
    'WAVELENGTH': wavelength,
    'HUE_SAT': lambda node, inputs, index: hue_saturation(*inputs),
    'SEPARATE_COLOR': lambda node, inputs, index: ('DOT_PRODUCT', MODES[node.mode][0](inputs[0]), numpy.eye(3)[index]),
    'COMBINE_COLOR': lambda node, inputs, index: MODES[node.mode][1](NODES['COMBXYZ'](node, inputs, index)),
    'CURVE_RGB': curves, 'CURVE_VEC': curves, 'CURVE_FLOAT': curves,
    'MIX': blend, 'MAP_RANGE': map_range, 'CLAMP': lambda node, inputs, index: between(*inputs)
        if node.clamp_type == 'RANGE' else ('MINIMUM', ('MAXIMUM', inputs[0], inputs[1]), inputs[2]),
    'ADD_SHADER': lambda node, inputs, index: [mix(a, b, 0.5) if attribute in (2, 3, 7, 8, 10, 12, 14)
        else ('SUBTRACT', ('ADD', a, b), 1) if attribute in (6, 9) else ('ADD', a, b)
        for attribute, (a, b) in enumerate(zip(*inputs))],
    'MATH': lambda node, inputs, index: (node.operation, *inputs) if OPS.get(node.operation)
        else COMPOSITES[node.operation](*inputs) if node.operation in COMPOSITES else inputs[0],
    'SEPXYZ': lambda node, inputs, index: ('DOT_PRODUCT', inputs[0], numpy.eye(3)[index]),
    'COMBXYZ': lambda node, inputs, index: vector(*inputs),
    'MAPPING': mapping, 'VECTOR_ROTATE': vector_rotate, 'VECT_TRANSFORM': vector_transform,
    'TEX_COORD': coordinates, 'CAMERA': lambda node, inputs, index: (normalize(('CAMERA_POINT',)),
        ('DOT_PRODUCT', ('CAMERA_POINT',), numpy.eye(3)[2]), length(('CAMERA_POINT',)))[index],
    'NEW_GEOMETRY': lambda node, inputs, index: {0: ('POSITION',), 1: facing(('NORMAL',)), 4: ('INCOMING',),
        6: ('BACKFACING',)}.get(index) or resolve(node.outputs[index]),
    'FRESNEL': fresnel, 'LAYER_WEIGHT': layer_weight, 'BUMP': bump,
    'VERTEX_COLOR': lambda node, inputs, index: ('VERTEX_ALPHA',) if index else ('VERTEX_COLOR',),
    'OBJECT_INFO': lambda node, inputs, index: ('OBJECT_INFO', index),
    'ATTRIBUTE': lambda node, inputs, index: (('VERTEX_COLOR',), ('VERTEX_COLOR',), ('DOT_PRODUCT', ('VERTEX_COLOR',),
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
        return {'Normal': ('NORMAL',), 'Coat Normal': ('NORMAL',), 'UV': ('UV',)}.get(socket.name, value)
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
        albedo, metallic, roughness, emissive, strength, transparency, ior, absorption, density, scatter = (get(source)
            if isinstance(source, str) else source for source in SHADERS.get(node.type, ('Color', 0, 1, 0, 0, 0, 1))
            + VOLUMES.get(node.type, (1, 0, 0)))
        if node.type == 'PRINCIPLED_VOLUME':  # Absorbs what it does not scatter by the absorption color, not its root
            absorption = 'SUBTRACT', 1, ('MULTIPLY', ('SUBTRACT', 1, absorption),
                ('MAXIMUM', 0, ('SUBTRACT', 1, scatter)))
        # The specular level scales the reflectance at normal incidence of the share not transmitted, as Cycles'; a
        # tint or level off Blender's defaults marks the tint, the shader compiling both out for scenes marking none
        tint, factor = get('Specular Tint', 1), get('Specular IOR Level', 0.5)
        level = mix(('MULTIPLY', factor, 2), 1, transparency)
        if any(isinstance(x, tuple) or numpy.any(x != y) for x, y in ((tint, 1), (factor, 0.5))):
            tint = 'SPECULAR', tint
        # Transmitting and refracting by the share of the energy not metallic, as Cycles' shaders mix it
        value = [get('Normal', ('NORMAL',)), albedo, metallic, roughness,
            ('MULTIPLY', ('MULTIPLY', emissive, strength), get('Alpha', 1)), ('MULTIPLY', transparency, ('SUBTRACT', 1,
            metallic)), ('ADD', 1, ('MULTIPLY', ('SUBTRACT', ior, 1), ('SUBTRACT', 1, metallic))),
            tint, level, get('Alpha', 1), absorption, density, scatter,
            ('TRANSLUCENT', get('Color')) if node.type == 'BSDF_TRANSLUCENT' else 0]
        # A coat follows as the surface of a clear dielectric covering by its weight, emitting nothing of its own
        weight = get('Coat Weight')
        if nonzero(weight):
            value.append([get('Coat Normal'), get('Coat Tint'), 0, get('Coat Roughness'), 0, 1, get('Coat IOR'), 1, 1,
                ('MULTIPLY', weight, get('Alpha', 1))])
    if hasattr(output, 'default_value') and animated(output): value = 'ANIMATED', value  # As of a value node
    if socket.type == 'VALUE' and output.type in WEIGHTS: return 'DOT_PRODUCT', value, WEIGHTS[output.type]
    if socket.type == 'SHADER' and not isinstance(value, list): value = [*BLACK[:4], value, *BLACK[5:]]  # Emits it
    return value

# The material's surface as rows, one per layer from the top: the row of its surface, filled by its volume, under that
# of a coat emitting in its place; black without an output; passing rays straight through without a surface shader
def shade(material, program):
    output = material.node_tree.get_output_node('CYCLES')
    if not output: return [program(BLACK)]
    surface, volume = resolve(output.inputs['Surface']), resolve(output.inputs['Volume'])[10:13]
    if output.inputs['Volume'].is_linked and not output.inputs['Surface'].is_linked:
        surface = [*BLACK[:9], 0, *BLACK[10:]]
    layers = [surface[:10]] if len(surface) == 14 else [[*surface[14][:4], surface[4], *surface[14][5:]],
        [*surface[:4], 0, *surface[5:10]]]
    # FlexLight's BSDF transmits apart from metallic reflection: its transmission is the share transmitted of the share
    # not metallic, its ior that of the share not metallic
    base = layers[-1]
    metallic, share = base[2], base[5]
    base[5] = 'DIVIDE', share, ('SUBTRACT', 1, metallic)
    base[6] = 'ADD', 1, ('DIVIDE', ('SUBTRACT', base[6], 1), ('SUBTRACT', 1, metallic))
    # The base layer transmits the surface's translucent color diffusely, a coat over it none
    attributes = [[*layer, *volume, surface[13] if layer is base else 0] for layer in layers]
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

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.visible = ()  # Names of the instances the renderer was last started on
        self.slots = {}  # First triangle, triangle count and key of each instance exported, by its index
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
        process = subprocess.Popen((BINARY + '-vulkan' * (self.device == 'VULKAN'), str(self.shared.fileno())),
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, pass_fds=(self.shared.fileno(),))
        self.requests = process.stdin
        self.answers = process.stdout
        process.stdin = process.stdout = None

    # Starts the renderer on the exported scene when what it renders changed. Blender also reports selection, scene
    # settings and cameras, which need none. Objects that only moved or deformed update their triangles in place, as
    # FlexLight updates the slots of its instances, while they keep their count and the key of their materials: camera
    # visibility, those of their slots and a light's radiance.
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
        # their handedness in object space, and per triangle its object's location, color, pass index, random number and
        # its material's pass index, as Cycles' object info node tells, then the object's axes
        columns = [[numpy.empty((0, *shape), 'f')] for shape in (*[(3, 3)] * 4, (3, 2), (3, 4), (3, 4), (19,))]
        materials = []
        ops, hints = [], {}  # Steps of all programs; the light power hint of each by its first
        textures = dict(self.shape[2]) if shaded else {}  # First texel, width, height and mean per image and ramp
        texels = [numpy.ones(4, 'f')]  # Linear floats after a white texel: the renderer loads no empty array
        baked, bakes, units, summaries, placed, again = [0], [], {}, {}, [], []  # Texels baked after those piped, each
        # bake's program, each unit's texture, what each expression of the surface the cut takes is as a unit, each
        # unit's place, and the bakes to run again. A unit's texture's steps, and the end before its program with its
        # first texel and size, count from the baked texels, as halves two to a texel, flagged in their height's bit 28.
        current = {}  # Of the object whose materials are shaded: the triangles of the material, their UVs, the scales
        # of its point inputs along them if they lie in [0, 1] without overlap, the bakes made over them
        places = self.placed if shaded else []  # The last export's units, which an update of values keeps in place
        def bake(expression, memo=None):  # Each part once per outermost call, as the recursions above
            memo = {} if memo is None else memo
            if id(expression) not in memo: memo[id(expression)] = baking(expression, memo)
            return memo[id(expression)]
        def baking(expression, memo):  # A unit of math, ramps and noise on the point inputs, costing two reads, baked
            # over its object's UVs at the resolution its frequencies need up to 4K, read at the UV;
            cost, inputs, size = summaries[id(expression)][2:5] if isinstance(expression, tuple) \
                else (None, set(), 0)
            size = current.get('scales') and cost is not None and inputs and cost >= 10 and size
            if not isinstance(expression, tuple) or not size or size > 4096 or baked[0] + size * size / 2 > BUDGET:
                if not isinstance(expression, tuple) or summaries[id(expression)][1] is None and len(
                        summaries[id(expression)][0]) == 1:  # Inexact on one image, live whole: baked parts add fetches
                    return expression  # Else as its operands are, but the alpha read an unassociation divides by
                return (expression[0], *(bake(part, memo) for part in expression[1:])) \
                    if expression[0] != 'UNASSOCIATE' else (expression[0], bake(expression[1], memo), expression[2])
            if (key := (int(current['triangles'][0]), expression_key(expression))) in units:  # As the emission's
                return 'BAKED', ('UV',), units[key]  # program of a material reads it again
            size, t = int(-(-max(64, size) // 16) * 16), current['uv'] * int(-(-max(64, size) // 16) * 16)
            low, high = (numpy.clip((f(1) + d) // 16, 0, size // 16 - 1).astype(int) for f, d in ((t.min, -1),
                (t.max, 1)))  # The 16 x 16 tiles of texels each triangle's UVs reach, a texel off its edges included
            n = (high - low + 1).prod(1)
            k, j = numpy.arange(n.sum()) - numpy.repeat(n.cumsum() - n, n), numpy.repeat(numpy.arange(len(n)), n)
            width = high[j, 0] - low[j, 0] + 1
            tiles = numpy.stack((current['triangles'][j], low[j, 0] + k % width, low[j, 1] + k // width, 0 * j), 1)
            # In an update of values the last export's unit, its steps and value again unless its expression changed
            tile, last, units[key], steps, value = places[len(bakes)] if len(bakes) < len(places) else (
                sum(map(len, texels)) // 4, None, Bake(), None, None)
            ops.append((0, tile, len(tiles), 0))
            texels.append(tiles.astype('u4').view('f').ravel())
            ops.append((0, baked[0], size, size | 1 << 28))
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
            textures[units[key]] = (baked[0], size, size | 1 << 28, numpy.array((*value, 1)))
            baked[0] += -(-size * size // 2)
            return 'BAKED', ('UV',), units[key]
        # Counted, then emitted keeping what it uses again, its colors associated as in the surface reads, its units
        def program(surface, reads=None, cut=not moved, emitted=True):  # baked, but in an update of moves: its bakes
            # the last's; with emitted false only cut
            surface, alpha, uses, slots = fold(surface), set(alpha_reads(reads or surface)), {}, {}
            if cut:  # Its expressions as units, all, then its units cut
                summaries.clear()
                for attribute in surface: summarize(attribute, summaries, current.get('scales'))
                surface = [bake(attribute) for attribute in surface]
            if not emitted: return surface
            surface, first = fold(unanimated(surface)), len(ops)
            # Its translucent color only marked: scenes without one run main's programs, the shader compiling it out
            if len(surface) == 14 and not marks(surface[13], 'TRANSLUCENT'): surface = surface[:13]
            emit(surface, [], textures, texels, alpha, uses)
            emitted = emit(surface, ops, textures, texels, alpha, uses, slots)
            # Each value kept for reuse takes the lowest slot free from its store to its last load, as the steps run
            # straight through, so a program needs only as many slots as it keeps values at once
            store, load = [*OPS].index('STORE'), [*OPS].index('LOAD')
            last, taken, renamed = {op[1]: k for k, op in enumerate(ops[first:], first) if op[0] == load}, set(), {}
            for k in range(first, len(ops)):
                code, slot = ops[k][:2]
                if code == store: renamed[slot] = min(set(range(len(taken) + 1)) - taken); taken.add(renamed[slot])
                if code in (store, load): ops[k] = (code, renamed[slot], 0, 0)
                if code == load and last[slot] == k: taken.discard(renamed[slot])
            assert max(renamed.values(), default=-1) < SLOTS, 'values a program keeps for reuse'
            # Opaque where it covers and passes nothing whatever the point: coverage 1, and ior not 1 or transparency 0
            scalar = lambda k: None if isinstance(surface[k], tuple) else numpy.float32(numpy.resize(surface[k], 3)[0])
            opaque = scalar(9) == 1 and (scalar(6) not in (None, 1) or scalar(5) == 0)
            hints[first] = max(emitted, 1e-6 if isinstance(surface[4], tuple) else 0)
            return hints[first], first, opaque
        rows = {None: [program(GRAY)]}  # Rows of the surface each material renders; an empty slot renders gray
        slots, volumes = [], {}  # Index, triangle count and key of each instance exported; BVHs of those filling volumes
        cuts = {}  # What each material of each object was cut over
        for i, instance in enumerate(depsgraph.object_instances):
            ob = instance.object
            bm = bmesh.new()
            if ob.hide_render or ob.type not in {'MESH', 'CURVE', 'SURFACE', 'FONT', 'META', 'LIGHT'} \
                or moved and ob.name not in moved and not (instance.is_instance and instance.parent.name in moved):
                continue
            if shaded and ob.type != 'LIGHT':  # Its rows alone, cut over its UVs as the last export's
                for slot in ob.material_slots:
                    if slot.material in rows or (slot.material, ob.name) in rows: continue
                    current.update(self.cuts.get((slot.material, ob.name), {'scales': None}), made=[])
                    row = shade(slot.material, program)
                    rows[(slot.material, ob.name) if current['made'] else slot.material] = row
                current.clear()
                continue
            if ob.type != 'LIGHT':  # Per corner of its triangles: index, vertex, normal (smooth, sharp or custom), UV
                mesh = ob.to_mesh()
                # Generated coordinates of the undeformed mesh, through the orco layer Cycles reads, which the mesh
                # loses when triangulated; of a mesh its modifiers only deform, the same vertices in the same order,
                # its original's, which a depsgraph evaluated for no render, as the viewport's first, holds no such layer
                # of; of others, which make vertices of their own, that layer, if any
                rest = ob.original.data if ob.original.type == 'MESH' and len(ob.original.data.vertices) \
                    == len(mesh.vertices) else mesh
                orco = numpy.empty(3 * len(mesh.vertices), 'f')
                rest.vertices.foreach_get('co' if rest is not mesh else 'undeformed_co', orco)
                orco = (orco.reshape(-1, 3) - rest.texspace_location) / (2 * numpy.array(rest.texspace_size)) + 0.5
                if any(face.loop_total > 4 for face in mesh.polygons):
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
                if mesh.uv_layers.active: mesh.uv_layers.active.uv.foreach_get('vector', uv)
                else:  # Cycles makes default tangents from spherical coordinates of the mesh's positions
                    p = co.reshape(-1, 3)[vertex]
                    lengths = numpy.linalg.norm(p, axis=1)
                    sphere = numpy.column_stack((numpy.where(numpy.any(p[:, :2], axis=1),
                        0.5 - numpy.arctan2(p[:, 0], p[:, 1]) / (2 * math.pi), 0), numpy.where(lengths > 0,
                        1 - numpy.arccos(numpy.clip(p[:, 2] / numpy.maximum(lengths, 1e-30), -1, 1)) / math.pi, 0)))
                    mesh.uv_layers.new().uv.foreach_set('vector', sphere.ravel())
                if mesh.polygons: mesh.calc_tangents()  # Of faces, which curves without a bevel have none of
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
                matrix = numpy.array(instance.matrix_world)
                positions = (co.reshape(-1, 3) @ matrix[:3, :3].T + matrix[:3, 3])[vertex[loops]].reshape(-1, 3, 3)
                if (filled := numpy.flatnonzero(numpy.isin(index, [k for k, slot in enumerate(ob.material_slots)
                        if slot.material and (output := slot.material.node_tree.get_output_node('CYCLES'))
                        and output.inputs['Volume'].is_linked]))).size:
                    volumes[i] = BVHTree.FromPolygons(positions.reshape(-1, 3).tolist(),
                        numpy.arange(3 * len(positions)).reshape(-1, 3).tolist()), int(filled[0])
                normals = normal.reshape(-1, 3)[loops] @ numpy.array(instance.matrix_world.to_3x3().adjugated())
                normals /= numpy.linalg.norm(normals, axis=1, keepdims=True)
                uv = uv.reshape(-1, 2)[loops].reshape(-1, 3, 2)
                orco = orco[vertex[loops]].reshape(-1, 3, 3)
                point = co.reshape(-1, 3)[vertex[loops]].reshape(-1, 3, 3)
                color = color[loops].reshape(-1, 3, 4)
                for slot in ob.material_slots:  # Of a material with units baked over this object's UVs, its own row
                    if slot.material in rows or (slot.material, ob.name) in rows: continue
                    mask = numpy.isin(index, [k for k, other in enumerate(ob.material_slots)
                        if other.material == slot.material])
                    t = uv[mask]
                    flat = numpy.abs((t[:, 1, 0] - t[:, 0, 0]) * (t[:, 2, 1] - t[:, 0, 1]) - (t[:, 1, 1] - t[:, 0, 1])
                        * (t[:, 2, 0] - t[:, 0, 0])).sum() / 2
                    current.update(triangles=sum(map(len, columns[0])) + numpy.nonzero(mask)[0], uv=t, made=[],
                        scales=not (moved or trivial(slot.material)) and 0 < flat <= 1 and 0 <= t.min() and t.max() <= 1
                        and {'GENERATED': stretch(orco[mask], t)})
                    cuts[(slot.material, ob.name)] = dict(current)
                    row = shade(slot.material, program)
                    rows[(slot.material, ob.name) if current['made'] else slot.material] = row
                current.clear()
                shades = [rows.get((slot.material, ob.name), rows.get(slot.material)) for slot in ob.material_slots] \
                    or [rows[None]]
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
                    disk(bm, 32, *2 * [2 * SUN_DISTANCE * math.tan(max(light.angle, SUN_MIN_ANGLE) / 2)], SUN_DISTANCE)
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
                uv, orco, point, color, tangent = (numpy.zeros((len(bm.faces), 3, n), 'f') for n in (2, 3, 3, 4, 4))
                index = numpy.array([face.material_index for face in bm.faces], 'i')
            passes = numpy.array([slot.material and slot.material.pass_index or 0 for slot in ob.material_slots] or [0])
            # Cycles' random number of an object, not instanced, by Jenkins' hash of its name's
            random = instance.random_id / 0xFFFFFFFF if instance.is_instance else hashed(functools.reduce(
                lambda h, c: (h * 37 + c) & 0xFFFFFFFF, ob.name.encode(), 0), 0)
            info = numpy.tile([*instance.matrix_world.translation, *ob.color, ob.pass_index, 0, random,
                *numpy.array(instance.matrix_world.to_3x3()).T.ravel()], (len(index), 1))
            info[:, 8] = passes[numpy.minimum(index, len(passes) - 1)]
            # Triangles, normals turned as the faces turn, a material of its row each
            for column, array in zip(columns, (positions, normals.reshape(-1, 3, 3), orco, point, uv, color, tangent,
                info)): column.append(array)
            table = numpy.array([(*row[0][:2], not ob.visible_camera, len(row), any(layer[2] for layer in row),
                row[0][3] if len(row[0]) > 3 else row[0][1]) for row in shades])
            materials.append(table[index])
            slots.append((i, len(positions), (ob.visible_camera, [slot.material and slot.material.name
                for slot in ob.material_slots], ob.type == 'LIGHT' and f'{radiance:.4g}')))
        # Update on stdin: slot count; per slot its first triangle and triangle count, then its arrays as in a scene
        if moved:
            if not all(self.slots.get(i, ())[1:] == (count, key) for i, count, key in slots):
                self.visible = None
                return self.start(depsgraph)
            self.volumes.update(volumes)
            self.requests.writelines((struct.pack('<2I', UPDATE, len(slots)), *(array for k, (i, count, _) in
                enumerate(slots) for array in (struct.pack('<2I', self.slots[i][0], count),
                *(column[k + 1].astype('f') for column in columns)))))
            return
        world = scene.world and scene.world.node_tree.get_output_node('CYCLES')
        world = program(resolve(world.inputs['Surface']) if world else BLACK)
        materials.append([(*world[:2], 0, 1, 0, world[1])])
        shape = [op[0] for op in ops], [(row[1], row[2], row[0] > 0, *row[3:]) for layers in rows.values()
            for row in layers], textures
        piped = self.piped if shaded else sum(map(len, texels)) // 4
        ops = [(code, texel + piped, width, height & ~(1 << 28)) if (code == 0 or [*OPS][code] in READS)
            and height >> 28 & 1 else (code, texel, width, height) for code, texel, width, height in ops]
        if shaded:  # Steps on stdin: their count, then the steps as in a scene, while their codes, the rows and the
            if shape[:2] != self.shape[:2] or len(textures) != len(self.shape[2]) or any(  # textures keep their shape
                    textures[key][:3] != entry[:3] for key, entry in self.shape[2].items() if isinstance(key, Bake)):
                self.visible = None
                return self.start(depsgraph)
            read = {texel for code, texel, *_ in ops if [*OPS][code].startswith(('IMAGE', 'ALPHA'))}  # The tables
            tables = {key: [] for key, entry in textures.items()
                if not isinstance(key, (tuple, Bake)) and entry[0] in read}
            means = {key: texture(key, {}, tables[key])[3] for key in tables}  # read, rebuilt; their means, which the
            if any((means[key] != textures[key][3]).any() for key in tables):  # hints take, as the renderer has them
                self.shape[2].update({key: (*textures[key][:3], means[key]) for key in tables})
                return self.start(depsgraph)
            # Then per table its first texel, width and texels, until a width of 0; per program its first step and
            # light power hint, until a first of 2^32 - 1; then the count and programs of the bakes to run again
            self.requests.writelines((struct.pack('<2I', STEPS, len(ops)), numpy.array(ops, 'I'), *(part for key in
                tables for part in (struct.pack('<2I', *textures[key][:2]), *tables[key])), struct.pack('<2I', 0, 0),
                numpy.array([*hints.items(), (2 ** 32 - 1, 0)], 'u4, f4'), struct.pack('<I', len(again)),
                numpy.array(again, 'I')))
            return
        self.shape = shape
        firsts = numpy.cumsum([0] + [count for _, count, _ in slots])
        self.slots = {i: (int(first), count, key) for (i, count, key), first in zip(slots, firsts)}
        self.volumes = volumes
        self.cuts, self.placed, self.piped = cuts, placed, piped
        materials = numpy.concatenate(materials)
        # Scene on stdin: triangle, step, texel, baked texel and bake counts; per triangle 9 vertex, 9 normal, 9
        # generated, 9 object, 6 UV, 12 color, 12 tangent and 19 info floats, a material of its emission, program,
        # hidden flag, layer count, opaque flag and emission program (then the world's); then the steps of 4 integers,
        # the texels and the programs of the bakes.
        self.requests.writelines((struct.pack('<6I', SCENE, firsts[-1], len(ops), piped, baked[0], len(bakes)),
            *(numpy.concatenate(column, dtype='f') for column in columns),
            numpy.hstack((materials[:, :1].astype('f').view('I'), materials[:, 1:].astype('I'))),
            numpy.array(ops, 'I'), *texels, numpy.array(bakes, 'I')))

    # Samples launched, then radiance sums and sample count per pixel, rows bottom to top, after up to launches more
    # samples, at most the first of sampling's samples or, reusing the last view's reservoirs, the second, of the view
    # from the camera's matrix through its perspective projection under the settings; none launched if the view already
    # had its samples. A view other than the last starts over.
    def trace(self, width, height, sampling, launches, settings, matrix, projection, camera=None):
        right = matrix.col[0].xyz
        up = matrix.col[1].xyz
        back = matrix.col[2].xyz
        x = right / projection[0][0]
        y = up / projection[1][1]
        center = x * projection[0][2] + y * projection[1][2] - back
        # The volume the camera is in: of an instance filling one that a ray up from the camera leaves an odd number of
        # times, its first triangle of a material filling it, or none
        medium = next((self.slots[i][0] + first for i, (tree, first) in self.volumes.items()
            if inside(tree, matrix.translation)), 2 ** 32 - 1)
        # Request on stdin: sampling, launches, size, settings, the volume the camera is in, the camera's origin and its
        # ray direction per NDC x, per NDC y and at the center, then the thin lens.
        self.requests.write(struct.pack(f'<3I2f{4 + len(settings)}I17f', REQUEST, *sampling, launches, width, height,
            *settings, medium, *matrix.translation, *x, *y, *center, *lens(camera)))
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
            camera.evaluated_get(depsgraph) if camera else None)
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
CLASSES = (FlexPreferences, Flex, RENDER_PT_flex, RENDER_PT_flex_restir)

# Timer: once make install has replaced this build, has Blender unregister, reload and register the extension
def reload():
    if os.path.exists(__file__) and os.path.getmtime(__file__) != MODIFIED:
        bpy.app.timers.register(lambda: addon_utils.enable(__package__) and None)
    return 1

def register():
    for binary in (BINARY, BINARY + '-vulkan'): os.chmod(binary, 0o755)  # Extension installs drop the executable bit
    global runnable  # Started without a file, a renderer exits once its device is up, failing without one
    runnable = tuple(key for key, suffix in BACKENDS if not subprocess.run((BINARY + suffix,),
        stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode)
    bpy.app.timers.register(reload, persistent=True)
    for name, prop in PROPERTIES.items(): setattr(bpy.types.Scene, name, prop)
    for cls in CLASSES: bpy.utils.register_class(cls)
    preferences = bpy.context.preferences.addons[__package__].preferences
    if runnable and preferences.device not in runnable: preferences.device = runnable[0]
    for name in PANELS: getattr(bpy.types, name).COMPAT_ENGINES.add(Flex.bl_idname)
    for handlers, handler in HANDLERS: handlers.append(handler)

def unregister():
    bpy.app.timers.unregister(reload)
    for handlers, handler in HANDLERS: handlers.remove(handler)
    for name in PANELS: getattr(bpy.types, name).COMPAT_ENGINES.remove(Flex.bl_idname)
    for cls in reversed(CLASSES): bpy.utils.unregister_class(cls)
    for name in PROPERTIES: delattr(bpy.types.Scene, name)
