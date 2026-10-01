# Blender render engine: path traces a fixed scene with the bundled OptiX binary.
import bpy, numpy, os, subprocess

SAMPLES = 1024
BINARY = os.path.join(os.path.dirname(__file__), 'renderer')

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'

    def render(self, depsgraph):
        width = self.resolution_x
        height = self.resolution_y
        # Radiance sums and sample count per pixel on stdout.
        output = subprocess.run([BINARY, str(width), str(height), str(SAMPLES)],
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
