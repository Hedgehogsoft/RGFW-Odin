# RGFW-Odin
![THE RGFW Logo](https://github.com/ColleagueRiley/RGFW/blob/main/logo.png?raw=true)

## Build statuses
![workflow](https://github.com/ColleagueRiley/RGFW-Odin/actions/workflows/linux.yml/badge.svg)
![workflow windows](https://github.com/ColleagueRiley/RGFW-Odin/actions/workflows/windows.yml/badge.svg)
![workflow windows](https://github.com/ColleagueRiley/RGFW-Odin/actions/workflows/macOS.yml/badge.svg)

# About
Odin bindings for RGFW,

Currently the graphics backend supports OpenGL, EGL, Vulkan, Metal and buffer rendering, WebGPU, and DirectX helpers are not included.

## building
To build the Odin binding simple run
`make build-RGFW`
you can also run `make` to build and then run an example program or `make debug` to build from scratch then run an example program.

# examples
![examples](https://github.com/ColleagueRiley/RGFW/blob/main/screenshot.PNG?raw=true)

## basic
A basic example can be found in `basic.odin`, it includes a basic OpenGL example of just about all of RGFW's functionalities.

## basic buffer
A basic example can be found in `basic-buffer.odin`, it includes a basic OpenGL example of buffer rendering with odin

## a very simple example
```c
package main

import "core:fmt"
import "RGFW"
import gl "vendor:OpenGL"

main :: proc() {
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

# Contacts
- email : ColleagueRiley@gmail.com
- discord : ColleagueRiley
- discord server : https://discord.gg/pXVNgVVbvh

# Documentation
More information about RGFW can be found on the [RGFW repo](https://RSGL.github.io/RGFW)

There is a lot of in-header-documentation, but more documentation can be found [here](https://RSGL.github.io/RGFW)

If you wish to build the documentation yourself, there is also a Doxygen file attached.

