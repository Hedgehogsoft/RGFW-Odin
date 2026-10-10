package rgfw_gl33_example

import "core:fmt"
import gl "vendor:OpenGL"

import rgfw "../../"

main :: proc() {
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    hints := rgfw.getGlobalHints_OpenGL()
    hints.major = 3
    hints.minor = 3
    rgfw.setGlobalHints_OpenGL(hints)

    /* hide by default until the window is ready to show*/
    win := rgfw.createWindow("a window", 0, 0, 800, 600, {.Center, .NoResize, .Hide})
    defer rgfw.window_close(win)
    rgfw.window_createContext_OpenGL(win, hints)

    rgfw.window_setExitKey(win, .Escape)
    gl.load_up_to(3, 3, rgfw.setProcAddress_OpenGL)

    version := gl.GetString(gl.VERSION)
    fmt.println("OpenGL Version:", version)

    rgfw.window_show(win)

    for rgfw.window_shouldClose(win) == false {
        event: rgfw.event
        for rgfw.window_checkEvent(win, &event) {}

        gl.ClearColor(0.1, 0.1, 0.1, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)
        rgfw.window_swapBuffers_OpenGL(win)
    }
}