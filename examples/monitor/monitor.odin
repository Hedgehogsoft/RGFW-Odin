package rgfw_monitor_example

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
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    win := rgfw.createWindow("a window", 0, 0, 800, 600, {.Center, .OpenGL})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)
    rgfw.window_swapInterval_OpenGL(win, 1) // Enable VSync

    load_gl_1_1()

    rgfw.window_makeCurrentContext_OpenGL(win)
    mon := rgfw.window_getMonitor(win)

    fmt.println("monitor :", mon.x, mon.y, mon.mode.w, mon.mode.h, mon.mode.refreshRate)

    x, y, w, h: i32
    rgfw.monitor_getWorkarea(mon, &x, &y, &w, &h)
    fmt.println("monitor work area:", x, y, w, h)

    count := rgfw.monitor_getModesPtr(mon, nil)
    modes := rgfw.monitor_getModes(mon, &count)
    count = rgfw.monitor_getModesPtr(mon, &modes)

    mode := mon.mode
    for i in 0..<count {
        fmt.println("mode", i, modes[i].w, modes[i].h, modes[i].refreshRate)
        if mode.refreshRate > 60 {
            rgfw.monitor_setMode(mon, &modes[i])
        }
    }

    rgfw.freeModes(modes)
    rgfw.monitor_setMode(mon, &mode)

    if mon == nil {
		fmt.println("failed to get monitor")
		return 
	}

    rgfw.monitor_scaleToWindow(mon, win)
    rgfw.window_setFullscreen(win, true)

    scaled := true

    for rgfw.window_shouldClose(win) == false {
        event: rgfw.event
        for rgfw.window_checkEvent(win, &event) && event.type != .windowClose {
            #partial switch event.type {
            case .windowFocusOut:
                if scaled == false { break }
                scaled = false
                rgfw.window_minimize(win)
                when ODIN_OS == .Linux || ODIN_OS == .FreeBSD || ODIN_OS == .OpenBSD {
                    rgfw.monitor_requestMode(rgfw.window_getMonitor(win), &mon.mode, .monitorScale)
                }
            case .windowFocusIn:
                if scaled == true { break }
                scaled = true
                mon = rgfw.window_getMonitor(win)
                rgfw.monitor_scaleToWindow(mon, win)
                rgfw.window_setFullscreen(win, true)
            }
        }
        w, h: i32
        rgfw.window_getSizeInPixels(win, &w, &h)

        gl.Viewport(0, 0, w, h)
        gl.ClearColor(0.1, 0.1, 0.1, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        glBegin(.TRIANGLES)
            glColor3f(1.0, 0.0, 0.0); glVertex2f(-0.6, -0.75)
            glColor3f(0.0, 1.0, 0.0); glVertex2f( 0.6, -0.75)
            glColor3f(0.0, 0.0, 1.0); glVertex2f( 0.0,  0.75)
        glEnd()

        rgfw.window_swapBuffers_OpenGL(win)
    }

    rgfw.monitor_requestMode(mon, &mode, .monitorScale)

}