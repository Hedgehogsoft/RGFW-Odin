package rgfw_dx11_example

import "base:runtime"
import "core:fmt"
import "core:sys/windows"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import d3d "vendor:directx/d3d_compiler"

import rgfw "../../"


directXinfo :: struct {
	pFactory: ^dxgi.IFactory,
	pAdapter: ^dxgi.IAdapter,
	pDevice:  ^d3d11.IDevice,
	pDeviceContext: ^d3d11.IDeviceContext,

    swapchain: ^dxgi.ISwapChain,
    renderTargetView: ^d3d11.IRenderTargetView,
    pDepthStencilView: ^d3d11.IDepthStencilView,
}

shaderString := `
struct VOut
{
    float4 position : SV_POSITION;
};

VOut VS(float3 position : POSITION)
{
    VOut output;
    output.position = float4(position, 1.0);

    return output;
}


float4 PS(VOut input) : SV_TARGET
{
    float z = (input.position.y * 0.095) +  (input.position.x  *  0.09);

    return float4(input.position.y / 255, input.position.x / 255, z / 255, 1.0);
}
`

main :: proc() {
    rgfw.init("RGFW Example", {})
    defer rgfw.deinit()

    win := rgfw.createWindow("name", 0, 0, 500, 500, {.Center})
    defer rgfw.window_close(win)
    rgfw.window_setExitKey(win, .Escape)

    dxInfo: directXinfo
    if (directXInit(win, &dxInfo) == false) {
        fmt.printf("failed to create a directX context\n")
        return
    }

    dxInfo.pDeviceContext->OMSetRenderTargets(1, &dxInfo.renderTargetView, nil)
    
    w, h: i32
    rgfw.window_getSizeInPixels(win, &w, &h)

    // Set viewport
    viewport: d3d11.VIEWPORT
    viewport.TopLeftX = 0
    viewport.TopLeftY = 0
    viewport.Width = f32(w)
    viewport.Height = f32(h)
    viewport.MinDepth = 0.0
    viewport.MaxDepth = 1.0
    dxInfo.pDeviceContext->RSSetViewports(1, &viewport)

    vertices := [?]f32 {
        +0.0, +0.5, 0.0,
        +0.5, -0.5, 0.0,
        -0.5, -0.5, 0.0
    }

    pVertexBuffer: ^d3d11.IBuffer
    bd: d3d11.BUFFER_DESC
    bd.Usage = .DYNAMIC
    bd.ByteWidth = size_of(vertices)
    bd.BindFlags = {.VERTEX_BUFFER}
    bd.CPUAccessFlags = {.WRITE}
    dxInfo.pDevice->CreateBuffer(&bd, nil, &pVertexBuffer)

    // Copy vertex data into vertex buffer
    ms: d3d11.MAPPED_SUBRESOURCE
    dxInfo.pDeviceContext->Map((^d3d11.IResource)(pVertexBuffer), 0, .WRITE_DISCARD, {}, &ms)
    runtime.mem_copy(ms.pData, &vertices, size_of(vertices))
    dxInfo.pDeviceContext->Unmap((^d3d11.IResource)(pVertexBuffer), 0)

    // Compile shaders
    pVertexShaderBlob: ^d3d.ID3DBlob
    pPixelShaderBlob: ^d3d.ID3DBlob
    pErrorBlob: ^d3d.ID3DBlob

    d3d.Compile(raw_data(shaderString), len(shaderString), nil, nil, nil, "VS", "vs_5_0", 0, 0, &pVertexShaderBlob, &pErrorBlob)
    d3d.Compile(raw_data(shaderString), len(shaderString), nil, nil, nil, "PS", "ps_5_0", 0, 0, &pPixelShaderBlob, &pErrorBlob)

    // Create shaders
    pVertexShader: ^d3d11.IVertexShader
    pPixelShader: ^d3d11.IPixelShader
    dxInfo.pDevice->CreateVertexShader(pVertexShaderBlob->GetBufferPointer(), pVertexShaderBlob->GetBufferSize(), nil, &pVertexShader)
    dxInfo.pDevice->CreatePixelShader(pPixelShaderBlob->GetBufferPointer(), pPixelShaderBlob->GetBufferSize(), nil, &pPixelShader)

    dxInfo.pDeviceContext->VSSetShader(pVertexShader, nil, 0)
    dxInfo.pDeviceContext->PSSetShader(pPixelShader, nil, 0)

    // Set input layout
    pInputLayout: ^d3d11.IInputLayout
    layout := [?]d3d11.INPUT_ELEMENT_DESC {
        {"POSITION", 0, .R32G32B32_FLOAT, 0, 0, .VERTEX_DATA, 0},
    }

    dxInfo.pDevice->CreateInputLayout(raw_data(&layout), 1, pVertexShaderBlob->GetBufferPointer(), pVertexShaderBlob->GetBufferSize(), &pInputLayout)
    dxInfo.pDeviceContext->IASetInputLayout(pInputLayout)

    for {
        rgfw.pollEvents()

        if rgfw.window_shouldClose(win) {
            break
        }

        clearColor := [4]f32{ 0.1, 0.1, 0.1, 1.0 }
        dxInfo.pDeviceContext->ClearRenderTargetView(dxInfo.renderTargetView, &clearColor)

        stride: u32 = size_of(f32) * 3
        offset: u32 = 0
        dxInfo.pDeviceContext->IASetVertexBuffers(0, 1, &pVertexBuffer, &stride, &offset)

        dxInfo.pDeviceContext->IASetPrimitiveTopology(.TRIANGLELIST)

        dxInfo.pDeviceContext->IASetInputLayout(pInputLayout)

        dxInfo.pDeviceContext->VSSetShader(pVertexShader, nil, 0)
        dxInfo.pDeviceContext->PSSetShader(pPixelShader, nil, 0)
        dxInfo.pDeviceContext->Draw(3, 0)

        dxInfo.swapchain->Present(0, {})
    }

    directXClose(win, &dxInfo)

    rgfw.window_close(win)
}

directXInit :: proc(win: ^rgfw.window, info: ^directXinfo) -> bool {
    w, h: i32
    rgfw.window_getSizeInPixels(win, &w, &h)

    assert(windows.SUCCEEDED(dxgi.CreateDXGIFactory(dxgi.IFactory_UUID, (^rawptr)(&info.pFactory))))

	if (windows.FAILED(info.pFactory->EnumAdapters(0, &info.pAdapter))) {
		fmt.eprintf("Failed to enumerate DXGI adapters\n")
		info.pFactory->Release()
		return false
	}

	featureLevels := [?]d3d11.FEATURE_LEVEL { ._11_0 }

	if (windows.FAILED(d3d11.CreateDevice(info.pAdapter, .UNKNOWN, nil, {}, raw_data(&featureLevels), 1, d3d11.SDK_VERSION, &info.pDevice, nil, &info.pDeviceContext))) {
		fmt.eprintf("Failed to create Direct3D device\n")
		info.pAdapter->Release()
		info.pFactory->Release()
		return false
	}

	rgfw.window_createSwapChain_DirectX(win, info.pFactory, (^windows.IUnknown)(info.pDevice), &info.swapchain)

	pBackBuffer: ^d3d11.ITexture2D
	info.swapchain->GetBuffer(0, d3d11.ITexture2D_UUID, (^windows.LPVOID)(&pBackBuffer))
	info.pDevice->CreateRenderTargetView((^d3d11.IResource)(pBackBuffer), nil, &info.renderTargetView)
	pBackBuffer->Release()

	depthStencilDesc: d3d11.TEXTURE2D_DESC
	depthStencilDesc.Width = u32(w)
	depthStencilDesc.Height = u32(h)
	depthStencilDesc.MipLevels = 1
	depthStencilDesc.ArraySize = 1
	depthStencilDesc.Format = .D24_UNORM_S8_UINT
	depthStencilDesc.SampleDesc.Count = 1
	depthStencilDesc.SampleDesc.Quality = 0
	depthStencilDesc.Usage = .DEFAULT
	depthStencilDesc.BindFlags = {.DEPTH_STENCIL}

	pDepthStencilTexture: ^d3d11.ITexture2D
	info.pDevice->CreateTexture2D(&depthStencilDesc, nil, &pDepthStencilTexture)

	depthStencilViewDesc: d3d11.DEPTH_STENCIL_VIEW_DESC
	depthStencilViewDesc.Format = depthStencilDesc.Format
	depthStencilViewDesc.ViewDimension = .TEXTURE2D
	depthStencilViewDesc.Texture2D.MipSlice = 0

	info.pDevice->CreateDepthStencilView((^d3d11.IResource)(pDepthStencilTexture), &depthStencilViewDesc, &info.pDepthStencilView)

	pDepthStencilTexture->Release()

	info.pDeviceContext->OMSetRenderTargets(1, &info.renderTargetView, info.pDepthStencilView)

	return true
}

directXClose :: proc(win: ^rgfw.window, dxInfo: ^directXinfo) {
    dxInfo.swapchain->Release()
    dxInfo.renderTargetView->Release()
    dxInfo.pDepthStencilView->Release()

    dxInfo.pDeviceContext->Release()
    dxInfo.pDevice->Release()
    dxInfo.pAdapter->Release()
    dxInfo.pFactory->Release()
}
