#include "fast_forward_overlay.h"

#include <algorithm>
#include <array>
#include <string>
#include <vector>

namespace FastForward {
namespace {
template<typename T> struct LocalCom {
    T* ptr = nullptr;
    ~LocalCom() { if (ptr) ptr->Release(); }
    LocalCom() = default;
    LocalCom(const LocalCom&) = delete;
    LocalCom& operator=(const LocalCom&) = delete;
};

struct Vertex {
    float x, y, z, rhw;
    D3DCOLOR color;
};

// A tiny built-in 5x7 font for "FAST FORWARD 2X/4X/8X/16X". Colored geometry
// avoids D3DX/font DLL dependencies and lost-device texture management.
std::array<unsigned char, 7> Glyph(char c) {
    switch (c) {
    case 'A': return {14, 17, 17, 31, 17, 17, 17};
    case 'D': return {30, 17, 17, 17, 17, 17, 30};
    case 'F': return {31, 16, 16, 30, 16, 16, 16};
    case 'O': return {14, 17, 17, 17, 17, 17, 14};
    case 'R': return {30, 17, 17, 30, 20, 18, 17};
    case 'S': return {15, 16, 16, 14, 1, 1, 30};
    case 'T': return {31, 4, 4, 4, 4, 4, 4};
    case 'W': return {17, 17, 17, 21, 21, 21, 10};
    case 'X': return {17, 17, 10, 4, 10, 17, 17};
    case '1': return {4, 12, 4, 4, 4, 4, 14};
    case '2': return {14, 17, 1, 2, 4, 8, 31};
    case '4': return {2, 6, 10, 18, 31, 2, 2};
    case '6': return {14, 16, 16, 30, 17, 17, 14};
    case '8': return {14, 17, 17, 14, 17, 17, 14};
    default: return {};
    }
}

void Quad(std::vector<Vertex>& vertices, float x, float y, float w, float h,
          D3DCOLOR color) {
    x -= 0.5f; // D3D9 pre-transformed pixel centers.
    y -= 0.5f;
    vertices.insert(vertices.end(), {
        {x, y, 0, 1, color}, {x + w, y, 0, 1, color}, {x, y + h, 0, 1, color},
        {x, y + h, 0, 1, color}, {x + w, y, 0, 1, color}, {x + w, y + h, 0, 1, color}
    });
}

std::vector<Vertex> Label(UINT width, UINT height, unsigned speed) {
    const std::string text = "FAST FORWARD " + std::to_string(speed) + "X";
    const size_t length = text.size();
    // Scale with resolution, fitting the complete label even in a small window.
    const float scale = std::max(1.0f, std::min(6.0f,
        std::min(height / 360.0f, width / static_cast<float>(length * 6 + 20))));
    const float margin = 6 * scale;
    const float padding = 4 * scale;
    const float labelWidth = (length * 6 - 1) * scale + padding * 2;
    const float left = std::max(0.0f, width - margin - labelWidth);
    const float x = left + padding;
    const float y = margin + padding;
    std::vector<Vertex> vertices;
    vertices.reserve(2048);
    Quad(vertices, left, margin, labelWidth,
         7 * scale + padding * 2, D3DCOLOR_ARGB(200, 12, 16, 24));
    for (size_t i = 0; i < length; ++i) {
        const auto rows = Glyph(text[i]);
        for (unsigned row = 0; row < 7; ++row)
            for (unsigned col = 0; col < 5; ++col)
                if (rows[row] & (1u << (4 - col)))
                    Quad(vertices, x + (i * 6 + col) * scale, y + row * scale,
                         scale, scale, D3DCOLOR_XRGB(255, 224, 128));
    }
    return vertices;
}
} // namespace

HRESULT DrawOverlay(IDirect3DDevice9* device, unsigned speed) {
    if (speed != 2 && speed != 4 && speed != 8 && speed != 16) return S_FALSE;
    if (!device) return D3DERR_INVALIDCALL;

    LocalCom<IDirect3DSurface9> backbuffer;
    HRESULT result = device->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, &backbuffer.ptr);
    if (FAILED(result)) return result;
    D3DSURFACE_DESC desc{};
    if (FAILED(result = backbuffer.ptr->GetDesc(&desc))) return result;

    LocalCom<IDirect3DStateBlock9> state;
    if (FAILED(result = device->CreateStateBlock(D3DSBT_ALL, &state.ptr))) return result;
    if (FAILED(result = state.ptr->Capture())) return result;
    D3DCAPS9 caps{};
    if (FAILED(result = device->GetDeviceCaps(&caps))) return result;
    const DWORD targetCount = std::min<DWORD>(caps.NumSimultaneousRTs, 4);
    std::array<LocalCom<IDirect3DSurface9>, 4> targets;
    for (DWORD i = 0; i < targetCount; ++i) {
        result = device->GetRenderTarget(i, &targets[i].ptr);
        if (FAILED(result) && result != D3DERR_NOTFOUND) return result;
    }
    LocalCom<IDirect3DSurface9> depth;
    result = device->GetDepthStencilSurface(&depth.ptr);
    if (FAILED(result) && result != D3DERR_NOTFOUND) return result;
    const auto vertices = Label(desc.Width, desc.Height, speed);
    if (FAILED(result = device->BeginScene())) return result;

    // Render targets/depth are not captured by D3DSBT_ALL. Explicitly save and
    // restore them, including MRTs left bound by post-processing.
    device->SetDepthStencilSurface(nullptr);
    for (DWORD i = 1; i < targetCount; ++i) device->SetRenderTarget(i, nullptr);
    result = device->SetRenderTarget(0, backbuffer.ptr);
    if (SUCCEEDED(result)) {
        const D3DVIEWPORT9 viewport{0, 0, desc.Width, desc.Height, 0.0f, 1.0f};
        device->SetViewport(&viewport);
        device->SetVertexShader(nullptr);
        device->SetPixelShader(nullptr);
        device->SetFVF(D3DFVF_XYZRHW | D3DFVF_DIFFUSE);
        device->SetStreamSourceFreq(0, 1);
        device->SetTexture(0, nullptr);
        device->SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
        device->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
        device->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
        device->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
        device->SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
        device->SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
        const std::pair<D3DRENDERSTATETYPE, DWORD> settings[] = {
            {D3DRS_ZENABLE, FALSE}, {D3DRS_ZWRITEENABLE, FALSE},
            {D3DRS_STENCILENABLE, FALSE}, {D3DRS_ALPHATESTENABLE, FALSE},
            {D3DRS_LIGHTING, FALSE}, {D3DRS_FOGENABLE, FALSE},
            {D3DRS_CULLMODE, D3DCULL_NONE}, {D3DRS_FILLMODE, D3DFILL_SOLID},
            {D3DRS_SHADEMODE, D3DSHADE_GOURAUD}, {D3DRS_SCISSORTESTENABLE, FALSE},
            {D3DRS_CLIPPLANEENABLE, 0}, {D3DRS_ALPHABLENDENABLE, TRUE},
            {D3DRS_BLENDOP, D3DBLENDOP_ADD}, {D3DRS_SRCBLEND, D3DBLEND_SRCALPHA},
            {D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA},
            {D3DRS_SEPARATEALPHABLENDENABLE, FALSE}, {D3DRS_COLORWRITEENABLE, 15},
            {D3DRS_SRGBWRITEENABLE, FALSE}, {D3DRS_MULTISAMPLEMASK, 0xffffffff}
        };
        for (const auto& setting : settings) device->SetRenderState(setting.first, setting.second);
        result = device->DrawPrimitiveUP(D3DPT_TRIANGLELIST,
            static_cast<UINT>(vertices.size() / 3), vertices.data(), sizeof(Vertex));
    }
    const HRESULT endResult = device->EndScene();
    if (SUCCEEDED(result)) result = endResult;
    for (DWORD i = 0; i < targetCount; ++i) device->SetRenderTarget(i, targets[i].ptr);
    device->SetDepthStencilSurface(depth.ptr);
    // Apply last: restoring render target 0 changes the viewport automatically.
    const HRESULT restoreResult = state.ptr->Apply();
    return FAILED(result) ? result : restoreResult;
}
} // namespace FastForward
