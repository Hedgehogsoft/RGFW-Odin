package rgfw_callbacks_example 

import "base:runtime"
import "core:fmt"

import rgfw "../../"

window: ^rgfw.window
rgfw_context: runtime.Context

errorfunc :: proc "c" (info: rgfw.debugInfo) {
    if info.type != .Error || info.code == .noError { return }
    context = rgfw_context
    fmt.printf("RGFW ERROR: %s\n", info.msg)
}

scaleUpdatedfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("scale updated %f %f\n", f64(e.scale.x), f64(e.scale.y))
}

windowmovefunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("window moved %i %i\n", e.mouse.x, e.mouse.y)
}

windowresizefunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("window resized %i %i\n", e.update.w, e.update.h)
}

windowminimizefunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("window minimize\n")
}

windowmaximizefunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("window maximize %i %i\n", e.update.w, e.update.h)
}

windowrestorefunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("window restore %i %i\n", e.update.w, e.update.h)
}

windowclosefunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("window quit\n")
}

focusfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context

    if e.focus.state {
        fmt.printf("window in focus\n")
    }
    else {
        fmt.printf("window out of focus\n")
    }
}

mouseNotifyfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context

    if e.mouse.inWindow {
        fmt.printf("mouse enter %i %i\n", e.mouse.x, e.mouse.y)
    } else {
        fmt.printf("mouse leave\n")
    }
        
}

mouseposfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window || rgfw.window_isKeyPressed(e.common.win, .ControlL) == false {
        return
    }
    context = rgfw_context
    fmt.printf("mouse moved %i %i\n", e.mouse.x, e.mouse.y)
}

dropfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("dropped : %s\n", cstring(e.drop.value.data))
}

dragfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    t_str := (e.drag.dataType == .File)  ? "file"  : (e.drag.dataType == .Text) ? "text" : (e.drag.dataType == .URL) ? "URL" : "image"
	a_str := (e.drag.action   == .Enter) ? "enter" : (e.drag.action   == .Move) ? "move" : "exit"

    fmt.printf("dnd drag (%s %s) at %i %i\n", t_str, a_str, e.drag.x, e.drag.y)
}

windowrefreshfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
}

keyCharfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    fmt.printf("key char : 0x%08x (%r)\n", e.keyChar.value, e.keyChar.value)
}

keyfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
    if e.key.state {
        mapped := rgfw.physicalToMappedKey(e.key.value)
        fmt.printf("key pressed : %i (%v), physical key : %i (%v),  with modstate : %i\n", e.key.value, e.key.value, mapped, mapped, e.key.mod);
	} else {
	    fmt.printf("key released : %i (%v) with modstate : %i\n", e.key.value, e.key.value, e.key.mod);
	}
}

mousebuttonfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
	if e.button.state {
        fmt.printf("mouse button pressed : %v\n", e.button.value)
    } else {
        fmt.printf("mouse button released : %v\n", e.button.value)
    }
}

scrollfunc :: proc "c" (e: rgfw.event) {
    if e.common.win != window { return }
    context = rgfw_context
	fmt.printf("mouse scrolled %f %f\n", f64(e.delta.x), f64(e.delta.y))
}

monitorfunc :: proc "c" (e: rgfw.event) {
	monitor := e.monitor.monitor

    context = rgfw_context
	if (e.monitor.state) {
		fmt.printf("Monitor connected [or found] %s [%i %i %i %i]\n", monitor.name, monitor.x, monitor.y, monitor.mode.w, monitor.mode.h)
	} else {
		fmt.printf("Monitor disconnected %s [%i %i %i %i]\n", monitor.name, monitor.x, monitor.y, monitor.mode.w, monitor.mode.h)
	}
}

main :: proc() {
    rgfw.init("RGFW Example", {})
    defer rgfw.deinit()

    window = rgfw.createWindow("RGFW Callbacks", 500, 500, 500, 500, {.Center, .AllowDND})
    defer rgfw.window_close(window)
    rgfw.window_setExitKey(window, .Escape)

    rgfw.setDebugCallback(errorfunc)
    rgfw.setEventCallback(.scaleUpdated,        scaleUpdatedfunc)
	rgfw.setEventCallback(.windowMoved,         windowmovefunc)
	rgfw.setEventCallback(.windowResized,       windowresizefunc)
    rgfw.setEventCallback(.windowMinimized,     windowminimizefunc) // dad
    rgfw.setEventCallback(.windowRestored,      windowrestorefunc)
    rgfw.setEventCallback(.windowMaximized,     windowmaximizefunc)
	rgfw.setEventCallback(.windowClose,         windowclosefunc)
	rgfw.setEventCallback(.mouseMotion,         mouseposfunc)
	rgfw.setEventCallback(.mouseScroll,         scrollfunc)
	rgfw.setEventCallback(.windowRefresh,       windowrefreshfunc)
	rgfw.setEventCallback(.windowFocusIn,       focusfunc)
	rgfw.setEventCallback(.windowFocusOut,      focusfunc)
	rgfw.setEventCallback(.mouseEnter,          mouseNotifyfunc)
	rgfw.setEventCallback(.mouseLeave,          mouseNotifyfunc)
	rgfw.setEventCallback(.dataDrop,            dropfunc)
	rgfw.setEventCallback(.dataDrag,            dragfunc)
	rgfw.setEventCallback(.keyChar,             keyCharfunc)
	rgfw.setEventCallback(.keyPressed,          keyfunc)
	rgfw.setEventCallback(.keyReleased,         keyfunc)
	rgfw.setEventCallback(.mouseButtonPressed,  mousebuttonfunc)
	rgfw.setEventCallback(.mouseButtonReleased, mousebuttonfunc)
    rgfw.setEventCallback(.monitorConnected,    monitorfunc)
	rgfw.setEventCallback(.monitorDisconnected, monitorfunc)

    for (rgfw.window_shouldClose(window) == false) {
		rgfw.pollEvents()
   }

    rgfw.window_close(window)
}