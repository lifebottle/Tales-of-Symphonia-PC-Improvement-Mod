#include "fast_forward_overlay.h"

#include <cassert>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <string>

// Run under Windows or Wine with a display. Uses the system D3D9Ex runtime,
// not our proxy, and reads actual rendered pixels back from its backbuffer.
int main() {
    wchar_t system[MAX_PATH]{};
    GetSystemDirectoryW(system, MAX_PATH);
    const std::wstring path = std::wstring(system) + L"\\d3d9.dll";
    HMODULE module = LoadLibraryW(path.c_str());
    assert(module);
    using Create9Ex = HRESULT (WINAPI*)(UINT, IDirect3D9Ex**);
    const auto proc = GetProcAddress(module, "Direct3DCreate9Ex");
    Create9Ex create = nullptr;
    static_assert(sizeof(create) == sizeof(proc));
    std::memcpy(&create, &proc, sizeof(create));
    assert(create);
    IDirect3D9Ex* d3d = nullptr;
    assert(SUCCEEDED(create(D3D_SDK_VERSION, &d3d)));
    HWND window = CreateWindowW(L"STATIC", L"Fast-forward overlay test",
        WS_OVERLAPPEDWINDOW, 0, 0, 640, 360, nullptr, nullptr, GetModuleHandleW(nullptr), nullptr);
    assert(window);
    D3DPRESENT_PARAMETERS params{};
    params.BackBufferWidth = 640;
    params.BackBufferHeight = 360;
    params.BackBufferFormat = D3DFMT_X8R8G8B8;
    params.BackBufferCount = 1;
    params.SwapEffect = D3DSWAPEFFECT_DISCARD;
    params.hDeviceWindow = window;
    params.Windowed = TRUE;
    params.PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE;
    IDirect3DDevice9Ex* device = nullptr;
    assert(SUCCEEDED(d3d->CreateDeviceEx(0, D3DDEVTYPE_HAL, window,
        D3DCREATE_SOFTWARE_VERTEXPROCESSING, &params, nullptr, &device)));

    for (unsigned speed : {1u, 2u, 4u, 8u, 16u, 1u}) {
        IDirect3DSurface9* back = nullptr;
        assert(SUCCEEDED(device->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, &back)));
        assert(SUCCEEDED(device->SetRenderTarget(0, back)));
        constexpr D3DCOLOR background = D3DCOLOR_XRGB(32, 64, 96);
        assert(SUCCEEDED(device->Clear(0, nullptr, D3DCLEAR_TARGET, background, 1, 0)));

        // Leave an offscreen target and unusual draw state bound, as a game
        // post-processing pass may. The overlay must use the backbuffer and
        // restore the target, viewport, shader inputs and render states.
        IDirect3DSurface9* offscreen = nullptr;
        assert(SUCCEEDED(device->CreateRenderTarget(128, 128, D3DFMT_X8R8G8B8,
            D3DMULTISAMPLE_NONE, 0, FALSE, &offscreen, nullptr)));
        assert(SUCCEEDED(device->SetRenderTarget(0, offscreen)));
        const D3DVIEWPORT9 viewport{3, 5, 100, 100, 0.2f, 0.8f};
        assert(SUCCEEDED(device->SetViewport(&viewport)));
        assert(SUCCEEDED(device->SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME)));
        assert(SUCCEEDED(device->SetRenderState(D3DRS_COLORWRITEENABLE, D3DCOLORWRITEENABLE_RED)));
        assert(SUCCEEDED(device->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE)));
        assert(SUCCEEDED(device->SetRenderState(D3DRS_SCISSORTESTENABLE, TRUE)));
        assert(SUCCEEDED(device->SetFVF(D3DFVF_XYZ | D3DFVF_TEX1)));
        IDirect3DVertexBuffer9* buffer = nullptr;
        assert(SUCCEEDED(device->CreateVertexBuffer(256, 0, 0, D3DPOOL_DEFAULT, &buffer, nullptr)));
        assert(SUCCEEDED(device->SetStreamSource(0, buffer, 0, 20)));

        assert(FastForward::DrawOverlay(device, speed) == (speed == 1 ? S_FALSE : S_OK));
        IDirect3DSurface9* restored = nullptr;
        assert(SUCCEEDED(device->GetRenderTarget(0, &restored)));
        assert(restored == offscreen);
        restored->Release();
        D3DVIEWPORT9 after{};
        assert(SUCCEEDED(device->GetViewport(&after)));
        assert(std::memcmp(&viewport, &after, sizeof(viewport)) == 0);
        DWORD value = 0;
        device->GetRenderState(D3DRS_FILLMODE, &value);
        assert(value == D3DFILL_WIREFRAME);
        device->GetRenderState(D3DRS_COLORWRITEENABLE, &value);
        assert(value == D3DCOLORWRITEENABLE_RED);
        device->GetRenderState(D3DRS_SCISSORTESTENABLE, &value);
        assert(value == TRUE);
        device->GetRenderState(D3DRS_ALPHABLENDENABLE, &value);
        assert(value == FALSE);
        device->GetFVF(&value);
        assert(value == (D3DFVF_XYZ | D3DFVF_TEX1));
        IDirect3DVertexBuffer9* restoredBuffer = nullptr;
        UINT offset = 0, stride = 0;
        device->GetStreamSource(0, &restoredBuffer, &offset, &stride);
        assert(restoredBuffer == buffer && offset == 0 && stride == 20);
        restoredBuffer->Release();

        IDirect3DSurface9* pixels = nullptr;
        assert(SUCCEEDED(device->CreateOffscreenPlainSurface(640, 360, D3DFMT_X8R8G8B8,
            D3DPOOL_SYSTEMMEM, &pixels, nullptr)));
        assert(SUCCEEDED(device->GetRenderTargetData(back, pixels)));
        D3DLOCKED_RECT locked{};
        assert(SUCCEEDED(pixels->LockRect(&locked, nullptr, D3DLOCK_READONLY)));
        unsigned changed = 0, text = 0;
        for (unsigned y = 0; y < 360; ++y) {
            const auto* row = reinterpret_cast<const DWORD*>(
                static_cast<const char*>(locked.pBits) + y * locked.Pitch);
            for (unsigned x = 0; x < 640; ++x) {
                const DWORD rgb = row[x] & 0xffffff;
                if (rgb != (background & 0xffffff)) {
                    ++changed;
                    assert(x >= (speed == 16 ? 531u : 537u) && x < 634 && y >= 6 && y < 21);
                }
                if (rgb == 0xffe080) ++text;
            }
        }
        assert(speed == 1 ? changed == 0 : changed > 500 && text > 100);
        if (speed > 1) {
            char filename[64];
            std::snprintf(filename, sizeof(filename), "fast-forward-%ux.bmp", speed);
            FILE* file = std::fopen(filename, "wb");
            assert(file);
            BITMAPFILEHEADER header{};
            BITMAPINFOHEADER bitmap{};
            header.bfType = 0x4d42;
            header.bfOffBits = sizeof(header) + sizeof(bitmap);
            header.bfSize = header.bfOffBits + 640 * 360 * 4;
            bitmap.biSize = sizeof(bitmap);
            bitmap.biWidth = 640;
            bitmap.biHeight = -360;
            bitmap.biPlanes = 1;
            bitmap.biBitCount = 32;
            std::fwrite(&header, sizeof(header), 1, file);
            std::fwrite(&bitmap, sizeof(bitmap), 1, file);
            for (unsigned y = 0; y < 360; ++y)
                std::fwrite(static_cast<const char*>(locked.pBits) + y * locked.Pitch, 640 * 4, 1, file);
            std::fclose(file);
        }
        pixels->UnlockRect();
        pixels->Release();
        device->SetRenderTarget(0, back);
        device->SetStreamSource(0, nullptr, 0, 0);
        buffer->Release();
        offscreen->Release();
        back->Release();
        // No persistent overlay resources should prevent reset or require
        // recreation before the next speed label is drawn.
        assert(SUCCEEDED(device->ResetEx(&params, nullptr)));
    }
    device->Release();
    d3d->Release();
    DestroyWindow(window);
    FreeLibrary(module);
    std::cout << "D3D9Ex overlay pixels, state restoration, and reset tests passed\n";
}
