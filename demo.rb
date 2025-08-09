# frozen_string_literal: true

require 'opengl'
require 'glfw'

$rotation_direction = 0  # -1: left, 0: none, 1: right
$rotation_speed = 0.5
$floor_color_scheme = 0  # 0: red-green, 1: red-white, 2: green-brown, 3: purple-cyan

# Exit with ESC key and control rotation with arrow keys
key_callback = GLFW.create_callback(:GLFWkeyfun) do |window, key, _scancode, action, _mods|
  if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
    GLFW.SetWindowShouldClose(window, 1)
  elsif key == GLFW::KEY_RIGHT
    # right key: rotate right
    $rotation_direction = 1 if action == GLFW::PRESS || action == GLFW::REPEAT
    $rotation_direction = 0 if action == GLFW::RELEASE
  elsif key == GLFW::KEY_LEFT
    # left key: rotate left
    $rotation_direction = -1 if action == GLFW::PRESS || action == GLFW::REPEAT
    $rotation_direction = 0 if action == GLFW::RELEASE
  elsif key == GLFW::KEY_UP && action == GLFW::PRESS
    # Up key: next color pattern
    $floor_color_scheme = ($floor_color_scheme + 1) % 4
  elsif key == GLFW::KEY_DOWN && action == GLFW::PRESS
    # Down key: previous color pattern
    $floor_color_scheme = ($floor_color_scheme - 1) % 4
  end
end

# Calculate normal vector
def calculate_normal(v1, v2, v3)
  # Calculate two vectors
  u = [v2[0] - v1[0], v2[1] - v1[1], v2[2] - v1[2]]
  v = [v3[0] - v1[0], v3[1] - v1[1], v3[2] - v1[2]]

  # Calculate cross product
  normal = [
    (u[1] * v[2]) - (u[2] * v[1]),
    (u[2] * v[0]) - (u[0] * v[2]),
    (u[0] * v[1]) - (u[1] * v[0])
  ]

  # Normalize
  length = Math.sqrt((normal[0]**2) + (normal[1]**2) + (normal[2]**2))
  normal.map { |n| n / length }
end

# Draw realistic 3D Ruby logo
def draw_realistic_ruby(x, y, z, size, rotation)
  GL.PushMatrix()
  GL.Translatef(x, y, z)
  GL.Rotatef(rotation * 0.5, 0, 1, 0)
  GL.Scalef(size, size, size)

  # Material settings (ruby gem texture)
  ruby_ambient = [0.5, 0.0, 0.0, 1.0].pack('F*')
  ruby_diffuse = [1.0, 0.0, 0.0, 1.0].pack('F*')
  ruby_specular = [1.0, 0.8, 0.8, 1.0].pack('F*')
  ruby_shininess = [100.0].pack('F*')

  GL.Materialfv(GL::FRONT_AND_BACK, GL::AMBIENT, ruby_ambient)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, ruby_diffuse)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::SPECULAR, ruby_specular)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::SHININESS, ruby_shininess)

  # More detailed ruby shape (octahedron base)
  vertices = [
    [0, 1.2, 0],      # Top vertex
    [0.8, 0.4, 0],    # Front right
    [0, 0.4, 0.8],    # Right
    [-0.8, 0.4, 0],   # Back right
    [0, 0.4, -0.8],   # Left
    [0.57, 0.4, 0.57],  # Front right diagonal
    [-0.57, 0.4, 0.57], # Back right diagonal
    [-0.57, 0.4, -0.57], # Back left diagonal
    [0.57, 0.4, -0.57], # Front left diagonal
    [0, -1.2, 0] # Bottom vertex
  ]

  # Upper facets
  faces_top = [
    [0, 1, 5], [0, 5, 2], [0, 2, 6], [0, 6, 3],
    [0, 3, 7], [0, 7, 4], [0, 4, 8], [0, 8, 1]
  ]

  # Central part
  faces_middle = [
    [1, 5, 9], [5, 2, 9], [2, 6, 9], [6, 3, 9],
    [3, 7, 9], [7, 4, 9], [4, 8, 9], [8, 1, 9]
  ]

  # Add color information to each vertex (for debugging)
  GL.ColorMaterial(GL::FRONT_AND_BACK, GL::AMBIENT_AND_DIFFUSE)
  GL.Enable(GL::COLOR_MATERIAL)

  GL.Begin(GL::TRIANGLES)

  # Explicitly set red color
  GL.Color3f(0.8, 0.1, 0.1)

  # Draw upper facets
  faces_top.each do |face|
    v1 = vertices[face[0]]
    v2 = vertices[face[1]]
    v3 = vertices[face[2]]
    normal = calculate_normal(v1, v2, v3)
    GL.Normal3f(normal[0], normal[1], normal[2])

    GL.Vertex3f(v1[0], v1[1], v1[2])
    GL.Vertex3f(v2[0], v2[1], v2[2])
    GL.Vertex3f(v3[0], v3[1], v3[2])
  end

  # Draw lower facets
  faces_middle.each do |face|
    v1 = vertices[face[0]]
    v2 = vertices[face[1]]
    v3 = vertices[face[2]]
    normal = calculate_normal(v1, v2, v3)
    GL.Normal3f(normal[0], normal[1], normal[2])

    GL.Vertex3f(v1[0], v1[1], v1[2])
    GL.Vertex3f(v2[0], v2[1], v2[2])
    GL.Vertex3f(v3[0], v3[1], v3[2])
  end

  GL.End()

  GL.Disable(GL::COLOR_MATERIAL)

  GL.PopMatrix()
end

# Draw realistic Taipei 101
def draw_realistic_taipei_101(x, y, z, rotation)
  GL.PushMatrix()
  GL.Translatef(x, y, z)
  GL.Rotatef(rotation * 0.1, 0, 1, 0)

  # Building material settings (glass and steel)
  building_ambient = [0.05, 0.05, 0.1, 1.0].pack('F*')
  building_diffuse = [0.2, 0.2, 0.3, 1.0].pack('F*')
  building_specular = [0.7, 0.7, 0.8, 1.0].pack('F*')
  building_shininess = [100.0].pack('F*')

  GL.Materialfv(GL::FRONT_AND_BACK, GL::AMBIENT, building_ambient)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, building_diffuse)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::SPECULAR, building_specular)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::SHININESS, building_shininess)

  # Each section of Taipei 101 (8-layer structure)
  8.times do |i|
    base_y = (i * 1.2) - 4
    width = 1.2 - (i * 0.12)
    height = 1.2

    # Add subtle taper to each layer
    taper = 0.95

    GL.PushMatrix()
    GL.Translatef(0, base_y, 0)

    # Draw each face of the octagon
    8.times do |j|
      angle1 = j * Math::PI * 2 / 8
      angle2 = (j + 1) * Math::PI * 2 / 8

      x1 = Math.cos(angle1) * width
      z1 = Math.sin(angle1) * width
      x2 = Math.cos(angle2) * width
      z2 = Math.sin(angle2) * width

      x3 = Math.cos(angle1) * width * taper
      z3 = Math.sin(angle1) * width * taper
      x4 = Math.cos(angle2) * width * taper
      z4 = Math.sin(angle2) * width * taper

      # Calculate face normal
      v1 = [x1, 0, z1]
      v2 = [x2, 0, z2]
      v3 = [x3, height, z3]
      normal = calculate_normal(v1, v2, v3)

      GL.Begin(GL::QUADS)
      GL.Normal3f(normal[0], normal[1], normal[2])
      GL.Vertex3f(x1, 0, z1)
      GL.Vertex3f(x2, 0, z2)
      GL.Vertex3f(x4, height, z4)
      GL.Vertex3f(x3, height, z3)
      GL.End()

      # Window details (represented as dark lines)
      window_material = [0.02, 0.02, 0.05, 1.0].pack('F*')
      GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, window_material)

      GL.LineWidth(1.0)
      GL.Begin(GL::LINES)
      # Horizontal lines
      5.times do |k|
        y_pos = (k * 0.2) + 0.1
        GL.Vertex3f(x1 * 0.95, y_pos, z1 * 0.95)
        GL.Vertex3f(x2 * 0.95, y_pos, z2 * 0.95)
      end
      GL.End()

      # Restore material
      GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, building_diffuse)
    end

    GL.PopMatrix()
  end

  # Top antenna section
  GL.PushMatrix()
  GL.Translatef(0, 5.6, 0)

  # Antenna material (metallic)
  antenna_diffuse = [0.7, 0.7, 0.7, 1.0].pack('F*')
  antenna_specular = [0.9, 0.9, 0.9, 1.0].pack('F*')
  GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, antenna_diffuse)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::SPECULAR, antenna_specular)

  # Cylindrical antenna
  slices = 16
  rings = 8
  radius = 0.05
  height = 2.0

  rings.times do |i|
    y1 = i * height / rings
    y2 = (i + 1) * height / rings

    GL.Begin(GL::QUAD_STRIP)
    slices.times do |j|
      angle = j * Math::PI * 2 / slices
      x = Math.cos(angle) * radius
      z = Math.sin(angle) * radius

      GL.Normal3f(Math.cos(angle), 0, Math.sin(angle))
      GL.Vertex3f(x, y1, z)
      GL.Vertex3f(x, y2, z)
    end
    GL.End()
  end

  GL.PopMatrix()
  GL.PopMatrix()
end

# Draw ground (for reflection effect)
def draw_ground
  # Checkerboard grid
  grid_size = 2.0
  grid_count = 20

  color_patterns = [
    # pattern 0: red and green
    {
      color1: {
        ambient: [0.0, 0.0, 0.05, 1.0],
        diffuse: [0.0, 0.0, 0.3, 1.0],
        specular: [0.1, 0.1, 0.3, 1.0]
      },
      color2: {
        ambient: [0.2, 0.18, 0.0, 1.0],
        diffuse: [0.8, 0.7, 0.0, 1.0],
        specular: [0.9, 0.8, 0.1, 1.0]
      }
    },
    # pattern 1: red and white
    {
      color1: {
        ambient: [0.2, 0.0, 0.0, 1.0],
        diffuse: [0.7, 0.0, 0.0, 1.0],
        specular: [0.9, 0.2, 0.2, 1.0]
      },
      color2: {
        ambient: [0.2, 0.2, 0.2, 1.0],
        diffuse: [0.9, 0.9, 0.9, 1.0],
        specular: [1.0, 1.0, 1.0, 1.0]
      }
    },
    # pattern 2: Green and brown
    {
      color1: {
        ambient: [0.0, 0.1, 0.0, 1.0],
        diffuse: [0.0, 0.5, 0.0, 1.0],
        specular: [0.2, 0.7, 0.2, 1.0]
      },
      color2: {
        ambient: [0.15, 0.08, 0.02, 1.0],
        diffuse: [0.4, 0.2, 0.05, 1.0],
        specular: [0.5, 0.3, 0.1, 1.0]
      }
    },
    # pattern 3: purple and cyan
    {
      color1: {
        ambient: [0.15, 0.0, 0.2, 1.0],
        diffuse: [0.5, 0.0, 0.7, 1.0],
        specular: [0.7, 0.3, 0.9, 1.0]
      },
      color2: {
        ambient: [0.0, 0.15, 0.2, 1.0],
        diffuse: [0.0, 0.6, 0.8, 1.0],
        specular: [0.3, 0.8, 1.0, 1.0]
      }
    }
  ]

  current_pattern = color_patterns[$floor_color_scheme]

  grid_count.times do |i|
    grid_count.times do |j|
      x = (i - (grid_count / 2)) * grid_size
      z = (j - (grid_count / 2)) * grid_size

      # Checkerboard pattern determination
      if (i + j).even?
        # Color 1
        color = current_pattern[:color1]
        GL.Materialfv(GL::FRONT_AND_BACK, GL::AMBIENT, color[:ambient].pack('F*'))
        GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, color[:diffuse].pack('F*'))
        GL.Materialfv(GL::FRONT_AND_BACK, GL::SPECULAR, color[:specular].pack('F*'))
      else
        # Color 2
        color = current_pattern[:color2]
        GL.Materialfv(GL::FRONT_AND_BACK, GL::AMBIENT, color[:ambient].pack('F*'))
        GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, color[:diffuse].pack('F*'))
        GL.Materialfv(GL::FRONT_AND_BACK, GL::SPECULAR, color[:specular].pack('F*'))
      end

      GL.Materialfv(GL::FRONT_AND_BACK, GL::SHININESS, [50.0].pack('F*'))

      GL.Begin(GL::QUADS)
      GL.Normal3f(0, 1, 0)
      GL.Vertex3f(x, -5, z)
      GL.Vertex3f(x + grid_size, -5, z)
      GL.Vertex3f(x + grid_size, -5, z + grid_size)
      GL.Vertex3f(x, -5, z + grid_size)
      GL.End()
    end
  end

  # Draw grid lines (white)
  GL.LineWidth(1.5)
  line_ambient = [0.2, 0.2, 0.2, 1.0].pack('F*')
  line_diffuse = [0.6, 0.6, 0.6, 1.0].pack('F*')
  line_specular = [0.8, 0.8, 0.8, 1.0].pack('F*')
  GL.Materialfv(GL::FRONT_AND_BACK, GL::AMBIENT, line_ambient)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::DIFFUSE, line_diffuse)
  GL.Materialfv(GL::FRONT_AND_BACK, GL::SPECULAR, line_specular)

  GL.Begin(GL::LINES)
  (grid_count + 1).times do |i|
    pos = (i - (grid_count / 2)) * grid_size
    GL.Vertex3f(pos, -4.98, -grid_count / 2 * grid_size)
    GL.Vertex3f(pos, -4.98, grid_count / 2 * grid_size)
    GL.Vertex3f(-grid_count / 2 * grid_size, -4.98, pos)
    GL.Vertex3f(grid_count / 2 * grid_size, -4.98, pos)
  end
  GL.End()
end

# Draw shadow (simple planar projection)
def draw_shadow(draw_object_proc, light_pos)
  GL.PushMatrix()

  # Calculate shadow projection matrix
  ground_plane = [0.0, 1.0, 0.0, 5.0] # y = -5 plane
  shadow_matrix = calculate_shadow_matrix(light_pos, ground_plane)

  GL.MultMatrixf(shadow_matrix)

  # Shadow material settings
  shadow_color = [0.0, 0.0, 0.0, 0.3].pack('F*')
  GL.Materialfv(GL::FRONT, GL::DIFFUSE, shadow_color)
  GL.Materialfv(GL::FRONT, GL::SPECULAR, shadow_color)

  # Use stencil buffer to draw shadows
  GL.Enable(GL::STENCIL_TEST)
  GL.StencilFunc(GL::EQUAL, 1, 0xFF)
  GL.StencilOp(GL::KEEP, GL::KEEP, GL::INCR)

  draw_object_proc.call

  GL.Disable(GL::STENCIL_TEST)
  GL.PopMatrix()
end

def calculate_shadow_matrix(light_pos, plane)
  dot = (plane[0] * light_pos[0]) + (plane[1] * light_pos[1]) +
        (plane[2] * light_pos[2]) + (plane[3] * light_pos[3])

  [
    dot - (light_pos[0] * plane[0]), -light_pos[0] * plane[1],
    -light_pos[0] * plane[2], -light_pos[0] * plane[3],
    -light_pos[1] * plane[0], dot - (light_pos[1] * plane[1]),
    -light_pos[1] * plane[2], -light_pos[1] * plane[3],
    -light_pos[2] * plane[0], -light_pos[2] * plane[1],
    dot - (light_pos[2] * plane[2]), -light_pos[2] * plane[3],
    -light_pos[3] * plane[0], -light_pos[3] * plane[1],
    -light_pos[3] * plane[2], dot - (light_pos[3] * plane[3])
  ].pack('F*')
end

# Set up perspective projection
def setup_perspective(width, height, fov, near, far)
  aspect = width.to_f / height
  top = near * Math.tan(fov * Math::PI / 360.0)
  bottom = -top
  left = bottom * aspect
  right = top * aspect

  GL.Frustum(left, right, bottom, top, near, far)
end

if __FILE__ == $PROGRAM_NAME
  # Load GLFW library
  begin
    GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  rescue LoadError
    begin
      GLFW.load_lib('/usr/local/lib/libglfw.dylib')
    rescue LoadError
      GLFW.load_lib
    end
  end

  GLFW.Init()

  # Hints for anti-aliasing
  GLFW.WindowHint(GLFW::SAMPLES, 4)

  window = GLFW.CreateWindow(1200, 800, 'Ruby × Taipei 101', nil, nil)
  GLFW.MakeContextCurrent(window)
  GLFW.SetKeyCallback(window, key_callback)

  GL.load_lib

  # OpenGL initial settings
  GL.Enable(GL::DEPTH_TEST)
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
  GL.Enable(GL::LIGHT1)
  GL.Enable(GL::LIGHT2) # Additional light
  GL.Enable(GL::NORMALIZE)
  GL.Enable(GL::MULTISAMPLE)
  GL.ShadeModel(GL::SMOOTH)

  # Enable two-sided lighting
  GL.LightModeli(GL::LIGHT_MODEL_TWO_SIDE, GL::TRUE)

  # Brighten ambient light
  GL.LightModelfv(GL::LIGHT_MODEL_AMBIENT, [0.4, 0.4, 0.4, 1.0].pack('F*'))

  # Main light (sunlight)
  light0_position = [5.0, 10.0, 5.0, 1.0].pack('F*')
  light0_diffuse = [1.0, 1.0, 0.9, 1.0].pack('F*')
  light0_specular = [1.0, 1.0, 1.0, 1.0].pack('F*')

  GL.Lightfv(GL::LIGHT0, GL::POSITION, light0_position)
  GL.Lightfv(GL::LIGHT0, GL::DIFFUSE, light0_diffuse)
  GL.Lightfv(GL::LIGHT0, GL::SPECULAR, light0_specular)

  # Fill light (bluish light)
  light1_position = [-5.0, 5.0, -5.0, 1.0].pack('F*')
  light1_diffuse = [0.4, 0.4, 0.5, 1.0].pack('F*')
  light1_specular = [0.3, 0.3, 0.4, 1.0].pack('F*')

  GL.Lightfv(GL::LIGHT1, GL::POSITION, light1_position)
  GL.Lightfv(GL::LIGHT1, GL::DIFFUSE, light1_diffuse)
  GL.Lightfv(GL::LIGHT1, GL::SPECULAR, light1_specular)

  # Additional light (to illuminate Ruby)
  light2_position = [0.0, 5.0, 10.0, 1.0].pack('F*')
  light2_diffuse = [0.6, 0.6, 0.6, 1.0].pack('F*')
  light2_specular = [0.5, 0.5, 0.5, 1.0].pack('F*')

  GL.Lightfv(GL::LIGHT2, GL::POSITION, light2_position)
  GL.Lightfv(GL::LIGHT2, GL::DIFFUSE, light2_diffuse)
  GL.Lightfv(GL::LIGHT2, GL::SPECULAR, light2_specular)

  # Fog effect (atmospheric feeling)
  GL.Enable(GL::FOG)
  GL.Fogi(GL::FOG_MODE, GL::LINEAR)
  fog_color = [0.7, 0.7, 0.8, 1.0].pack('F*')
  GL.Fogfv(GL::FOG_COLOR, fog_color)
  GL.Fogf(GL::FOG_START, 20.0)
  GL.Fogf(GL::FOG_END, 50.0)

  width_buf = ' ' * 8
  height_buf = ' ' * 8
  rotation = 0.0
  time = 0.0
  camera_distance = 20.0

  until GLFW.WindowShouldClose(window) == GLFW::TRUE
    GLFW.GetFramebufferSize(window, width_buf, height_buf)
    width = width_buf.unpack1('L')
    height = height_buf.unpack1('L')

    GL.Viewport(0, 0, width, height)
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT | GL::STENCIL_BUFFER_BIT)
    GL.ClearColor(0.7, 0.7, 0.8, 1.0)

    # Set projection matrix
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    setup_perspective(width, height, 45.0, 0.1, 100.0)

    # Set model-view matrix
    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()

    # Camera settings
    camera_x = Math.sin(time * 0.1) * camera_distance
    camera_z = Math.cos(time * 0.1) * camera_distance
    camera_y = 8 + (Math.sin(time * 0.05) * 2)

    # Alternative implementation of gluLookAt
    eye = [camera_x, camera_y, camera_z]
    center = [0, 0, 0]
    up = [0, 1, 0]

    f = [center[0] - eye[0], center[1] - eye[1], center[2] - eye[2]]
    f_length = Math.sqrt((f[0]**2) + (f[1]**2) + (f[2]**2))
    f = f.map { |v| v / f_length }

    s = [(f[1] * up[2]) - (f[2] * up[1]),
         (f[2] * up[0]) - (f[0] * up[2]),
         (f[0] * up[1]) - (f[1] * up[0])]
    s_length = Math.sqrt((s[0]**2) + (s[1]**2) + (s[2]**2))
    s = s.map { |v| v / s_length }

    u = [(s[1] * f[2]) - (s[2] * f[1]),
         (s[2] * f[0]) - (s[0] * f[2]),
         (s[0] * f[1]) - (s[1] * f[0])]

    m = [
      s[0], u[0], -f[0], 0.0,
      s[1], u[1], -f[1], 0.0,
      s[2], u[2], -f[2], 0.0,
      0.0, 0.0, 0.0, 1.0
    ].pack('F*')

    GL.MultMatrixf(m)
    GL.Translatef(-eye[0], -eye[1], -eye[2])

    # Update light positions
    GL.Lightfv(GL::LIGHT0, GL::POSITION, light0_position)
    GL.Lightfv(GL::LIGHT1, GL::POSITION, light1_position)
    GL.Lightfv(GL::LIGHT2, GL::POSITION, light2_position)

    # Draw ground
    draw_ground

    # Set up stencil buffer
    GL.ClearStencil(0)
    GL.Enable(GL::STENCIL_TEST)
    GL.StencilFunc(GL::ALWAYS, 1, 0xFF)
    GL.StencilOp(GL::KEEP, GL::KEEP, GL::REPLACE)

    # Draw Taipei 101
    draw_realistic_taipei_101(0, 0, 0, rotation)

    # Draw Ruby logos
    draw_realistic_ruby(-4, (Math.sin(time * 0.5) * 0.5) - 2, 0, 1.5, rotation)
    draw_realistic_ruby(4, (Math.cos(time * 0.7) * 0.5) - 2, -2, 1.2, rotation)
    draw_realistic_ruby(0, (Math.sin(time * 0.3) * 0.3) - 2.5, 4, 1.0, rotation)
    draw_realistic_ruby(0, (Math.sin(time * 0.5) * 0.3) - 2.5, -4, 0.8, rotation)

    GL.Disable(GL::STENCIL_TEST)

    # 回転方向に応じて回転角度を更新
    rotation += $rotation_speed * $rotation_direction
    time += 0.016

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end
