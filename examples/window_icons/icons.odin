package rgfw_icons_example

import "core:fmt"
import "core:bytes"
import "core:image/"
import "core:image/png"

import rgfw "../../"

main :: proc() {
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    win := rgfw.createWindow("RGFW icons", 0,0, 600, 400, {.Center, .NoResize})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)

    icon, err := image.load("logo.png")
    if err != nil {
        fmt.println("Failed to load icon.png", err)
        return
    }
    defer image.destroy(icon)

    rgfw.window_setIconEx(win, raw_data(&base_icon), 3, 3, .RGBA8, .Window)
    rgfw.window_setIconEx(
        win, raw_data(icon.pixels.buf), 
        i32(icon.width), i32(icon.height), .RGBA8, .Taskbar)

    for rgfw.window_shouldClose(win) == false {
        rgfw.pollEvents()
    }
}

base_icon := [3*3*4]byte {
    0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 
    0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 
    0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF,
}