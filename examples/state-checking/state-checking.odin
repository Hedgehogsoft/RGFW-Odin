package rgfw_state_checking_example

import "core:fmt"

import rgfw "../../"

WindowState :: struct {
    isInFocus: bool,
    isFullscreen: bool,
    isMinimized: bool,
    isMaximized: bool,
    posX, posY: i32,
    width, height: i32,
    escapePressed: bool,
    spaceDown: bool,
    enterReleased: bool,
    controlPressed: bool,
    leftMousePressed: bool,
    rightMouseDown: bool,
    middleMouseReleased: bool,
    scrollX, scrollY: f32,
    mouseX, mouseY: i32,
	vectorX, vectorY: f32,
    didMouseLeave: bool,
    didMouseEnter: bool,
    isMouseInside: bool,
    drop: bool,
    drag: bool,
    dragX, dragY: i32,
    dataDrop: ^rgfw.dataDropNode,
}


main :: proc() {
    rgfw.init("RGFW Example", {})
    defer rgfw.deinit()

    win := rgfw.createWindow("RGFW State Checking", 500, 500, 500, 500, {.Center, .AllowDND})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)

    prevState: WindowState

    for rgfw.window_shouldClose(win) == false {
        rgfw.pollEvents()

        currState := WindowState{
            rgfw.window_isInFocus(win),
            rgfw.window_isFullscreen(win),
            rgfw.window_isMinimized(win),
            rgfw.window_isMaximized(win),
            0, 0,
            0, 0,
            rgfw.window_isKeyPressed(win, .Escape),
            rgfw.window_isKeyDown(win, .Space),
            rgfw.window_isKeyReleased(win, .Enter),
            rgfw.window_isKeyPressed(win, .ControlL),
            rgfw.window_isMousePressed(win, .Left),
            rgfw.window_isMouseDown(win, .Right),
            rgfw.window_isMouseReleased(win, .Middle),
            0, 0,
            0, 0,
			0.0, 0.0,
            rgfw.window_didMouseLeave(win),
            rgfw.window_didMouseEnter(win),
            rgfw.window_isMouseInside(win),
            rgfw.window_didDataDrop(win),
            rgfw.window_isDataDragging(win),
            0, 0, {},
        }

		rgfw.window_getPosition(win, &currState.posX, &currState.posY)
        rgfw.window_getSize(win, &currState.width, &currState.height)
        rgfw.window_getMouse(win, &currState.mouseX, &currState.mouseY)
		rgfw.getMouseVector(&currState.vectorX, &currState.vectorY)
		rgfw.getMouseScroll(&currState.scrollX, &currState.scrollY)

        rgfw.window_getDataDrag(win, &currState.dragX, &currState.dragY)
        currState.dataDrop = rgfw.window_getDataDrop(win)

        if currState.isInFocus != prevState.isInFocus {
            fmt.printf("Is in focus: %s\n", currState.isInFocus ? "Yes" : "No")
        }
        if (currState.isFullscreen != prevState.isFullscreen) {
            fmt.printf("Is fullscreen: %s\n", currState.isFullscreen ? "Yes" : "No")
        }
        if (currState.isMinimized != prevState.isMinimized) {
            fmt.printf("Is minimized: %s\n", currState.isMinimized ? "Yes" : "No")
        }
        if (currState.isMaximized != prevState.isMaximized) {
            fmt.printf("Is maximized: %s\n", currState.isMaximized ? "Yes" : "No")
        }
        if (currState.posX != prevState.posX || currState.posY != prevState.posY) {
            fmt.printf("Window position: (%i, %i)\n", currState.posX, currState.posY)
        }
        if (currState.width != prevState.width || currState.height != prevState.height) {
            fmt.printf("Window size: (%i, %i)\n", currState.width, currState.height)
        }
        if (currState.escapePressed != prevState.escapePressed) {
            fmt.printf("Is Escape key pressed: %s\n", currState.escapePressed ? "Yes" : "No")
        }
        if (currState.spaceDown != prevState.spaceDown) {
            fmt.printf("Is Space key down: %s\n", currState.spaceDown ? "Yes" : "No")
        }
        if (currState.enterReleased != prevState.enterReleased) {
            fmt.printf("Is Enter key released: %s\n", currState.enterReleased ? "Yes" : "No")
        }
        if (currState.controlPressed != prevState.controlPressed) {
            fmt.printf("Is Control key pressed: %s\n", currState.controlPressed ? "Yes" : "No")
        }
        if (currState.leftMousePressed != prevState.leftMousePressed) {
            fmt.printf("Is left mouse button pressed: %s\n", currState.leftMousePressed ? "Yes" : "No")
        }
        if (currState.rightMouseDown != prevState.rightMouseDown) {
            fmt.printf("Is right mouse button down: %s\n", currState.rightMouseDown ? "Yes" : "No")
        }
        if (currState.middleMouseReleased != prevState.middleMouseReleased) {
            fmt.printf("Is middle mouse button released: %s\n", currState.middleMouseReleased ? "Yes" : "No")
        }
        if (currState.scrollX != prevState.scrollX || currState.scrollY != prevState.scrollY) {
            fmt.printf("Mouse scrolling (%f %f)\n", currState.scrollX, currState.scrollY)
        }
        if (rgfw.isKeyDown(.ControlL) && (currState.mouseX != prevState.mouseX || currState.mouseY != prevState.mouseY)) {
            fmt.printf("Mouse position in window: (%i, %i)\n", currState.mouseX, currState.mouseY)
        }
        if (rgfw.isKeyDown(.ControlL) && (currState.vectorX != prevState.vectorX || currState.vectorY != prevState.vectorY)) {
            fmt.printf("Mouse vector: (%f, %f)\n", currState.vectorX, currState.vectorY)
        }
        if (currState.didMouseLeave != prevState.didMouseLeave) {
            fmt.printf("Did mouse leave: %s\n", currState.didMouseLeave ? "Yes" : "No")
        }
        if (currState.didMouseEnter != prevState.didMouseEnter) {
            fmt.printf("Did mouse enter: %s\n", currState.didMouseEnter ? "Yes" : "No")
        }
        if (currState.isMouseInside != prevState.isMouseInside) {
            fmt.printf("Is mouse inside the window: %s\n", currState.isMouseInside ? "Yes" : "No")
        }

        if (currState.drag != prevState.drag || (currState.drag && (currState.dragX != prevState.dragX || currState.dragY != prevState.dragY))) {
            if (currState.drag) {
                fmt.printf("Is dragging data, %i %i\n", currState.dragX, currState.dragY)
            } else {
                fmt.printf("Is not dragging data\n")
            }
        }

        if currState.drop != prevState.drop {
            if currState.drop {
                fmt.printf("Data dropped :\n")
                for node := currState.dataDrop; node != nil; node = node.next {
                    fmt.printf("    file : %s\n", node.data[:node.length])
                }
            } else {
                fmt.printf("No data has ben dropped\n")
            }
        }

        prevState = currState
    }
    
    return
}
