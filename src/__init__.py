# Blender render engine: exports the scene as world-space triangles and path traces it with the bundled OptiX binary.
import bpy, bmesh, math, numpy, os, struct, subprocess
from mathutils import Matrix

SUN_DISTANCE = 1e5
BINARY = os.path.join(os.path.dirname(__file__), 'renderer')
# Material: baseColor, emission, then first texel, width, height and ramp of each one's texture; a hidden flag follows
GRAY = [0.8, 0.8, 0.8, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0]

def encode(linear):  # Linear to sRGB
    return numpy.where(linear <= 0.0031308, linear * 12.92, 1.055 * linear.clip(0, 1) ** (1 / 2.4) - 0.055)

# The socket's color, or white and the image linked to it, directly or through a color ramp; then the image's first
# texel, width and height and the ramp's first texel, 0 without one
def tint(socket, textures, texels):
    nodes = [link.from_node for link in socket.links]
    ramps = [node for node in nodes if node.type == 'VALTORGB']
    feeds = [link.from_node for ramp in ramps for link in ramp.inputs['Fac'].links] or nodes
    for image in [node.image for node in feeds if hasattr(node, 'image') and node.image and node.image.size[0]]:
        if image not in textures:
            pixels = numpy.empty(len(image.pixels), 'f')
            image.pixels.foreach_get(pixels)
            if image.is_float: pixels = encode(pixels)
            textures[image] = sum(map(len, texels)) // 4, *image.size
            texels.append((pixels * 255 + 0.5).clip(0, 255).astype('B'))
        for ramp in set(ramps) - textures.keys():  # The ramp's colors as 256 texels
            colors = encode(numpy.array([ramp.color_ramp.evaluate(i / 255) for i in range(256)]))
            textures[ramp] = sum(map(len, texels)) // 4
            texels.append((colors * 255 + 0.5).astype('B').ravel())
        return [1, 1, 1, *textures[image], sum(textures[ramp] for ramp in ramps)]
    return [*socket.default_value[:3], 0, 1, 1, 0]

# The material's surface as rows, one or none: base color and emission of its Principled BSDF, gray without one; none
# for volumes without a surface shader and for textured alpha
def shade(material, textures, texels):
    output = material.node_tree.get_output_node('ALL')
    shaders = [node for node in material.node_tree.nodes if node.type == 'BSDF_PRINCIPLED'][:1]
    if not (output and output.inputs['Surface'].is_linked) or any(node.inputs['Alpha'].is_linked for node in shaders):
        return []
    for node in shaders:
        color = tint(node.inputs['Base Color'], textures, texels)
        emission = tint(node.inputs['Emission Color'], textures, texels)
        strength = node.inputs['Emission Strength'].default_value
        return [[*color[:3], *(c * strength for c in emission[:3]), *color[3:], *emission[3:]]]
    return [GRAY]

def disk(bm, sides, x, y, z):  # Polygon at height z around the ellipse with diameters x, y
    bmesh.ops.create_circle(bm, cap_ends=True, segments=sides, radius=0.5 / math.cos(math.pi / sides),
        matrix=Matrix.Translation((0, 0, z)) @ Matrix.Diagonal((x, y, 1, 1)) @ Matrix.Rotation(math.pi / sides, 4, 'Z'))

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'

    def render(self, depsgraph):
        scene = depsgraph.scene_eval
        vertices = []
        uvs = []
        materials = []
        rows = {None: [GRAY]}  # Rows of the surface each material renders; an empty slot renders gray
        textures = {}  # First texel, width, height per image; first texel per ramp
        texels = [numpy.full(4, 255, 'B')]  # sRGB bytes after the white texel of untextured colors
        for instance in depsgraph.object_instances:
            ob = instance.object
            bm = bmesh.new()
            if ob.hide_render: continue
            if ob.type in {'MESH', 'CURVE', 'SURFACE', 'FONT', 'META'}:
                bm.from_mesh(ob.to_mesh())
                ob.to_mesh_clear()
                for slot in ob.material_slots:
                    if slot.material not in rows: rows[slot.material] = shade(slot.material, textures, texels)
                shades = [rows[slot.material] for slot in ob.material_slots] or [[GRAY]]
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
                shades = [[[0, 0, 0, *(c * radiance for c in light.color), 0, 1, 1, 0, 0, 1, 1, 0]],
                    [[0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0]]]
            uv = bm.loops.layers.uv.verify()
            for face in bm.faces:
                for row in shades[face.material_index]:  # No row for a surface that is not rendered
                    vertices.extend(c for vertex in face.verts for c in vertex.co)
                    uvs.extend(c for loop in face.loops for c in loop[uv].uv)
                    materials.extend((*row, not ob.visible_camera))
        world = [0, 0, 0, 0, 1, 1, 0]
        for node in scene.world.node_tree.nodes if scene.world else ():
            if node.type == 'BACKGROUND':
                world = tint(node.inputs['Color'], textures, texels)
                world[:3] = [c * node.inputs['Strength'].default_value for c in world[:3]]
        materials.extend((*world[:3], 0, 0, 0, *world[3:], 0, 1, 1, 0, 0))
        matrix = scene.camera.matrix_world.normalized()
        projection = scene.camera.calc_matrix_camera(depsgraph, x=scene.render.resolution_x,
            y=scene.render.resolution_y)
        right = matrix.col[0].xyz / projection[0][0]
        up = matrix.col[1].xyz / projection[1][1]
        center = right * projection[0][2] + up * projection[1][2] - matrix.col[2].xyz
        width = self.resolution_x
        height = self.resolution_y
        triangles = numpy.array(vertices, 'f').reshape(-1, 3, 3)
        materials = numpy.array(materials).reshape(-1, 15)
        texels = numpy.concatenate(texels)
        # Cumulative doubled area times summed emission per triangle: the binary picks light samples by it. In doubles,
        # tiny emitters after bright ones keep intervals of their power.
        normals = numpy.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0])
        power = numpy.cumsum(numpy.linalg.norm(normals, axis=1) * materials[:-1, 3:6].sum(1))
        # Scene on stdin: triangle count, texel count, the camera's origin and its ray direction per NDC x, per NDC y
        # and at the center; per triangle 9 vertex floats, 6 UV floats, a material of 6 floats and 9 integers (then the
        # world's), the power; then the texels. Radiance sums and sample count per pixel on stdout.
        header = struct.pack('<II12f', len(power), len(texels) // 4, *matrix.translation, *right, *up, *center)
        description = b''.join((header,
            triangles.tobytes(), numpy.array(uvs, 'f').tobytes(),
            numpy.hstack((materials[:, :6].astype('f').view('I'), materials[:, 6:].astype('I'))).tobytes(),
            power.astype('d').tobytes(), texels.tobytes()))
        output = subprocess.run([BINARY, str(width), str(height), str(scene.flex_samples)], input=description,
            stdout=subprocess.PIPE, check=True).stdout
        # Blender rows run bottom to top
        sums = numpy.frombuffer(output, numpy.float32).reshape(height, width, 4)[::-1]
        result = self.begin_result(0, 0, width, height)  # Blender clips the result to the render border
        border = depsgraph.scene.render
        x = int(border.use_border * border.border_min_x * width)
        y = int(border.use_border * border.border_min_y * height)
        pixels = (sums / sums[..., 3:])[y:y + result.resolution_y, x:x + result.resolution_x]
        result.layers[0].passes['Combined'].rect.foreach_set(pixels.ravel())
        self.end_result(result)

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

def register():
    os.chmod(BINARY, 0o755)  # Extension installs drop the executable bit
    bpy.types.Scene.flex_samples = bpy.props.IntProperty(name='Max Samples', description='Paths traced per pixel',
        default=1024, min=1)
    bpy.utils.register_class(Flex)
    bpy.utils.register_class(RENDER_PT_flex)

def unregister():
    bpy.utils.unregister_class(RENDER_PT_flex)
    bpy.utils.unregister_class(Flex)
    del bpy.types.Scene.flex_samples
