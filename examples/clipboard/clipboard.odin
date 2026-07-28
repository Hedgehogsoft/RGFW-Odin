package main

import "core:fmt"
import RGFW "../../"
import gl "vendor:OpenGL"


main :: proc() {
	RGFW.init("RGFW Example", {})
	defer RGFW.deinit()

	win := RGFW.createWindow("RGFW Example Window", 500, 500, 500, 500, {.Center})
	defer RGFW.window_close(win)
	RGFW.window_setExitKey(win, .Escape)

	for !RGFW.window_shouldClose(win) {
		RGFW.pollEvents()

		if RGFW.isKeyDown(.ControlL) {
			switch {
			case RGFW.isKeyPressed(.V):
				if clipboard := RGFW.readClipboard(.Text); clipboard != nil {
					fmt.printfln("clipboard paste %i: %s", clipboard.length, cast(cstring)clipboard.data)
				} else {
					fmt.printfln("failed to read clipboard")
				}

			case RGFW.isKeyPressed(.C):
				str: cstring = "string"

				data: RGFW.dataTransfer
				data.data = transmute([^]u8)str
				data.length = cast(uint)len(str) + 1
				data.type = .Text
				RGFW.writeClipboard(data)

				if clipboard := RGFW.readClipboard(.Text); clipboard != nil {
					fmt.printfln("clipboard paste %i: %s", clipboard.length, cast(cstring)clipboard.data)
				} else {
					fmt.printfln("failed to read clipboard")
				}
			}
		}
	}
}