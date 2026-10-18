# Blender render engine: exports the scene as world-space triangles and path traces it with the bundled OptiX binary.
import addon_utils, bpy, bmesh, gpu, math, mmap, numpy, os, struct, subprocess, time
from gpu_extras.presets import draw_texture_2d
from mathutils import Matrix
from bl_ui.properties_data_camera import classes as CAMERA_PANELS

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
# emission
OPS = {'END': lambda *surface: numpy.sum(numpy.resize(surface[4], 3)), **dict.fromkeys(('PUSH', 'UV', 'NORMAL', 'IMAGE',
    'ALPHA', 'NORMAL_MAP')), 'ADD': numpy.add, 'SUBTRACT': numpy.subtract, 'MULTIPLY': numpy.multiply,
    'DOT_PRODUCT': numpy.dot, 'MAXIMUM': numpy.maximum, 'LOGARITHM': logarithm,
    'MULTIPLY_ADD': lambda a, b, c: a * b + c, **dict.fromkeys(('IMAGE_LINEAR', 'ALPHA_LINEAR')),
    'DIVIDE': divide, 'SNAP': lambda a, b: numpy.floor(divide(a, b)) * b, **dict.fromkeys(('GENERATED', 'NOISE',
    'IMAGE_CUBIC', 'ALPHA_CUBIC')), 'POWER': power, 'EXPONENT': numpy.exp,
    'MINIMUM': numpy.minimum, 'LESS_THAN': lambda a, b: (a < b) * 1.0, 'FLOOR': numpy.floor,
    'MODULO': lambda a, b: numpy.fmod(a, b, out=numpy.zeros(3), where=b != 0), 'SINE': numpy.sin, 'COSINE': numpy.cos,
    'TANGENT': numpy.tan, 'ARCSINE': lambda a: numpy.arcsin(numpy.clip(a, -1, 1)),
    'ARCCOSINE': lambda a: numpy.arccos(numpy.clip(a, -1, 1)), 'ARCTANGENT': numpy.arctan, 'ARCTAN2': numpy.arctan2,
    'SINH': numpy.sinh, 'COSH': numpy.cosh, 'TANH': numpy.tanh, 'CROSS_PRODUCT': numpy.cross, 'RGB_TO_HSV': to_hsv,
    'HSV_TO_RGB': from_hsv, 'RGB_TO_HSL': to_hsl, 'HSL_TO_RGB': from_hsl,
    'ROTATE': lambda v, k, a: v * numpy.cos(a) + numpy.cross(k, v) * numpy.sin(a)
        + k * numpy.dot(k, v) * (1 - numpy.cos(a)), 'EQUIRECTANGULAR': equirectangular, 'MIRROR_BALL': mirror_ball,
    **dict.fromkeys(('POSITION', 'INCOMING', 'BACKFACING', 'DIELECTRIC', 'LIGHT_PATH', 'WHITE_NOISE', 'VORONOI',
    'STORE', 'LOAD'))}
# Surface: expressions of its normal, albedo, metallic, roughness, emissive, transparency, ior, specular tint, specular
# level, coverage, absorption and density
GRAY = [('NORMAL',), 0.8, 0, 0.5, 0, 0, 1, 1, 1, 1, 1, 0]
BLACK = [('NORMAL',), 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0]
# Albedo, metallic, roughness, emissive, its strength, transparency and ior per shader node, each the name of an input
# or a constant; an ior of 1 reflects nothing specularly, as Cycles' diffuse shaders. Volume shaders on surfaces
# reflect nothing, and rays pass through a portal without a position or direction; any other shader is diffuse.
SHADERS = {'BSDF_PRINCIPLED': ('Base Color', 'Metallic', 'Roughness', 'Emission Color', 'Emission Strength',
        'Transmission Weight', 'IOR'), 'BSDF_METALLIC': ('Base Color', 1, 'Roughness', 0, 0, 0, 1.5),
    'EEVEE_SPECULAR': ('Base Color', 0, 'Roughness', 'Emissive Color', 1, 'Transparency', 1.5),
    **dict.fromkeys(('PRINCIPLED_VOLUME', 'VOLUME_ABSORPTION', 'VOLUME_SCATTER', 'VOLUME_COEFFICIENTS'),
        (0, 0, 1, 0, 0, 0, 1)), 'BSDF_RAY_PORTAL': ('Color', 0, 0, 0, 0, 1, 1),
    'BSDF_GLOSSY': ('Color', 1, 'Roughness', 0, 0, 0, 1.5), 'BSDF_GLASS': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'),
    'BSDF_REFRACTION': ('Color', 0, 'Roughness', 0, 0, 1, 'IOR'), 'BSDF_TRANSPARENT': ('Color', 0, 0, 0, 0, 1, 1),
    'EMISSION': (0, 0, 1, 'Color', 'Strength', 0, 1), 'BACKGROUND': (0, 0, 1, 'Color', 'Strength', 0, 1)}
# Absorption color and density per volume shader node; any other absorbs nothing
VOLUMES = {'VOLUME_ABSORPTION': ('Color', 'Density'), 'PRINCIPLED_VOLUME': ('Absorption Color', 'Density')}
# Luminance of a color and mean of a vector, as Blender converts them to values
WEIGHTS = {'RGBA': numpy.array((0.2126, 0.7152, 0.0722)), 'VECTOR': numpy.full(3, 1 / 3)}
# Blender's material and camera panels the engine shows
PANELS = ('EEVEE_MATERIAL_PT_context_material', 'EEVEE_MATERIAL_PT_surface', 'MATERIAL_PT_custom_props',
    'MATERIAL_PT_animation', *(panel.__name__ for panel in CAMERA_PANELS))
SCENE, REQUEST, UPDATE = range(3)  # Kinds of what the renderer is piped

def span(node):  # Of the points of a curves node's curves
    curves = node.mapping.curves
    return min(curve.points[0].location[0] for curve in curves), max(curve.points[-1].location[0] for curve in curves)

def table(node):  # 256 colors of a ramp, or of a curves node's curves over their span, of RGB curves after the combined
    if node.type == 'VALTORGB': return [node.color_ramp.evaluate(i / 255) for i in range(256)]
    mapping, curves = node.mapping, [*node.mapping.curves]
    mapping.initialize()
    rgb = node.type == 'CURVE_RGB'
    return [[*(mapping.evaluate(curve, mapping.evaluate(curves[3], x) if rgb else x) for curve in (curves * 3)[:3]), 1]
        for x in numpy.linspace(*span(node), 256)]

def decode(srgb):  # sRGB to linear
    return numpy.where(srgb <= 0.04045, srgb / 12.92, ((srgb + 0.055) / 1.055) ** 2.4)

# First texel, width, height and mean of an image or of a ramp or curves node's 256 colors, added as linear floats at
# first use
def texture(source, textures, texels):
    if isinstance(source, ImageRead): source = source.node
    if source not in textures:
        ramp = source.type not in ('TEX_IMAGE', 'TEX_ENVIRONMENT')
        image = source if ramp else source.image
        pixels = numpy.empty(1024 if ramp else len(image.pixels), 'f')
        if ramp: pixels[:] = numpy.ravel(table(source))
        else: image.pixels.foreach_get(pixels)
        if not (ramp or image.is_float or image.colorspace_settings.is_data):
            pixels.reshape(-1, 4)[:, :3] = decode(pixels.reshape(-1, 4)[:, :3])
        if not ramp and image.alpha_mode == 'STRAIGHT' and not image.colorspace_settings.is_data:  # As Cycles keeps
            pixels.reshape(-1, 4)[:, :3] *= pixels.reshape(-1, 4)[:, 3:]  # them, associated
        if not ramp and image.alpha_mode == 'NONE': pixels.reshape(-1, 4)[:, 3] = 1
        textures[source] = (sum(map(len, texels)) // 4, *((256, 1) if ramp else image.size),
            pixels.reshape(-1, 4).mean(0))
        texels.append(pixels)
    return textures[source]

def expression_key(expression):
    if isinstance(expression, tuple): return tuple(map(expression_key, expression))
    if isinstance(expression, ImageRead): return expression.key
    if isinstance(expression, (int, float, numpy.number, numpy.ndarray)):
        return tuple(numpy.resize(expression, 3).astype('f'))
    return expression

class ImageRead:  # Samples Cycles can merge share whether their alpha is read
    def __init__(self, node, point):
        self.node = node
        self.key = (node.image, node.interpolation, node.projection, getattr(node, 'projection_blend', 0),
            getattr(node, 'extension', 'REPEAT'), expression_key(fold(point)))

def alpha_reads(expression):  # Image samples whose alpha contributes to the resolved surface
    if isinstance(expression, list):
        for part in expression: yield from alpha_reads(part)
    elif isinstance(expression, tuple):
        name, *operands = expression
        if name in ('ALPHA', 'ALPHA_LINEAR', 'ALPHA_CUBIC') and isinstance(operands[-1], ImageRead):
            yield operands[-1].key
        for part in operands[:1] if name == 'UNASSOCIATE' else operands: yield from alpha_reads(part)

# Appends the steps of an expression to ops, operands first, a surface's seven before an end; returns its value under
# textures of their mean. Without slots it counts in uses each expression met, entering none twice; with them those met
# again are kept in a slot and loaded.
def emit(expression, ops, textures, texels, alphas, uses, slots=None):
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
    if name == 'UNASSOCIATE':
        return emit(('DIVIDE', *operands) if operands[1][-1].key in alphas else operands[0], ops, textures, texels,
            alphas, uses, slots)
    payload = texture(operands.pop(), textures, texels) if name in ('IMAGE', 'ALPHA', 'IMAGE_LINEAR',
        'ALPHA_LINEAR', 'IMAGE_CUBIC', 'ALPHA_CUBIC') else (0, 0, 0, numpy.ones(4))
    values = [emit(operand, ops, textures, texels, alphas, uses, slots) for operand in operands]
    ops.append(([*OPS].index(name), *payload[:3]))
    if name == 'LIGHT_PATH': return float(values[0] >= 8)  # Of no ray, length and depth one, as light sampling shades
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
    if name != 'UNASSOCIATE' and OPS[name] and not any(isinstance(operand, tuple) for operand in operands):
        return OPS[name](*(numpy.resize(operand, 3) for operand in operands))
    return name, *operands

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
    if node.data_type == 'FLOAT' and any(isinstance(fold(v), tuple) for v in inputs):
        value = 'MULTIPLY', value, ('LESS_THAN', 0, absolute(('SUBTRACT', high, low)))
    return between(value, to_low, to_high) if node.clamp else value

def hue_saturation(hue, saturation, value, factor, color):  # Of a hue saturation value node, as Cycles'
    hsv = 'RGB_TO_HSV', color
    hsv = 'ADD', ('ADD', ('MULTIPLY', fraction(('ADD', hsv, ('ADD', hue, 0.5))), numpy.eye(3)[0]),
        ('MULTIPLY', clamp(('MULTIPLY', hsv, saturation)), numpy.eye(3)[1])), ('MULTIPLY', ('MULTIPLY', hsv, value),
        numpy.eye(3)[2])
    return 'MAXIMUM', mix(color, ('HSV_TO_RGB', hsv), factor), 0

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

def offset(seed):  # Cycles' random offset of noise by the seed: Jenkins' hash of it with each axis, as floats
    def hash(*keys):
        v = [(0xdeadbeef + 21 + key) & 0xFFFFFFFF for key in (*keys, 0)]
        for t, s, k in ((2, 1, 14), (0, 2, 11), (1, 0, 25), (2, 1, 16), (0, 2, 4), (1, 0, 14), (2, 1, 24)):
            v[t] = ((v[t] ^ v[s]) - (v[s] << k | v[s] >> 32 - k)) & 0xFFFFFFFF
        return v[2] / 0xFFFFFFFF
    bits = lambda value: struct.unpack('<I', struct.pack('<f', value))[0]
    return numpy.array([100 + 100 * hash(bits(seed), bits(axis)) for axis in range(3)])

# Of a noise texture node, as Cycles' of 3D points, which it takes in any dimension, at the generated point without a
# vector: its fractal, the type of which the renderer numbers, at the point distorted by signed noise, for its color
# also at two offsets
def noise(node, inputs, index):
    get = dict(zip((socket.name for socket in node.inputs if socket.enabled), inputs)).get
    point = get('Vector') if get('Vector') is not None and node.inputs['Vector'].is_linked else ('GENERATED',)
    kind = 'UNNORMALIZED' if node.noise_type == 'FBM' and not node.normalize else node.noise_type
    kind = ('FBM', 'UNNORMALIZED', 'MULTIFRACTAL', 'HETERO_TERRAIN', 'HYBRID_MULTIFRACTAL',
        'RIDGED_MULTIFRACTAL').index(kind)
    fractal = lambda p: ('NOISE', p, vector(get('Detail'), get('Roughness'), get('Lacunarity')),
        vector(get('Offset', 0), get('Gain', 0), kind))
    point, distortion = ('MULTIPLY', point, get('Scale')), get('Distortion')
    if isinstance(distortion, tuple) or numpy.any(distortion):
        signed = lambda seed: ('NOISE', ('ADD', point, offset(seed)), numpy.array((0, 0, 1)), numpy.array((0, 0, 1)))
        point = 'ADD', point, ('MULTIPLY', vector(signed(0), signed(1), signed(2)), distortion)
    if not index: return fractal(point)
    return vector(fractal(point), fractal(('ADD', point, offset(3))), fractal(('ADD', point, offset(4))))

# Of a white noise texture node, its value or color, of four dimensions as of three, as Cycles'
def white_noise(node, inputs, index):
    dimensions = int(node.noise_dimensions[0])
    return 'WHITE_NOISE', inputs[0], numpy.array((min(dimensions, 3), index, 0))

# Of a Voronoi texture node's distance, color or position, as Cycles' of 3D points, which it takes in any dimension, at
# the generated point without a vector, the distance normalized by the farthest its metric makes it
def voronoi(node, inputs, index):
    get = dict(zip((socket.name for socket in node.inputs if socket.enabled), inputs)).get
    point = get('Vector') if get('Vector') is not None and node.inputs['Vector'].is_linked else ('GENERATED',)
    metric = ('EUCLIDEAN', 'MANHATTAN', 'CHEBYCHEV', 'MINKOWSKI').index(node.distance)
    value = 'VORONOI', ('MULTIPLY', point, get('Scale')), vector(('F1', 'F2', 'SMOOTH_F1').index(node.feature), metric,
        get('Exponent', 1)), vector(get('Randomness'), get('Smoothness', 0), index)
    if index == 2: return 'DIVIDE', value, get('Scale')
    if index or not node.normalize: return value
    farthest = ('POWER', 3, ('DIVIDE', 1, get('Exponent'))) if metric == 3 else (3 ** 0.5, 3, 1)[metric]
    return 'DIVIDE', value, ('MULTIPLY', ('ADD', 0.5, ('MULTIPLY', 0.5, clamp(get('Randomness')))),
        ('MULTIPLY', farthest, 2 if node.feature == 'F2' else 1))

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
    if isinstance(distortion, tuple) or numpy.any(distortion): n = 'ADD', n, ('MULTIPLY', distortion, ('SUBTRACT',
        ('MULTIPLY', ('NOISE', ('MULTIPLY', p, detail_scale), vector(detail, roughness, 2), numpy.zeros(3)), 2), 1))
    if node.wave_profile == 'SIN': return 'ADD', 0.5, ('MULTIPLY', 0.5, ('SINE', ('SUBTRACT', n, math.pi / 2)))
    n = 'DIVIDE', n, 2 * math.pi
    return fraction(n) if node.wave_profile == 'SAW' else ('MULTIPLY', absolute(('SUBTRACT', n, ('FLOOR', ('ADD', n,
        0.5)))), 2)

def facing(normal):  # Turned toward the incoming direction on the backs of faces, as Cycles' shading normals
    return 'MULTIPLY', normal, ('SUBTRACT', 1, ('MULTIPLY', ('BACKFACING',), 2))

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
        node.mapping.initialize()
        looked = node.mapping.evaluate(node.mapping.curves[0], float(numpy.resize(fold(value), 3)[0]))
        return mix(value, between(looked, node.mapping.clip_min_y, node.mapping.clip_max_y)
            if node.mapping.use_clip else looked, factor)
    low, high = span(node)
    f = 'DIVIDE', ('SUBTRACT', value, low), high - low
    looked = lookup(node, f, 0) if node.type == 'CURVE_FLOAT' else vector(*(lookup(node, ('DOT_PRODUCT', f,
        numpy.eye(3)[k]), k) for k in range(3)))
    return mix(value, looked, factor)

# Color or alpha of an image node at its vector, pink when missing, of an environment node along its projected
# direction. Cycles dissociates colors from their alpha where reading it unless the image packs channels, ignores its
# alpha, which is one then, or holds data.
def image(node, inputs, index):
    if not (node.image and node.image.size[0]): return numpy.array((1, 0, 1))
    source = ImageRead(node, inputs[0] if node.inputs[0].is_linked else ('UV',))
    vector = inputs[0] if node.inputs[0].is_linked else ('UV',)
    if node.type == 'TEX_ENVIRONMENT':
        vector = node.projection, inputs[0] if node.inputs[0].is_linked else ('GENERATED',)
    read = lambda name: (name + {'Linear': '_LINEAR', 'Cubic': '_CUBIC', 'Smart': '_CUBIC'}.get(node.interpolation,
        ''), vector, source)
    if index or node.image.alpha_mode in (
            'CHANNEL_PACKED', 'NONE') or node.image.colorspace_settings.is_data: return read(('IMAGE', 'ALPHA')[index])
    return 'UNASSOCIATE', read('IMAGE'), read('ALPHA')

# The nodes resolved exactly: the expression of an output by its index, given those of the node's enabled inputs. An
# image is read at the UV without a vector and is pink when missing; mixes blend plainly unless by an operation. A
# normal map bends the normal by its strength toward the color's normal in tangent space and keeps it in any other
# space. Added shaders sum their iors' excess over 1, as Cycles sums their reflections. Of texture coordinates only the
# generated and reflection ones are known.
NODES = {'NORMAL_MAP': lambda node, inputs, index: mix(('NORMAL',), ('NORMAL_MAP', inputs[1]), inputs[0])
        if node.space == 'TANGENT' else ('NORMAL',), 'REROUTE': lambda node, inputs, index: inputs[0],
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
    'HUE_SAT': lambda node, inputs, index: hue_saturation(*inputs),
    'SEPARATE_COLOR': lambda node, inputs, index: ('DOT_PRODUCT', MODES[node.mode][0](inputs[0]), numpy.eye(3)[index]),
    'COMBINE_COLOR': lambda node, inputs, index: MODES[node.mode][1](NODES['COMBXYZ'](node, inputs, index)),
    'CURVE_RGB': curves, 'CURVE_VEC': curves, 'CURVE_FLOAT': curves,
    'MIX': blend, 'MAP_RANGE': map_range, 'CLAMP': lambda node, inputs, index: between(*inputs)
        if node.clamp_type == 'RANGE' else ('MINIMUM', ('MAXIMUM', inputs[0], inputs[1]), inputs[2]),
    'ADD_SHADER': lambda node, inputs, index: [mix(a, b, 0.5) if attribute in (2, 3, 7, 8, 10, 12)
        else ('SUBTRACT', ('ADD', a, b), 1) if attribute in (6, 9) else ('ADD', a, b)
        for attribute, (a, b) in enumerate(zip(*inputs))],
    'MATH': lambda node, inputs, index: (node.operation, *inputs) if OPS.get(node.operation)
        else COMPOSITES[node.operation](*inputs) if node.operation in COMPOSITES else inputs[0],
    'SEPXYZ': lambda node, inputs, index: ('DOT_PRODUCT', inputs[0], numpy.eye(3)[index]),
    'COMBXYZ': lambda node, inputs, index: vector(*inputs),
    'MAPPING': mapping, 'VECTOR_ROTATE': vector_rotate,
    'TEX_COORD': lambda node, inputs, index: ('GENERATED',) if not index else ('SUBTRACT', ('MULTIPLY',
        facing(('NORMAL',)), ('MULTIPLY', ('DOT_PRODUCT', facing(('NORMAL',)), ('INCOMING',)), 2)), ('INCOMING',))
        if index == 6 else resolve(node.outputs[index]),
    'NEW_GEOMETRY': lambda node, inputs, index: {0: ('POSITION',), 1: facing(('NORMAL',)), 4: ('INCOMING',),
        6: ('BACKFACING',)}.get(index) or resolve(node.outputs[index]),
    'FRESNEL': fresnel, 'LAYER_WEIGHT': layer_weight, 'LIGHT_PATH': lambda node, inputs, index: ('LIGHT_PATH', index)
        if index in (0, 1, 2, 3, 5, 6, 8, 9) else resolve(node.outputs[index]),
    'TEX_NOISE': noise, 'TEX_WHITE_NOISE': white_noise, 'TEX_GRADIENT': gradient, 'TEX_CHECKER': checker,
    'TEX_WAVE': wave, 'TEX_VORONOI': voronoi}
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
        albedo, metallic, roughness, emissive, strength, transparency, ior, absorption, density = (get(source)
            if isinstance(source, str) else source for source in SHADERS.get(node.type, ('Color', 0, 1, 0, 0, 0, 1))
            + VOLUMES.get(node.type, (1, 0)))
        # The specular level scales the reflectance at normal incidence of the share not transmitted, as Cycles'
        level = mix(('MULTIPLY', get('Specular IOR Level', 0.5), 2), 1, transparency)
        value = [get('Normal', ('NORMAL',)), albedo, metallic, roughness,
            ('MULTIPLY', ('MULTIPLY', emissive, strength), get('Alpha', 1)), transparency, ior,
            get('Specular Tint', 1), level, get('Alpha', 1), absorption, density]
        # A coat follows as the surface of a clear dielectric covering by its weight, emitting nothing of its own
        weight = get('Coat Weight')
        if isinstance(weight, tuple) or numpy.any(weight):
            value.append([get('Coat Normal'), get('Coat Tint'), 0, get('Coat Roughness'), 0, 1, get('Coat IOR'), 1, 1,
                ('MULTIPLY', weight, get('Alpha', 1))])
    if socket.type == 'VALUE' and output.type in WEIGHTS: return 'DOT_PRODUCT', value, WEIGHTS[output.type]
    if socket.type == 'SHADER' and not isinstance(value, list): value = [*BLACK[:4], value, *BLACK[5:]]  # Emits it
    return value

# The material's surface as rows, one per layer from the top or none: the row of its surface, absorbing as its volume,
# under that of a coat emitting in its place; black without an output; none for volumes without a surface shader
def shade(material, program):
    output = material.node_tree.get_output_node('CYCLES')
    if not output: return [program(BLACK)]
    if output.inputs['Volume'].is_linked and not output.inputs['Surface'].is_linked:
        return []
    surface, volume = resolve(output.inputs['Surface']), resolve(output.inputs['Volume'])[10:12]
    layers = [surface[:10]] if len(surface) == 12 else [[*surface[12][:4], surface[4], *surface[12][5:]],
        [*surface[:4], 0, *surface[5:10]]]
    return [program([*layer, *volume]) for layer in layers]

def disk(bm, sides, x, y, z):  # Polygon at height z around the ellipse with diameters x, y
    bmesh.ops.create_circle(bm, cap_ends=True, segments=sides, radius=0.5 / math.cos(math.pi / sides),
        matrix=Matrix.Translation((0, 0, z)) @ Matrix.Diagonal((x, y, 1, 1)) @ Matrix.Rotation(math.pi / sides, 4, 'Z'))

def settings(scene, viewport):  # The scene's settings of the renderer, in its order; the viewport denoises every result
    return scene.flex_restir, scene.flex_decorrelation, scene.flex_neighbors, scene.flex_bounces, scene.flex_paths, \
        scene.flex_denoise * (1 + viewport)

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
        self.texture = None  # The viewport's view as last traced
        self.memory = (0, 0)  # Renderer allocations: used and peak in MiB
        self.following = None  # The frame after the last one rendered, which reuses its reservoirs in an animation
        self.shared = open(os.memfd_create('flex'), 'rb', 0)  # In memory file the renderer leaves its sums in
        self.spawn()

    # The engine keeps only the renderer's pipes, taken off the Popen, which Python keeps alive while its process runs:
    # once the engine drops them, the renderer reads the end of its input and exits.
    def spawn(self):
        process = subprocess.Popen((BINARY, str(self.shared.fileno())), stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            pass_fds=(self.shared.fileno(),))
        self.requests = process.stdin
        self.answers = process.stdout
        process.stdin = process.stdout = None

    # Starts the renderer on the exported scene when what it renders changed. Blender also reports selection, scene
    # settings and cameras, which need none. Objects that only moved or deformed update their triangles in place, as
    # FlexLight updates the slots of its instances, while they keep their count and the key of their materials: camera
    # visibility, those of their slots and a light's radiance.
    def start(self, depsgraph):
        visible = [instance.object.name for instance in depsgraph.object_instances]
        if visible == self.visible and all(isinstance(update.id, (bpy.types.Scene, bpy.types.Camera))
                or getattr(update.id, 'type', '') == 'CAMERA' for update in depsgraph.updates): return
        moved = visible == self.visible and all(isinstance(update.id, (bpy.types.Scene, bpy.types.Camera,
            bpy.types.Object, bpy.types.Action)) for update in depsgraph.updates) \
            and {update.id.name for update in depsgraph.updates}
        self.visible = visible
        scene = depsgraph.scene_eval
        vertices = [numpy.empty((0, 3, 3), 'f')]  # Per object, after none for a scene without triangles
        corners = [numpy.empty((0, 3, 3), 'f')]  # Normals
        uvs = [numpy.empty((0, 3, 2), 'f')]
        generated = [numpy.empty((0, 3, 3), 'f')]  # Texture coordinates, the points in the mesh's texture space
        materials = []
        ops = []  # Steps of all programs
        textures = {}  # First texel, width, height and mean per image and ramp
        texels = [numpy.ones(4, 'f')]  # Linear floats after a white texel: the renderer loads no empty array
        def program(surface):  # Counted, then emitted keeping what it uses again
            surface, first, alpha, uses, slots = fold(surface), len(ops), set(alpha_reads(surface)), {}, {}
            emit(surface, [], textures, texels, alpha, uses)
            emitted = emit(surface, ops, textures, texels, alpha, uses, slots)
            assert len(slots) <= SLOTS, 'values a program keeps for reuse'
            return emitted, first
        rows = {None: [program(GRAY)]}  # Rows of the surface each material renders; an empty slot renders gray
        slots = []  # Index, triangle count and key of each instance exported
        for i, instance in enumerate(depsgraph.object_instances):
            ob = instance.object
            bm = bmesh.new()
            if ob.hide_render or ob.type not in {'MESH', 'CURVE', 'SURFACE', 'FONT', 'META', 'LIGHT'} \
                or moved and ob.name not in moved: continue
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
                orco = (co.reshape(-1, 3) - mesh.texspace_location) / (2 * numpy.array(mesh.texspace_size)) + 0.5
                ob.to_mesh_clear()
                matrix = numpy.array(instance.matrix_world)
                positions = (co.reshape(-1, 3) @ matrix[:3, :3].T + matrix[:3, 3])[vertex[loops]].reshape(-1, 3, 3)
                normals = normal.reshape(-1, 3)[loops] @ numpy.array(instance.matrix_world.to_3x3().adjugated())
                uv = uv.reshape(-1, 2)[loops].reshape(-1, 3, 2)
                orco = orco[vertex[loops]].reshape(-1, 3, 3)
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
                orco = numpy.zeros((len(bm.faces), 3, 3), 'f')
                index = numpy.array([face.material_index for face in bm.faces], 'i')
            # Triangles of the surfaces rendered, normals turned as the faces turn, a material of its row each
            rendered = numpy.array([bool(row) for row in shades])[index]
            vertices.append(positions[rendered])
            corners.append(normals.reshape(-1, 3, 3)[rendered])
            uvs.append(uv[rendered])
            generated.append(orco[rendered])
            table = numpy.array([(*(row or [(0, 0)])[0], not ob.visible_camera, len(row)) for row in shades])
            materials.append(table[index[rendered]])
            slots.append((i, len(vertices[-1]), (ob.visible_camera, [slot.material and slot.material.name
                for slot in ob.material_slots], ob.type == 'LIGHT' and f'{radiance:.4g}')))
        # Update on stdin: slot count; per slot its first triangle and triangle count, then its arrays as in a scene
        if moved:
            if not all(self.slots.get(i, ())[1:] == (count, key) for i, count, key in slots):
                self.visible = None
                return self.start(depsgraph)
            self.requests.writelines((struct.pack('<2I', UPDATE, len(slots)), *(array for k, (i, count, _) in
                enumerate(slots) for array in (struct.pack('<2I', self.slots[i][0], count),
                *(arrays[k + 1].astype('f') for arrays in (vertices, corners, generated, uvs))))))
            return
        firsts = numpy.cumsum([0] + [count for _, count, _ in slots])
        self.slots = {i: (int(first), count, key) for (i, count, key), first in zip(slots, firsts)}
        world = scene.world and scene.world.node_tree.get_output_node('CYCLES')
        materials.append([(*program(resolve(world.inputs['Surface']) if world else BLACK), 0, 1)])
        triangles = numpy.concatenate(vertices, dtype='f')
        materials = numpy.concatenate(materials)
        # Scene on stdin: triangle, step and texel counts; per triangle 9 vertex, 9 normal, 9 generated and 6 UV floats,
        # a material of its emission, program, hidden flag and layer count (then the world's); then the steps of 4
        # integers and the texels.
        self.requests.writelines((struct.pack('<4I', SCENE, len(triangles), len(ops), sum(map(len, texels)) // 4),
            triangles,
            *(numpy.concatenate(arrays, dtype='f') for arrays in (corners, generated, uvs)),
            numpy.hstack((materials[:, :1].astype('f').view('I'), materials[:, 1:].astype('I'))),
            numpy.array(ops, 'I'), *texels))

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
        # Request on stdin: sampling, launches, size, settings, the camera's origin and its ray direction
        # per NDC x, per NDC y and at the center, then the thin lens.
        self.requests.write(struct.pack(f'<3I2f{3 + len(settings)}I17f', REQUEST, *sampling, launches, width, height,
            *settings, *matrix.translation, *x, *y, *center, *lens(camera)))
        self.requests.flush()
        launched, *self.memory = struct.unpack('<I2f', self.answers.read(12))  # Launches, memory, the view's sums
        sums = mmap.mmap(self.shared.fileno(), 16 * width * height, access=mmap.ACCESS_READ)
        return launched, numpy.frombuffer(sums, 'f').reshape(-1, width, 4)[::-1]

    # Shows the result after ever larger batches of samples, until it has them all or the render is cancelled
    def render(self, depsgraph):
        scene = depsgraph.scene_eval
        width = self.resolution_x
        height = self.resolution_y
        self.update_progress(0)
        self.update_stats('', f'{scene.name} | Syncing scene')
        self.start(depsgraph)
        camera = (scene.camera.matrix_world.normalized(),
            scene.camera.calc_matrix_camera(depsgraph, x=scene.render.resolution_x, y=scene.render.resolution_y),
            scene.camera)
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
                settings(scene, False), *camera)
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
            settings(scene, True), context.region_data.view_matrix.inverted(), context.region_data.window_matrix,
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
        self.layout.prop(context.scene, 'flex_denoise')
        for name in ('resolution_x', 'resolution_y', 'resolution_percentage', 'use_persistent_data'):
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
    bpy.types.Scene.flex_denoise = bpy.props.BoolProperty(name='Denoise',
        description='Denoise the result with the OptiX denoiser')
    bpy.types.Scene.flex_restir = bpy.props.BoolProperty(name='ReSTIR',
        description='Reuse paths across pixels and samples with ReSTIR PT Enhanced', default=True)
    bpy.types.Scene.flex_decorrelation = bpy.props.BoolProperty(name='Decorrelation', description='Reuse samples '
        'repeated across the neighborhood less over time. Biased: trades correlation artifacts for energy loss')
    bpy.types.Scene.flex_neighbors = bpy.props.IntProperty(name='Spatial Neighbors',
        description='Pixels each pixel reuses paths from per sample, fewer trade quality for speed', default=3, min=1,
        max=3)
    bpy.types.Scene.flex_reuse = bpy.props.BoolProperty(name='Reuse Samples', description='Trace fewer samples of a '
        'view reusing the last one\'s paths, as an animation\'s frames do after its first and after camera jumps')
    bpy.types.Scene.flex_reuse_samples = bpy.props.IntProperty(name='Reuse Samples',
        description='Paths traced per pixel of a view reusing the last one\'s', default=128, min=1)
    bpy.types.Scene.flex_jump_distance = bpy.props.FloatProperty(name='Distance', description='Farthest the camera '
        'moves between views to reuse samples, a farther move jumps and traces all of them', default=1, min=0,
        subtype='DISTANCE')
    bpy.types.Scene.flex_jump_angle = bpy.props.FloatProperty(name='Angle', description='Furthest the camera turns '
        'between views to reuse samples, a further turn jumps and traces all of them', default=math.radians(10), min=0,
        max=math.pi, subtype='ANGLE')
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
    del bpy.types.Scene.flex_denoise
    del bpy.types.Scene.flex_restir
    del bpy.types.Scene.flex_decorrelation
    del bpy.types.Scene.flex_neighbors
    del bpy.types.Scene.flex_reuse
    del bpy.types.Scene.flex_reuse_samples
    del bpy.types.Scene.flex_jump_distance
    del bpy.types.Scene.flex_jump_angle
