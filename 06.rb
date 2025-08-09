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
    GL.ClearColor(0.0, 0.0, 0.0, 0.0)
    GL.Clear(GL::COLOR_BUFFER_BIT)
    GL.Begin(GL::QUADS)
    GL.Color3f(1,0,0) # 1
    GL.Vertex3f(-1,-1,1);GL.Vertex3f(1,-1,1);GL.Vertex3f(1,1,1);GL.Vertex3f(-1,1,1)
    GL.Color3f(0,1,0) # 2
    GL.Vertex3f(-1,-1,-1);GL.Vertex3f(-1,1,-1);GL.Vertex3f(1,1,-1);GL.Vertex3f(1,-1,-1)
    GL.Color3f(0,0,1) # 3
    GL.Vertex3f(-1,1,-1);GL.Vertex3f(-1,1,1);GL.Vertex3f(1,1,1);GL.Vertex3f(1,1,-1)
    GL.Color3f(1,1,0) # 4
    GL.Vertex3f(-1,-1,-1);GL.Vertex3f(1,-1,-1);GL.Vertex3f(1,-1,1);GL.Vertex3f(-1,-1,1)
    GL.Color3f(0,1,1) # 5
    GL.Vertex3f(1,-1,-1);GL.Vertex3f(1,1,-1);GL.Vertex3f(1,1,1);GL.Vertex3f(1,-1,1)
    GL.Color3f(1,0,1) # 6
    GL.Vertex3f(-1,-1,-1);GL.Vertex3f(-1,-1,1);GL.Vertex3f(-1,1,1);GL.Vertex3f(-1,1,-1)
    GL.End()
    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
  end

  GLFW.DestroyWindow(window)
  GLFW.Terminate()
end
