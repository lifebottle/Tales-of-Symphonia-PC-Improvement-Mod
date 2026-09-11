/*
 * D3D9 Texture Replacement Proxy - IDirect3DDevice9 Wrapper Implementation
 *
 * Most methods are pure passthrough. The key interception points are:
 *   - CreateTexture: we hook this to track textures, but actual replacement
 *     happens via D3DXCreateTextureFromFileInMemoryEx interception in dllmain.
 *   - SetTexture: swap original textures with their replacements at bind time.
 *   - Reset: clear the texture replacement cache.
 */

#include "device_proxy.h"
#include "d3d9_proxy.h"
#include "texture_manager.h"
#include "d3dx9_hook.h"
#include "crc32.h"
#include "logger.h"


Direct3DDevice9Proxy::Direct3DDevice9Proxy(IDirect3DDevice9* pOriginal, IDirect3D9* pD3D9Proxy)
    : m_pOriginal(pOriginal)
    , m_pD3D9Proxy(pD3D9Proxy)
    , m_refCount(1) {
    LOG("[Device] Proxy IDirect3DDevice9 created");

    // Install IAT hooks for D3DX texture creation so we can hash
    // the source DDS blob the same way TSFix does.
    D3DXHook::Install();
}

Direct3DDevice9Proxy::~Direct3DDevice9Proxy() {
    // Release all cached replacement textures
    std::lock_guard<std::mutex> lock(m_texMutex);
    for (auto& pair : m_textureReplacements) {
        if (pair.second)
            pair.second->Release();
    }
    m_textureReplacements.clear();
    LOG("[Device] Proxy IDirect3DDevice9 destroyed");
}

void Direct3DDevice9Proxy::TrackTexture(IDirect3DTexture9* pOriginal, uint32_t crc32, IDirect3DTexture9* pReplacement) {
    std::lock_guard<std::mutex> lock(m_texMutex);
    if (pReplacement) {
        m_textureReplacements[pOriginal] = pReplacement;
        LOG("[Device] Tracking replacement for texture CRC32=%08X (orig=%p, repl=%p)",
            crc32, pOriginal, pReplacement);
    }
}

// IUnknown
HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::QueryInterface(REFIID riid, void** ppvObj) {
    HRESULT hr = m_pOriginal->QueryInterface(riid, ppvObj);
    if (SUCCEEDED(hr))
        *ppvObj = this;
    return hr;
}

ULONG STDMETHODCALLTYPE Direct3DDevice9Proxy::AddRef() {
    m_pOriginal->AddRef();
    return ++m_refCount;
}

ULONG STDMETHODCALLTYPE Direct3DDevice9Proxy::Release() {
    ULONG ref = --m_refCount;
    if (ref == 0) {
        m_pOriginal->Release();
        delete this;
    } else {
        m_pOriginal->Release();
    }
    return ref;
}

// === All passthrough methods ===

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::TestCooperativeLevel() {
    return m_pOriginal->TestCooperativeLevel();
}

UINT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetAvailableTextureMem() {
    return m_pOriginal->GetAvailableTextureMem();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::EvictManagedResources() {
    return m_pOriginal->EvictManagedResources();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetDirect3D(IDirect3D9** ppD3D9) {
    if (ppD3D9) {
        *ppD3D9 = m_pD3D9Proxy;
        m_pD3D9Proxy->AddRef();
        return D3D_OK;
    }
    return D3DERR_INVALIDCALL;
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetDeviceCaps(D3DCAPS9* pCaps) {
    return m_pOriginal->GetDeviceCaps(pCaps);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetDisplayMode(UINT iSwapChain, D3DDISPLAYMODE* pMode) {
    return m_pOriginal->GetDisplayMode(iSwapChain, pMode);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetCreationParameters(D3DDEVICE_CREATION_PARAMETERS* pParameters) {
    return m_pOriginal->GetCreationParameters(pParameters);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetCursorProperties(UINT XHotSpot, UINT YHotSpot, IDirect3DSurface9* pCursorBitmap) {
    return m_pOriginal->SetCursorProperties(XHotSpot, YHotSpot, pCursorBitmap);
}

void STDMETHODCALLTYPE Direct3DDevice9Proxy::SetCursorPosition(int X, int Y, DWORD Flags) {
    m_pOriginal->SetCursorPosition(X, Y, Flags);
}

BOOL STDMETHODCALLTYPE Direct3DDevice9Proxy::ShowCursor(BOOL bShow) {
    return m_pOriginal->ShowCursor(bShow);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateAdditionalSwapChain(D3DPRESENT_PARAMETERS* pPresentationParameters, IDirect3DSwapChain9** pSwapChain) {
    return m_pOriginal->CreateAdditionalSwapChain(pPresentationParameters, pSwapChain);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetSwapChain(UINT iSwapChain, IDirect3DSwapChain9** pSwapChain) {
    return m_pOriginal->GetSwapChain(iSwapChain, pSwapChain);
}

UINT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetNumberOfSwapChains() {
    return m_pOriginal->GetNumberOfSwapChains();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::Reset(D3DPRESENT_PARAMETERS* pPresentationParameters) {
    LOG("[Device] Reset called - clearing texture replacement cache");

    // Release cached replacements before reset
    {
        std::lock_guard<std::mutex> lock(m_texMutex);
        for (auto& pair : m_textureReplacements) {
            if (pair.second)
                pair.second->Release();
        }
        m_textureReplacements.clear();
    }

    // Clear D3DX texture hash map — all texture pointers are invalidated by Reset
    D3DXHook::ClearAll();

    return m_pOriginal->Reset(pPresentationParameters);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::Present(CONST RECT* pSourceRect, CONST RECT* pDestRect, HWND hDestWindowOverride, CONST RGNDATA* pDirtyRegion) {
    return m_pOriginal->Present(pSourceRect, pDestRect, hDestWindowOverride, pDirtyRegion);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetBackBuffer(UINT iSwapChain, UINT iBackBuffer, D3DBACKBUFFER_TYPE Type, IDirect3DSurface9** ppBackBuffer) {
    return m_pOriginal->GetBackBuffer(iSwapChain, iBackBuffer, Type, ppBackBuffer);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetRasterStatus(UINT iSwapChain, D3DRASTER_STATUS* pRasterStatus) {
    return m_pOriginal->GetRasterStatus(iSwapChain, pRasterStatus);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetDialogBoxMode(BOOL bEnableDialogs) {
    return m_pOriginal->SetDialogBoxMode(bEnableDialogs);
}

void STDMETHODCALLTYPE Direct3DDevice9Proxy::SetGammaRamp(UINT iSwapChain, DWORD Flags, CONST D3DGAMMARAMP* pRamp) {
    m_pOriginal->SetGammaRamp(iSwapChain, Flags, pRamp);
}

void STDMETHODCALLTYPE Direct3DDevice9Proxy::GetGammaRamp(UINT iSwapChain, D3DGAMMARAMP* pRamp) {
    m_pOriginal->GetGammaRamp(iSwapChain, pRamp);
}

// === CreateTexture - interception point ===
HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateTexture(
    UINT Width, UINT Height, UINT Levels, DWORD Usage, D3DFORMAT Format,
    D3DPOOL Pool, IDirect3DTexture9** ppTexture, HANDLE* pSharedHandle)
{
    // Just pass through - the main texture replacement happens in the
    // D3DXCreateTextureFromFileInMemoryEx hook (dllmain.cpp) because
    // that's where we have the source data to compute CRC32.
    return m_pOriginal->CreateTexture(Width, Height, Levels, Usage, Format, Pool, ppTexture, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateVolumeTexture(UINT Width, UINT Height, UINT Depth, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DVolumeTexture9** ppVolumeTexture, HANDLE* pSharedHandle) {
    return m_pOriginal->CreateVolumeTexture(Width, Height, Depth, Levels, Usage, Format, Pool, ppVolumeTexture, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateCubeTexture(UINT EdgeLength, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DCubeTexture9** ppCubeTexture, HANDLE* pSharedHandle) {
    return m_pOriginal->CreateCubeTexture(EdgeLength, Levels, Usage, Format, Pool, ppCubeTexture, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateVertexBuffer(UINT Length, DWORD Usage, DWORD FVF, D3DPOOL Pool, IDirect3DVertexBuffer9** ppVertexBuffer, HANDLE* pSharedHandle) {
    return m_pOriginal->CreateVertexBuffer(Length, Usage, FVF, Pool, ppVertexBuffer, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateIndexBuffer(UINT Length, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DIndexBuffer9** ppIndexBuffer, HANDLE* pSharedHandle) {
    return m_pOriginal->CreateIndexBuffer(Length, Usage, Format, Pool, ppIndexBuffer, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateRenderTarget(UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Lockable, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle) {
    return m_pOriginal->CreateRenderTarget(Width, Height, Format, MultiSample, MultisampleQuality, Lockable, ppSurface, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateDepthStencilSurface(UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Discard, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle) {
    return m_pOriginal->CreateDepthStencilSurface(Width, Height, Format, MultiSample, MultisampleQuality, Discard, ppSurface, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::UpdateSurface(IDirect3DSurface9* pSourceSurface, CONST RECT* pSourceRect, IDirect3DSurface9* pDestinationSurface, CONST POINT* pDestPoint) {
    return m_pOriginal->UpdateSurface(pSourceSurface, pSourceRect, pDestinationSurface, pDestPoint);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::UpdateTexture(IDirect3DBaseTexture9* pSourceTexture, IDirect3DBaseTexture9* pDestinationTexture) {
    return m_pOriginal->UpdateTexture(pSourceTexture, pDestinationTexture);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetRenderTargetData(IDirect3DSurface9* pRenderTarget, IDirect3DSurface9* pDestSurface) {
    return m_pOriginal->GetRenderTargetData(pRenderTarget, pDestSurface);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetFrontBufferData(UINT iSwapChain, IDirect3DSurface9* pDestSurface) {
    return m_pOriginal->GetFrontBufferData(iSwapChain, pDestSurface);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::StretchRect(IDirect3DSurface9* pSourceSurface, CONST RECT* pSourceRect, IDirect3DSurface9* pDestSurface, CONST RECT* pDestRect, D3DTEXTUREFILTERTYPE Filter) {
    return m_pOriginal->StretchRect(pSourceSurface, pSourceRect, pDestSurface, pDestRect, Filter);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::ColorFill(IDirect3DSurface9* pSurface, CONST RECT* pRect, D3DCOLOR color) {
    return m_pOriginal->ColorFill(pSurface, pRect, color);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateOffscreenPlainSurface(UINT Width, UINT Height, D3DFORMAT Format, D3DPOOL Pool, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle) {
    return m_pOriginal->CreateOffscreenPlainSurface(Width, Height, Format, Pool, ppSurface, pSharedHandle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetRenderTarget(DWORD RenderTargetIndex, IDirect3DSurface9* pRenderTarget) {
    return m_pOriginal->SetRenderTarget(RenderTargetIndex, pRenderTarget);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetRenderTarget(DWORD RenderTargetIndex, IDirect3DSurface9** ppRenderTarget) {
    return m_pOriginal->GetRenderTarget(RenderTargetIndex, ppRenderTarget);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetDepthStencilSurface(IDirect3DSurface9* pNewZStencil) {
    return m_pOriginal->SetDepthStencilSurface(pNewZStencil);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetDepthStencilSurface(IDirect3DSurface9** ppZStencilSurface) {
    return m_pOriginal->GetDepthStencilSurface(ppZStencilSurface);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::BeginScene() {
    return m_pOriginal->BeginScene();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::EndScene() {
    return m_pOriginal->EndScene();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::Clear(DWORD Count, CONST D3DRECT* pRects, DWORD Flags, D3DCOLOR Color, float Z, DWORD Stencil) {
    return m_pOriginal->Clear(Count, pRects, Flags, Color, Z, Stencil);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetTransform(D3DTRANSFORMSTATETYPE State, CONST D3DMATRIX* pMatrix) {
    return m_pOriginal->SetTransform(State, pMatrix);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetTransform(D3DTRANSFORMSTATETYPE State, D3DMATRIX* pMatrix) {
    return m_pOriginal->GetTransform(State, pMatrix);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::MultiplyTransform(D3DTRANSFORMSTATETYPE State, CONST D3DMATRIX* pMatrix) {
    return m_pOriginal->MultiplyTransform(State, pMatrix);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetViewport(CONST D3DVIEWPORT9* pViewport) {
    return m_pOriginal->SetViewport(pViewport);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetViewport(D3DVIEWPORT9* pViewport) {
    return m_pOriginal->GetViewport(pViewport);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetMaterial(CONST D3DMATERIAL9* pMaterial) {
    return m_pOriginal->SetMaterial(pMaterial);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetMaterial(D3DMATERIAL9* pMaterial) {
    return m_pOriginal->GetMaterial(pMaterial);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetLight(DWORD Index, CONST D3DLIGHT9* pLight) {
    return m_pOriginal->SetLight(Index, pLight);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetLight(DWORD Index, D3DLIGHT9* pLight) {
    return m_pOriginal->GetLight(Index, pLight);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::LightEnable(DWORD Index, BOOL Enable) {
    return m_pOriginal->LightEnable(Index, Enable);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetLightEnable(DWORD Index, BOOL* pEnable) {
    return m_pOriginal->GetLightEnable(Index, pEnable);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetClipPlane(DWORD Index, CONST float* pPlane) {
    return m_pOriginal->SetClipPlane(Index, pPlane);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetClipPlane(DWORD Index, float* pPlane) {
    return m_pOriginal->GetClipPlane(Index, pPlane);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetRenderState(D3DRENDERSTATETYPE State, DWORD Value) {
    return m_pOriginal->SetRenderState(State, Value);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetRenderState(D3DRENDERSTATETYPE State, DWORD* pValue) {
    return m_pOriginal->GetRenderState(State, pValue);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateStateBlock(D3DSTATEBLOCKTYPE Type, IDirect3DStateBlock9** ppSB) {
    return m_pOriginal->CreateStateBlock(Type, ppSB);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::BeginStateBlock() {
    return m_pOriginal->BeginStateBlock();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::EndStateBlock(IDirect3DStateBlock9** ppSB) {
    return m_pOriginal->EndStateBlock(ppSB);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetClipStatus(CONST D3DCLIPSTATUS9* pClipStatus) {
    return m_pOriginal->SetClipStatus(pClipStatus);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetClipStatus(D3DCLIPSTATUS9* pClipStatus) {
    return m_pOriginal->GetClipStatus(pClipStatus);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetTexture(DWORD Stage, IDirect3DBaseTexture9** ppTexture) {
    return m_pOriginal->GetTexture(Stage, ppTexture);
}

// === SetTexture - key interception point for texture swapping ===
//
// Primary path: look up the TSFix-compatible CRC32 stored by our D3DX IAT hook.
// Fallback path: if D3DX hooks weren't installed (no d3dx9 imports), try LockRect.
HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetTexture(DWORD Stage, IDirect3DBaseTexture9* pTexture) {
    if (pTexture) {
        std::lock_guard<std::mutex> lock(m_texMutex);

        // Check if we already have a replacement mapping
        auto it = m_textureReplacements.find(pTexture);
        if (it != m_textureReplacements.end()) {
            if (it->second) {
                return m_pOriginal->SetTexture(Stage, it->second);
            }
            return m_pOriginal->SetTexture(Stage, pTexture);
        }

        // First time seeing this texture — compute/look up its hash
        uint32_t crc = D3DXHook::GetTextureHash(pTexture);

        if (crc != 0) {
            // D3DX IAT hook path — hash matches TSFix naming
            auto& texMgr = TextureManager::Instance();

            if (texMgr.IsLoggingEnabled()) {
                LOG("[SetTex] D3DX CRC32=%08X", crc);
            }

            if (texMgr.HasReplacement(crc)) {
                IDirect3DTexture9* pRepl = texMgr.GetReplacementTexture(m_pOriginal, crc);
                if (pRepl) {
                    m_textureReplacements[pTexture] = pRepl;
                    LOG("[SetTex] Replacing CRC32=%08X", crc);
                    return m_pOriginal->SetTexture(Stage, pRepl);
                }
            }

            // No replacement — cache so we don't re-check
            m_textureReplacements[pTexture] = nullptr;

        } else if (pTexture->GetType() == D3DRTYPE_TEXTURE) {
            // Fallback: LockRect-based hashing for textures not created via D3DX
            IDirect3DTexture9* pTex2D = static_cast<IDirect3DTexture9*>(pTexture);
            D3DSURFACE_DESC desc;
            if (SUCCEEDED(pTex2D->GetLevelDesc(0, &desc))) {
                if (!(desc.Usage & D3DUSAGE_RENDERTARGET) && !(desc.Usage & D3DUSAGE_DEPTHSTENCIL)) {
                    D3DLOCKED_RECT locked;
                    if (SUCCEEDED(pTex2D->LockRect(0, &locked, nullptr, D3DLOCK_READONLY))) {
                        uint32_t dataSize = 0;
                        bool isCompressed = (desc.Format == D3DFMT_DXT1 || desc.Format == D3DFMT_DXT2 ||
                                            desc.Format == D3DFMT_DXT3 || desc.Format == D3DFMT_DXT4 ||
                                            desc.Format == D3DFMT_DXT5);
                        if (isCompressed) {
                            uint32_t blockSize = (desc.Format == D3DFMT_DXT1) ? 8 : 16;
                            dataSize = ((desc.Width + 3) / 4) * ((desc.Height + 3) / 4) * blockSize;
                        } else {
                            dataSize = desc.Height * locked.Pitch;
                        }
                        if (dataSize > 0) {
                            uint32_t fbCrc = crc32_compute(locked.pBits, dataSize);
                            auto& texMgr = TextureManager::Instance();
                            if (texMgr.IsLoggingEnabled()) {
                                LOG("[SetTex] Fallback CRC32=%08X %ux%u fmt=%d",
                                    fbCrc, desc.Width, desc.Height, desc.Format);
                            }
                            if (texMgr.HasReplacement(fbCrc)) {
                                IDirect3DTexture9* pRepl = texMgr.GetReplacementTexture(m_pOriginal, fbCrc);
                                if (pRepl) {
                                    m_textureReplacements[pTexture] = pRepl;
                                    pTex2D->UnlockRect(0);
                                    LOG("[SetTex] Replacing (fallback) CRC32=%08X", fbCrc);
                                    return m_pOriginal->SetTexture(Stage, pRepl);
                                }
                            }
                            m_textureReplacements[pTexture] = nullptr;
                        }
                        pTex2D->UnlockRect(0);
                    } else {
                        m_textureReplacements[pTexture] = nullptr;
                    }
                }
            }
        }
    }
    return m_pOriginal->SetTexture(Stage, pTexture);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetTextureStageState(DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD* pValue) {
    return m_pOriginal->GetTextureStageState(Stage, Type, pValue);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetTextureStageState(DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD Value) {
    return m_pOriginal->SetTextureStageState(Stage, Type, Value);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetSamplerState(DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD* pValue) {
    return m_pOriginal->GetSamplerState(Sampler, Type, pValue);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetSamplerState(DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD Value) {
    return m_pOriginal->SetSamplerState(Sampler, Type, Value);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::ValidateDevice(DWORD* pNumPasses) {
    return m_pOriginal->ValidateDevice(pNumPasses);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetPaletteEntries(UINT PaletteNumber, CONST PALETTEENTRY* pEntries) {
    return m_pOriginal->SetPaletteEntries(PaletteNumber, pEntries);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetPaletteEntries(UINT PaletteNumber, PALETTEENTRY* pEntries) {
    return m_pOriginal->GetPaletteEntries(PaletteNumber, pEntries);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetCurrentTexturePalette(UINT PaletteNumber) {
    return m_pOriginal->SetCurrentTexturePalette(PaletteNumber);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetCurrentTexturePalette(UINT* PaletteNumber) {
    return m_pOriginal->GetCurrentTexturePalette(PaletteNumber);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetScissorRect(CONST RECT* pRect) {
    return m_pOriginal->SetScissorRect(pRect);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetScissorRect(RECT* pRect) {
    return m_pOriginal->GetScissorRect(pRect);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetSoftwareVertexProcessing(BOOL bSoftware) {
    return m_pOriginal->SetSoftwareVertexProcessing(bSoftware);
}

BOOL STDMETHODCALLTYPE Direct3DDevice9Proxy::GetSoftwareVertexProcessing() {
    return m_pOriginal->GetSoftwareVertexProcessing();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetNPatchMode(float nSegments) {
    return m_pOriginal->SetNPatchMode(nSegments);
}

float STDMETHODCALLTYPE Direct3DDevice9Proxy::GetNPatchMode() {
    return m_pOriginal->GetNPatchMode();
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::DrawPrimitive(D3DPRIMITIVETYPE PrimitiveType, UINT StartVertex, UINT PrimitiveCount) {
    return m_pOriginal->DrawPrimitive(PrimitiveType, StartVertex, PrimitiveCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::DrawIndexedPrimitive(D3DPRIMITIVETYPE Type, INT BaseVertexIndex, UINT MinVertexIndex, UINT NumVertices, UINT startIndex, UINT primCount) {
    return m_pOriginal->DrawIndexedPrimitive(Type, BaseVertexIndex, MinVertexIndex, NumVertices, startIndex, primCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::DrawPrimitiveUP(D3DPRIMITIVETYPE PrimitiveType, UINT PrimitiveCount, CONST void* pVertexStreamZeroData, UINT VertexStreamZeroStride) {
    return m_pOriginal->DrawPrimitiveUP(PrimitiveType, PrimitiveCount, pVertexStreamZeroData, VertexStreamZeroStride);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::DrawIndexedPrimitiveUP(D3DPRIMITIVETYPE PrimitiveType, UINT MinVertexIndex, UINT NumVertices, UINT PrimitiveCount, CONST void* pIndexData, D3DFORMAT IndexDataFormat, CONST void* pVertexStreamZeroData, UINT VertexStreamZeroStride) {
    return m_pOriginal->DrawIndexedPrimitiveUP(PrimitiveType, MinVertexIndex, NumVertices, PrimitiveCount, pIndexData, IndexDataFormat, pVertexStreamZeroData, VertexStreamZeroStride);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::ProcessVertices(UINT SrcStartIndex, UINT DestIndex, UINT VertexCount, IDirect3DVertexBuffer9* pDestBuffer, IDirect3DVertexDeclaration9* pVertexDecl, DWORD Flags) {
    return m_pOriginal->ProcessVertices(SrcStartIndex, DestIndex, VertexCount, pDestBuffer, pVertexDecl, Flags);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateVertexDeclaration(CONST D3DVERTEXELEMENT9* pVertexElements, IDirect3DVertexDeclaration9** ppDecl) {
    return m_pOriginal->CreateVertexDeclaration(pVertexElements, ppDecl);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetVertexDeclaration(IDirect3DVertexDeclaration9* pDecl) {
    return m_pOriginal->SetVertexDeclaration(pDecl);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetVertexDeclaration(IDirect3DVertexDeclaration9** ppDecl) {
    return m_pOriginal->GetVertexDeclaration(ppDecl);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetFVF(DWORD FVF) {
    return m_pOriginal->SetFVF(FVF);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetFVF(DWORD* pFVF) {
    return m_pOriginal->GetFVF(pFVF);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateVertexShader(CONST DWORD* pFunction, IDirect3DVertexShader9** ppShader) {
    return m_pOriginal->CreateVertexShader(pFunction, ppShader);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetVertexShader(IDirect3DVertexShader9* pShader) {
    return m_pOriginal->SetVertexShader(pShader);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetVertexShader(IDirect3DVertexShader9** ppShader) {
    return m_pOriginal->GetVertexShader(ppShader);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetVertexShaderConstantF(UINT StartRegister, CONST float* pConstantData, UINT Vector4fCount) {
    return m_pOriginal->SetVertexShaderConstantF(StartRegister, pConstantData, Vector4fCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetVertexShaderConstantF(UINT StartRegister, float* pConstantData, UINT Vector4fCount) {
    return m_pOriginal->GetVertexShaderConstantF(StartRegister, pConstantData, Vector4fCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetVertexShaderConstantI(UINT StartRegister, CONST int* pConstantData, UINT Vector4iCount) {
    return m_pOriginal->SetVertexShaderConstantI(StartRegister, pConstantData, Vector4iCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetVertexShaderConstantI(UINT StartRegister, int* pConstantData, UINT Vector4iCount) {
    return m_pOriginal->GetVertexShaderConstantI(StartRegister, pConstantData, Vector4iCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetVertexShaderConstantB(UINT StartRegister, CONST BOOL* pConstantData, UINT BoolCount) {
    return m_pOriginal->SetVertexShaderConstantB(StartRegister, pConstantData, BoolCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetVertexShaderConstantB(UINT StartRegister, BOOL* pConstantData, UINT BoolCount) {
    return m_pOriginal->GetVertexShaderConstantB(StartRegister, pConstantData, BoolCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetStreamSource(UINT StreamNumber, IDirect3DVertexBuffer9* pStreamData, UINT OffsetInBytes, UINT Stride) {
    return m_pOriginal->SetStreamSource(StreamNumber, pStreamData, OffsetInBytes, Stride);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetStreamSource(UINT StreamNumber, IDirect3DVertexBuffer9** ppStreamData, UINT* pOffsetInBytes, UINT* pStride) {
    return m_pOriginal->GetStreamSource(StreamNumber, ppStreamData, pOffsetInBytes, pStride);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetStreamSourceFreq(UINT StreamNumber, UINT Setting) {
    return m_pOriginal->SetStreamSourceFreq(StreamNumber, Setting);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetStreamSourceFreq(UINT StreamNumber, UINT* pSetting) {
    return m_pOriginal->GetStreamSourceFreq(StreamNumber, pSetting);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetIndices(IDirect3DIndexBuffer9* pIndexData) {
    return m_pOriginal->SetIndices(pIndexData);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetIndices(IDirect3DIndexBuffer9** ppIndexData) {
    return m_pOriginal->GetIndices(ppIndexData);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreatePixelShader(CONST DWORD* pFunction, IDirect3DPixelShader9** ppShader) {
    return m_pOriginal->CreatePixelShader(pFunction, ppShader);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetPixelShader(IDirect3DPixelShader9* pShader) {
    return m_pOriginal->SetPixelShader(pShader);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetPixelShader(IDirect3DPixelShader9** ppShader) {
    return m_pOriginal->GetPixelShader(ppShader);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetPixelShaderConstantF(UINT StartRegister, CONST float* pConstantData, UINT Vector4fCount) {
    return m_pOriginal->SetPixelShaderConstantF(StartRegister, pConstantData, Vector4fCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetPixelShaderConstantF(UINT StartRegister, float* pConstantData, UINT Vector4fCount) {
    return m_pOriginal->GetPixelShaderConstantF(StartRegister, pConstantData, Vector4fCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetPixelShaderConstantI(UINT StartRegister, CONST int* pConstantData, UINT Vector4iCount) {
    return m_pOriginal->SetPixelShaderConstantI(StartRegister, pConstantData, Vector4iCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetPixelShaderConstantI(UINT StartRegister, int* pConstantData, UINT Vector4iCount) {
    return m_pOriginal->GetPixelShaderConstantI(StartRegister, pConstantData, Vector4iCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::SetPixelShaderConstantB(UINT StartRegister, CONST BOOL* pConstantData, UINT BoolCount) {
    return m_pOriginal->SetPixelShaderConstantB(StartRegister, pConstantData, BoolCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::GetPixelShaderConstantB(UINT StartRegister, BOOL* pConstantData, UINT BoolCount) {
    return m_pOriginal->GetPixelShaderConstantB(StartRegister, pConstantData, BoolCount);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::DrawRectPatch(UINT Handle, CONST float* pNumSegs, CONST D3DRECTPATCH_INFO* pRectPatchInfo) {
    return m_pOriginal->DrawRectPatch(Handle, pNumSegs, pRectPatchInfo);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::DrawTriPatch(UINT Handle, CONST float* pNumSegs, CONST D3DTRIPATCH_INFO* pTriPatchInfo) {
    return m_pOriginal->DrawTriPatch(Handle, pNumSegs, pTriPatchInfo);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::DeletePatch(UINT Handle) {
    return m_pOriginal->DeletePatch(Handle);
}

HRESULT STDMETHODCALLTYPE Direct3DDevice9Proxy::CreateQuery(D3DQUERYTYPE Type, IDirect3DQuery9** ppQuery) {
    return m_pOriginal->CreateQuery(Type, ppQuery);
}
