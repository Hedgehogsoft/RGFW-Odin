package rgfw_event_queue_example

import "core:fmt"

import rgfw "../../"



main :: proc() {
    rgfw.init("RGFW Example", {})
    defer rgfw.deinit()

    win := rgfw.createWindow("RGFW Events", 500, 500, 500, 500, {.Center, .AllowDND})
    defer rgfw.window_close(win)
    event: rgfw.event
    rgfw.window_setExitKey(win, .Escape)

    for rgfw.window_shouldClose(win) == false {
        rgfw.waitForEvent(i32(rgfw.eventWait.WaitNext))
        for rgfw.window_checkEvent(win, &event) {
            #partial switch event.type {
            case .windowClose:         fmt.println("window closed")
            case .keyPressed:          fmt.println("Key pressed", event.keyChar.value)
            case .keyReleased:         fmt.println("Key released", event.keyChar.value)
            case .mouseButtonPressed:  fmt.println("mouse button pressed", event.button.value)
            case .mouseButtonReleased: fmt.println("Mouse Button Released", event.button.value)
            case .mouseScroll:         fmt.println("Mouse Button scroll", event.delta.x, event.delta.y)
            case .windowMinimized:     fmt.println("window minimized")
            case .windowFocusIn:       fmt.println("Focused")
            case .windowFocusOut:      fmt.println("Unfocused")
            case .mouseEnter:          fmt.println("Mouse Entered", event.mouse.x, event.mouse.y)
            case .mouseLeave:          fmt.println("Mouse left")
            case .windowRefresh:       fmt.println("Refresh")
            case .dataDrag:            fmt.println("Drag :", event.drag.x, event.drag.y)
            case .scaleUpdated:        fmt.println("Scale Updated :", event.scale.x, event.scale.y)
            
            case .windowMoved:
                x, y: i32
                rgfw.window_getPosition(win, &x, &y)
                fmt.println("window moved", x, y)

            case .windowResized:
                w, h: i32
                rgfw.window_getSizeInPixels(win, &w, &h)
                fmt.println("window resize", w, h)

            case .windowMaximized:
                w, h: i32
                rgfw.window_getSizeInPixels(win, &w, &h)
                fmt.println("window maximized", w, h)

            case .windowRestored:
                w, h: i32
                rgfw.window_getSizeInPixels(win, &w, &h)
                fmt.println("window restored", w, h)

            case .mousePosChanged:
                if rgfw.window_isKeyPressed(win, .ControlL) {
                    fmt.printf("Mouse pos changed %i %i\n", event.mouse.x, event.mouse.y)
                }

            case .dataDrop:
                fmt.printfln("dropped : %q", cstring(event.drop.value.data))
            }
        }
    }
    rgfw.window_close(win)
}