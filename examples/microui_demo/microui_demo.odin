package rgfw_mircoui_example

import "core:fmt"
import "core:log"
import "core:strings"
import "core:unicode/utf8"

import gl "vendor:OpenGL"
import mu "vendor:microui"

import rgfw "../../"


s := struct{
	mu_ctx: ^mu.Context,
	log_buf:         [1<<16]byte,
	log_buf_len:     int,
	log_buf_updated: bool,
	bg: mu.Color,

	width: f32,
	height: f32,

    pixel_ratio: f32,
}{
	width = 960,
	height = 540,
	bg = {90, 95, 100, 255},
}

main :: proc() {
	rgfw.init("RGFW Example", {.OpenGL})
    defer rgfw.deinit()

	hints := rgfw.getGlobalHints_OpenGL()
	hints.major = 2
	hints.minor = 1
	rgfw.setGlobalHints_OpenGL(hints)

    window := rgfw.createWindow(
        "MircoUI Example", 0, 0, 
        i32(s.width), i32(s.height), 
        {.Center, .OpenGL}
    )
    defer rgfw.window_close(window)
	rgfw.window_swapInterval_OpenGL(window, 1)

	w, h: i32
	rgfw.window_getSizeInPixels(window, &w, &h)

    mon := rgfw.window_getMonitor(window)
    s.width  = f32(w)
    s.height = f32(h)
    s.pixel_ratio = mon.pixelRatio

    load_gl()
    r_init()
    rgfw.window_setExitKey(window, .Escape)

    s.mu_ctx = new(mu.Context)
    mu.init(s.mu_ctx)
    s.mu_ctx.text_width = text_width
    s.mu_ctx.text_height = text_height

    update_viewport()

    for !rgfw.window_shouldClose(window) {
        event: rgfw.event
        loop: for rgfw.window_checkEvent(window, &event) {
            #partial switch event.type {
            case .windowClose: break loop
            case .mousePosChanged:
                mu.input_mouse_move(s.mu_ctx, event.mouse.x, event.mouse.y)
            
            case .mouseScroll:
                mu.input_scroll(s.mu_ctx, i32(event.delta.x), i32(event.delta.y))

            case .mouseButtonPressed:
                x, y: i32
                rgfw.window_getMouse(window, &x, &y)
                b := mouse_buttons_map[event.button.value]
                mu.input_mouse_down(s.mu_ctx, x, y, b)
            case .mouseButtonReleased:
				x, y: i32
                rgfw.window_getMouse(window, &x, &y)
                b := mouse_buttons_map[event.button.value]
                mu.input_mouse_up(s.mu_ctx, x, y, b)
				
			case .keyChar:
				b, n := utf8.encode_rune(rune(event.keyChar.value))
				mu.input_text(s.mu_ctx, string(b[:n]))

            case .keyPressed:
				if event.key.value != .Null {
					k := key_map[event.key.value]
					mu.input_key_down(s.mu_ctx, k)
				}
            case .keyReleased:
				if event.key.value != .Null {
					k := key_map[event.key.value]
					mu.input_key_up(s.mu_ctx, k)
				}

            case .windowResized:
				w, h: i32
                rgfw.window_getSizeInPixels(window, &w, &h)
				s.width = f32(w)
				s.height = f32(h)
				update_viewport()
            }
        }

		mu.begin(s.mu_ctx)
		all_windows(s.mu_ctx)
		mu.end(s.mu_ctx)

		r_clear({0, 1, 2, 255})
		cmd: ^mu.Command
		for mu.next_command(s.mu_ctx, &cmd) {
			switch v in cmd.variant {
			case ^mu.Command_Text: r_draw_text(v.str, v.pos, v.color)
			case ^mu.Command_Rect: r_draw_rect(v.rect, v.color)
			case ^mu.Command_Icon: r_draw_icon(v.id, v.rect, v.color)
			case ^mu.Command_Clip: r_set_clip_rect(v.rect)
			case ^mu.Command_Jump:
			}
		}

		r_present()
		rgfw.window_swapBuffers_OpenGL(window)
    }
}



text_width :: proc(font: mu.Font, text: string) -> i32 {
    return r_get_text_width(text)
}

text_height :: proc(mu.Font) -> i32 {
	return r_get_text_height()
}

update_viewport :: proc() {
    vw := i32(s.width * s.pixel_ratio)
    vh := i32(s.height * s.pixel_ratio)
    gl.Viewport(0, 0, vw, vh)
    gl.Scissor(0, 0, vw, vh)
}



u8_slider :: proc(ctx: ^mu.Context, val: ^u8, lo, hi: u8) -> (res: mu.Result_Set) {
	mu.push_id(ctx, uintptr(val))

	@static tmp: mu.Real
	tmp = mu.Real(val^)
	res = mu.slider(ctx, &tmp, mu.Real(lo), mu.Real(hi), 0, "%.0f", {.ALIGN_CENTER})
	val^ = u8(tmp)
	mu.pop_id(ctx)
	return
}

write_log :: proc(str: string) {
	s.log_buf_len += copy(s.log_buf[s.log_buf_len:], str)
	s.log_buf_len += copy(s.log_buf[s.log_buf_len:], "\n")
	s.log_buf_updated = true
}

read_log :: proc() -> string {
	return string(s.log_buf[:s.log_buf_len])
}
reset_log :: proc() {
	s.log_buf_updated = true
	s.log_buf_len = 0
}

all_windows :: proc(ctx: ^mu.Context) {
	@static opts := mu.Options{.NO_CLOSE}

	if mu.window(ctx, "Demo Window", {40, 40, 300, 450}, opts) {
		if .ACTIVE in mu.header(ctx, "Window Info") {
			win := mu.get_current_container(ctx)
			mu.layout_row(ctx, {54, -1}, 0)
			mu.label(ctx, "Position:")
			mu.label(ctx, fmt.tprintf("%d, %d", win.rect.x, win.rect.y))
			mu.label(ctx, "Size:")
			mu.label(ctx, fmt.tprintf("%d, %d", win.rect.w, win.rect.h))
		}

		if .ACTIVE in mu.header(ctx, "Window Options") {
			mu.layout_row(ctx, {120, 120, 120}, 0)
			for opt in mu.Opt {
				state := opt in opts
				if .CHANGE in mu.checkbox(ctx, fmt.tprintf("%v", opt), &state)  {
					if state {
						opts += {opt}
					} else {
						opts -= {opt}
					}
				}
			}
		}

		if .ACTIVE in mu.header(ctx, "Test Buttons", {.EXPANDED}) {
			mu.layout_row(ctx, {86, -110, -1})
			mu.label(ctx, "Test buttons 1:")
			if .SUBMIT in mu.button(ctx, "Button 1") { write_log("Pressed button 1") }
			if .SUBMIT in mu.button(ctx, "Button 2") { write_log("Pressed button 2") }
			mu.label(ctx, "Test buttons 2:")
			if .SUBMIT in mu.button(ctx, "Button 3") { write_log("Pressed button 3") }
			if .SUBMIT in mu.button(ctx, "Button 4") { write_log("Pressed button 4") }
		}

		if .ACTIVE in mu.header(ctx, "Tree and Text", {.EXPANDED}) {
			mu.layout_row(ctx, {140, -1})
			mu.layout_begin_column(ctx)
			if .ACTIVE in mu.treenode(ctx, "Test 1") {
				if .ACTIVE in mu.treenode(ctx, "Test 1a") {
					mu.label(ctx, "Hello")
					mu.label(ctx, "world")
				}
				if .ACTIVE in mu.treenode(ctx, "Test 1b") {
					if .SUBMIT in mu.button(ctx, "Button 1") { write_log("Pressed button 1") }
					if .SUBMIT in mu.button(ctx, "Button 2") { write_log("Pressed button 2") }
				}
			}
			if .ACTIVE in mu.treenode(ctx, "Test 2") {
				mu.layout_row(ctx, {53, 53})
				if .SUBMIT in mu.button(ctx, "Button 3") { write_log("Pressed button 3") }
				if .SUBMIT in mu.button(ctx, "Button 4") { write_log("Pressed button 4") }
				if .SUBMIT in mu.button(ctx, "Button 5") { write_log("Pressed button 5") }
				if .SUBMIT in mu.button(ctx, "Button 6") { write_log("Pressed button 6") }
			}
			if .ACTIVE in mu.treenode(ctx, "Test 3") {
				@static checks := [3]bool{true, false, true}
				mu.checkbox(ctx, "Checkbox 1", &checks[0])
				mu.checkbox(ctx, "Checkbox 2", &checks[1])
				mu.checkbox(ctx, "Checkbox 3", &checks[2])

			}
			mu.layout_end_column(ctx)

			mu.layout_begin_column(ctx)
			mu.layout_row(ctx, {-1})
			mu.text(ctx,
				"Lorem ipsum dolor sit amet, consectetur adipiscing "+
				"elit. Maecenas lacinia, sem eu lacinia molestie, mi risus faucibus "+
				"ipsum, eu varius magna felis a nulla.",
			)
			mu.layout_end_column(ctx)
		}

		if .ACTIVE in mu.header(ctx, "Background Colour", {.EXPANDED}) {
			mu.layout_row(ctx, {-78, -1}, 68)
			mu.layout_begin_column(ctx)
			{
				mu.layout_row(ctx, {46, -1}, 0)
				mu.label(ctx, "Red:");   u8_slider(ctx, &s.bg.r, 0, 255)
				mu.label(ctx, "Green:"); u8_slider(ctx, &s.bg.g, 0, 255)
				mu.label(ctx, "Blue:");  u8_slider(ctx, &s.bg.b, 0, 255)
			}
			mu.layout_end_column(ctx)

			r := mu.layout_next(ctx)
			mu.draw_rect(ctx, r, s.bg)
			mu.draw_box(ctx, mu.expand_rect(r, 1), ctx.style.colors[.BORDER])
			mu.draw_control_text(ctx, fmt.tprintf("#%02x%02x%02x", s.bg.r, s.bg.g, s.bg.b), r, .TEXT, {.ALIGN_CENTER})
		}
	}



	if mu.window(ctx, "Log Window", {350, 40, 300, 200}, opts) {
		mu.layout_row(ctx, {-1}, -28)
		mu.begin_panel(ctx, "Log")
		mu.layout_row(ctx, {-1}, -1)
		mu.text(ctx, read_log())
		if s.log_buf_updated {
			panel := mu.get_current_container(ctx)
			panel.scroll.y = panel.content_size.y
			s.log_buf_updated = false
		}
		mu.end_panel(ctx)

		@static buf: [128]byte
		@static buf_len: int
		submitted := false
		mu.layout_row(ctx, {-70, -1})
		if .SUBMIT in mu.textbox(ctx, buf[:], &buf_len) {
			mu.set_focus(ctx, ctx.last_id)
			submitted = true
		}
		if .SUBMIT in mu.button(ctx, "Submit") {
			submitted = true
		}
		if submitted {
			write_log(string(buf[:buf_len]))
			buf_len = 0
		}
	}

	if mu.window(ctx, "Style Window", {350, 250, 300, 240}) {
		@static colors := [mu.Color_Type]string{
			.TEXT         = "text",
			.BORDER       = "border",
			.WINDOW_BG    = "window bg",
			.TITLE_BG     = "title bg",
			.TITLE_TEXT   = "title text",
			.PANEL_BG     = "panel bg",
			.BUTTON       = "button",
			.BUTTON_HOVER = "button hover",
			.BUTTON_FOCUS = "button focus",
			.BASE         = "base",
			.BASE_HOVER   = "base hover",
			.BASE_FOCUS   = "base focus",
			.SCROLL_BASE  = "scroll base",
			.SCROLL_THUMB = "scroll thumb",
			.SELECTION_BG = "selection bg",
		}

		sw := i32(f32(mu.get_current_container(ctx).body.w) * 0.14)
		mu.layout_row(ctx, {80, sw, sw, sw, sw, -1})
		for label, col in colors {
			mu.label(ctx, label)
			u8_slider(ctx, &ctx.style.colors[col].r, 0, 255)
			u8_slider(ctx, &ctx.style.colors[col].g, 0, 255)
			u8_slider(ctx, &ctx.style.colors[col].b, 0, 255)
			u8_slider(ctx, &ctx.style.colors[col].a, 0, 255)
			mu.draw_rect(ctx, mu.layout_next(ctx), ctx.style.colors[col])
		}
	}
}

mouse_buttons_map := #partial [rgfw.mouseButton]mu.Mouse {
	.Left   = .LEFT,
	.Right  = .RIGHT,
	.Middle = .MIDDLE,
}

key_map := #partial #sparse [rgfw.key]mu.Key {
	.ShiftL    = .SHIFT,       .ShiftR = .SHIFT,
	.ControlL  = .CTRL,      .ControlR = .CTRL,
	.AltL      = .ALT,           .AltR = .ALT,
    .Enter     = .RETURN,   .PadReturn = .RETURN,
	.BackSpace = .BACKSPACE,
	.Delete    = .DELETE,
	.Left      = .LEFT,
	.Right     = .RIGHT,
	.Home      = .HOME,
	.End       = .END,
	.A         = .A,
	.X         = .X,
	.C         = .C,
	.V         = .V,
}
