package rgfw_gears_example

import "core:os"
import "core:fmt"
import "core:math"
import "core:time"
import "core:strconv"
import gl "vendor:OpenGL"

import rgfw "../../"


glEnableClientState: proc "c" ( gl.GL_Enum )
glMatrixMode:        proc "c" ( gl.GL_Enum )
glPushMatrix:        proc "c" ( )
glPopMatrix:         proc "c" ( )
glLoadIdentity:      proc "c" ( )
glOrtho:             proc "c" ( f64, f64, f64, f64, f64, f64 )
glTexCoordPointer:   proc "c" ( i32, gl.GL_Enum, i32, rawptr )
glVertexPointer:     proc "c" ( i32, gl.GL_Enum, i32, rawptr )
glColorPointer:      proc "c" ( i32, gl.GL_Enum, i32, rawptr )
glBegin:             proc "c" ( gl.GL_Enum )
glEnd:               proc "c" ()
glColor3f:           proc "c" ( f32, f32, f32 )
glVertex2f:          proc "c" ( f32, f32 )
glVertex3f:          proc "c" ( f32, f32, f32 )
glShadeModel:        proc "c" ( u32 )
glNormal3f:          proc "c" ( f32, f32, f32 )
glRotatef:           proc "c" ( f32, f32, f32, f32 )
glTranslatef:        proc "c" ( f32, f32, f32 )
glTranslated:        proc "c" ( f64, f64, f64 )
glCallList:          proc "c" ( u32 )
glFrustum:           proc "c" ( f64, f64, f64, f64, f64, f64 )
glLightfv:           proc "c" ( gl.GL_Enum, gl.GL_Enum, [^]f32 )
glNewList:           proc "c" ( u32, gl.GL_Enum )
glEndList:           proc "c" ( )
glMaterialfv:        proc "c" ( gl.GL_Enum, gl.GL_Enum, [^]f32 )
glGenLists:          proc "c" ( i32 ) -> u32
glDeleteLists:       proc "c" ( u32, i32 )

load_gl :: proc() {
    gl.load_up_to(1, 1, rgfw.setProcAddress_OpenGL)
    rgfw.setProcAddress_OpenGL(&glEnableClientState, "glEnableClientState")
    rgfw.setProcAddress_OpenGL(&glMatrixMode,        "glMatrixMode")
    rgfw.setProcAddress_OpenGL(&glPushMatrix,        "glPushMatrix")
    rgfw.setProcAddress_OpenGL(&glLoadIdentity,      "glLoadIdentity")
    rgfw.setProcAddress_OpenGL(&glOrtho,             "glOrtho")
    rgfw.setProcAddress_OpenGL(&glTexCoordPointer,   "glTexCoordPointer")
    rgfw.setProcAddress_OpenGL(&glVertexPointer,     "glVertexPointer")
    rgfw.setProcAddress_OpenGL(&glColorPointer,      "glColorPointer")
    rgfw.setProcAddress_OpenGL(&glPopMatrix,         "glPopMatrix")
    rgfw.setProcAddress_OpenGL(&glBegin,             "glBegin")
    rgfw.setProcAddress_OpenGL(&glEnd,               "glEnd")
    rgfw.setProcAddress_OpenGL(&glColor3f,           "glColor3f")
    rgfw.setProcAddress_OpenGL(&glVertex2f,          "glVertex2f")
    rgfw.setProcAddress_OpenGL(&glVertex3f,          "glVertex3f")
    rgfw.setProcAddress_OpenGL(&glShadeModel,        "glShadeModel")
    rgfw.setProcAddress_OpenGL(&glNormal3f,          "glNormal3f")
    rgfw.setProcAddress_OpenGL(&glRotatef,           "glRotatef")
    rgfw.setProcAddress_OpenGL(&glTranslatef,        "glTranslatef")
    rgfw.setProcAddress_OpenGL(&glTranslated,        "glTranslated")
    rgfw.setProcAddress_OpenGL(&glCallList,          "glCallList")
    rgfw.setProcAddress_OpenGL(&glFrustum,           "glFrustum")
    rgfw.setProcAddress_OpenGL(&glLightfv,           "glLightfv")
    rgfw.setProcAddress_OpenGL(&glNewList,           "glNewList")
    rgfw.setProcAddress_OpenGL(&glEndList,           "glEndList")
    rgfw.setProcAddress_OpenGL(&glMaterialfv,        "glMaterialfv")
    rgfw.setProcAddress_OpenGL(&glGenLists,          "glGenLists")
    rgfw.setProcAddress_OpenGL(&glDeleteLists,       "glDeleteLists")
}

State :: struct {
    win: ^rgfw.window,

    view_rot: [3]f32,
    gear1, gear2, gear3: u32,
    gangle: f32,

    stereo:     bool, /* Enable stereo  */
    samples:    i32,  /* Choose visual with at least N samples */
    animate:    bool, /* Animation */
    eyesep:     f64,  /* Eye separation */
    fix_point:  f64,  /* Fixation point distance */
    left, right, asp: f64 /* Stereo frustum params */
} 


/*
 *
 *  Draw a gear wheel.  You'll probably want to call this function when
 *  building a display list since we do a lot of trig here.
 *
 *  Input:  inner_radius - radius of hole at center
 *          outer_radius - radius at center of teeth
 *          width - width of gear
 *          teeth - number of teeth
 *          tooth_depth - depth of tooth
 */
gear :: proc(inner_radius: f32, outer_radius: f32, width: f32, teeth: i32, tooth_depth: f32) {
    u, v, len: f32

    r0 := inner_radius
    r1 := outer_radius - tooth_depth / 2.0
    r2 := outer_radius + tooth_depth / 2.0

    da := 2.0 * math.PI / f64(teeth) / 4.0

    glShadeModel(gl.FLAT)

    glNormal3f(0.0, 0.0, 1.0)

    /* draw front face */
    glBegin(.QUAD_STRIP)
    for i in 0..=teeth {
        angle := f64(i) * 2.0 * math.PI / f64(teeth)
        angle_cos := f32(math.cos(angle))
        angle_sin := f32(math.sin(angle))

        glVertex3f(r0 * angle_cos, r0 * angle_sin, width * 0.5)
        glVertex3f(r1 * angle_cos, r1 * angle_sin, width * 0.5)
        if i < teeth {
            glVertex3f(r0 * angle_cos, r0 * angle_sin, width * 0.5)
            glVertex3f(r1 * f32(math.cos(angle + 3 * da)), r1 * f32(math.sin(angle + 3 * da)),
            width * 0.5)
        }
    }
    glEnd()

    /* draw front sides of teeth */
    glBegin(.QUADS)
    for i in 0..<teeth {
        angle := f64(i) * 2.0 * math.PI / f64(teeth)

        glVertex3f(r1 * f32(math.cos(angle)), r1 * f32(math.sin(angle)), width * 0.5)
        glVertex3f(r2 * f32(math.cos(angle + da)), r2 * f32(math.sin(angle + da)), width * 0.5)
        glVertex3f(r2 * f32(math.cos(angle + 2 * da)), r2 * f32(math.sin(angle + 2 * da)),
            width * 0.5)
        glVertex3f(r1 * f32(math.cos(angle + 3 * da)), r1 * f32(math.sin(angle + 3 * da)),
            width * 0.5)
    }
    glEnd()

    glNormal3f(0.0, 0.0, -1.0)

    /* draw back face */
    glBegin(.QUAD_STRIP)
    for i in 0..=teeth {
        angle := f64(i) * 2.0 * math.PI / f64(teeth)
        glVertex3f(r1 * f32(math.cos(angle)), r1 * f32(math.sin(angle)), -width * 0.5)
        glVertex3f(r0 * f32(math.cos(angle)), r0 * f32(math.sin(angle)), -width * 0.5)
        if (i < teeth) {
            glVertex3f(r1 * f32(math.cos(angle + 3 * da)), r1 * f32(math.sin(angle + 3 * da)),
                -width * 0.5)
            glVertex3f(r0 * f32(math.cos(angle)), r0 * f32(math.sin(angle)), -width * 0.5)
        }
    }
    glEnd()

    /* draw back sides of teeth */
    glBegin(.QUADS)
    for i in 0..<teeth{
        angle := f64(i) * 2.0 * math.PI / f64(teeth)

        glVertex3f(r1 * f32(math.cos(angle + 3 * da)), r1 * f32(math.sin(angle + 3 * da)),
            -width * 0.5)
        glVertex3f(r2 * f32(math.cos(angle + 2 * da)), r2 * f32(math.sin(angle + 2 * da)),
            -width * 0.5)
        glVertex3f(r2 * f32(math.cos(angle + da)), r2 * f32(math.sin(angle + da)), -width * 0.5)
        glVertex3f(r1 * f32(math.cos(angle)), r1 * f32(math.sin(angle)), -width * 0.5)
    }
    glEnd()

    /* draw outward faces of teeth */
    glBegin(.QUAD_STRIP)
    for i in 0..<teeth {
        angle := f64(i) * 2.0 * math.PI / f64(teeth)

        glVertex3f(r1 * f32(math.cos(angle)), r1 * f32(math.sin(angle)), width * 0.5)
        glVertex3f(r1 * f32(math.cos(angle)), r1 * f32(math.sin(angle)), -width * 0.5)
        u = r2 * f32(math.cos(angle + da)) - r1 * f32(math.cos(angle))
        v = r2 * f32(math.sin(angle + da)) - r1 * f32(math.sin(angle))
        len = math.sqrt(u * u + v * v)
        u /= len
        v /= len
        glNormal3f(v, -u, 0.0)
        glVertex3f(r2 * f32(math.cos(angle + da)), r2 * f32(math.sin(angle + da)), width * 0.5)
        glVertex3f(r2 * f32(math.cos(angle + da)), r2 * f32(math.sin(angle + da)), -width * 0.5)
        glNormal3f(f32(math.cos(angle)), f32(math.sin(angle)), 0.0)
        glVertex3f(r2 * f32(math.cos(angle + 2 * da)), r2 * f32(math.sin(angle + 2 * da)),
            width * 0.5)
        glVertex3f(r2 * f32(math.cos(angle + 2 * da)), r2 * f32(math.sin(angle + 2 * da)),
            -width * 0.5)
        u = r1 * f32(math.cos(angle + 3 * da)) - r2 * f32(math.cos(angle + 2 * da))
        v = r1 * f32(math.sin(angle + 3 * da)) - r2 * f32(math.sin(angle + 2 * da))
        glNormal3f(v, -u, 0.0)
        glVertex3f(r1 * f32(math.cos(angle + 3 * da)), r1 * f32(math.sin(angle + 3 * da)),
            width * 0.5)
        glVertex3f(r1 * f32(math.cos(angle + 3 * da)), r1 * f32(math.sin(angle + 3 * da)),
            -width * 0.5)
        glNormal3f(f32(math.cos(angle)), f32(math.sin(angle)), 0.0)
    }

    glVertex3f(r1 * math.cos_f32(0), r1 * math.sin_f32(0), width * 0.5)
    glVertex3f(r1 * math.cos_f32(0), r1 * math.sin_f32(0), -width * 0.5)

    glEnd()

    glShadeModel(gl.SMOOTH)

    /* draw inside radius cylinder */
    glBegin(.QUAD_STRIP)
    for i in 0..=teeth {
        angle := f64(i) * 2.0 * math.PI / f64(teeth)
        glNormal3f(-f32(math.cos(angle)), -f32(math.sin(angle)), 0.0)
        glVertex3f(r0 * f32(math.cos(angle)), r0 * f32(math.sin(angle)), -width * 0.5)
        glVertex3f(r0 * f32(math.cos(angle)), r0 * f32(math.sin(angle)), width * 0.5)
    }
    glEnd()
}


draw :: proc() {
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

    glPushMatrix()
    glRotatef(s.view_rot.x, 1.0, 0.0, 0.0)
    glRotatef(s.view_rot.y, 0.0, 1.0, 0.0)
    glRotatef(s.view_rot.z, 0.0, 0.0, 1.0)

    glPushMatrix()
    glTranslatef(-3.0, -2.0, 0.0)
    glRotatef(s.gangle, 0.0, 0.0, 1.0)
    glCallList(s.gear1)
    glPopMatrix()

    glPushMatrix()
    glTranslatef(3.1, -2.0, 0.0)
    glRotatef(-2.0 * s.gangle - 9.0, 0.0, 0.0, 1.0)
    glCallList(s.gear2)
    glPopMatrix()

    glPushMatrix()
    glTranslatef(-3.1, 4.2, 0.0)
    glRotatef(-2.0 * s.gangle - 25.0, 0.0, 0.0, 1.0)
    glCallList(s.gear3)
    glPopMatrix()

    glPopMatrix()
}


draw_gears :: proc() {
    if s.stereo {
        /* First left eye.  */
        gl.DrawBuffer(gl.BACK_LEFT)

        glMatrixMode(.PROJECTION)
        glLoadIdentity()
        glFrustum(s.left, s.right, -s.asp, s.asp, 5.0, 60.0)

        glMatrixMode(.MODELVIEW)

        glPushMatrix()
        glTranslated(+0.5 * s.eyesep, 0.0, 0.0)
        draw()
        glPopMatrix()

        /* Then right eye.  */
        gl.DrawBuffer(gl.BACK_RIGHT)

        glMatrixMode(.PROJECTION)
        glLoadIdentity()
        glFrustum(-s.right, -s.left, -s.asp, s.asp, 5.0, 60.0)

        glMatrixMode(.MODELVIEW)

        glPushMatrix()
        glTranslated(-0.5 * s.eyesep, 0.0, 0.0)
        draw()
        glPopMatrix()
    }
     else {
        draw()
    }
}


/** Draw single frame, do SwapBuffers, compute FPS */
draw_frame :: proc() {
    @static frames: i32
    @static tRot0 := time.Tick{-1}
    @static tRate0 := time.Tick{-1}
    t := time.tick_now()

    if tRot0._nsec  < 0 { tRot0  = t }
    if tRate0._nsec < 0 { tRate0 = t }

    if s.animate {
        dt := time.duration_seconds(time.tick_diff(tRot0, t))
        tRot0 = t
        /* advance rotation for next frame */
        s.gangle += f32(70.0 * dt)  /* 70 degrees per second */
        if (s.gangle > 3600.0) {
            s.gangle -= 3600.0
        }
    }

    draw_gears()
    rgfw.window_swapBuffers_OpenGL(s.win)

    frames += 1
    if time.tick_diff(tRate0, t) >= time.Second {
        seconds := time.tick_diff(tRate0, t)
        fps := f64(frames) / time.duration_seconds(seconds)
        fmt.printf("%d frames in %3.1f = %6.3f FPS\n", frames, seconds, fps)
        os.flush(os.stdout)
        tRate0 = t
        frames = 0
    }
}


/* new window size or exposure */
reshape :: proc(width: i32, height: i32) {
    gl.Viewport(0, 0, width, height)

    if s.stereo {
        s.asp = f64(height) / f64(width)
        w := s.fix_point * (1.0 / 5.0)

        s.left = -5.0 * ((w - 0.5 * s.eyesep) / s.fix_point)
        s.right = 5.0 * ((w + 0.5 * s.eyesep) / s.fix_point)
    }
    else {
        h := f64(height) / f64(width)

        glMatrixMode(.PROJECTION)
        glLoadIdentity()
        glFrustum(-1.0, 1.0, -h, h, 5.0, 60.0)
    }

    glMatrixMode(.MODELVIEW)
    glLoadIdentity()
    glTranslatef(0.0, 0.0, -40.0)
}


init :: proc() {
    @static pos   := [4]f32{ 5.0, 5.0, 10.0, 0.0 }
    @static red   := [4]f32{ 0.8, 0.1,  0.0, 1.0 }
    @static green := [4]f32{ 0.0, 0.8,  0.2, 1.0 }
    @static blue  := [4]f32{ 0.2, 0.2,  1.0, 1.0 }

    glLightfv(.LIGHT0, .POSITION, raw_data(&pos))
    gl.Enable(gl.CULL_FACE)
    gl.Enable(gl.LIGHTING)
    gl.Enable(gl.LIGHT0)
    gl.Enable(gl.DEPTH_TEST)

    /* make the gears */
    s.gear1 = glGenLists(1)
    glNewList(s.gear1, .COMPILE)
    glMaterialfv(.FRONT, .AMBIENT_AND_DIFFUSE, raw_data(&red))
    gear(1.0, 4.0, 1.0, 20, 0.7)
    glEndList()

    s.gear2 = glGenLists(1)
    glNewList(s.gear2, .COMPILE)
    glMaterialfv(.FRONT, .AMBIENT_AND_DIFFUSE,  raw_data(&green))
    gear(0.5, 2.0, 2.0, 10, 0.7)
    glEndList()

    s.gear3 = glGenLists(1)
    glNewList(s.gear3, .COMPILE)
    glMaterialfv(.FRONT, .AMBIENT_AND_DIFFUSE,  raw_data(&blue))
    gear(1.3, 2.0, 0.5, 10, 0.7)
    glEndList()

    gl.Enable(gl.NORMALIZE)
}


usage :: proc() {
    fmt.println(`Usage:
  -stereo                 run in stereo mode
  -samples N              run in multisample mode with at least N samples
  -fullscreen             run in fullscreen mode
  -info                   display OpenGL renderer info`)
}


s := State {
    view_rot = { 20, 30, 0 },
    eyesep = 5,
    fix_point = 40,
    animate = true,
}

main :: proc() {
    win_width  := i32(300)
    win_height := i32(300)
    x, y: i32
    print_info: bool
    flag: rgfw.windowFlag

    for i := 1; i < len(os.args)-1; i += 1 {
        switch os.args[i] {
        case "-info":       print_info = true
        case "-stereo":     s.stereo = true
        case "-fullscreen": flag = .Fullscreen
        case "-samples":
            samples, ok := strconv.parse_int(os.args[i+1], 10)
            if ok {
                s.samples = i32(samples)
                i += 1
                break
            }
            fallthrough
        case:
            usage()
            return
        }
    }

    if print_info {
        fmt.println("GL_RENDERER   = ", gl.GetString(gl.RENDERER))
        fmt.println("GL_VERSION    = ", gl.GetString(gl.VERSION))
        fmt.println("GL_VENDOR     = ", gl.GetString(gl.VENDOR))
        fmt.println("GL_EXTENSIONS = ", gl.GetString(gl.EXTENSIONS))
    }

    rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()
    
    s.win = rgfw.createWindow("gears", x, y, win_width, win_height, {.Center, .OpenGL, flag})
    defer rgfw.window_close(s.win)
    rgfw.window_setExitKey(s.win, .Escape)
    rgfw.window_makeCurrentContext_OpenGL(s.win)
    
    load_gl()
    init()
    defer {
        glDeleteLists(s.gear1, 1)
        glDeleteLists(s.gear2, 1)
        glDeleteLists(s.gear3, 1)
    }

    /* Set initial projection/viewing transformation.
    * We can't be sure we'll get a ConfigureNotify event when the window
    * first appears.
    */
    w, h: i32
    rgfw.window_getSizeInPixels(s.win, &w, &h)
    reshape(w, h)

    for !rgfw.window_shouldClose(s.win) {
        event: rgfw.event
        for rgfw.window_checkEvent(s.win, &event) {

            #partial switch event.type {
            case .windowResized:
                rgfw.window_getSizeInPixels(s.win, &w, &h)
                reshape(w, h)
            case .keyPressed:
                #partial switch event.key.value {
                case .Left:  s.view_rot.y += 5.0
                case .Right: s.view_rot.y -= 5.0
                case .Up:    s.view_rot.x += 5.0
                case .Down:  s.view_rot.x -= 5.0
                }
            }
        }
        draw_frame()
    }
}
