package rgfw_flash_example

import "core:fmt"
import rgfw "../../"

main :: proc() {
	rgfw.init("RGFW Flash Test", {})
    defer rgfw.deinit()
    
    win := rgfw.createWindow("RGFW Flash Demo", 0, 0, 600, 400, {.Center})
    defer rgfw.window_close(win)

    rgfw.window_setExitKey(win, .Escape)

    mode: bool
    was_focused: bool

    for !rgfw.window_shouldClose(win) {
        rgfw.pollEvents()

        if (rgfw.isKeyPressed(.Space)) {
            mode = !mode
        }

        is_focused := rgfw.window_isInFocus(win)

        if (!is_focused && was_focused) {
            rgfw.window_flash(win, mode ? .UntilFocused : .Briefly)
        }

        was_focused = is_focused
    }

    return 
}