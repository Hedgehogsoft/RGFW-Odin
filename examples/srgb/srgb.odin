package rgfw_srgb

import "core:fmt"
import "core:log"
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
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    hints := rgfw.getGlobalHints_OpenGL()
    hints.sRGB = true
    hints.samples = 4
    rgfw.setGlobalHints_OpenGL(hints)

    win := rgfw.createWindow("RGFW Example Window", 500, 500, 500, 500, {.Center, .OpenGL})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)

    load_gl_1_1()

    rgfw.window_makeCurrentContext_OpenGL(win)

    for !rgfw.window_shouldClose(win) {
        rgfw.pollEvents()

        gl.ClearColor(1, 1, 1, 1)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        glBegin(.TRIANGLES)
            glColor3f(1.0, 0.0, 0.0); glVertex2f(-0.6, -0.75)
			glColor3f(0.0, 1.0, 0.0); glVertex2f( 0.6, -0.75)
			glColor3f(0.0, 0.0, 1.0); glVertex2f( 0.0,  0.75)
		glEnd()

		rgfw.window_swapBuffers_OpenGL(win)
		gl.Flush()
    }
}