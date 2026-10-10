package rgfw_gl33_example

import "core:fmt"
import gl "vendor:OpenGL"

import rgfw "../../"

main :: proc() {
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    hints := rgfw.getGlobalHints_OpenGL()
    hints.major = 3
    hints.minor = 3
    rgfw.setGlobalHints_OpenGL(hints)

	window := rgfw.createWindow("LearnOpenGL", 800, 600, 800, 600, {.AllowDND, .Center, .ScaleToMonitor, .OpenGL})
    if window == nil {
        fmt.println("Failed to create RGFW window")
        return
    }
    defer rgfw.window_close(window)
    
    rgfw.window_setExitKey(window, .Escape)
    rgfw.window_makeCurrentContext_OpenGL(window)

    gl.load_up_to(3, 3, rgfw.setProcAddress_OpenGL)

    success: i32
    info_log: [512]u8

    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, &vertex_shader_source, nil)
    gl.CompileShader(vertex_shader)
    // check for shader compile errors
    gl.GetShaderiv(vertex_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(vertex_shader, 512, nil, raw_data(&info_log))
        fmt.printfln("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n%s", info_log)
    }

    // fragment shader
    fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader, 1, &fragment_shader_source, nil)
    gl.CompileShader(fragment_shader)
    // check for shader compile errors
    gl.GetShaderiv(fragment_shader, gl.COMPILE_STATUS, &success)
    if success == 0 {
        gl.GetShaderInfoLog(fragment_shader, 512, nil, raw_data(&info_log))
        fmt.printfln("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n%s", info_log)
    }

    // link shaders
    shader_program := gl.CreateProgram()
    defer gl.DeleteProgram(shader_program)

    gl.AttachShader(shader_program, vertex_shader)
    gl.AttachShader(shader_program, fragment_shader)
    gl.LinkProgram(shader_program)
    // check for linking errors
    gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success)
    if success == 0 {
        gl.GetProgramInfoLog(shader_program, 512, nil, raw_data(&info_log))
        fmt.printfln("ERROR::SHADER::PROGRAM::LINKING_FAILED\n%s", info_log)
    }
    gl.DeleteShader(vertex_shader)
    gl.DeleteShader(fragment_shader)

    vertices := [?]f32 {
         0.5,  0.5, 0.0,  // top right
         0.5, -0.5, 0.0,  // bottom right
        -0.5, -0.5, 0.0,  // bottom left
        -0.5,  0.5, 0.0   // top left
    }
    
    indices := [?]u32 {  // note that we start from 0!
        0, 1, 3,  // first Triangle
        1, 2, 3   // second Triangle
    }

    VBO, VAO, EBO: u32
    gl.GenVertexArrays(1, &VAO)
    gl.GenBuffers(1, &VBO)
    gl.GenBuffers(1, &EBO)
    defer {
        gl.DeleteVertexArrays(1, &VAO)
        gl.DeleteBuffers(1, &VBO)
        gl.DeleteBuffers(1, &EBO)
    }

    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    gl.BindVertexArray(VAO)

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    // remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
    //glBindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    gl.BindVertexArray(0)


    // uncomment this call to draw in wireframe polygons.
    // gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE);

    // render loop
    // -----------
    for rgfw.window_shouldClose(window) == false {
        event: rgfw.event

        for rgfw.window_checkEvent(window, &event) {
            if event.type == .windowClose {
                break
            }
        }

		// render
        // ------
        gl.ClearColor(0.2, 0.3, 0.3, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        // draw our first triangle
        gl.UseProgram(shader_program)
        // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        gl.BindVertexArray(VAO) 
        // gl.DrawArrays(gl.TRIANGLES, 0, 6)
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
        // glBindVertexArray(0); // no need to unbind it every time

        rgfw.window_swapBuffers_OpenGL(window)
    }
}


when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 {
    vertex_shader_source: cstring = `
#version 330 es
layout (location = 0) in vec3 aPos;
void main() 
{
    gl._Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
`
    fragment_shader_source: cstring = `
#version 330 es
out vec4 FragColor;
void main()
{
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
`

} else {
    vertex_shader_source: cstring = `
#version 330 core
attribute vec3 aPos;
void main() {
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
`
    fragment_shader_source: cstring = `
#version 330 core
void main() {
    gl_FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
`
}
