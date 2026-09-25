package rgfw_gl11_example

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

import rgfw "../../"

glBegin:        proc "c" (mode: gl.GL_Enum)
glEnd:          proc "c" ()
glColor3f:      proc "c" (r, g, b: f32)
glVertex2f:     proc "c" (x, y: f32)
glMatrixMode:   proc "c" (mode: gl.GL_Enum)
glLoadIdentity: proc "c" ()
glColor3ub:     proc "c" (r, g, b: u8)
glTexCoord2f:   proc "c" (x, y: f32)
glVertex3f:     proc "c" (x, y, z: f32)
glRotatef:      proc "c" (angle, x, y, z: f32)
glTranslatef:   proc "c" (x, y, z: f32)
glMultMatrixf:  proc "c" (m: [^]f32)

load_gl_1_1 :: proc() {
    gl.load_up_to(1, 1, rgfw.setProcAddress_OpenGL)
    rgfw.setProcAddress_OpenGL(&glBegin,        "glBegin")
    rgfw.setProcAddress_OpenGL(&glEnd,          "glEnd")
    rgfw.setProcAddress_OpenGL(&glColor3f,      "glColor3f")
    rgfw.setProcAddress_OpenGL(&glVertex2f,     "glVertex2f")
    rgfw.setProcAddress_OpenGL(&glMatrixMode,   "glMatrixMode")
    rgfw.setProcAddress_OpenGL(&glLoadIdentity, "glLoadIdentity")
    rgfw.setProcAddress_OpenGL(&glColor3ub,     "glColor3ub")
    rgfw.setProcAddress_OpenGL(&glTexCoord2f,   "glTexCoord2f")
    rgfw.setProcAddress_OpenGL(&glVertex3f,     "glVertex3f")
    rgfw.setProcAddress_OpenGL(&glRotatef,      "glRotatef")
    rgfw.setProcAddress_OpenGL(&glTranslatef,   "glTranslatef")
    rgfw.setProcAddress_OpenGL(&glMultMatrixf,  "glMultMatrixf")
}


DEG2RAD :: 3.14/180.0

pitch := f32(0.0)
yaw   := f32(0.0)
camX  := f32(0)
camZ  := f32(0)

main :: proc() {
    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

    win := rgfw.createWindow("First person camera", 0, 0, 800, 450, {.Center, .NoResize, .FocusOnShow, .OpenGL})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)
    load_gl_1_1()

    rgfw.window_swapInterval_OpenGL(win, 1) // Enable VSync

    gl.Enable(gl.DEPTH_TEST)
    gl.DepthFunc(gl.LEQUAL)

    gl.Enable(gl.TEXTURE_2D)
    texture: u32
    gl.GenTextures(1, &texture)

    texture_data := [?]u8{
        0,   0,   0,   255,   255, 255, 255, 255,
        255, 255, 255, 255,   0,   0,   0,   255
    }

    gl.BindTexture(gl.TEXTURE_2D,texture)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 2, 2, 0, gl.RGBA, gl.UNSIGNED_BYTE, &texture_data[0])

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)

    glMatrixMode(.PROJECTION)
    glLoadIdentity()
    glPerspective(60, 16.0 / 9.0, 1.0, 1000)
    glMatrixMode(.MODELVIEW)

    rgfw.window_captureRawMouse(win, true)

    event: rgfw.event
    for rgfw.window_shouldClose(win) == false {
        for rgfw.window_checkEvent(win, &event) {
            if event.type == .windowClose {
                break
            }

            #partial switch event.type {
            case .mouseRawMotion:
                dev_x := event.delta.x
                dev_y := event.delta.y

                /* apply the changes to pitch and yaw*/
                yaw += f32(dev_x) / 15.0
                pitch += f32(dev_y) / 15.0

            case .keyPressed:
                #partial switch (event.key.value) {
                case .Return:
                    rgfw.window_showMouse(win, false)
                    rgfw.window_captureRawMouse(win, true)

                case .BackSpace:
                    rgfw.window_showMouse(win, true)
                    rgfw.window_captureRawMouse(win, false)

                case .Left:  yaw -= 5
                case .Right: yaw += 5
                case .Up:    pitch -= 5
                case .Down:  pitch += 5
                }
            }
        }

        if event.type == .windowClose {
            break
        }

        if rgfw.isKeyDown(.W) {
            camX += math.cos((yaw + 90) * DEG2RAD)/5.0
            camZ -= math.sin((yaw + 90) * DEG2RAD)/5.0
        }
        if rgfw.isKeyDown(.S) {
            camX += math.cos((yaw + 270) * DEG2RAD)/5.0
            camZ -= math.sin((yaw + 270) * DEG2RAD)/5.0
        }

        if rgfw.isKeyDown(.A) {
            camX += math.cos(yaw * DEG2RAD)/5.0
            camZ -= math.sin(yaw * DEG2RAD)/5.0
        }

        if rgfw.isKeyDown(.D) {
            camX += math.cos((yaw + 180) * DEG2RAD)/5.0
            camZ -= math.sin((yaw + 180) * DEG2RAD)/5.0
        }

        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        glLoadIdentity()
        update_camera()

        w, h: i32
        rgfw.window_getSizeInPixels(win, &w, &h)
        gl.Viewport(0, 0, w, h)

        glBegin(.QUADS)

        glColor3ub(150, 0, 0);  glTexCoord2f(0.0,  0.0);   glVertex3f(-50.0, -5.0,  -50.0)
        glColor3ub(150, 0, 0);  glTexCoord2f(25.0, 0.0);   glVertex3f(50.0,  -5.0,  -50.0)
        glColor3ub(150, 0, 0);  glTexCoord2f(25.0, 25.0);  glVertex3f(50.0,  -5.0,  50.0)
        glColor3ub(150, 0, 0);  glTexCoord2f(0.0,  25.0);  glVertex3f(-50.0, -5.0,  50.0)

        glColor3ub(255, 192, 203);  glTexCoord2f(0.0,  0.0);   glVertex3f(-50.0, -5.0,  -50)
        glColor3ub(255, 192, 203);  glTexCoord2f(25.0, 0.0);   glVertex3f(50.0,  -5.0,  -50)
        glColor3ub(255, 192, 203);  glTexCoord2f(25.0, 25.0);  glVertex3f(50.0,  50.0,  1)
        glColor3ub(255, 192, 203);  glTexCoord2f(0.0,  25.0);  glVertex3f(-50.0, 50.0,  1)

        glColor3ub(0, 0, 203); glTexCoord2f(0.0,  0.0);   glVertex3f(-50.0, -5.0,  50)
        glColor3ub(0, 0, 203); glTexCoord2f(25.0, 0.0);   glVertex3f(50.0,  -5.0,  50)
        glColor3ub(0, 0, 203); glTexCoord2f(25.0, 25.0);  glVertex3f(50.0,  50.0,  -50)
        glColor3ub(0, 0, 203); glTexCoord2f(0.0,  25.0);  glVertex3f(-50.0, 50.0,  -50)

        glEnd()

        rgfw.window_swapBuffers_OpenGL(win)
    }

    gl.DeleteTextures(1, &texture)

    rgfw.window_close(win)
    return
}

update_camera :: proc() {
    if pitch >= 90 {
        pitch = 90
    } else if pitch <= -90 {
        pitch = -90
    }

    glRotatef(pitch, 1.0, 0.0, 0.0)
    glRotatef(yaw, 0.0, 1.0, 0.0)

    glTranslatef(camX, 0.0, -camZ)
}

glPerspective :: proc(fovY, aspect, zNear, zFar: f32) {
    fovY := (fovY * DEG2RAD) / 2.0
    f := (math.cos(fovY) / math.sin(fovY))

    projectionMatrix: [16]f32

    projectionMatrix[0] = f / aspect
    projectionMatrix[5] = f
    projectionMatrix[10] = (zFar + zNear) / (zNear - zFar)
    projectionMatrix[11] = -1.0
    projectionMatrix[14] = (2.0 * zFar * zNear) / (zNear - zFar)

    glMultMatrixf(&projectionMatrix[0])
}
