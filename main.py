import moderngl_window as mglw


class App(mglw.WindowConfig):
    window_size = 1280, 720
    resource_dir = 'program'

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.quad = mglw.geometry.quad_fs()
        self.program = self.load_program(vertex_shader='vertex_shader.glsl', fragment_shader='fragment_shader.glsl')
        self.u_scroll = 2.0
        # textures
        self.texture1 = self.load_texture_2d('../textures/bricks.png')
        self.texture2 = self.load_texture_2d('../textures/floor.jpg')
        # uniforms
        self.program['u_scroll'] = self.u_scroll
        self.program['u_resolution'] = self.window_size
        self.program['u_texture1'] = 1
        self.program['u_texture2'] = 2

    def on_render(self, time, frame_time):
        self.ctx.clear()
        self.program['u_time'] = time
        self.texture1.use(location = 1)
        self.texture2.use(location = 2)
        self.quad.render(self.program)

    def on_mouse_position_event(self, x, y, dx, dy):
        self.program['u_mouse'] = (x, y)

    def mouse_scroll_event(self, x_offset, y_offset):
        self.u_scroll = max(1.0, self.u_scroll + y_offset)
        self.program['u_scroll'] = self.u_scroll

if __name__ == '__main__':
    App.run()