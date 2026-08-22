package rgfw_mouse_icons_example

import "core:fmt"
import "core:image"
import "core:image/png"

import rgfw "../../"

main :: proc() {
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    win := rgfw.createWindow("RGFW icons", 0, 0, 600, 600, {.Center, .NoResize})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)

    icon, err := image.load("logo.png")
    if err != nil {
        fmt.println("failed to load icon.png", err)
        return
    }
    defer image.destroy(icon)

    mouse := rgfw.createMouse(raw_data(icon.pixels.buf), i32(icon.width), i32(icon.height), .RGBA8)
    defer rgfw.freeMouse(mouse)

    rgfw.window_setMouse(win, mouse)
    show := true

    for rgfw.window_shouldClose(win) == false {
        rgfw.pollEvents()
        if rgfw.isKeyReleased(.Space) {
            show = !show
            rgfw.window_showMouse(win, show)
        }
    }
}
