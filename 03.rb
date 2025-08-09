# frozen_string_literal: true

require 'opengl'
require 'glfw'

key_callback = GLFW.create_callback(:GLFWkeyfun) do |window, key, _scancode, action, _mods|
  GLFW.SetWindowShouldClose(window, 1) if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
end

if __FILE__ == $PROGRAM_NAME
  GLFW.load_lib('/opt/homebrew/lib/libglfw.dylib')
  GLFW.Init()
  GL.load_lib

  window = GLFW.CreateWindow(640, 480, 'Example', nil, nil)
  GLFW.MakeContextCurrent(window)
  GLFW.SetKeyCallback(window, key_callback)

  until GLFW.WindowShouldClose(window) == GLFW::TRUE
    GL.Begin(GL::TRIANGLES)
    GL.Color3f(1.0, 0.0, 0.0)
    GL.Vertex2f(-0.8, -0.8)
    GL.Color3f(0.0, 1.0, 0.0)
    GL.Vertex2f(0.8, -0.8)
    GL.Color3f(0.0, 0.0, 1.0)
    GL.Vertex2f(0.0, 0.9)
    GL.End
    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end
