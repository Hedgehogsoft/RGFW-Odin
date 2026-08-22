package rgfw_standard_mouse_icons

import rgfw "../../"

main :: proc() {
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    win := rgfw.createWindow("RGFW icon", 0, 0, 600, 400, {.Center, .NoResize})
    defer rgfw.window_close(win)

    rgfw.window_setExitKey(win, .Escape)
    mouse: rgfw.mouseIcon

    show := true

    for rgfw.window_shouldClose(win) == false {
        rgfw.pollEvents()
        if rgfw.isMousePressed(.Left) {
            rgfw.window_setMouseStandard(win, mouse)
            if mouse < max(rgfw.mouseIcon) {
                mouse += rgfw.mouseIcon(1)
            } else {
                mouse = rgfw.mouseIcon(0)
            }
        }

        if rgfw.isKeyPressed(.Space) {
            show = !show
            rgfw.window_showMouse(win, show)
        }
    }
}