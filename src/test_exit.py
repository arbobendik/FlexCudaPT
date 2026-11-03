# The renderer ends with its Blender: run apart from make test, as it kills processes, after it, by python3
# src/test_exit.py, on the build make test installed (build/blender). A background Blender renders a plane of 2M
# triangles with Flex, its writes to the renderer marked on its output, and is killed by SIGKILL at four points: in the
# export, before any byte is piped; in the scene's transfer; in the scene's compile, run cold; in a frame, its second
# request written. Each time, on both backends, its renderer must end within a second.
import os, signal, subprocess, sys, tempfile, time
DRIVER = '''
import bpy
engine = bpy.types.RenderEngine.bl_rna_get_subclass_py('FLEX')
spawn = engine.spawn
class Marked:  # The renderer's input, each write marked on the output as it begins
    def __init__(self, pipe): self.pipe, self.writes = pipe, 0
    def mark(self): self.writes += 1; print('write', self.writes, flush=True)
    def write(self, data): self.mark(); self.pipe.write(data)
    def writelines(self, lines): self.mark(); self.pipe.writelines(lines); print('sent', flush=True)
    def flush(self): self.pipe.flush()
engine.spawn = lambda self: (spawn(self), setattr(self, 'requests', Marked(self.requests)))
bpy.ops.mesh.primitive_grid_add(x_subdivisions=1000, y_subdivisions=1000, size=4)
bpy.ops.object.camera_add(location=(0, 0, 6))
scene = bpy.context.scene
scene.camera, scene.render.engine, scene.flex_samples = bpy.context.object, 'FLEX', 1 << 20
scene.render.resolution_x = scene.render.resolution_y = 64
bpy.context.preferences.addons['bl_ext.user_default.flex_cuda_pt'].preferences.device = DEVICE
print('start', flush=True)
bpy.ops.render.render()
'''
POINTS = {'export': ('start', 0.5), 'transfer': ('write 1', 0.05), 'compile': ('sent', 0.2), 'frame': ('write 3', 0)}
def children(pid):  # Of its main thread, which makes the engines: the render's, and a passing one for its passes
    return [int(c) for c in open(f'/proc/{pid}/task/{pid}/children').read().split()]
alive = lambda pid: os.path.exists(f'/proc/{pid}')  # Not yet reaped: the user's service manager reaps orphans at once
failed = []
for device in ('OPTIX', 'VULKAN'):
    for point, (marker, delay) in POINTS.items():
        with tempfile.TemporaryDirectory() as cache:  # Shader caches empty: a cold compile, long enough to be killed in
            blender = subprocess.Popen(('blender', '-b', '--python-expr', f'DEVICE = {device!r}\n' + DRIVER),
                stdout=subprocess.PIPE, text=True, env={**os.environ, 'OPTIX_CACHE_PATH': cache,
                'BLENDER_USER_RESOURCES': os.path.join(os.path.dirname(__file__), '..', 'build', 'blender'),
                '__GL_SHADER_DISK_CACHE_PATH': cache})
            while (line := blender.stdout.readline()) and line.strip() != marker: pass
            time.sleep(delay)
            renderers = children(blender.pid)
            blender.send_signal(signal.SIGKILL), blender.wait()
            killed = time.monotonic()
            while any(map(alive, renderers)) and time.monotonic() - killed < 1: time.sleep(0.01)
            left = [pid for pid in renderers if alive(pid)]
            print(device, point, 'renderers', renderers, 'left after a second', left, flush=True)
            if not line or not renderers or left: failed.append((device, point))
            for pid in left: os.kill(pid, signal.SIGKILL)  # Ours, which the test must not leave running
assert not failed, f'renderers outliving their Blender: {failed}'
print('renderers end with their Blender')
