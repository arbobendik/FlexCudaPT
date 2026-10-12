# Blender render engine: exports the scene as camera-space triangles and path traces it with the bundled OptiX binary.
import bpy, bmesh, numpy, os, struct, subprocess

SAMPLES = 1024
BINARY = os.path.join(os.path.dirname(__file__), 'renderer')
# Material: baseColor, emission, then first texel, width, height of the base color's texture
GRAY = [0.8, 0.8, 0.8, 0, 0, 0, 0, 1, 1]

def encode(linear):  # Linear to sRGB
    return numpy.where(linear <= 0.0031308, linear * 12.92, 1.055 * linear.clip(0, 1) ** (1 / 2.4) - 0.055)

# The socket's color, or white and the image linked to it; then first texel, width, height
def tint(socket, textures, texels):
    nodes = [link.from_node for link in socket.links]
    for image in [node.image for node in nodes if hasattr(node, 'image') and node.image and node.image.size[0]]:
        if image not in textures:
            pixels = numpy.empty(len(image.pixels), 'f')
            image.pixels.foreach_get(pixels)
            if image.is_float: pixels = encode(pixels)
            textures[image] = sum(map(len, texels)) // 4, *image.size
            texels.append((pixels * 255 + 0.5).clip(0, 255).astype('B'))
        return [1, 1, 1, *textures[image]]
    return [*socket.default_value[:3], 0, 1, 1]

# The material's surface as rows, one or none: base color and emission of its Principled BSDF, gray without one; none
# for volumes without a surface shader and for textured alpha
def shade(material, textures, texels):
    output = material.node_tree.get_output_node('ALL')
    shaders = [node for node in material.node_tree.nodes if node.type == 'BSDF_PRINCIPLED'][:1]
    if not (output and output.inputs['Surface'].is_linked) or any(node.inputs['Alpha'].is_linked for node in shaders):
        return []
    for node in shaders:
        color = tint(node.inputs['Base Color'], textures, texels)
        emission = node.inputs['Emission Color'].default_value
        strength = node.inputs['Emission Strength'].default_value
        return [[*color[:3], *(c * strength for c in emission[:3]), *color[3:]]]
    return [GRAY]

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'

    def render(self, depsgraph):
        scene = depsgraph.scene_eval
        view = scene.camera.matrix_world.normalized().inverted()
        vertices = []
        uvs = []
        materials = []
        rows = {None: [GRAY]}  # Rows of the surface each material renders; an empty slot renders gray
        textures = {}  # First texel, width, height per image
        texels = [numpy.full(4, 255, 'B')]  # sRGB bytes after the white texel of untextured colors
        for instance in depsgraph.object_instances:
            ob = instance.object
            bm = bmesh.new()
            if ob.type in {'MESH', 'CURVE', 'SURFACE', 'FONT', 'META'}:
                bm.from_mesh(ob.to_mesh())
                ob.to_mesh_clear()
                for slot in ob.material_slots:
                    if slot.material not in rows: rows[slot.material] = shade(slot.material, textures, texels)
                shades = [rows[slot.material] for slot in ob.material_slots] or [[GRAY]]
            bmesh.ops.triangulate(bm, faces=bm.faces[:])
            bm.transform(view @ instance.matrix_world)
            uv = bm.loops.layers.uv.verify()
            for face in bm.faces:
                for row in shades[face.material_index]:  # No row for a surface that is not rendered
                    vertices.extend(c for vertex in face.verts for c in vertex.co)
                    uvs.extend(c for loop in face.loops for c in loop[uv].uv)
                    materials.extend(row)
        focal = scene.camera.calc_matrix_camera(depsgraph, x=scene.render.resolution_x,
            y=scene.render.resolution_y)[1][1]
        width = self.resolution_x
        height = self.resolution_y
        triangles = numpy.array(vertices, 'f').reshape(-1, 3, 3)
        materials = numpy.array(materials).reshape(-1, 9)
        texels = numpy.concatenate(texels)
        # Cumulative doubled area times summed emission per triangle: the binary picks light samples by it.
        normals = numpy.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0])
        power = numpy.cumsum(numpy.linalg.norm(normals, axis=1) * materials[:, 3:6].sum(1))
        # Scene on stdin: triangle count, texel count, focal; per triangle 9 vertex floats, 6 UV floats, a material of
        # 6 floats and 3 integers, the power; then the texels. Radiance sums and sample count per pixel on stdout.
        description = b''.join((struct.pack('<IIf', len(power), len(texels) // 4, focal),
            triangles.tobytes(), numpy.array(uvs, 'f').tobytes(),
            numpy.hstack((materials[:, :6].astype('f').view('I'), materials[:, 6:].astype('I'))).tobytes(),
            power.astype('f').tobytes(), texels.tobytes()))
        output = subprocess.run([BINARY, str(width), str(height), str(SAMPLES)], input=description,
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

def register():
    os.chmod(BINARY, 0o755)  # Extension installs drop the executable bit
    bpy.utils.register_class(Flex)

def unregister(): bpy.utils.unregister_class(Flex)
