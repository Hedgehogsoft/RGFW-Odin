package rgfw_mircoui_example

import gl "vendor:OpenGL"
import mu "vendor:microui"

import rgfw "../../"

BUFFER_SIZE :: 16384

tex_buf:   [BUFFER_SIZE *  8]f32
vert_buf:  [BUFFER_SIZE *  8]f32
color_buf: [BUFFER_SIZE * 16]u8
index_buf: [BUFFER_SIZE *  6]f32

buf_idx: i32


glEnableClientState: proc "c" (gl.GL_Enum)
glMatrixMode:        proc "c" (gl.GL_Enum)
glPushMatrix:        proc "c" ()
glPopMatrix:         proc "c" ()
glLoadIdentity:      proc "c" ()
glOrtho:             proc "c" (f64, f64, f64, f64, f64, f64)
glTexCoordPointer:   proc "c" (i32, gl.GL_Enum, i32, rawptr)
glVertexPointer:     proc "c" (i32, gl.GL_Enum, i32, rawptr)
glColorPointer:      proc "c" (i32, gl.GL_Enum, i32, rawptr)

load_gl :: proc() {
    gl.load_up_to(2, 1, rgfw.setProcAddress_OpenGL)
    rgfw.setProcAddress_OpenGL(&glEnableClientState, "glEnableClientState")
    rgfw.setProcAddress_OpenGL(&glMatrixMode,        "glMatrixMode")
    rgfw.setProcAddress_OpenGL(&glPushMatrix,        "glPushMatrix")
    rgfw.setProcAddress_OpenGL(&glLoadIdentity,      "glLoadIdentity")
    rgfw.setProcAddress_OpenGL(&glOrtho,             "glOrtho")
    rgfw.setProcAddress_OpenGL(&glTexCoordPointer,   "glTexCoordPointer")
    rgfw.setProcAddress_OpenGL(&glVertexPointer,     "glVertexPointer")
    rgfw.setProcAddress_OpenGL(&glColorPointer,      "glColorPointer")
    rgfw.setProcAddress_OpenGL(&glPopMatrix,         "glPopMatrix")
}

r_init :: proc() {
    /* init gl */
    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    gl.Disable(gl.CULL_FACE)
    gl.Disable(gl.DEPTH_TEST)
    gl.Enable(gl.SCISSOR_TEST)
    gl.Enable(gl.TEXTURE_2D)
    glEnableClientState(.VERTEX_ARRAY)
    glEnableClientState(.TEXTURE_COORD_ARRAY)
    glEnableClientState(.COLOR_ARRAY)

    /* init texture */
    id: u32
    gl.GenTextures(1, &id)
    gl.BindTexture(gl.TEXTURE_2D, id)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.ALPHA, 
        mu.DEFAULT_ATLAS_WIDTH, mu.DEFAULT_ATLAS_HEIGHT, 0,
        gl.ALPHA, gl.UNSIGNED_BYTE, &mu.default_atlas_alpha
    )
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    assert(gl.GetError() == 0)
}

flush :: proc() {
    if (buf_idx == 0) { return }

    glMatrixMode(.PROJECTION)
    glPushMatrix()
    glLoadIdentity()
    glOrtho(0.0, f64(s.width), f64(s.height), 0.0, -1.0, +1.0)
    glMatrixMode(.MODELVIEW)
    glPushMatrix()
    glLoadIdentity()

    glTexCoordPointer(2, .FLOAT, 0, &tex_buf)
    glVertexPointer(2, .FLOAT, 0, &vert_buf)
    glColorPointer(4, .UNSIGNED_BYTE, 0, &color_buf)
    when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 {
        gl.DrawElements(gl.TRIANGLES, buf_idx * 6, gl.UNSIGNED_INT, index_buf)
    } else {
        gl.DrawArrays(gl.TRIANGLES, 0, buf_idx * 6)
    }

    glMatrixMode(.MODELVIEW)
    glPopMatrix()
    glMatrixMode(.PROJECTION)
    glPopMatrix()

    buf_idx = 0
}


push_quad :: proc(dst: mu.Rect, src: mu.Rect, color: mu.Color) {
    if buf_idx == BUFFER_SIZE { 
        flush()
    }

    texvert_idx := buf_idx *  8
    color_idx   := buf_idx * 16
    element_idx := buf_idx *  4
    index_idx   := buf_idx *  6
    buf_idx += 1

    /* update texture buffer */
    x := f32(src.x) / mu.DEFAULT_ATLAS_WIDTH
    y := f32(src.y) / mu.DEFAULT_ATLAS_HEIGHT
    w := f32(src.w) / mu.DEFAULT_ATLAS_WIDTH
    h := f32(src.h) / mu.DEFAULT_ATLAS_HEIGHT
    tex_buf[texvert_idx + 0] = x
    tex_buf[texvert_idx + 1] = y
    tex_buf[texvert_idx + 2] = x + w
    tex_buf[texvert_idx + 3] = y
    tex_buf[texvert_idx + 4] = x
    tex_buf[texvert_idx + 5] = y + h
    tex_buf[texvert_idx + 6] = x + w
    tex_buf[texvert_idx + 7] = y + h

    /* update vertex buffer */
    vert_buf[texvert_idx + 0] = f32(dst.x)
    vert_buf[texvert_idx + 1] = f32(dst.y)
    vert_buf[texvert_idx + 2] = f32(dst.x + dst.w)
    vert_buf[texvert_idx + 3] = f32(dst.y)
    vert_buf[texvert_idx + 4] = f32(dst.x)
    vert_buf[texvert_idx + 5] = f32(dst.y + dst.h)
    vert_buf[texvert_idx + 6] = f32(dst.x + dst.w)
    vert_buf[texvert_idx + 7] = f32(dst.y + dst.h)

    /* update color buffer */
    c_arr := transmute([4]u8)color
    copy(color_buf[color_idx +  0:], c_arr[:])
    copy(color_buf[color_idx +  4:], c_arr[:])
    copy(color_buf[color_idx +  8:], c_arr[:])
    copy(color_buf[color_idx + 12:], c_arr[:])

    /* update index buffer */
    index_buf[index_idx + 0] = f32(element_idx + 0)
    index_buf[index_idx + 1] = f32(element_idx + 1)
    index_buf[index_idx + 2] = f32(element_idx + 2)
    index_buf[index_idx + 3] = f32(element_idx + 2)
    index_buf[index_idx + 4] = f32(element_idx + 3)
    index_buf[index_idx + 5] = f32(element_idx + 1)
}


r_draw_rect :: proc(rect: mu.Rect, color: mu.Color) {
    push_quad(rect, mu.default_atlas[mu.DEFAULT_ATLAS_WHITE], color)
}


r_draw_text :: proc(text: string, pos: mu.Vec2, color: mu.Color) {
    dst := mu.Rect{ pos.x, pos.y, 0, 0 }
    for c in transmute([]u8)text {
        if ((c & 0xc0) == 0x80) { continue }
        chr := int(min(c, 127))
        src := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + chr]
        dst.w = src.w
        dst.h = src.h
        push_quad(dst, src, color)
        dst.x += dst.w
    }
}


r_draw_icon :: proc(id: mu.Icon, rect: mu.Rect, color: mu.Color) {
    src := mu.default_atlas[id]
    x := rect.x + (rect.w - src.w) / 2
    y := rect.y + (rect.h - src.h) / 2
    push_quad({x, y, src.w, src.h}, src, color)
}


r_get_text_width :: proc(text: string) -> i32 {
    res: i32
    for c in transmute([]u8)text {
        if ((c & 0xc0) == 0x80) { continue }
        chr := int(min(c, 127))
        res += mu.default_atlas[mu.DEFAULT_ATLAS_FONT + chr].w
    }
    return res
}


r_get_text_height :: proc() -> i32 {
    return 18
}


r_set_clip_rect :: proc(rect: mu.Rect) {
    flush()
    /* Scale clip rect by pixel ratio for HiDPI framebuffers */
    sx := i32(f32(rect.x) * s.pixel_ratio)
    sy := i32((s.height - f32(rect.y + rect.h)) * s.pixel_ratio)
    sw := i32(f32(rect.w) * s.pixel_ratio)
    sh := i32(f32(rect.h) * s.pixel_ratio)
    gl.Scissor(sx, sy, sw, sh)
}


r_clear :: proc(clr: mu.Color) {
    flush()

    gl.Viewport(0, 0, i32(s.width * s.pixel_ratio), i32(s.height * s.pixel_ratio))
    gl.ClearColor(f32(clr.r) / 255, f32(clr.g) / 255, f32(clr.b) / 255, f32(clr.a) / 255)
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

r_present :: proc() {
    flush()
}