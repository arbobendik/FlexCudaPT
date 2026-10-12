# Blender render engine: exports the scene as camera-space triangles and path traces it with the bundled OptiX binary.
import bpy, bmesh, numpy, os, struct, subprocess

SAMPLES = 1024
BINARY = os.path.join(os.path.dirname(__file__), 'renderer')
GRAY = [0.8, 0.8, 0.8, 0, 0, 0]  # Material: baseColor, emission

# The material's surface as rows, one or none: base color and emission of its Principled BSDF, gray without one; none
# for volumes without a surface shader and for textured alpha
def shade(material):
    output = material.node_tree.get_output_node('ALL')
    shaders = [node for node in material.node_tree.nodes if node.type == 'BSDF_PRINCIPLED'][:1]
    if not (output and output.inputs['Surface'].is_linked) or any(node.inputs['Alpha'].is_linked for node in shaders):
        return []
    for node in shaders:
        color = node.inputs['Base Color'].default_value
        emission = node.inputs['Emission Color'].default_value
        strength = node.inputs['Emission Strength'].default_value
        return [[*color[:3], *(c * strength for c in emission[:3])]]
    return [GRAY]

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'

    def render(self, depsgraph):
        scene = depsgraph.scene_eval
        view = scene.camera.matrix_world.normalized().inverted()
        vertices = []
        materials = []
        rows = {None: [GRAY]}  # Rows of the surface each material renders; an empty slot renders gray
        for instance in depsgraph.object_instances:
            ob = instance.object
            bm = bmesh.new()
            if ob.type in {'MESH', 'CURVE', 'SURFACE', 'FONT', 'META'}:
                bm.from_mesh(ob.to_mesh())
                ob.to_mesh_clear()
                for slot in ob.material_slots:
                    if slot.material not in rows: rows[slot.material] = shade(slot.material)
                shades = [rows[slot.material] for slot in ob.material_slots] or [[GRAY]]
            bmesh.ops.triangulate(bm, faces=bm.faces[:])
            bm.transform(view @ instance.matrix_world)
            for face in bm.faces:
                for row in shades[face.material_index]:  # No row for a surface that is not rendered
                    vertices.extend(c for vertex in face.verts for c in vertex.co)
                    materials.extend(row)
        focal = scene.camera.calc_matrix_camera(depsgraph, x=scene.render.resolution_x,
            y=scene.render.resolution_y)[1][1]
        width = self.resolution_x
        height = self.resolution_y
        triangles = numpy.array(vertices, 'f').reshape(-1, 3, 3)
        materials = numpy.array(materials).reshape(-1, 6)
        # Cumulative doubled area times summed emission per triangle: the binary picks light samples by it. In doubles,
        # tiny emitters after bright ones keep intervals of their power.
        normals = numpy.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0])
        power = numpy.cumsum(numpy.linalg.norm(normals, axis=1) * materials[:, 3:].sum(1))
        # Scene on stdin: triangle count, focal; per triangle 9 vertex floats, a material of 6 floats, the power.
        # Radiance sums and sample count per pixel on stdout.
        description = b''.join((struct.pack('<If', len(power), focal), triangles.tobytes(),
            materials.astype('f').tobytes(), power.astype('d').tobytes()))
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
