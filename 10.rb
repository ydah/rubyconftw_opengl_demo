# frozen_string_literal: true

require 'opengl'
require 'glfw'

key_callback = GLFW.create_callback(:GLFWkeyfun) do |window, key, _scancode, action, _mods|
  GLFW.SetWindowShouldClose(window, 1) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()

  window = GLFW.CreateWindow(640, 480, 'Cube with Lighting', nil, nil)
  GLFW.MakeContextCurrent(window)
  GLFW.SetKeyCallback(window, key_callback)

  GL.load_lib

  GL.ClearColor(0.0, 0.0, 0.0, 1.0)
  GL.Enable(GL::DEPTH_TEST)

  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
  GL.Enable(GL::NORMALIZE)

  ambient_light = [0.2, 0.2, 0.2, 1.0].pack('F*')
  diffuse_light = [1.0, 1.0, 1.0, 1.0].pack('F*')
  specular_light = [1.0, 1.0, 1.0, 1.0].pack('F*')
  GL.Lightfv(GL::LIGHT0, GL::AMBIENT, ambient_light)
  GL.Lightfv(GL::LIGHT0, GL::DIFFUSE, diffuse_light)
  GL.Lightfv(GL::LIGHT0, GL::SPECULAR, specular_light)

  GL.Enable(GL::COLOR_MATERIAL)
  GL.ColorMaterial(GL::FRONT, GL::AMBIENT_AND_DIFFUSE)

  specular_material = [1.0, 1.0, 1.0, 1.0].pack('F*')
  shininess = 50.0
  GL.Materialfv(GL::FRONT, GL::SPECULAR, specular_material)
  GL.Materialf(GL::FRONT, GL::SHININESS, shininess)

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
    GL.Translatef(0.0, 0.0, -9.0) # カメラをZ軸負の方向に移動

    light_pos = [2.0, 3.0, 4.0, 1.0].pack('F*') # Rubyの配列をメモリブロックに変換
    GL.Lightfv(GL::LIGHT0, GL::POSITION, light_pos)

    GL.Rotatef(rotation_angle, 1.0, 1.0, 0.0)
    rotation_angle += 0.5

    GL.Begin(GL::QUADS)
      GL.Normal3f(0.0, 0.0, 1.0)
      GL.Color3f(1, 0, 0); GL.Vertex3f(-1, -1,  1); GL.Vertex3f( 1, -1,  1); GL.Vertex3f( 1,  1,  1); GL.Vertex3f(-1,  1,  1)
      GL.Normal3f(0.0, 0.0, -1.0)
      GL.Color3f(0, 1, 0); GL.Vertex3f(-1, -1, -1); GL.Vertex3f(-1,  1, -1); GL.Vertex3f( 1,  1, -1); GL.Vertex3f( 1, -1, -1)
      GL.Normal3f(0.0, 1.0, 0.0)
      GL.Color3f(0, 0, 1); GL.Vertex3f(-1,  1, -1); GL.Vertex3f(-1,  1,  1); GL.Vertex3f( 1,  1,  1); GL.Vertex3f( 1,  1, -1)
      GL.Normal3f(0.0, -1.0, 0.0)
      GL.Color3f(1, 1, 0); GL.Vertex3f(-1, -1, -1); GL.Vertex3f( 1, -1, -1); GL.Vertex3f( 1, -1,  1); GL.Vertex3f(-1, -1,  1)
      GL.Normal3f(1.0, 0.0, 0.0)
      GL.Color3f(0, 1, 1); GL.Vertex3f( 1, -1, -1); GL.Vertex3f( 1,  1, -1); GL.Vertex3f( 1,  1,  1); GL.Vertex3f( 1, -1,  1)
      GL.Normal3f(-1.0, 0.0, 0.0)
      GL.Color3f(1, 0, 1); GL.Vertex3f(-1, -1, -1); GL.Vertex3f(-1, -1,  1); GL.Vertex3f(-1,  1,  1); GL.Vertex3f(-1,  1, -1)
    GL.End()

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end
