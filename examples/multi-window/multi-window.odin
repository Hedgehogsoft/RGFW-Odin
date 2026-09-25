package rgfw_multo_window_example

import "core:fmt"
import "core:thread"
import gl "vendor:OpenGL"

import "core:sys/windows"

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

check_events :: proc(win: ^rgfw.window) {
    event: rgfw.event

    for rgfw.window_checkQueuedEvent(win, &event) {
        #partial switch event.type {
        case .windowClose:
            rgfw.window_setShouldClose(win, true)

        case .windowResized:
            w, h: i32
            rgfw.window_getSizeInPixels(event.common.win, &w, &h)
            if w != 0 && h != 0 {
                fmt.printfln("window %p: resize: %dx%d", win, w, h)
            }

        case .dataDrop:
            fmt.printfln("window %p: drag and drop: %dx%d:", rawptr(win), event.mouse.x, event.mouse.y)
            fmt.printfln("\t %q", event.drop.value.data[:event.drop.value.length])

        case .keyPressed:
            if !rgfw.window_isKeyDown(win, .ControlL) && !rgfw.window_isKeyDown(win, .ControlR) {
                break
            }

            if event.key.value == .C {
                buf: [33]byte
                str := fmt.bprintf(buf[:32], "window %p: 刺猬", win)
                data := rgfw.dataTransfer {
                    data = raw_data(str),
                    length = len(str) + 1,
                    type = .Text,
                }
                rgfw.writeClipboard(data)

            } else if event.key.value == .V {
                data := rgfw.readClipboard(.Text)
                if data == nil { break }
                fmt.printf("clipboard paste %i: %q\n", u32(data.length), data.data[:data.length])
            }
        }
    }
}

loop :: proc(ptr: rawptr) {
    win := (^rgfw.window)(ptr)
    rgfw.window_makeCurrentContext_OpenGL(win)

    blue: int
    frames: int

    for !rgfw.window_shouldClose(win) {
        check_events(win)
        if rgfw.window_isKeyPressed(win, .Space) {
            blue = (blue + 1) % 100
        }

        gl.ClearColor(0, 0, f32(blue) * 0.01, 1)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        glBegin(.TRIANGLES)
            glColor3f(1.0, 0.0, 0.0); glVertex2f(-0.6, -0.75)
            glColor3f(0.0, 1.0, 0.0); glVertex2f( 0.6, -0.75)
            glColor3f(0.0, 0.0, 1.0); glVertex2f( 0.0,  0.75)
        glEnd()

        rgfw.window_swapBuffers_OpenGL(win)
        frames += 1
    }

    fmt.printfln("window %p: total frames %v", win, frames);
	rgfw.window_makeCurrentContext_OpenGL(nil);

}


main :: proc() {
    when ODIN_OS == .Windows {
        windows.SetConsoleOutputCP(.UTF8)
    }

    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    load_gl_1_1()

    hints := rgfw.getGlobalHints_OpenGL()

    win1 := rgfw.createWindow("RGFW Example Window 1", 500, 500, 500, 500, {.AllowDND, .OpenGL})

	rgfw.window_makeCurrentContext_OpenGL(nil) /* this is so we can share the context on wine for some reason */

	hints.share = rgfw.window_getContext_OpenGL(win1)
	rgfw.setGlobalHints_OpenGL(hints)

	win2 := rgfw.createWindow("RGFW Example Window 2", 100, 100, 200, 200, {.NoResize, .AllowDND, .OpenGL})

	rgfw.window_makeCurrentContext_OpenGL(nil) /* this is so we can share the context on wine for some reason */

	win3 := rgfw.createWindow("RGFW Example Window 3", 20, 500, 400, 300, {.NoResize, .AllowDND, .OpenGL})
	fmt.println("OpenGL Version:", gl.GetString(gl.VERSION))
	rgfw.window_makeCurrentContext_OpenGL(nil) /* this is really important (this releases the opengl context on this thread) */

    rgfw.window_setExitKey(win1, .Escape)
    rgfw.window_setExitKey(win2, .Escape)
    rgfw.window_setExitKey(win3, .Escape)
	rgfw.setQueueEvents(true) /* manually enable the queue so we don't accidently miss the first few events */

	thread1 := thread.create_and_start_with_data(win1, loop)
	thread2 := thread.create_and_start_with_data(win2, loop)
	thread3 := thread.create_and_start_with_data(win3, loop)

	for (!rgfw.window_shouldClose(win1) && !rgfw.window_shouldClose(win2) && !rgfw.window_shouldClose(win3)) {
		rgfw.pollEvents()
	}

	rgfw.window_setShouldClose(win1, true)
	rgfw.window_setShouldClose(win2, true)
	rgfw.window_setShouldClose(win3, true)
	thread.join(thread1)
	thread.join(thread2)
	thread.join(thread3)

	rgfw.window_close(win1)
	rgfw.window_close(win2)
	rgfw.window_close(win3)

}