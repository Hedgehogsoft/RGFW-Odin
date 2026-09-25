package rgfw_egl_example

import "core:fmt"
import gl "vendor:OpenGL"

import rgfw "../../"


glBegin:    proc "c" (mode: gl.GL_Enum)
glEnd:      proc "c" ()
glColor3f:  proc "c" (r, g, b: f32)
glVertex2f: proc "c" (x, y: f32)

load_gl_1_1 :: proc() {
    gl.load_up_to(1, 1, rgfw.setProcAddress_OpenGL)
    rgfw.setProcAddress_OpenGL(&glBegin,    "glBegin")
    rgfw.setProcAddress_OpenGL(&glEnd,      "glEnd")
    rgfw.setProcAddress_OpenGL(&glColor3f,  "glColor3f")
    rgfw.setProcAddress_OpenGL(&glVertex2f, "glVertex2f")
}


main :: proc() {
    rgfw.init("RGFW Example", {.EGL})
    defer rgfw.deinit()

    hints := rgfw.getGlobalHints_OpenGL()
    hints.major = 1
    hints.minor = 1
    rgfw.setGlobalHints_OpenGL(hints)

	win := rgfw.createWindow("a window", 0, 0, 800, 600, {.EGL, .Center, .NoResize, .Transparent})
    defer rgfw.window_close(win)
    load_gl_1_1()

    rgfw.window_makeCurrentContext_EGL(win)
    rgfw.window_setExitKey(win, .Escape)

    for rgfw.window_shouldClose(win) == false {
        rgfw.pollEvents()

        gl.ClearColor(0.0, 0.0, 0.0, 0.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        glBegin(.TRIANGLES)
        glColor3f(1.0, 0.0, 0.0); glVertex2f(-0.6, -0.75)
        glColor3f(0.0, 1.0, 0.0); glVertex2f(0.6, -0.75)
        glColor3f(0.0, 0.0, 1.0); glVertex2f(0.0, 0.75)
        glEnd()
        rgfw.window_swapBuffers_EGL(win)
        gl.Flush()
    }

    rgfw.window_close(win)
    return 
}

