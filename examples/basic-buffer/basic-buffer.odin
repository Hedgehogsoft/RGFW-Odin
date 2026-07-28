package main

import "core:fmt"
import RGFW "../../"


pixelWidth : i32

rect :: struct {
	x, y, w, h : i32
}

drawRect :: proc(buffer : [][4]u8, r : rect, color: [3]u8) {
	for x := r.x; x < (r.x + r.w); x += 1 {
		for y := r.y; y < (r.y + r.h); y += 1 {
			buffer[y * pixelWidth + x] = {**color.rgb, 255}
		}
	}
}

main :: proc() {
	RGFW.init("basic buffer", {})
	defer RGFW.deinit()

	win := RGFW.createWindow("RGFW Example Window", 500, 500, 500, 500, {.Center})
	defer RGFW.window_close(win)

	mon := RGFW.window_getMonitor(win)
	pixelWidth = mon.mode.w

	width : i32 = 500
	height : i32 = 500

	if mon != nil {
		width  = i32(f32(mon.mode.w) * mon.pixelRatio)
		height = i32(f32(mon.mode.h) * mon.pixelRatio)
	}

	buffer := make([][4]u8, width * height)
	defer delete(buffer)

	surface := RGFW.createSurface(raw_data(&buffer[:][0]), width, height, .RGBA8)

	for !RGFW.window_shouldClose(win) {
		RGFW.pollEvents()

		RGFW.window_getSize(win, &width, &height)
		drawRect(buffer, {0, 0, width, height}, {0, 0, 255})
		drawRect(buffer, {200, 200, 200, 200}, {255, 0, 0})

		RGFW.window_blitSurface(win, surface)
	}
}
