# frozen_string_literal: true

require 'opengl'
require 'glfw'

key_callback = GLFW.create_callback(:GLFWkeyfun) do |window, key, _scancode, action, _mods|
  GLFW.SetWindowShouldClose(window, 1) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()
  window = GLFW.CreateWindow(640, 480, 'Example', nil, nil)
  GLFW.MakeContextCurrent(window)
  GLFW.SetKeyCallback(window, key_callback)

  GL.load_lib
  GL.ClearColor(0.0, 0.0, 0.0, 1.0)
  GL.Enable(GL::DEPTH_TEST)
  rotation_angle = 0.0

  width_buf = [0].pack('I')
  height_buf = [0].pack('I')

  until GLFW.WindowShouldClose(window) == GLFW::TRUE
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GLFW.GetFramebufferSize(window, width_buf, height_buf)
    width = width_buf.unpack('I').first
    height = height_buf.unpack('I').first
    GL.Viewport(0, 0, width, height)
    height = 1 if height == 0
    aspect = width.to_f / height.to_f
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    fovy_degrees = 45.0
    near_clip = 0.1
    far_clip = 100.0
    fovy_radians = fovy_degrees * Math::PI / 180.0
    top = Math.tan(fovy_radians / 2.0) * near_clip
    bottom = -top
    right = top * aspect
    left = -right
    GL.Frustum(left, right, bottom, top, near_clip, far_clip)
    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()
    GL.Translatef(0.0, 0.0, -9.0)
    GL.Rotatef(rotation_angle, 1.0, 1.0, 0.0)
    rotation_angle += 0.5

    GL.Begin(GL::QUADS)
    GL.Color3f(1, 0, 0); GL.Vertex3f(-1, -1,  1); GL.Vertex3f( 1, -1,  1); GL.Vertex3f( 1,  1,  1); GL.Vertex3f(-1,  1,  1)
    GL.Color3f(0, 1, 0); GL.Vertex3f(-1, -1, -1); GL.Vertex3f(-1,  1, -1); GL.Vertex3f( 1,  1, -1); GL.Vertex3f( 1, -1, -1)
    GL.Color3f(0, 0, 1); GL.Vertex3f(-1,  1, -1); GL.Vertex3f(-1,  1,  1); GL.Vertex3f( 1,  1,  1); GL.Vertex3f( 1,  1, -1)
    GL.Color3f(1, 1, 0); GL.Vertex3f(-1, -1, -1); GL.Vertex3f( 1, -1, -1); GL.Vertex3f( 1, -1,  1); GL.Vertex3f(-1, -1,  1)
    GL.Color3f(0, 1, 1); GL.Vertex3f( 1, -1, -1); GL.Vertex3f( 1,  1, -1); GL.Vertex3f( 1,  1,  1); GL.Vertex3f( 1, -1,  1)
    GL.Color3f(1, 0, 1); GL.Vertex3f(-1, -1, -1); GL.Vertex3f(-1, -1,  1); GL.Vertex3f(-1,  1,  1); GL.Vertex3f(-1,  1, -1)
    GL.End()

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end
