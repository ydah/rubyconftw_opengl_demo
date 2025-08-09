require 'opengl'
require 'glfw'

callback = GLFW.create_callback(:GLFWkeyfun) do |window, key, _, action, _|
  if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
    GLFW.SetWindowShouldClose(window, 1)
  end
end

def draw_sphere(radius, slices, stacks)
  (0...stacks).each do |i|
    lat0 = Math::PI * (-0.5 + i.to_f / stacks)
    z0 = Math.sin(lat0)
    zr0 = Math.cos(lat0)

    lat1 = Math::PI * (-0.5 + (i + 1).to_f / stacks)
    z1 = Math.sin(lat1)
    zr1 = Math.cos(lat1)

    GL.Begin(GL::QUAD_STRIP)

    (0..slices).each do |j|
      lng = 2 * Math::PI * j.to_f / slices
      x = Math.cos(lng)
      y = Math.sin(lng)

      GL.Normal3f(x * zr1, y * zr1, z1)
      GL.Vertex3f(radius * x * zr1, radius * y * zr1, radius * z1)

      GL.Normal3f(x * zr0, y * zr0, z0)
      GL.Vertex3f(radius * x * zr0, radius * y * zr0, radius * z0)
    end

    GL.End()
  end
end

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()
  GL.load_lib

  window = GLFW::CreateWindow(800, 600, "Example", nil, nil)
  GLFW::MakeContextCurrent(window)

  GL.Enable(GL::DEPTH_TEST)
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
  GL.Enable(GL::COLOR_MATERIAL)

  light_position = [5.0, 5.0, 5.0, 1.0].pack('f*')
  light_ambient = [0.2, 0.2, 0.2, 1.0].pack('f*')
  light_diffuse = [0.8, 0.8, 0.8, 1.0].pack('f*')
  light_specular = [1.0, 1.0, 1.0, 1.0].pack('f*')

  GL.Lightfv(GL::LIGHT0, GL::POSITION, light_position)
  GL.Lightfv(GL::LIGHT0, GL::AMBIENT, light_ambient)
  GL.Lightfv(GL::LIGHT0, GL::DIFFUSE, light_diffuse)
  GL.Lightfv(GL::LIGHT0, GL::SPECULAR, light_specular)

  material_ambient = [0.2, 0.2, 0.2, 1.0].pack('f*')
  material_diffuse = [0.8, 0.8, 0.8, 1.0].pack('f*')
  material_specular = [1.0, 1.0, 1.0, 1.0].pack('f*')
  material_shininess = [50.0].pack('f*')

  GL.Materialfv(GL::FRONT, GL::AMBIENT, material_ambient)
  GL.Materialfv(GL::FRONT, GL::DIFFUSE, material_diffuse)
  GL.Materialfv(GL::FRONT, GL::SPECULAR, material_specular)
  GL.Materialfv(GL::FRONT, GL::SHININESS, material_shininess)

  GL.MatrixMode(GL::PROJECTION)
  GL.LoadIdentity()
  fov = 45.0
  aspect = 800.0 / 600.0
  near = 0.1
  far = 100.0
  fh = Math.tan(fov * Math::PI / 360.0) * near
  fw = fh * aspect
  GL.Frustum(-fw, fw, -fh, fh, near, far)

  rotation = 0.0

  until GLFW::WindowShouldClose(window) == GLFW::TRUE
    GL.ClearColor(0.1, 0.1, 0.1, 1.0)
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()

    GL.Translatef(0.0, 0.0, -5.0)
    GL.Rotatef(20.0, 1.0, 0.0, 0.0)

    rotation += 1.0
    GL.Rotatef(rotation, 0.0, 1.0, 0.0)

    GL.PushMatrix()
    GL.Translatef(0.0, 0.0, 0.0)
    GL.Color3f(1.0, 0.2, 0.2)
    draw_sphere(0.8, 30, 30)
    GL.PopMatrix()

    GLFW::SwapBuffers(window)
    GLFW::PollEvents()
  end

  GLFW::Terminate()
end

