package RGFW

import "core:c"

import "vendor:vulkan"

when ODIN_OS == .Windows {
    @(extra_linker_flags="/NODEFAULTLIB:msvcrt")
		foreign import native {
			"lib/RGFW_msvc.lib",
			"system:user32.lib",
			"system:gdi32.lib",
			"system:shell32.lib",
            "system:winmm.lib",
		}
} else when ODIN_OS == .Darwin {
    foreign import native {
        "RGFW.a",
        "system:Cocoa.framework",
        "system:IOKit.framework",
    }
} else when (ODIN_OS == .Linux || ODIN_OS == .FreeBSD || ODIN_OS == .OpenBSD) {
    foreign import native {
        "RGFW.a",
    }
}

initFlags :: enum(u8) {
	initOpenGL = (1 << 0), /*!< Load Native OpenGL */
	initEGL = (1 << 1), /*!< Load EGL */
	initVulkan = (1 << 2), /*!< Load Vulkan */
	initX11 = (1 << 3), /*!< Force X11 (over Wayland) */
};

info :: struct {};

/*! @brief The window stucture for interfacing with the window */
window :: struct {};

/*! @brief The source window stucture for interfacing with the underlying windowing API (e.g. winapi, wayland, cocoa, etc) */
window_src :: struct {};

/*! @brief The color format for pixel data */
format :: enum(u8) {
	formatRGB8 = 0,    /*!< 8-bit RGB (3 channels) */
	formatBGR8,    /*!< 8-bit BGR (3 channels) */
	formatRGBA8,   /*!< 8-bit RGBA (4 channels) */
	formatARGB8,   /*!< 8-bit RGBA (4 channels) */
	formatBGRA8,   /*!< 8-bit BGRA (4 channels) */
	formatABGR8,   /*!< 8-bit BGRA (4 channels) */
	formatCount
};

/*! @brief layout struct for mapping out format types */
colorLayout :: struct {  r : i32, g : i32, b : i32, a : i32, channels : u32  };

/*! @brief function type converting raw image data between formats */
convertImageDataFunc :: proc(dest_data : ^u8 , src_data : ^u8, srcLayout : ^colorLayout , destLayout : ^colorLayout , count : c.size_t);

/*! @brief a stucture for interfacing with the underlying native image (e.g. XImage, HBITMAP, etc) */
nativeImage :: struct {};

/*! @brief a stucture for interfacing with pixel data as a renderable surface */
surface :: struct {};

/*! @brief gamma struct for monitors */
gammaRamp :: struct {
	red : ^u16, /*!< array for the red channel */
	green : ^u16, /*!< array for the green channel */
	blue : ^u16, /*!< array for the blue channel */
	count : c.size_t /*! count of elements in each channel */
};

/*! @brief monitor mode data | can be changed by the user (with functions)*/
monitorMode :: struct {
	w : i32, h : i32, /*!< monitor workarea size */
	refreshRate : c.float,/*!< monitor refresh rate */
	red : u8, blue : u8, green : u8, /*!< sizeof rgb values */
	src : rawptr /*!< source API mode */
};

/*! @brief structure for monitor node and source monitor data */
monitorNode :: struct {};

/*! @brief structure for monitor data */
monitor :: struct {
	x : i32, y : i32, /*!< x - y of the monitor workarea */
	name : [128]u8, /*!< monitor name */
	scaleX : c.float, scaleY : c.float, /*!< monitor content scale */
	pixelRatio : c.float, /*!< pixel ratio for monitor (1.0 for regular, 2.0 for hiDPI)  */
	physW : c.float, physH : c.float, /*!< monitor physical size in inches */
	mode : monitorMode,  /*!< current mode of the monitor */
	userPtr : rawptr, /*!< pointer for user data */
	node : ^monitorNode /*!< source node data of the monitor */
};

/*! @brief what type of request you are making for the monitor */
modeRequest ::enum(u8) {
	monitorScale = 1 << (0), /*!< scale the monitor size */
	monitorRefresh = 1 << (1), /*!< change the refresh rate */
	monitorRGB = 1 << (2), /*!< change the monitor RGB bits size */
	monitorAll = monitorScale | monitorRefresh | monitorRGB
};

/*! @brief RGFW's abstract keycodes */
key ::enum(u8) {
	keyNULL = 0,
	keyEscape = '\033',
	keyBacktick = '`',
	key0 = '0',
	key1 = '1',
	key2 = '2',
	key3 = '3',
	key4 = '4',
	key5 = '5',
	key6 = '6',
	key7 = '7',
	key8 = '8',
	key9 = '9',
	keyMinus = '-',
	keyEqual = '=',
	keyEquals = keyEqual,
	keyBackSpace = '\b',
	keyTab = '\t',
	keySpace = ' ',
	keyA = 'a',
	keyB = 'b',
	keyC = 'c',
	keyD = 'd',
	keyE = 'e',
	keyF = 'f',
	keyG = 'g',
	keyH = 'h',
	keyI = 'i',
	keyJ = 'j',
	keyK = 'k',
	keyL = 'l',
	keyM = 'm',
	keyN = 'n',
	keyO = 'o',
	keyP = 'p',
	keyQ = 'q',
	keyR = 'r',
	keyS = 's',
	keyT = 't',
	keyU = 'u',
	keyV = 'v',
	keyW = 'w',
	keyX = 'x',
	keyY = 'y',
	keyZ = 'z',
	keyPeriod = '.',
	keyComma = ',',
	keySlash = '/',
	keyBracket = '[',
    keyCloseBracket = ']',
    keySemicolon = ';',
	keyApostrophe = '\'',
	keyBackSlash = '\\',
	keyReturn = '\n',
	keyEnter = keyReturn,
	keyDelete = '\177', /* 127 */
	keyF1,
	keyF2,
	keyF3,
	keyF4,
	keyF5,
	keyF6,
	keyF7,
	keyF8,
	keyF9,
	keyF10,
	keyF11,
	keyF12,
    keyF13,
    keyF14,
    keyF15,
    keyF16,
    keyF17,
    keyF18,
    keyF19,
    keyF20,
    keyF21,
    keyF22,
    keyF23,
    keyF24,
    keyF25,
	keyCapsLock,
	keyShiftL,
	keyControlL,
	keyAltL,
	keySuperL,
	keyShiftR,
	keyControlR,
	keyAltR,
	keySuperR,
	keyUp,
	keyDown,
	keyLeft,
	keyRight,
	keyInsert,
	keyMenu,
	keyEnd,
	keyHome,
	keyPageUp,
	keyPageDown,
	keyNumLock,
	keyPadSlash,
	keyPadMultiply,
	keyPadPlus,
	keyPadMinus,
	keyPadEqual,
	keyPadEquals = keyPadEqual,
	keyPad1,
	keyPad2,
	keyPad3,
	keyPad4,
	keyPad5,
	keyPad6,
	keyPad7,
	keyPad8,
	keyPad9,
	keyPad0,
	keyPadPeriod,
	keyPadReturn,
	keyScrollLock,
    keyPrintScreen,
    keyPause,
	keyWorld1,
    keyWorld2,
};

/*! @brief abstract mouse button codes */
mouseButton :: enum(u8) {
	mouseLeft = 0, /*!< left mouse button */
	mouseMiddle, /*!< mouse-wheel-button */
	mouseRight, /*!< right mouse button */
	mouseMisc1, mouseMisc2, mouseMisc3, mouseMisc4, mouseMisc5,
	mouseFinal
};

/*! abstract key modifier codes */
keymod :: enum(u8) {
	modCapsLock = 1 << (0),
	modNumLock  = 1 << (1),
	modControl  = 1 << (2),
	modAlt = 1 << (3),
	modShift  = 1 << (4),
	modSuper = 1 << (5),
	modScrollLock = 1 << (6)
};

/*! types of dnd drag actions */
dndActionType :: enum(u8) {
	dndActionNone = 0,
	dndActionEnter, /*!< data has been dragged into the window area */
	dndActionMove, /*!< the data that was dragged into the window area has moved inside the window */
	dndActionExit, /*!< the data that was dragged into the window area has left the window */
};

/*! types of transfered data (clipboard, dnd) */
dataTransferType :: enum(u8) {
	dataNone = 0,
	dataText, /*!< plain text string */
	dataFile, /*!< file string */
	dataURL, /*!< URL string */
	dataImage, /*!< raw image data */
	dataUnknown /*!< unknown raw data */
};

/*! struct for data transfers, mostly used for the clipboard API */
dataTransfer :: struct {
	data : ^u8, /*!< transfered data */
	length : c.size_t, /*!< the full length of the data in bytes, including null-terminator, if included. null-terminators are ensured when reading data from RGFW */
	type : dataTransferType /*!< the type of data being transfered */
};

/*! internal node for a individual data drop */
dataDropNode :: struct {
	data : ^u8, /*!< dropped data */
	length : c.size_t, /*!< the size of the data in bytes */
	type : dataTransferType, /*!< the type of data being dropped */
	next : ^dataDropNode /*!< the next drop data node if any [when handling callbacks, this will always be NULL because the linked list is built as events are processed] */
}

/*! @brief codes for the event types that can be sent */
eventType :: enum(u8) {
	eventNone = 0, /*!< no event has been sent */
 	keyPressed, /*!< a key has been pressed */
	keyReleased, /*!< a key has been released */
	keyChar, /*!< keyboard character input event specifically for utf8 input */
	mouseButtonPressed, /*!< a mouse button has been pressed (left,middle,right) */
	mouseButtonReleased, /*!< a mouse button has been released (left,middle,right) */
	mouseScroll, /*!< a mouse scroll event */
	mouseMotion, /*!< the position of the mouse has been changed / the mouse has moved */
	mouseRawMotion, /*!< raw mouse motion */
	mouseEnter, /*!< mouse entered the window */
	mouseLeave, /*!< mouse left the window */
	windowMoved, /*!< the window was moved (by the user) */
	windowResized, /*!< the window was resized (by the user), [on WASM this means the browser was resized] */
	windowFocusIn, /*!< window is in focus now */
	windowFocusOut, /*!< window is out of focus now */
	windowRefresh, /*!< The window content needs to be refreshed */
	windowClose, /*!< the user attempts to close the window */
	windowMaximized, /*!< the window was maximized */
	windowMinimized, /*!< the window was minimized */
	windowRestored, /*!< the window was restored */
	dataDrop, /*!< data has been dropped into the window */
	dataDrag, /*!< the start of a drag and drop event, when data is being dragged */
	scaleUpdated, /*!< content scale factor changed */
	monitorConnected, /*!< a monitor has been connected */
	monitorDisconnected, /*!< a monitor has been disconnected */
	eventCount, /*!< the number of event types there are */
	mousePosChanged = mouseMotion, /*!< alias for mouseMotion (may be deleted at some point) */
};

/*! @brief flags for toggling whether or not an event should be processed */
eventFlag :: enum(u32) {
    keyPressedFlag = 1 << (eventType.keyPressed),
    keyReleasedFlag = 1 << (eventType.keyReleased),
    keyCharFlag = 1 << (eventType.keyChar),
    mouseScrollFlag = 1 << (eventType.mouseScroll),
    mouseButtonPressedFlag = 1 << (eventType.mouseButtonPressed),
    mouseButtonReleasedFlag = 1 << (eventType.mouseButtonReleased),
    mouseMotionFlag = 1 << (eventType.mouseMotion),
    mouseRawMotionFlag = 1 << (eventType.mouseRawMotion),
    mouseEnterFlag = 1 << (eventType.mouseEnter),
    mouseLeaveFlag = 1 << (eventType.mouseLeave),
    windowMovedFlag = 1 << (eventType.windowMoved),
    windowResizedFlag = 1 << (eventType.windowResized),
    windowFocusInFlag = 1 << (eventType.windowFocusIn),
    windowFocusOutFlag = 1 << (eventType.windowFocusOut),
    windowRefreshFlag = 1 << (eventType.windowRefresh),
    windowMaximizedFlag = 1 << (eventType.windowMaximized),
    windowMinimizedFlag = 1 << (eventType.windowMinimized),
    windowRestoredFlag = 1 << (eventType.windowRestored),
    scaleUpdatedFlag = 1 << (eventType.scaleUpdated),
    windowCloseFlag = 1 << (eventType.windowClose),
    dataDropFlag = 1 << (eventType.dataDrop),
    dataDragFlag = 1 << (eventType.dataDrag),
	monitorConnectedFlag = 1 << (eventType.monitorConnected),
	monitorDisconnectedFlag = 1 << (eventType.monitorDisconnected),
    mousePosChangedFlag = mouseMotionFlag, /* alias for mouseMotionFlag (may be deleted at some point) */

    keyEventsFlag = keyPressedFlag | keyReleasedFlag | keyCharFlag,
    mouseEventsFlag = mouseButtonPressedFlag | mouseButtonReleasedFlag | mouseMotionFlag | mouseEnterFlag | mouseLeaveFlag | mouseScrollFlag | mouseRawMotionFlag,
    windowEventsFlag = windowMovedFlag | windowResizedFlag | windowRefreshFlag | windowMaximizedFlag | windowMinimizedFlag | windowRestoredFlag | scaleUpdatedFlag,
    windowFocusEventsFlag = windowFocusInFlag | windowFocusOutFlag,
    dataDragDropEventsFlag = dataDropFlag | dataDragFlag,
	monitorEventsFlag = monitorConnectedFlag | monitorDisconnectedFlag,
    allEventFlags = keyEventsFlag | mouseEventsFlag | windowEventsFlag | windowFocusEventsFlag | dataDragDropEventsFlag | windowCloseFlag | monitorEventsFlag
};

/*! Event structure(s) and union for checking/getting events */

/*! @brief common event data across all events */
commonEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window /*!< the window this event applies to (for event queue events) */
}

/*! @brief event data for all focus events */
windowFocusEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	state : bool /*!< wether or not the window is in focus or not */
}

/*! @brief event data for any mouse button event (press/release) */
mouseButtonEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	value : mouseButton, /* !< which mouse button was pressed */
	state : bool /*!< if the button was pressed or released */
}

/*! @brief event data for any mouse scroll or raw motion event */
mouseDeltaEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	x, y : c.float /*!< the raw mouse scroll or motion delta value */
}

/*! @brief event data for a mouse position event (mouseMotion) */
mouseMotionEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	x : i32, /*!< mouse x of event (or drop point) */
	y : i32, /*!< mouse y of event (or drop point) */
	inWindow : bool /*!< if the mouse is in the window or not */
};

/*! @brief event data for a key press/release event */
keyEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	value : key, /*!< the physical key of the event, refers to where key is physically */
	repeat : bool, /*!< key press event repeated (the key is being held) */
	mod : keymod , /*!< state of the key modifier state */
	state : bool /*!< if the key was pressed or released */
};

/*! @brief event data for a key character event */
keyCharEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	value : u32 /*!< the unicode value of the key */
};

/*! @brief event data for any data drop event */
dataDropEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	value : ^dataDropNode
};

/*! @brief event data for any data drag event */
dataDragEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	x : i32,
	y : i32, /*!< mouse x, y of event (or drop point) */
	action : dndActionType , /*!< the type of drag action, e.g. enter, leave, move */
	dataType : dataTransferType , /*!< the type of data being dragged*/
}

/*! @brief event data for when the window scale (DPI) is updated */
scaleUpdatedEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	x : c.float, y : c.float /*!< DPI scaling */
}

/*! @brief event data for when a monitor is connected, disconnected or updated */
monitorEvent :: struct {
	type : eventType, /*!< which event has been sent?*/
	win : ^window, /*!< the window this event applies to (for event queue events) */
	monitor : ^monitor, /*!< the monitor that this event applies to */
	state : bool /*!< if the monitor is connected or disconnected */
}

/*! @breif event data for when the window is updated, moved, resized or refreshed */
windowUpdateEvent :: struct {
	type : eventType, /*!< the specific event type */
	win : ^window, /*!< the window that was updated */
	x : i32, /*!< the new window x OR the x of the rectanglular refresh area */
	y : i32, /*!< the new window y OR the y of the rectanglular refresh area */
	w : i32, /*!< the new window width OR the width of the rectanglular refresh area */
	h : i32 /*!< the new window height OR the height of the rectanglular refresh area */
}

/*! @brief union for all of the event stucture types */
event :: struct #raw_union {
	type : eventType, /*!< which event has been sent?*/
	common : commonEvent, /*!< common event data (e.g.) type and win */
	focus : windowFocusEvent, /*!< event data  for focus in/out events */
	update : windowUpdateEvent, /*!< data for window update/move/resize/refresh events */
	button : mouseButtonEvent, /*!< data for a button press/release */
	delta : mouseDeltaEvent, /*!< data for a mouse scroll or raw motion */
	mouse : mouseMotionEvent, /*!< data for mouse motion events */
	key : keyEvent, /*!< data for key press/release/hold events */
	keyChar : keyCharEvent, /*!< data for key character events */
	drop : dataDropEvent, /*!< data dropping events */
	drag : dataDragEvent, /*!< data for data dragging events */
	scale : scaleUpdatedEvent, /*!< data for dpi scaling update events */
	monitor : monitorEvent  /*!< data for monitor events */
};

/*!
	@!brief codes for for the code is stupid and C++ waitForEvent
	waitMS -> Allows the function to keep checking for events even after there are no more events
			  if waitMS == 0, the loop will not wait for events
			  if waitMS > 0, the loop will wait that many miliseconds after there are no more events until it returns
			  if waitMS == -1 or waitMS == the max size of an unsigned 32-bit int, the loop will not return until it gets another event
*/
eventWait :: enum(i32) {
	eventNoWait = 0,
	eventWaitNext = -1
};

/*! @brief generic event callback function type */
genericFunc:: #type proc "c" (e : ^event);

/*! brief structure that holds an array to callback data*/
callbacks :: struct {
	arr : [eventType.eventCount]genericFunc /*!< an array of all the callbacks */
};

/*! @brief optional bitwise arguments for making a windows, these can be OR'd together */
windowFlags :: enum(u32) {
	windowNoBorder = 1 << (0), /*!< the window doesn't have a border / frame / decor */
	windowNoResize = 1 << (1), /*!< the window cannot be resized by the user */
	windowAllowDND = 1 << (2), /*!< the window supports drag and drop */
	windowHideMouse = 1 << (3), /*! the window should hide the mouse (can be toggled later on using `window_showMouse`) */
	windowFullscreen = 1 << (4), /*!< the window is fullscreen by default */
	windowTranslucent = 1 << (5), /*!< the window is translucent (only properly works on X11 and MacOS, although it's meant for for windows) */
	windowTransparent = windowTranslucent,  /*!< the window is translucent (only properly works on X11 and MacOS, although it's meant for for windows) */
	windowCenter = 1 << (6), /*! center the window on the screen */
	windowRawMouse = 1 << (7), /*!< use raw mouse mouse on window creation */
	windowScaleToMonitor = 1 << (8), /*! scale the window to the screen */
	windowHide = 1 << (9), /*! the window is hidden */
	windowMaximize = 1 << (10), /*!< maximize the window on creation */
	windowCenterCursor = 1 << (11), /*!< center the cursor to the window on creation */
	windowcfloating = 1 << (12), /*!< create a c.floating window */
	windowFocusOnShow = 1 << (13), /*!< focus the window when it's shown */
	windowMinimize = 1 << (14), /*!< focus the window when it's shown */
	windowFocus = 1 << (15), /*!< if the window is in focus */
	windowCaptureMouse = 1 << (16), /*!< capture the mouse mouse mouse on window creation */
	windowOpenGL = 1 << (17), /*!< create an OpenGL context (you can also do this manually with window_createContext_OpenGL) */
	windowEGL = 1 << (18), /*!< create an EGL context (you can also do this manually with window_createContext_EGL) */
	noDeinitOnClose = 1 << (19), /*!< do not auto deinit RGFW if the window closes and this is the last window open */
	windowedFullscreen = windowNoBorder | windowMaximize,
	windowCaptureRawMouse = windowCaptureMouse | windowRawMouse
};

/*! @brief the types of icon to set */
icon :: enum(u8) {
	iconTaskbar = 1 << (0),
	iconWindow = 1 << (1),
	iconBoth = iconTaskbar | iconWindow
};

/*! @brief standard mouse icons */
mouseIcon :: enum(u8) {
	mouseNormal = 0,
	mouseArrow,
	mouseIbeam,
	mouseText = mouseIbeam,
	mouseCrosshair,
	mousePointingHand,
	mouseResizeEW,
	mouseResizeNS,
	mouseResizeNWSE,
	mouseResizeNESW,
	mouseResizeNW,
	mouseResizeN,
	mouseResizeNE,
	mouseResizeE,
	mouseResizeSE,
	mouseResizeS,
	mouseResizeSW,
	mouseResizeW,
	mouseResizeAll,
	mouseNotAllowed,
	mouseWait,
	mouseProgress,
	mouseIconCount,
    mouseIconFinal = 16 /* padding for alignment */
};

/*! @breif flash request type */
flashRequest :: enum(u8) {
	flashCancel = 0,
	flashBriefly,
	flashUntilFocused
};

/*! @brief the type of debug message */
debugType :: enum(u8) {
	typeError = 0, typeWarning, typeInfo
};

/*! @brief error codes for known failure types */
errorCode :: enum(u8) {
	noError = 0, /*!< no error */
	errOutOfMemory,
	errOpenGLContext, errEGLContext, /*!< error with the OpenGL context */
	errWayland, errX11,
	errDirectXContext,
	errIOKit,
	errClipboard,
	errFailedFuncLoad,
	errBuffer,
	errMetal,
	errPlatform,
	errEventQueue,
	infoWindow, infoBuffer, infoGlobal, infoOpenGL,
	warningWayland, warningOpenGL
};

/*! @brief data for debug messages */
debugInfo :: struct {
	type : debugType, /*!< the type of message */
	code : errorCode, /*!< the code for the specific type of debug message */
	msg : cstring /*!< string message */
};

/*! @brief callback function type for debug messags */
debugFunc :: proc(info : ^debugInfo);

/*! @brief function pointer equivalent of rawptr */
//proc :: proc();

/*! @brief abstract structure for interfacing with the underlying OpenGL API */
glContext :: struct {};

/*! @brief abstract structure for interfacing with the underlying EGL API */
eglContext :: struct {};

/*! values for the releaseBehavior hint */
glReleaseBehavior :: enum(i32)   {
	glReleaseFlush = 0, /*!< flush the pipeline will be flushed when the context is release */
	glReleaseNone /*!< do nothing on release */
};

/*! values for the profile hint */
glProfile :: enum(i32)  {
	glCore = 0, /*!< the core OpenGL version, e.g. just support for that version */
	glForwardCompatibility, /*!< only compatibility for newer versions of OpenGL as well as the requested version */
	glCompatibility, /*!< allow compatibility for older versions of OpenGL as well as the requested version */
	glES, /*!< use OpenGL ES */
	glWeb /*!< use WebGL version (otherwise the version is changed to match it's GLES equivalent) */
};

/*! values for the renderer hint */
glRenderer :: enum(i32)  {
	glAccelerated = 0, /*!< hardware accelerated (GPU) */
	glSoftware /*!< software rendered (CPU) */
};

/*! OpenGL initalization hints */
glHints :: struct {
	stencil : i32,  /*!< set stencil buffer bit size (0 by default) */
	samples : i32, /*!< set number of sample buffers (0 by default) */
	stereo : i32, /*!< hint the context to use stereoscopic frame buffers for 3D (false by default) */
	auxBuffers : i32, /*!< number of aux buffers (0 by default) */
	doubleBuffer : i32, /*!< request double buffering (true by default) */
	red : i32, green : i32, blue : i32, alpha : i32, /*!< set color bit sizes (all 8 by default) */
	depth : i32, /*!< set depth buffer bit size (24 by default) */
	accumRed : i32, accumGreen : i32, accumBlue : i32, accumAlpha : i32, /*!< set accumulated RGBA bit sizes (all 0 by default) */
	sRGB: bool, /*!< request sRGA format (false by default) */
	robustness : bool, /*!< request a "robust" (as in memory-safe) context (false by default). For more information check the overview section: https://registry.khronos.org/OpenGL/extensions/EXT/EXT_robustness.txt */
	debug : bool, /*!< request OpenGL debugging (false by default). */
	noError : bool, /*!< request no OpenGL errors (false by default). This causes OpenGL errors to be undefined behavior. For more information check the overview section: https://registry.khronos.org/OpenGL/extensions/KHR/KHR_no_error.txt */
	releaseBehavior : glReleaseBehavior , /*!< hint how the OpenGL driver should behave when changing contexts (glReleaseNone by default). For more information check the overview section: https://registry.khronos.org/OpenGL/extensions/KHR/KHR_context_flush_control.txt */
	profile : glProfile , /*!< set OpenGL API profile (glCore by default) */
	major : i32, minor : i32,  /*!< set the OpenGL API profile version (by default glMajor is 1, glMinor is 0) */
	share : ^glContext,  /*!< Share this OpenGL context with newly created OpenGL contexts; defaults to NULL. */
	shareEGL : ^eglContext, /*!< Share this EGL context with newly created OpenGL contexts; defaults to NULL. */
	renderer : glRenderer /*!< renderer to use e.g. accelerated or software defaults to accelerated */
};


@(default_calling_convention="c", link_prefix="RGFW_")
foreign native {
	/**!
	* @brief Allocates memory using the allocator defined by ALLOC at compile time.
	* @param size The size (in bytes) of the memory block to allocate.
	* @return A pointer to the allocated memory block.
	*/
	alloc :: proc(size : c.size_t) -> rawptr  ---

	/**!
	* @brief Frees memory using the deallocator defined by FREE at compile time.
	* @param ptr A pointer to the memory block to free.
	*/
	free :: proc(ptr : rawptr) ---

	/**!
	* @brief Returns the size (in bytes) of the window structure.
	* @return The size of the window structure.
	*/
	sizeofWindow :: proc() -> c.size_t ---

	/**!
	* @brief Returns the size (in bytes) of the window_src structure.
	* @return The size of the window_src structure.
	*/
	sizeofWindowSrc :: proc() -> c.size_t ---

	/**!
	* @brief Checks if Wayland is currently being used.
	* @return TRUE if using Wayland, FALSE otherwise.
	*/
	usingWayland :: proc() -> bool ---

	/**!
	* @brief Retrieves the current Cocoa layer (macOS only).
	* @return A pointer to the Cocoa layer, or NULL if the platform is not in use.
	*/
	getLayer_OSX :: proc() -> rawptr  ---

	/**!
	* @brief Retrieves the current X11 display connection.
	* @return A pointer to the X11 display, or NULL if the platform is not in use.
	*/
	getDisplay_X11 :: proc() -> rawptr  ---

	/**!
	* @brief Retrieves the current Wayland display connection.
	* @return A pointer to the Wayland display (`struct wl_display*`), or NULL if the platform is not in use.
	*/
	getDisplay_Wayland :: proc() -> rawptr ---

	/**!
	* @brief (macOS only) Changes the current working directory to the application’s resource folder.
	*/
	moveToMacOSResourceDir :: proc() ---

	/*! copy image to another image, respecting each image's format */
	copyImageData :: proc(dest_data : ^u8, w : i32, h : i32, dest_format : format, src_data : ^u8, src_format : format, func : convertImageDataFunc) ---

	/**!
	* @brief Returns the size (in bytes) of the nativeImage structure.
	* @return The size of the nativeImage structure.
	*/
	sizeofNativeImage :: proc() -> c.size_t ---

	/**!
	* @brief Returns the size (in bytes) of the surface structure.
	* @return The size of the surface structure.
	*/
	sizeofSurface:: proc() -> c.size_t  ---

	/**!
	* @brief Returns the native format type for the system
	* @return the native format type for the system as a format enum value
	*/
	nativeFormat :: proc() -> format  ---

	/**!
	* @brief Creates a new surface from raw pixel data.
	* @param data A pointer to the pixel data buffer.
	* @param w The width of the surface in pixels.
	* @param h The height of the surface in pixels.
	* @param format The pixel format of the data.
	* @return A pointer to the newly created surface.
	*
	* NOTE: when you create a surface using createSurface / ptr, on X11 it uses the root window's visual
	* this means it may fail to render on any other window if the visual does not match
	* window_createSurface and window_createSurfacePtr exist only for X11 to address this issues
	* Of course, you can also manually set the root window with setRootWindow
	*/
	createSurface :: proc(data : ^u8, w : i32, h : i32, format : format) -> ^surface ---

	/**!
	* @brief Creates a surface using a pre-allocated surface structure.
	* @param data A pointer to the pixel data buffer.
	* @param w The width of the surface in pixels.
	* @param h The height of the surface in pixels.
	* @param format The pixel format of the data.
	* @param surface A pointer to a pre-allocated surface structure.
	* @return TRUE if successful, FALSE otherwise.
	*/
	createSurfacePtr :: proc(data : ^u8, w : i32, h : i32, format : format, surface : ^surface) -> bool  ---

	/**!
	* @brief Retrieves the native image associated with a surface.
	* @param surface A pointer to the surface.
	* @return A pointer to the native nativeImage associated with the surface.
	*/
	surface_getNativeImage :: proc(surface : ^surface) -> ^nativeImage ---

	/**!
	* @brief Frees the surface pointer and any buffers used for software rendering.
	* @param surface A pointer to the surface to free.
	*/
	surface_free :: proc(surface : ^surface) ---

	/**!
	* @brief Frees only the internal buffers used for software rendering, leaving the surface struct intact.
	* @param surface A pointer to the surface whose buffers should be freed.
	*/
	surface_freePtr :: proc(surface : ^surface) ---


	/**!
	* @brief create a mouse icon from bitmap data (similar to window_setIcon).
	* @param data A pointer to the bitmap pixel data.
	* @param w The width of the mouse icon in pixels.
	* @param h The height of the mouse icon in pixels.
	* @param format The pixel format of the data.
	* @return A pointer to the newly loaded mouse structure.
	*
	* @note The icon is not resized by default.
	*/
	createMouse :: proc(data : ^u8, w : i32, h : i32, format : format) -> rawptr ---

	/**!
	* @brief create a standard mouse icon
	* @param mouse The standard cursor type (see MOUSE enum).
	* @return A pointer to the newly loaded mouse structure.
	*/
	createMouseStandard :: proc(mouse : mouseIcon) -> rawptr ---

	/**!
	* @brief Frees the data associated with an mouse structure.
	* @param mouse A pointer to the mouse to free.
	*/
	freeMouse :: proc(mouse : rawptr) ---

	/**!
	* @brief Get an allocated array of the supported modes of a monitor
	* @param monitor the source monitor object
	* @param count [OUTPUT] the count of the array
	* @return the allocated array of supported modes
	*/
	monitor_getModes :: proc(monitor : ^monitor, count : ^c.size_t) -> ^monitorMode ---

	/**!
	* @brief Free RGFW allocated modes array
	* @param monitor the source monitor object
	* @param modes a pointer to an allocated array of modes
	*/
	freeModes :: proc(mode : ^monitorMode) ---

	/**!
	* @brief Get the supported modes of a monitor using a pre-allocated array
	* @param monitor the source monitor object
	* @param modes [OUTPUT] a pointer to an allocated array of modes
	* @return the number of (possible) modes, if [modes == NULL] the possible nodes *may* be less than the actual modes
	*/
	monitor_getModesPtr :: proc(monitor : ^monitor, modes : ^^monitorMode) -> c.size_t  ---

	/**!
	* @brief find the closest monitor mode based on the give mode with size being the highest priority, format being the second and refreshrate being the third.
	* @param monitor the source monitor object
	* @param mode user filled mode to use for comparison
	* @param modes [OUTPUT] a pointer to be filled with the output closest monitor
	* @return returns true if a suitable monitor was found and false if no suitable monitor was found at all
	*/

	monitor_findClosestMode :: proc(monitor : ^monitor, mode : ^monitorMode, closest : ^monitorMode) -> bool ---

	/**!
	* @brief Get the allocated gamma ramp
	* @param monitor the source monitor object
	*/
	monitor_getGammaRamp :: proc(monitor : ^monitor) -> ^gammaRamp ---

	/**!
	* @brief Free the gamma ramp allocated by RGFW
	* @param allocated gamma ramp
	*/
	freeGammaRamp :: proc(ramp : ^gammaRamp) ---

	/**!
	* @brief Get the monitor's gamma ramp using a pre-allocated struct with allocated data
	* @param monitor the source monitor object
	* @param ramp [OUTPUT] a pointer to an allocated gamma ramp (can be NULL to just get the count)
	* @return the count of the gamma ramp
	*/
	monitor_getGammaRampPtr :: proc(monitor : ^monitor, ramp : ^gammaRamp) -> c.size_t ---

	/**!
	* @brief Set the monitor's gamma ramp using a pre-allocated struct with allocated data
	* @param monitor the source monitor object
	* @param ramp a pointer to an allocated gamma ramp
	* @return a bool if the function was successful
	*/
	monitor_setGammaRamp :: proc(monitor : ^monitor, ramp : ^gammaRamp) -> bool ---

	/**!
	* @brief Create and set the monitor's gamma ramp with a base gamma exponent
	* @param monitor the source monitor object
	* @param the gamma exponent
	* @return a bool if the function was successful
	*/
	monitor_setGamma :: proc(monitor : ^monitor, gamma : c.float) -> bool ---

	/**!
	* @brief Create and set the monitor's gamma ramp with a base gamma exponent using a pre-allocated array
	* @param monitor the source monitor object
	* @param gamma the gamma exponent
	* @param pre-allocated gammaramp channel
	* @param count the length of the allocated channel array
	* @return a bool if the function was successful
	*/
	monitor_setGammaPtr :: proc(monitor : ^monitor, gamma : c.float, ptr : ^u16, count : c.size_t) -> bool ---

	/**!
	* @brief Get the workarea of a monitor, meaning the parts not occupied by OS graphics (i.e. the taskbar)
	* @param monitor the source monitor object
	* @param x [OUTPUT] the x pos of the workarea
	* @param y [OUTPUT] the y pos of the workarea
	* @param w [OUTPUT] the width of the workarea
	* @param h [OUTPUT] the height of the workarea
	* @return a bool if the function was successful
	*/
	monitor_getWorkarea :: proc(monitor : ^monitor, x : ^i32, y : ^i32, width : ^i32, height : ^i32) -> bool ---

	/**!
	* @brief Get the position of a monitor (the same as monitor.x / monitor.y)
	* @param x [OUTPUT] the x position of the monitor
	* @param y [OUTPUT] the y position of the monitor
	* @return a bool if the function was successful
	*/
	monitor_getPosition :: proc(monitor : ^monitor, x : ^i32, y : ^i32) -> bool ---

	/**!
	* @brief Get the name of a monitor (the same as monitor.name)
	* @return the cstring of the monitor's name
	*/
	monitor_getName :: proc(monitor : ^monitor) -> cstring ---

	/**!
	* @brief Get the scale of a monitor (the same as monitor.scaleX / monitor.scaleY)
	* @param monitor the source monitor object
	* @param x [OUTPUT] the x scale of the monitor
	* @param y [OUTPUT] the y scale of the monitor
	* @return a bool if the function was successful
	*/
	monitor_getScale :: proc(monitor : ^monitor, x : ^c.float, y : ^c.float) -> bool ---

	/**!
	* @brief Get the physical size of a monitor (the same as monitor.physW / monitor.physH)
	* @param monitor the source monitor object
	* @param w [OUTPUT] the physical width of the monitor
	* @param h [OUTPUT] the physical height of the monitor
	* @return a bool if the function was successful
	*/
	monitor_getPhysicalSize :: proc(monitor : ^monitor, w : ^c.float, h : ^c.float) -> bool ---

	/**!
	* @brief Set the user pointer of a monitor (the same as monitor.userPtr = userPtr)
	* @param monitor the source monitor object
	* @param userPtr the new user pointer for the monitor
	*/
	monitor_setUserPtr :: proc(monitor : ^monitor, userPtr : rawptr) ---

	/**!
	* @brief Get the user pointer of a monitor (the same as monitor.userPtr)
	* @param monitor the source monitor object
	* @return the user pointer of the monitor
	*/
	monitor_getUserPtr :: proc(monitor : ^monitor) -> rawptr ---

	/**!
	* @brief Get the mode of a monitor (the same as monitor.mode)
	* @param monitor the source monitor object
	* @param mode [OUTPUT] current mode the monitor
	* @return a bool if the function was successful
	*/
	monitor_getMode :: proc(monitor : ^monitor, mode : ^monitorMode) -> bool  ---

	/**!
	* @brief Poll and check for monitor updates (this is called internally on monitor update events and init)
	*/
	pollMonitors :: proc() ---

	/**!
	* @brief free all leftlover monitor data (this is called internally deinit)
	*/
	freeMonitors :: proc() ---

	/**!
	* @brief Allocates and returns an array of all available monitors.
	* @param len [OUTPUT] A pointer to store the number of monitors found.
	* @return An allocated array of pointers to monitor structures that must be freed.
	*/
	getMonitors :: proc(len : ^c.size_t) -> ^^monitor  ---

	/**!
	* @brief fills a pre-allocated array with available monitors.
	* @param maximum number of monitors that the passed [monitors] buffer supports, can be zero to get the length alone
	* @param pre-allocated buffer of monitors, can be NULL to get the length alone
	* @param len [OUTPUT] A pointer to store the number of monitors found, if max is not zero and monitors is not NULL, length will be set to max.
	* @return An array of pointers to monitor structures or NULL if the function failed.
	*/
	getMonitorsPtr :: proc(max : c.size_t, monitors : ^^monitor, len : ^c.size_t) -> bool ---

	/**!
	* @brief Retrieves the primary monitor.
	* @return A pointer to the monitor structure representing the primary monitor.
	*/
	getPrimaryMonitor :: proc() -> ^monitor ---

	/**!
	* @brief Requests the display mode for a monitor (based on what attributes are directly requested).
	* @param mon The monitor to apply the mode change to.
	* @param mode The desired monitorMode.
	* @param request The modeRequest describing how to handle the mode change.
	* @return TRUE if the mode was successfully applied, otherwise FALSE.
	*/
	monitor_requestMode :: proc(mon : ^monitor, mode : ^monitorMode, request : ^modeRequest) -> bool ---

	/**!
	* @brief Sets a specific display mode for a monitor directly.
	* @param mon The monitor to apply the mode change to.
	* @param mode The desired monitorMode.
	* @param request The modeRequest describing how to handle the mode change.
	* @return TRUE if the mode was successfully applied, otherwise FALSE.
	*/
	monitor_setMode :: proc(mon : ^monitor, mode : ^monitorMode) -> bool ---

	/**!
	* @brief Compares two monitor modes to check if they are equivalent.
	* @param mon The first monitor mode.
	* @param mon2 The second monitor mode.
	* @param request The modeRequest that defines the comparison parameters.
	* @return TRUE if both modes are equivalent, otherwise FALSE.
	*/
	monitorModeCompare :: proc(mode : ^monitorMode, mode2 : ^monitorMode, request : ^modeRequest) -> bool ---

	/**!
	* @brief Scales a monitor’s mode to match a window’s size.
	* @param mon The monitor to be scaled.
	* @param win The window whose size should be used as a reference.
	* @return TRUE if the scaling was successful, otherwise FALSE.
	*/
	monitor_scaleToWindow :: proc(mon : ^monitor, win : ^window) -> bool ---

	/**!
	* @brief set (enable or disable) raw mouse mode globally
	* @param the boolean state of raw mouse mode
	*
	*/
	setRawMouseMode :: proc(state : bool) ---

	/**!
	* @brief toggles building the drag-and-drop (DND) linked list
	* @param allow TRUE to allow DND building, FALSE to disable
	* @note this is for state checking, the list is created by default if you are using the event queue
	*/
	setBuildDND :: proc(allow : bool) ---

	/**!
	* @brief sleep until RGFW gets an event or the timer ends (defined by OS)
	* @param waitMS how long to wait for the next event (in miliseconds)
	*/
	waitForEvent :: proc(waitMS : i32) ---

	/**!
	* @brief Set if events should be queued or not (enabled by default if the event queue is checked)
	* @param queue boolean value if RGFW should queue events or not
	*/
	setQueueEvents :: proc(queue : bool) ---

	/**!
	* @brief Sets the callback function for the event.
	* @param the event type for the callback
	* @param func The function to be called when the event is triggered.
	* @return The previously set callback function, if any.
	*/
	setEventCallback :: proc(type : eventType, func : genericFunc) -> genericFunc ---

	/**!
	* @brief Sets the callback function for two continuous events.
	* @param func The function to be called when the event is triggered.
	* @param [OUTPUT] The previously set callback function for the first event, if any.
	* @param [OUTPUT] The previously set callback function for the second event, if any.
	*/
	setDualEventCallback :: proc(type : eventType, func : genericFunc, first : ^genericFunc, second : ^genericFunc) ---

	/**!
	* @brief Sets the callback function for all events.
	* @param func The function to be called when the event is triggered.
	* @param [OUTPUT] a structure that holds an array of all the event callbacks
	*/
	setAllEventCallbacks :: proc(func : genericFunc, callbacks : ^callbacks) ---

	/**!
	* @brief check all the events until there are none left and updates window structure attributes
	*/
	pollEvents :: proc() ---

	/**!
	* @brief check all the events until there are none left and updates window structure attributes
	* queues events if the queue is checked and/or requested
	*/
	stopCheckEvents :: proc() ---

	/**!
	* @brief polls and pops the next event
	* @param event [OUTPUT] a pointer to store the retrieved event
	* @return TRUE if an event was found, FALSE otherwise
	*
	* NOTE: Using this function without a loop may cause event lag.
	* For multi-threaded systems, use pollEvents combined with checkQueuedEvent.
	*
	* Example:
	* event event ---
	* while (checkEvent(win, &event)) {
	*     // handle event
	* }
	*/
	checkEvent :: proc(event : ^event) -> bool ---

	/**!
	* @brief pops the first queued event
	* @param event [OUTPUT] a pointer to store the retrieved event
	* @return TRUE if an event was found, FALSE otherwise
	*/
	checkQueuedEvent :: proc(event : ^event) -> bool ---

	/** * @defgroup Input
	* @{ */

	/**!
	* @brief returns true if the key is pressed during the current frame
	* @param key the key code of the key you want to check
	* @return The boolean value if the key is pressed or not
	*/
	isKeyPressed :: proc(key : key) -> bool  ---

	/**!
	* @brief returns true if the key was released during the current frame
	* @param key the key code of the key you want to check
	* @return The boolean value if the key is released or not
	*/
	isKeyReleased :: proc(key : key) -> bool  ---

	/**!
	* @brief returns true if the key is down
	* @param key the key code of the key you want to check
	* @return The boolean value if the key is down or not
	*/
	isKeyDown :: proc(key : key) -> bool ---

	/**!
	* @brief returns true if the mouse button is pressed during the current frame
	* @param button the mouse button code of the button you want to check
	* @return The boolean value if the button is pressed or not
	*/
	isMousePressed :: proc(button : mouseButton) -> bool ---

	/**!
	* @brief returns true if the mouse button is released during the current frame
	* @param button the mouse button code of the button you want to check
	* @return The boolean value if the button is released or not
	*/
	isMouseReleased :: proc(button : mouseButton) -> bool ---

	/**!
	* @brief returns true if the mouse button is down
	* @param button the mouse button code of the button you want to check
	* @return The boolean value if the button is down or not
	*/
	isMouseDown :: proc(button : mouseButton) -> bool ---

	/**!
	* @brief outputs the current x, y position of the mouse
	* @param X [OUTPUT] a pointer for the output X value
	* @param Y [OUTPUT] a pointer for the output Y value
	*/
	getMouseScroll :: proc(x : ^c.float, y : ^c.float) ---

	/**!
	* @brief outputs the current x, y movement vector of the mouse
	* @param X [OUTPUT] a pointer for the output X vector value
	* @param Y [OUTPUT] a pointer for the output Y vector value
	*/
	getMouseVector :: proc(x : ^c.float, y : ^c.float) ---
	/** @} */

	/**!
	* @brief creates a new window
	* @param name the requested title of the window
	* @param x the requested x position of the window
	* @param y the requested y position of the window
	* @param w the requested width of the window
	* @param h the requested height of the window
	* @param flags extra arguments ((u32)0 means no flags used)
	* @return A pointer to the newly created window structure
	*
	* NOTE: (windows) if the executable has an icon resource named ICON, it will be set as the initial icon for the window
	*/
	createWindow :: proc(name : cstring, x : i32, y : i32, w : i32, h : i32, flags : windowFlags) -> ^window ---

	/**!
	* @brief creates a new window using a pre-allocated window structure
	* @param name the requested title of the window
	* @param x the requested x position of the window
	* @param y the requested y position of the window
	* @param w the requested width of the window
	* @param h the requested height of the window
	* @param flags extra arguments ((u32)0 means no flags used)
	* @param win a pointer the pre-allocated window structure
	* @return A pointer to the newly created window structure
	*/
	createWindowPtr :: proc(name : cstring, x : i32, y : i32, w : i32, h : i32, flags : windowFlags, win : ^window) -> ^window ---

	/**!
	* @brief creates a new surface structure
	* @param win the source window of the surface
	* @param data a pointer to the raw data of the structure (you allocate this)
	* @param w the width the data
	* @param h the height of the data
	* @return A pointer to the newly created surface structure
	*
	* NOTE: when you create a surface using createSurface / ptr, on X11 it uses the root window's visual
	* this means it may fail to render on any other window if the visual does not match
	* window_createSurface and window_createSurfacePtr exist only for X11 to address this issues
	* Of course, you can also manually set the root window with setRootWindow
	*/
	window_createSurface :: proc(win: ^window, data : ^u8, w : i32, h : i32, format : format) -> ^surface ---

	/**!
	* @brief creates a new surface structure using a pre-allocated surface structure
	* @param win the source window of the surface
	* @param data a pointer to the raw data of the structure (you allocate this)
	* @param w the width the data
	* @param h the height of the data
	* @param a pointer to the pre-allocated surface structure
	* @return a bool if the creation was successful or not
	*/
	window_createSurfacePtr :: proc(win: ^window, data : ^u8, w : i32, h : i32, format : format, surface : ^surface) -> bool  ---

	/**!
	* @brief set the function/callback used for converting surface data between formats
	* @param surface a pointer to the surface
	* @param a function pointer for the function to use [if NULL the default function is used]
	*/
	surface_setConvertFunc :: proc(surface : ^surface, func : convertImageDataFunc) ---

	/**!
	* @brief blits a surface stucture to the window
	* @param win a pointer the window to blit to
	* @param surface a pointer to the surface
	*/
	window_blitSurface :: proc(win: ^window, surface : ^surface) ---

	/**!
	* @brief gets the position of the window | with window.x and window.y
	* @param x [OUTPUT] the x position of the window
	* @param y [OUTPUT] the y position of the window
	* @return a bool if the function was successful
	*/
	window_getPosition :: proc(win: ^window, x: ^i32, y: ^i32) -> bool --- /*!<  */

	/**!
	* @brief gets the size of the window | with window.w and window.h
	* @param win a pointer to the window
	* @param w [OUTPUT] the width of the window
	* @param h [OUTPUT] the height of the window
	* @return a bool if the function was successful
	*/
	window_getSize :: proc(win: ^window, w: ^i32, h: ^i32) -> bool ---

	/**!
	* @brief gets the size of the window in exact pixels
	* @param win a pointer to the window
	* @param w [OUTPUT] the width of the window
	* @param h [OUTPUT] the height of the window
	* @return a bool if the function was successful
	*/
	window_getSizeInPixels :: proc(win: ^window, w: ^i32, h: ^i32) -> bool ---

	/**!
	* @brief gets the flags of the window | returns window._flags
	* @param win a pointer to the window
	* @return the window flags
	*/
	window_getFlags :: proc(win: ^window) -> u32 ---

	/**!
	* @brief returns the exit key assigned to the window
	* @param win a pointer to the target window
	* @return The key code assigned as the exit key
	*/
	window_getExitKey :: proc(win: ^window) -> key ---

	/**!
	* @brief sets the exit key for the window
	* @param win a pointer to the target window
	* @param key the key code to assign as the exit key
	*/
	window_setExitKey :: proc(win: ^window, key : key) ---

	/**!
	* @brief sets the types of events you want the window to receive
	* @param win a pointer to the target window
	* @param events the event flags to enable (use allEventFlags for all)
	*/
	window_setEnabledEvents :: proc(win: ^window, events : eventFlag ) ---

	/**!
	* @brief gets the currently enabled events for the window
	* @param win a pointer to the target window
	* @return The enabled event flags for the window
	*/
	window_getEnabledEvents :: proc(win: ^window) -> eventFlag ---

	/**!
	* @brief enables all events and disables selected ones
	* @param win a pointer to the target window
	* @param events the event flags to disable
	*/
	window_setDisabledEvents :: proc(win: ^window, events : eventFlag) ---

	/**!
	* @brief directly enables or disables a specific event or group of events
	* @param win a pointer to the target window
	* @param event the event flag or group of flags to modify
	* @param state TRUE to enable, FALSE to disable
	*/
	window_setEventState :: proc(win: ^window, event : eventFlag, state : bool) ---

	/**!
	* @brief gets the user pointer associated with the window
	* @param win a pointer to the target window
	* @return The user-defined pointer stored in the window
	*/
	window_getUserPtr :: proc(win: ^window) -> rawptr  ---

	/**!
	* @brief sets a user pointer for the window
	* @param win a pointer to the target window
	* @param ptr a pointer to associate with the window
	*/
	window_setUserPtr :: proc(win: ^window, ptr : rawptr) ---

	/**!
	* @brief retrieves the platform-specific window source pointer
	* @param win a pointer to the target window
	* @return A pointer to the internal window_src structure
	*/
	window_getSrc :: proc(win: ^window) -> ^window_src ---

	/**!
	* @brief sets the macOS layer object associated with the window
	* @param win a pointer to the target window
	* @param layer a pointer to the macOS layer object
	* @note Only available on macOS platforms
	*/
	window_setLayer_OSX :: proc(win: ^window, layer : rawptr ) ---

	/**!
	* @brief retrieves the macOS view object associated with the window
	* @param win a pointer to the target window
	* @return A pointer to the macOS view object, or NULL if not on macOS
	*/
	window_getView_OSX :: proc(win: ^window) -> rawptr ---

	/**!
	* @brief retrieves the macOS window object
	* @param win a pointer to the target window
	* @return A pointer to the macOS window object, or NULL if not on macOS
	*/
	window_getWindow_OSX :: proc(win: ^window) -> rawptr ---

	/**!
	* @brief retrieves the HWND handle for the window
	* @param win a pointer to the target window
	* @return A pointer to the Windows HWND handle, or NULL if not on Windows
	*/
	window_getHWND :: proc(win: ^window) -> rawptr ---

	/**!
	* @brief retrieves the HDC handle for the window
	* @param win a pointer to the target window
	* @return A pointer to the Windows HDC handle, or NULL if not on Windows
	*/
	window_getHDC :: proc(win: ^window) -> rawptr ---

	/**!
	* @brief retrieves the X11 Window handle for the window
	* @param win a pointer to the target window
	* @return The X11 Window handle, or 0 if not on X11
	*/
	window_getWindow_X11 :: proc(win: ^window) -> u64 ---

	/**!
	* @brief retrieves the Wayland surface handle for the window
	* @param win a pointer to the target window
	* @return A pointer to the Wayland wl_surface, or NULL if not on Wayland
	*/
	window_getWindow_Wayland :: proc(win: ^window) -> rawptr ---

	/** * @defgroup Window_management
	* @{ */

	/*! set the window flags (will undo flags if they don't match the old ones) */
	window_setFlags :: proc(win: ^window, windowFlags : u32) ---

	/**!
	* @brief polls and pops the next event with the matching target window in event queue, pushes back events that don't match
	* @param win a pointer to the target window
	* @param event [OUTPUT] a pointer to store the retrieved event
	* @return TRUE if an event was found, FALSE otherwise
	*
	* NOTE: Using this function without a loop may cause event lag.
	* For multi-threaded systems, use pollEvents combined with window_checkQueuedEvent.
	*
	* Example:
	* event event ---
	* while (window_checkEvent(win, &event)) {
	*     // handle event
	* }
	*/
	window_checkEvent :: proc(win: ^window, event : ^event) -> bool ---

	/**!
	* @brief pops the first queued event with the matching target window, pushes back events that don't match
	* @param win a pointer to the target window
	* @param event [OUTPUT] a pointer to store the retrieved event
	* @return TRUE if an event was found, FALSE otherwise
	*/
	window_checkQueuedEvent :: proc(win: ^window, event : ^event) -> bool ---

	/**!
	* @brief checks if a key was pressed while the window is in focus
	* @param win a pointer to the target window
	* @param key the key code to check
	* @return TRUE if the key was pressed, FALSE otherwise
	*/
	window_isKeyPressed :: proc(win: ^window, key : key) -> bool ---

	/**!
	* @brief checks if a key is currently being held down
	* @param win a pointer to the target window
	* @param key the key code to check
	* @return TRUE if the key is held down, FALSE otherwise
	*/
	window_isKeyDown :: proc(win: ^window, key : key) -> bool ---

	/**!
	* @brief checks if a key was released
	* @param win a pointer to the target window
	* @param key the key code to check
	* @return TRUE if the key was released, FALSE otherwise
	*/
	window_isKeyReleased :: proc(win: ^window, key : key) -> bool ---

	/**!
	* @brief checks if a mouse button was pressed
	* @param win a pointer to the target window
	* @param button the mouse button code to check
	* @return TRUE if the mouse button was pressed, FALSE otherwise
	*/
	window_isMousePressed :: proc(win: ^window, button : mouseButton) -> bool ---

	/**!
	* @brief checks if a mouse button is currently held down
	* @param win a pointer to the target window
	* @param button the mouse button code to check
	* @return TRUE if the mouse button is down, FALSE otherwise
	*/
	window_isMouseDown :: proc(win: ^window, button : mouseButton) -> bool ---

	/**!
	* @brief checks if a mouse button was released
	* @param win a pointer to the target window
	* @param button the mouse button code to check
	* @return TRUE if the mouse button was released, FALSE otherwise
	*/
	window_isMouseReleased :: proc(win: ^window, button : mouseButton) -> bool ---

	/**!
	* @brief checks if the mouse left the window (true only for the first frame)
	* @param win a pointer to the target window
	* @return TRUE if the mouse left, FALSE otherwise
	*/
	window_didMouseLeave :: proc(win: ^window) -> bool ---

	/**!
	* @brief checks if the mouse entered the window (true only for the first frame)
	* @param win a pointer to the target window
	* @return TRUE if the mouse entered, FALSE otherwise
	*/
	window_didMouseEnter :: proc(win: ^window) -> bool ---

	/**!
	* @brief checks if the mouse is currently inside the window bounds
	* @param win a pointer to the target window
	* @return TRUE if the mouse is inside, FALSE otherwise
	*/
	window_isMouseInside :: proc(win: ^window) -> bool ---

	/**!
	* @brief checks if there is data being dragged into or within the window
	* @param win a pointer to the target window
	* @return TRUE if data is being dragged, FALSE otherwise
	*/
	window_isDataDragging :: proc(win: ^window) -> bool ---

	/**!
	* @brief gets the position of a data drag
	* @param win a pointer to the target window
	* @param x [OUTPUT] pointer to store the x position
	* @param y [OUTPUT] pointer to store the y position
	* @return TRUE if there is an active drag, FALSE otherwise
	*/
	window_getDataDrag :: proc(win: ^window, x : ^i32, y : ^i32) -> bool ---

	/**!
	* @brief checks if a data drop occurred in the window (first frame only)
	* @param win a pointer to the target window
	* @return TRUE if data was dropped, FALSE otherwise
	*/
	window_didDataDrop :: proc(win: ^window) -> bool ---

	/**!
	* @brief retrieves data from a data drop (drag and drop)
	* @param win a pointer to the target window
	* @return a valid pointer to the root drag node if a data drop occurred, NULL otherwise
	*/
	window_getDataDrop :: proc(win: ^window) -> ^dataDropNode ---

	/**!
	* @brief closes the window and frees its associated structure
	* @param win a pointer to the target window
	*/
	window_close :: proc(win: ^window) ---

	/**!
	* @brief closes the window without freeing its structure
	* @param win a pointer to the target window
	*/
	window_closePtr :: proc(win: ^window) ---

	/**!
	* @brief fetches the size of the window through the OS (and updates the internal values)
	* @param win a pointer to the window
	* @param w [OUTPUT] the width of the window
	* @param h [OUTPUT] the height of the window
	* @return a bool if the function was successful
	*/
	window_fetchSize :: proc(win: ^window, w : ^i32, h : ^i32) -> bool ---

	/**!
	* @brief moves the window to a new position on the screen
	* @param win a pointer to the target window
	* @param x the new x position
	* @param y the new y position
	*/
	window_move :: proc(win: ^window, x : i32, y : i32) ---

	/**!
	* @brief moves the window to a specific monitor
	* @param win a pointer to the target window
	* @param m the target monitor
	*/
	window_moveToMonitor :: proc(win: ^window, monitor : ^monitor) ---

	/**!
	* @brief resizes the window to the given dimensions
	* @param win a pointer to the target window
	* @param w the new width
	* @param h the new height
	*/
	window_resize :: proc(win: ^window, w : i32, h : i32) ---

	/**!
	* @brief sets the aspect ratio of the window
	* @param win a pointer to the target window
	* @param w the width ratio
	* @param h the height ratio
	*/
	window_setAspectRatio :: proc(win: ^window, w : i32, h : i32) ---

	/**!
	* @brief sets the minimum size of the window
	* @param win a pointer to the target window
	* @param w the minimum width
	* @param h the minimum height
	*/
	window_setMinSize :: proc(win: ^window, w : i32, h : i32) ---

	/**!
	* @brief sets the maximum size of the window
	* @param win a pointer to the target window
	* @param w the maximum width
	* @param h the maximum height
	*/
	window_setMaxSize :: proc(win: ^window, w : i32, h : i32) ---

	/**!
	* @brief sets focus to the window
	* @param win a pointer to the target window
	*/
	window_focus :: proc(win: ^window) ---

	/**!
	* @brief checks if the window is currently in focus
	* @param win a pointer to the target window
	* @return TRUE if the window is in focus, FALSE otherwise
	*/
	window_isInFocus :: proc(win: ^window) -> bool ---

	/**!
	* @brief raises the window to the top of the stack
	* @param win a pointer to the target window
	*/
	window_raise :: proc(win: ^window) ---

	/**!
	* @brief maximizes the window
	* @param win a pointer to the target window
	*/
	window_maximize :: proc(win: ^window) ---

	/**!
	* @brief toggles fullscreen mode for the window
	* @param win a pointer to the target window
	* @param fullscreen TRUE to enable fullscreen, FALSE to disable
	*/
	window_setFullscreen :: proc(win: ^window, fullscreen : bool) ---

	/**!
	* @brief centers the window on the screen
	* @param win a pointer to the target window
	*/
	window_center :: proc(win: ^window) ---

	/**!
	* @brief minimizes the window
	* @param win a pointer to the target window
	*/
	window_minimize :: proc(win: ^window) ---

	/**!
	* @brief restores the window from minimized state
	* @param win a pointer to the target window
	*/
	window_restore :: proc(win: ^window) ---

	/**!
	* @brief makes the window a floating window
	* @param win a pointer to the target window
	* @param floating TRUE to float, FALSE to disable
	*/
	window_setFloating :: proc(win: ^window, floating : bool) ---

	/**!
	* @brief sets the opacity level of the window
	* @param win a pointer to the target window
	* @param opacity the opacity level (0–255)
	*/
	window_setOpacity :: proc(win: ^window, opacity : u8) ---

	/**!
	* @brief toggles window borders / frame / decor
	* @param win a pointer to the target window
	* @param border TRUE for bordered, FALSE for borderless
	*/
	window_setBorder :: proc(win: ^window, border : bool) ---

	/**!
	* @brief checks if the window is borderless (has a border, frame or decor)
	* @param win a pointer to the target window
	* @return TRUE if borderless, FALSE otherwise
	*/
	window_borderless :: proc(win: ^window) -> bool ---

	/**!
	* @brief toggles drag-and-drop (DND) support for the window
	* @param win a pointer to the target window
	* @param allow TRUE to allow DND, FALSE to disable
	* @note windowAllowDND must still be passed when creating the window
	*/
	window_setDND :: proc(win: ^window, allow : bool) ---

	/**!
	* @brief checks if drag-and-drop (DND) is allowed
	* @param win a pointer to the target window
	* @return TRUE if DND is enabled, FALSE otherwise
	*/
	window_allowsDND :: proc(win: ^window) -> bool ---

	/**!
	* @brief toggles mouse passthrough for the window
	* @param win a pointer to the target window
	* @param passthrough TRUE to enable passthrough, FALSE to disable
	*/
	window_setMousePassthrough :: proc(win: ^window, passthrough : bool) ---

	/**!
	* @brief renames the window
	* @param win a pointer to the target window
	* @param name the new title string for the window
	*/
	window_setName :: proc(win: ^window, name : cstring) ---

	/**!
	* @brief sets the icon for the window and taskbar
	* @param win a pointer to the target window
	* @param data the image data
	* @param w the width of the icon
	* @param h the height of the icon
	* @param format the image format
	* @return TRUE if successful, FALSE otherwise
	*
	* NOTE: The image may be resized by default.
	*/
	window_setIcon :: proc(win: ^window, data: ^u8, w: i32, h: i32, format: format) -> bool  ---

	/**!
	* @brief sets the icon for the window and/or taskbar
	* @param win a pointer to the target window
	* @param data the image data
	* @param w the width of the icon
	* @param h the height of the icon
	* @param format the image format
	* @param type the target icon type (taskbar, window, or both)
	* @return TRUE if successful, FALSE otherwise
	*/
	window_setIconEx :: proc(win: ^window, data: ^u8, w: i32, h: i32, format: format, type: icon) -> bool  ---

	/**!
	* @brief sets the mouse icon for the window using a loaded mouse icon
	* @param win a pointer to the target window
	* @param mouse a pointer to the mouse struct containing the icon
	*/
	window_setMouse :: proc(win: ^window, mouse: rawptr) -> bool ---

	/**!
	* @brief Sets the mouse to a preloaded [by RGFW] standard system cursor.
	* @param win The target window.
	* @param mouse The standardmouse icon (see mouseIcon enum).
	* @return True if the standard cursor was successfully applied.
	*/
	window_setMouseStandard :: proc(win: ^window, icon : mouseIcon ) -> bool  ---

	/**!
	* @brief Sets the mouse to the default cursor icon.
	* @param win The target window.
	* @return True if the default cursor was successfully set.
	*/
	window_setMouseDefault :: proc(win: ^window) -> bool ---

	/**!
	* @brief set (enable or disable) raw mouse mode only for the select window
	* @param win The target window.
	* @param the boolean state of raw mouse mode
	*
	*/
	window_setRawMouseMode :: proc(win: ^window, state : bool) ---

	/**!
	* @brief lock/unlock the cursor.
	* @param win The target window.
	* @param the boolean state of the mouse's capture state
	*
	*/
	window_captureMouse :: proc(win: ^window, state : bool) ---

	/**!
	* @brief lock/unlock the cursor and enable raw mpuise mode.
	* @param win The target window.
	* @param the boolean state of raw mouse mode
	*
	*/
	window_captureRawMouse :: proc(win: ^window, state : bool) ---

	/**!
	* @brief Returns true if the mouse is using raw mouse mode
	* @param win The target window.
	* @return True if the mouse is using raw mouse input mode.
	*/
	window_isRawMouseMode :: proc(win: ^window) -> bool  ---


	/**!
	* @brief Returns true if the mouse is captured
	* @param win The target window.
	* @return True if the mouse is being captured.
	*/
	window_isCaptured :: proc(win: ^window) -> bool  ---

	/**!
	* @brief Hides the window from view.
	* @param win The target window.
	*/
	window_hide :: proc(win: ^window) ---

	/**!
	* @brief Shows the window if it was hidden.
	* @param win The target window.
	*/
	window_show :: proc(win: ^window) -> bool ---

	/**!
	* @breif request a window flash to get attention from the user
	* @param win the target window
	* @param request the flash operation requested
	*/
	window_flash :: proc(win: ^window, request: flashRequest) ---

	/**!
	* @brief Sets whether the window should close.
	* @param win The target window.
	* @param shouldClose True to signal the window should close, false to keep it open.
	*
	* This can override or trigger the `window_shouldClose` state by modifying window flags.
	*/
	window_setShouldClose :: proc(win: ^window, shouldClose: bool) ---

	/**!
	* @brief Retrieves the current global mouse position.
	* @param x [OUTPUT] Pointer to store the X position of the mouse on the screen.
	* @param y [OUTPUT] Pointer to store the Y position of the mouse on the screen.
	* @return True if the position was successfully retrieved.
	*/
	getGlobalMouse :: proc(x: ^i32, y: ^i32) -> bool  ---

	/**!
	* @brief Retrieves the mouse position relative to the window.
	* @param win The target window.
	* @param x [OUTPUT] Pointer to store the X position within the window.
	* @param y [OUTPUT] Pointer to store the Y position within the window.
	* @return True if the position was successfully retrieved.
	*/
	window_getMouse :: proc(win: ^window, x: ^i32, y: ^i32) -> bool  ---

	/**!
	* @brief Shows or hides the mouse cursor for the window.
	* @param win The target window.
	* @param show True to show the mouse, false to hide it.
	*/
	window_showMouse :: proc(win: ^window, show: bool) -> bool ---

	/**!
	* @brief Checks if the mouse is currently hidden in the window.
	* @param win The target window.
	* @return True if the mouse is hidden.
	*/
	window_isMouseHidden :: proc(win: ^window) -> bool ---

	/**!
	* @brief Moves the mouse to the specified position within the window.
	* @param win The target window.
	* @param x The new X position.
	* @param y The new Y position.
	*/
	window_moveMouse :: proc(win: ^window, x: i32, y: i32) ---

	/**!
	* @brief Checks if the window should close.
	* @param win The target window.
	* @return True if the window should close (for example, if ESC was pressed or a close event occurred).
	*/
	window_shouldClose :: proc(win: ^window) -> bool ---

	/**!
	* @brief Checks if the window is currently fullscreen.
	* @param win The target window.
	* @return True if the window is fullscreen.
	*/
	window_isFullscreen :: proc(win: ^window) -> bool ---

	/**!
	* @brief Checks if the window is currently hidden.
	* @param win The target window.
	* @return True if the window is hidden.
	*/
	window_isHidden :: proc(win: ^window) -> bool ---

	/**!
	* @brief Checks if the window is minimized.
	* @param win The target window.
	* @return True if the window is minimized.
	*/
	window_isMinimized :: proc(win: ^window) -> bool ---

	/**!
	* @brief Checks if the window is maximized.
	* @param win The target window.
	* @return True if the window is maximized.
	*/
	window_isMaximized :: proc(win: ^window) -> bool ---

	/**!
	* @brief Checks if the window is floating.
	* @param win The target window.
	* @return True if the window is floating.
	*/
	window_isFloating :: proc(win: ^window) -> bool ---
	/** @} */

	/** * @defgroup Monitor
	* @{ */

	/**!
	* @brief Scales the window to match its monitor’s resolution.
	* @param win The target window.
	*
	* This function is automatically called when the flag `scaleToMonitor`
	* is used during window creation.
	*/
	window_scaleToMonitor :: proc(win: ^window) ---

	/**!
	* @brief Retrieves the monitor structure associated with the window.
	* @param win The target window.
	* @return The monitor structure of the window.
	*/
	window_getMonitor :: proc(win: ^window) -> ^monitor ---

	/** @} */

	/** * @defgroup Clipboard
	* @{ */

	/**!
	* @brief Reads clipboard data.
	* @return A pointer to the clipboard data object or NULL on failure.
	*/
	readClipboard::proc() -> ^dataTransfer ---

	/**!
	* @brief Reads clipboard data into your object pointer using your provided buffer, or returns the required length if the buffer is NULL or bufferCapacity is 0.
	* @param buffer the buffer used to fill the output dataTransfer object's data
	* @param capacity the capacity/length of the buffer in bytes
	* @param data [OUTPUT] A pointer to the dataTransfer object that will receive the clipboard data. (cannot be NULL)
	* @return returns TRUE on success and FALSE on failure
	*/
	readClipboardPtr :: proc(buffer: ^u8, capacity: c.size_t, data: ^dataTransfer) -> bool ---

	/**!
	* @brief Writes data to the clipboard.
	* @param data The data to be written to the clipboard, including the length and type.
	* @param returns TRUE on success and FALSE on failure
	*/
	writeClipboard::proc(data: ^dataTransfer) -> bool ---
	/** @} */



	/** * @defgroup error handling
	* @{ */
	/**!
	* @brief Sets the callback function to handle debug messages from RGFW.
	* @param func The function pointer to be used as the debug callback.
	* @return The previously set debug callback function.
	*/
	setDebugCallback :: proc(func : debugFunc ) -> debugFunc ---

	/**!
	* @brief Sends a debug message manually through the currently set debug callback.
	* @param type The type of debug message being sent.
	* @param err The associated error code.
	* @param msg The debug message text.
	*/
	debugCallback :: proc(type : debugType , code : errorCode ,  msg : cstring) ---
	/** @} */

	/** * @defgroup graphics_API
	* @{ */

	/*! native rendering API functions */
	/* these are native opengl specific functions and will NOT work with EGL */

	/*!< make the window the current OpenGL drawing context

		NOTE:
		if you want to switch the graphics context's thread,
		you have to run window_makeCurrentContext_OpenGL(NULL) --- on the old thread
		then window_makeCurrentContext_OpenGL(valid_window) on the new thread
	*/

	/**!
	* @brief Sets the global OpenGL hints to the specified pointer.
	* @param hints A pointer to the glHints structure containing the desired OpenGL settings.
	*/
	setGlobalHints_OpenGL :: proc(hints : ^glHints) ---

	/**!
	* @brief Resets the global OpenGL hints to their default values.
	*/
	resetGlobalHints_OpenGL :: proc() ---

	/**!
	* @brief Gets the current global OpenGL hints pointer.
	* @return A pointer to the currently active glHints structure.
	*/
	getGlobalHints_OpenGL :: proc() -> ^glHints ---

	/**!
	* @brief Creates and allocates an OpenGL context for the specified window.
	* @param win A pointer to the target window.
	* @param hints A pointer to an glHints structure defining context creation parameters.
	* @return A pointer to the newly created glContext.
	*/
	window_createContext_OpenGL :: proc(win: ^window, hints : ^glHints) -> ^glContext ---

	/**!
	* @brief Creates an OpenGL context for the specified window using a preallocated context structure.
	* @param win A pointer to the target window.
	* @param ctx A pointer to an already allocated glContext structure.
	* @param hints A pointer to an glHints structure defining context creation parameters.
	* @return TRUE on success, FALSE on failure.
	*/
	window_createContextPtr_OpenGL :: proc(win: ^window, ctx : ^glContext, hints : ^glHints) -> bool ---

	/**!
	* @brief Retrieves the OpenGL context associated with a window.
	* @param win A pointer to the window.
	* @return A pointer to the associated glContext, or NULL if none exists or if the context is EGL-based.
	*/
	window_getContext_OpenGL :: proc(win: ^window) -> ^glContext ---

	/**!
	* @brief Deletes and frees the OpenGL context.
	* @param win A pointer to the window.
	* @param ctx A pointer to the glContext to delete.
	*
	* @note This is automatically called by window_close if the window’s context is not NULL.
	*/
	window_deleteContext_OpenGL :: proc(win: ^window, ctx : ^glContext) ---

	/**!
	* @brief Deletes the OpenGL context without freeing its memory.
	* @param win A pointer to the window.
	* @param ctx A pointer to the glContext to delete.
	*
	* @note This is automatically called by window_close if the window’s context is not NULL.
	*/
	window_deleteContextPtr_OpenGL :: proc(win: ^window, ctx : ^glContext) ---

	/**!
	* @brief Retrieves the native source context from an glContext.
	* @param ctx A pointer to the glContext.
	* @return A pointer to the native OpenGL context handle.
	*/
	glContext_getSourceContext :: proc(ctx : ^glContext) -> rawptr  ---

	/**!
	* @brief Makes the specified window the current OpenGL rendering target.
	* @param win A pointer to the window to make current.
	*
	* @note This is typically called internally by window_makeCurrent.
	*/
	window_makeCurrentWindow_OpenGL :: proc(win: ^window) ---

	/**!
	* @brief Makes the OpenGL context of the specified window current.
	* @param win A pointer to the window whose context should be made current.
	*
	* @note To move a context between threads, call window_makeCurrentContext_OpenGL(NULL)
	*       on the old thread before making it current on the new one.
	*/
	window_makeCurrentContext_OpenGL :: proc(win: ^window) ---

	/**!
	* @brief Swaps the OpenGL buffers for the specified window.
	* @param win A pointer to the window whose buffers should be swapped.
	*/
	window_swapBuffers_OpenGL :: proc(win: ^window) ---

	/**!
	* @brief Retrieves the current OpenGL context.
	* @return A pointer to the currently active OpenGL context (GLX, WGL, Cocoa, or WebGL backend).
	*/
	getCurrentContext_OpenGL :: proc() -> rawptr  ---

	/**!
	* @brief Retrieves the current OpenGL window.
	* @return A pointer to the window currently bound as the OpenGL context target.
	*/
	getCurrentWindow_OpenGL :: proc() -> ^window ---

	/**!
	* @brief Sets the OpenGL swap interval (vsync).
	* @param win A pointer to the window.
	* @param swapInterval The desired swap interval value (0 to disable vsync, 1 to enable).
	*/
	window_swapInterval_OpenGL :: proc(win: ^window, swapInterval : i32) ---

	/**!
	* @brief Retrieves the address of a native OpenGL procedure.
	* @param procname The name of the OpenGL function to look up.
	* @return A pointer to the function, or NULL if not found.
	*/
	getProcAddress_OpenGL :: proc(procname : cstring) -> rawptr  ---

	/**!
	* @brief Checks whether a specific OpenGL or OpenGL ES API extension is supported.
	* @param extension The name of the extension to check.
	* @param len The length of the extension string.
	* @return TRUE if supported, FALSE otherwise.
	*/
	extensionSupported_OpenGL :: proc(extension : ^u8, len : c.size_t) -> bool ---

	/**!
	* @brief Checks whether a specific platform-dependent OpenGL extension is supported.
	* @param extension The name of the extension to check.
	* @param len The length of the extension string.
	* @return TRUE if supported, FALSE otherwise.
	*/
	extensionSupportedPlatform_OpenGL :: proc(extension : ^u8, len : c.size_t) -> bool ---

	/* these are EGL specific functions, they may fallback to OpenGL */
	/**!
	 * @brief Creates and allocates an OpenGL/EGL context for the specified window.
	 * @param win A pointer to the target window.
	 * @param hints A pointer to an glHints structure defining context creation parameters.
	 * @return A pointer to the newly created eglContext.
	*/
	window_createContext_EGL :: proc(win : ^window, hints : ^glHints) -> ^eglContext ---

	/**!
	 * @brief Creates an OpenGL/EGL context for the specified window using a preallocated context structure.
	 * @param win A pointer to the target window.
	 * @param ctx A pointer to an already allocated eglContext structure.
	 * @param hints A pointer to an glHints structure defining context creation parameters.
	 * @return TRUE on success, FALSE on failure.
	*/
	window_createContextPtr_EGL :: proc(win : ^window, ctx : ^eglContext, hints : ^glHints) -> bool ---

	/**!
	 * @brief Frees and deletes an OpenGL/EGL context.
	 * @param win A pointer to the window.
	 * @param ctx A pointer to the eglContext to delete.
	 *
	 * @note Automatically called by window_close if RGFW owns the context.
	*/
	window_deleteContext_EGL :: proc(win : ^window, ctx : ^eglContext) ---

	/**!
	 * @brief Deletes an OpenGL/EGL context without freeing its memory.
	 * @param win A pointer to the window.
	 * @param ctx A pointer to the eglContext to delete.
	 *
	 * @note Automatically called by window_close if RGFW owns the context.
	*/
	window_deleteContextPtr_EGL :: proc(win : ^window, ctx : ^eglContext) ---

	/**!
	 * @brief Retrieves the OpenGL/EGL context associated with a window.
	 * @param win A pointer to the window.
	 * @return A pointer to the associated eglContext, or NULL if none exists or if the context is a native OpenGL context.
	*/
	window_getContext_EGL :: proc(win : ^window) -> ^eglContext ---

	/**!
	 * @brief Retrieves the EGL display handle.
	 * @return A pointer to the native EGLDisplay.
	*/
	getDisplay_EGL :: proc() -> rawptr ---

	/**!
	 * @brief Retrieves the native source context from an eglContext.
	 * @param ctx A pointer to the eglContext.
	 * @return A pointer to the native EGLContext handle.
	*/
	eglContext_getSourceContext :: proc(ctx : ^eglContext) -> rawptr ---

	/**!
	 * @brief Retrieves the EGL surface handle from an eglContext.
	 * @param ctx A pointer to the eglContext.
	 * @return A pointer to the EGLSurface associated with the context.
	*/
	eglContext_getSurface :: proc(ctx : ^eglContext) -> rawptr ---

	/**!
	 * @brief Retrieves the Wayland EGL window handle from an eglContext.
	 * @param ctx A pointer to the eglContext.
	 * @return A pointer to the wl_egl_window associated with the EGL context.
	*/
	eglContext_wlEGLWindow :: proc(ctx : ^eglContext) -> rawptr ---

	/**!
	 * @brief Swaps the EGL buffers for the specified window.
	 * @param win A pointer to the window whose buffers should be swapped.
	 *
	 * @note Typically called by window_swapInterval.
	*/
	window_swapBuffers_EGL :: proc(win : ^window) ---

	/**!
	 * @brief Makes the specified window the current EGL rendering target.
	 * @param win A pointer to the window to make current.
	 *
	 * @note This is typically called internally by window_makeCurrent.
	*/
	window_makeCurrentWindow_EGL :: proc(win : ^window) ---

	/**!
	 * @brief Makes the EGL context of the specified window current.
	 * @param win A pointer to the window whose context should be made current.
	 *
	 * @note To move a context between threads, call window_makeCurrentContext_EGL(NULL)
	 *       on the old thread before making it current on the new one.
	*/
	window_makeCurrentContext_EGL :: proc(win : ^window) ---

	/**!
	 * @brief Retrieves the current EGL context.
	 * @return A pointer to the currently active EGLContext.
	*/
	getCurrentContext_EGL :: proc() -> rawptr ---

	/**!
	 * @brief Retrieves the current EGL window.
	 * @return A pointer to the window currently bound as the EGL context target.
	*/
	getCurrentWindow_EGL :: proc() -> ^window ---

	/**!
	 * @brief Sets the EGL swap interval (vsync).
	 * @param win A pointer to the window.
	 * @param swapInterval The desired swap interval value (0 to disable vsync, 1 to enable).
	*/
	window_swapInterval_EGL :: proc(win : ^window, swapInterval : i32) ---

	/**!
	 * @brief Retrieves the address of a native OpenGL or OpenGL ES procedure in an EGL context.
	 * @param procname The name of the OpenGL function to look up.
	 * @return A pointer to the function, or NULL if not found.
	*/
	getProcAddress_EGL :: proc(procname : cstring) -> rawptr ---

	/**!
	 * @brief Checks whether a specific OpenGL or OpenGL ES API extension is supported in the current EGL context.
	 * @param extension The name of the extension to check.
	 * @param len The length of the extension string.
	 * @return TRUE if supported, FALSE otherwise.
	*/
	extensionSupported_EGL :: proc(extension : cstring, len : c.size_t) -> bool ---

	/**!
	 * @brief Checks whether a specific platform-dependent EGL extension is supported in the current context.
	 * @param extension The name of the extension to check.
	 * @param len The length of the extension string.
	 * @return TRUE if supported, FALSE otherwise.
	*/
	extensionSupportedPlatform_EGL :: proc(extension : cstring, len : c.size_t) -> bool ---

	/* if you don't want to use the above macros */

	/**!
	 * @brief Retrieves the Vulkan instance extensions required by RGFW.
	 * @param count [OUTPUT] A pointer that will receive the number of required extensions (typically 2).
	 * @return A pointer to a static array of required Vulkan instance extension names.
	*/
	getRequiredInstanceExtensions_Vulkan :: proc(count : c.size_t) -> []cstring ---

	/**!
	 * @brief Creates a Vulkan surface for the specified window.
	 * @param win A pointer to the window for which to create the Vulkan surface.
	 * @param instance The Vulkan instance used to create the surface.
	 * @param surface [OUTPUT] A pointer to a VkSurfaceKHR handle that will receive the created surface.
	 * @return A VkResult indicating success or failure.
	*/
	window_createSurface_Vulkan :: proc(win : ^window, instance : vulkan.Instance, surface : ^vulkan.SurfaceKHR) -> vulkan.Result ---

	/**!
	 * @brief Checks whether the specified Vulkan physical device and queue family support presentation for RGFW.
	 * @param instance The Vulkan instance.
	 * @param physicalDevice The Vulkan physical device to check.
	 * @param queueFamilyIndex The index of the queue family to query for presentation support.
	 * @return TRUE if presentation is supported, FALSE otherwise.
	*/
	getPhysicalDevicePresentationSupport_Vulkan :: proc(instance : vulkan.Instance, physicalDevice : vulkan.PhysicalDevice, queueFamilyIndex : u32) -> bool ---

	getInstanceProcAddress_Vulkan :: proc(instance : vulkan.Instance, procname : cstring) -> rawptr ---

	/** * @defgroup Supporting
	* @{ */

	/**!
	* @brief Sets the root (main) RGFW window.
	* @param win A pointer to the window to set as the root window.
	*/
	setRootWindow :: proc(win: ^window) ---

	/**!
	* @brief Retrieves the current root RGFW window.
	* @return A pointer to the current root window.
	*/
	getRootWindow :: proc() -> ^window ---

	/**!
	* @brief Pushes an event into the standard RGFW event queue.
	* @param event A pointer to the event to be added to the queue.
	*/
	eventQueuePush :: proc(event: ^event) ---

	/**!
	* @brief Pushes an event into the standard RGFW event queue and call the callback.
	* @param event A pointer to the event to be added to the queue.
	*/
	eventQueuePushAndCall :: proc(event: ^event) ---

	/**!
	* @brief Clears all events from the RGFW event queue without processing them.
	*/
	eventQueueFlush :: proc() ---

	/**!
	* @brief Pops the next event from the RGFW event queue.
	* @return A pointer to the popped event, or NULL if the queue is empty.
	*/
	eventQueuePop :: proc() -> ^event ---

	/**!
	* @brief Pops the next event from the RGFW event queue that matches the target window, pushes back events that don't matchj.
	* @param win A pointer to the target window.
	* @return A pointer to the popped event, or NULL if the queue is empty.
	*/
	window_eventQueuePop :: proc(win: ^window) -> ^event ---

	/**!
	* @brief Converts an API keycode to the RGFW unmapped (physical) key.
	* @param keycode The platform-specific keycode.
	* @return The corresponding RGFW keycode.
	*/
	apiKeyToRGFW :: proc(keycode : u32) -> key  ---

	/**!
	* @brief Converts an RGFW keycode to the unmapped (physical) API key.
	* @param keycode The RGFW keycode.
	* @return The corresponding platform-specific keycode.
	*/
	rgfwToApiKey :: proc(keycode : key) -> u32  ---

	/**!
	* @brief Converts an physical RGFW keycode to a mapped RGFW keycode.
	* @param keycode the physical RGFW keycode.
	* @return The corresponding mapped RGFW keycode.
	*/
	physicalToMappedKey :: proc(keycode : key) -> key  ---

	/**!
	* @brief Retrieves the size of the info structure.
	* @return The size (in bytes) of info.
	*/
	sizeofInfo :: proc() -> c.size_t ---

	/**!
	* @brief Initializes the RGFW library internally.
	* @return 0 on success, a negative number error error on failure.
	* @note This is automatically called when the first window is created.
	*/
	init :: proc(class_name : cstring, flags : initFlags) -> i32  ---

	/**!
	* @brief Deinitializes the current instance of the RGFW library.
	* @note This is automatically called when the last open window is closed.
	*/
	deinit :: proc() ---

	/**!
	* @brief Initializes RGFW using a user-provided info structure.
	* @param info A pointer to an info structure to be used for initialization.
	* @return  0 on success, a negative number error error on failure and a positive number for a warning.
	*/
	init_ptr :: proc(class_name : cstring, flags : initFlags, info : ^info) -> i32 ---

	/**!
	* @brief Deinitializes a specific RGFW instance stored in the provided info pointer.
	* @param info A pointer to the info structure representing the instance to deinitialize.
	*/
	deinit_ptr :: proc(info : ^info) ---

	/**!
	* @brief Sets the global info structure pointer.
	* @param info A pointer to the info structure to set.
	*/
	setInfo :: proc(info : ^info) ---

	/**!
	* @brief Retrieves the global info structure pointer.
	* @return A pointer to the current info structure.
	*/
	getInfo :: proc() -> ^info ---
}

setProcAddress_OpenGL :: proc(p: rawptr, name: cstring) {
	(^rawptr)(p)^ = getProcAddress_OpenGL(name)
}

setProcAddress_EGL :: proc(p: rawptr, name: cstring) {
	(^rawptr)(p)^ = getProcAddress_EGL(name)
}

setInstanceProcAddress_Vulkan :: proc(p: rawptr, instance : vulkan.Instance, name: cstring) {
	(^rawptr)(p)^ = getInstanceProcAddress_Vulkan(instance, name)
}
