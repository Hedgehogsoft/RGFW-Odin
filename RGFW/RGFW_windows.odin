package RGFW
import winapi "core:sys/windows"

window_src :: struct {
    window : winapi.HWND, /*!< source window */
    hdc : winapi.HDC, /*!< source HDC */
    hOffset : u32, /*!< height offset for window */
    ctx : winapi.HGLRC, /*!< source graphics context */
    hdcMem  : winapi.HDC,
    bitmap : winapi.HBITMAP,
    maxSize : area, 
    minSize : area /* for setting max/min resize (RGFW_WINDOWS) */
}