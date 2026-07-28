# RGFW-Odin
![THE RGFW Logo](https://github.com/ColleagueRiley/RGFW/blob/main/logo.png?raw=true)

## Build statuses
![workflow](https://github.com/ColleagueRiley/RGFW-Odin/actions/workflows/linux.yml/badge.svg)
![workflow windows](https://github.com/ColleagueRiley/RGFW-Odin/actions/workflows/windows.yml/badge.svg)
![workflow windows](https://github.com/ColleagueRiley/RGFW-Odin/actions/workflows/macOS.yml/badge.svg)

# About
Odin bindings for RGFW,

Backends supported includes, X11, Cocoa and Windows, Web has not been tested and Wayland support has not yet been included.

Currently the graphics backend supports OpenGL, EGL, Vulkan, Metal, DirectX and buffer rendering, WebGPU helpers are not included.

## building
To build the RGFW binaries for the Odin binding run
`make` or `./build.bat` on Windows

# Getting started
## a very simple example
```c
package main

import "core:fmt"
import "RGFW"
import gl "vendor:OpenGL"

main :: proc() {
    RGFW.init("example", .initOpenGL);
    defer RGFW.deinit();

	window := RGFW.createWindow("window", 200, 200, 200, 200, .windowCenter | .windowOpenGL);
	RGFW.window_makeCurrentContext_OpenGL(window);

	gl.load_up_to(3, 3, RGFW.setProcAddress_OpenGL)

	for (!RGFW.window_shouldClose(window)) {
		RGFW.pollEvents();

		gl.Clear(gl.COLOR_BUFFER_BIT)
		gl.ClearColor(0, 0, 0, 1.0)

		RGFW.window_swapBuffers_OpenGL(window);
	}


	RGFW.window_close(window);
}
```

This can be compiled with

`odin run [file].odin -file`

## other examples
![examples](https://github.com/ColleagueRiley/RGFW/blob/main/screenshot.PNG?raw=true)

You can find more examples [here](examples) 

They can all be compiled with 

```sh
cd example/[example]
odin run .
```

# Contacts
- email : ColleagueRiley@gmail.com
- discord : ColleagueRiley
- discord server : https://discord.gg/pXVNgVVbvh
