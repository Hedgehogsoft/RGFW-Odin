#+build windows

package RGFW

import "vendor:directx/dxgi"

@(default_calling_convention="c", link_prefix="RGFW_")
foreign {
	window_createSwapChain_DirectX :: proc(win : ^window, pFactory : ^dxgi.IFactory, pDevice : ^dxgi.IUnknown, swapchain : ^^dxgi.ISwapChain) -> i32 ---
}
