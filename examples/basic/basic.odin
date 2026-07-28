package main

import "core:fmt"
import RGFW "../../"
import gl "vendor:OpenGL"


running := true

gotMsg := false
keyfunc ::  proc "c" (event: RGFW.event) {
	gotMsg = true
}

main :: proc() {
	RGFW.init("RGFW odin", {.OpenGL})
	defer RGFW.deinit()

	win := RGFW.createWindow("RGFW Example Window", 500, 500, 500, 500, {.Center, .OpenGL})
	defer RGFW.window_close(win)

	RGFW.setEventCallback(.keyPressed, keyfunc)
	RGFW.setEventCallback(.keyReleased, keyfunc)

	RGFW.window_makeCurrentContext_OpenGL(win)
	RGFW.window_swapInterval_OpenGL(win, 1)
	gl.load_up_to(3, 3, RGFW.setProcAddress_OpenGL)
	gl.ClearColor(0, 0, 0, 0)

	for running && !RGFW.window_isKeyPressed(win, .Escape) {
		if gotMsg {
			fmt.println("got message from callback")
			gotMsg = false
		}

		event : RGFW.event
event_loop:
		for RGFW.window_checkEvent(win, &event) {
			#partial switch event.type {
			case .windowMoved:   fmt.println("window moved")
			case .windowResized: fmt.println("window resized")
			case .windowClose:   running = false; break event_loop
			}
		}

		if (RGFW.window_isKeyPressed(win, .W)) {
			RGFW.window_setMouseDefault(win)
		}
		else if (RGFW.window_isKeyPressed(win, .Q)) {
			RGFW.window_showMouse(win, false)
		}

		drawLoop(win)
	}
}

drawLoop :: proc(w: ^RGFW.window) {
	RGFW.window_makeCurrentContext_OpenGL(w)

	gl.ClearColor(0.35, 0, 0.25, 255)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	RGFW.window_swapBuffers_OpenGL(w)
}
