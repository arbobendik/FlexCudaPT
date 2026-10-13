# Blender render engine.
import bpy

class Flex(bpy.types.RenderEngine):
    bl_idname = 'FLEX'
    bl_label = 'Flex'

def register():
    bpy.utils.register_class(Flex)

def unregister(): bpy.utils.unregister_class(Flex)
