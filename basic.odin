package main

import "core:fmt"
import "RGFW"
import gl "vendor:OpenGL"

running := true

gotMsg := false
keyfunc ::  proc "c" (event: ^RGFW.event) {
    gotMsg = true // because you can't call odin functions from C-odin functions
}

main :: proc() {  
    win := RGFW.createWindow("RGFW Example Window", 500, 500, 500, 500, .windowCenter | .windowOpenGL);
   
    
    RGFW.window_makeCurrentContext_OpenGL(win);

    RGFW.setEventCallback(.keyPressed, keyfunc)
    RGFW.setEventCallback(.keyReleased, keyfunc)

    gl.load_up_to(3, 3, RGFW.setProcAddress_OpenGL)

    RGFW.window_swapInterval_OpenGL(win, 1);

    gl.ClearColor(0, 0, 0, 0);

    for (running && RGFW.window_isKeyPressed(win, .keyEscape) == false) {   
        if (gotMsg) {
            fmt.printf("got message from callback\n")
            gotMsg = false
        }

        event : RGFW.event;
        for (RGFW.window_checkEvent(win, &event)) {
            if (event.type == .windowMoved) {
                fmt.printf("window moved\n");
            }
            else if (event.type == .windowResized) {
                fmt.printf("window resized\n");
            }
            if (event.type == .windowClose) {
                running = false;  
                break;
            }

            if (RGFW.window_isKeyPressed(win, .keyW)) {
                RGFW.window_setMouseDefault(win);
            }
            else if (RGFW.window_isKeyPressed(win, .keyQ)) {
                RGFW.window_showMouse(win, false);
            }

        }
        
        drawLoop(win);
    }
    
    RGFW.window_close(win);
}

drawLoop :: proc(w: ^RGFW.window) {
    RGFW.window_makeCurrentContext_OpenGL(w);

    gl.ClearColor(0.35, 0, 0.25, 255);

    gl.Clear(gl.COLOR_BUFFER_BIT);
    
    RGFW.window_swapBuffers_OpenGL(w); 
}