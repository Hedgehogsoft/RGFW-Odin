package rgfw_flags_example

import "core:fmt"

import rgfw "../../"


main :: proc() {
    rgfw.init("RGFW Example", {})
    defer rgfw.deinit()

    win := rgfw.createWindow("RGFW flags", 0, 0, 600, 400, {.AllowDND})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)

    for rgfw.window_shouldClose(win) == false {

        //fmt.printf("Maximized: %v\n", rgfw.window_isMaximized(win))
        event: rgfw.event
        for rgfw.window_checkEvent(win, &event) {
            if event.type == .windowClose { break }
            if event.type != .keyPressed { continue }

            #partial switch event.key.value {
            case .B:
                fmt.printf("Borderless: %v\n", !rgfw.window_borderless(win))
                rgfw.window_setBorder(win, rgfw.window_borderless(win))

            case .R:
                @static res := true
                res = !res
                fmt.printf("Resizable: %v\n", res)
                if res {
                    rgfw.window_setMaxSize(win, 0, 0)
                    rgfw.window_setMinSize(win, 0, 0)
                } else {
                    w, h: i32
                    rgfw.window_getSizeInPixels(win, &w, &h)
                    rgfw.window_setMaxSize(win, w, h)
                    rgfw.window_setMinSize(win, w, h)
                }

            case .D:
                fmt.printf("Allow Drops: %v\n", rgfw.window_allowsDND(win))
                rgfw.window_setDND(win, !rgfw.window_allowsDND(win))

            case .T:
                fmt.printf("Mouse shown: %v\n", rgfw.window_isMouseHidden(win))
                rgfw.window_showMouse(win, rgfw.window_isMouseHidden(win))
                
            case .M:
                fmt.printf("Maximized: %v\n", rgfw.window_isMaximized(win))
                if rgfw.window_isMaximized(win) { rgfw.window_restore(win) }
                else { rgfw.window_maximize(win) }

            case .F:
                fmt.printf("fullscreen: %v\n", rgfw.window_isFullscreen(win))
                rgfw.window_setFullscreen(win, !rgfw.window_isFullscreen(win))

            case .H:
                fmt.printf("Hidden: %v\n", rgfw.window_isHidden(win))
                if rgfw.window_isHidden(win) { rgfw.window_show(win) }
                else { rgfw.window_hide(win) }

            case .S:
                fmt.printf("Scaling to monitor\n")
                rgfw.window_scaleToMonitor(win)

            case .C:
                fmt.printf("Centering window\n")
                rgfw.window_center(win)

            case .I:
                fmt.printf("floating: %v\n", !rgfw.window_isFloating(win))
                rgfw.window_setFloating(win, !rgfw.window_isFloating(win))
            }
        }
    }

    return
}