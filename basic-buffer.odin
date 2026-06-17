package main

import "core:fmt"
import RGFW "RGFW"
import gl "vendor:OpenGL"
import "core:mem"

pixelWidth : i32;

rect :: struct {
    x, y, w, h : i32
}

drawRect :: proc(buffer : []u8, r : rect, color: ^[3]u8) {
    for x := r.x; x < (r.x + r.w); x += 1 {
        for y := r.y; y < (r.y + r.h); y += 1 {
            index : i32 = y * (4 * pixelWidth) + x * 4;
            
            mem.copy(&(buffer[index]), &color[0], 3 * size_of(u8));
        }
    }
}

main :: proc() {  
    win := RGFW.createWindow("RGFW Example Window", 500, 500, 500, 500, .windowCenter); 
    
    mon := RGFW.window_getMonitor(win);
    pixelWidth = mon.mode.w;
	width : u32 = 500;
	height : u32 = 500;

	if (mon != nil) {
		width = u32(f32(mon.mode.w) * mon.pixelRatio);
		height = u32(f32(mon.mode.h) * mon.pixelRatio);
	}

    buffer := make([]u8, width * height * 4)
    defer delete(buffer)

	surface := RGFW.createSurface(raw_data(buffer), i32(width), i32(height), .formatRGBA8);

    for (RGFW.window_shouldClose(win) == false) {
        RGFW.pollEvents(); 
       
        width : i32;
        height : i32;
        RGFW.window_getSize(win, &width, &height)
        color1 : [3]u8 = {0, 0, 255}
        drawRect(buffer, {0, 0, width, height}, &color1)

        color2 : [3]u8 = {255, 0, 0}
        drawRect(buffer, {200, 200, 200, 200}, &color2)

        RGFW.window_blitSurface(win, surface);
    }
    
    RGFW.window_close(win);
}