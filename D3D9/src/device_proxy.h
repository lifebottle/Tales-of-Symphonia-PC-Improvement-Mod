#pragma once
/*
 * D3D9 Texture Replacement Proxy - IDirect3DDevice9 Wrapper
 * Wraps the real IDirect3DDevice9 to intercept texture creation and usage.
 * 
 * Key interception points:
 *   - CreateTexture: hash source data, check for replacements
 *   - SetTexture: swap replacement textures at bind time
 *   - D3DXCreateTextureFromFileInMemoryEx (via vtable): intercept & replace
 */

#include <d3d9.h>
#include <unordered_map>
#include <mutex>
#include <cstdint>

class Direct3DDevice9Proxy : public IDirect3DDevice9 {
public:
    Direct3DDevice9Proxy(IDirect3DDevice9* pOriginal, IDirect3D9* pD3D9Proxy);
    virtual ~Direct3DDevice9Proxy();

    IDirect3DDevice9* GetReal() const { return m_pOriginal; }

    // Track texture -> CRC32 mapping for SetTexture replacement
    void TrackTexture(IDirect3DTexture9* pOriginal, uint32_t crc32, IDirect3DTexture9* pReplacement);

    /*** IUnknown methods ***/
    STDMETHOD(QueryInterface)(REFIID riid, void** ppvObj) override;
    STDMETHOD_(ULONG, AddRef)() override;
    STDMETHOD_(ULONG, Release)() override;

    /*** IDirect3DDevice9 methods ***/
    STDMETHOD(TestCooperativeLevel)() override;
    STDMETHOD_(UINT, GetAvailableTextureMem)() override;
    STDMETHOD(EvictManagedResources)() override;
    STDMETHOD(GetDirect3D)(IDirect3D9** ppD3D9) override;
    STDMETHOD(GetDeviceCaps)(D3DCAPS9* pCaps) override;
    STDMETHOD(GetDisplayMode)(UINT iSwapChain, D3DDISPLAYMODE* pMode) override;
    STDMETHOD(GetCreationParameters)(D3DDEVICE_CREATION_PARAMETERS* pParameters) override;
    STDMETHOD(SetCursorProperties)(UINT XHotSpot, UINT YHotSpot, IDirect3DSurface9* pCursorBitmap) override;
    STDMETHOD_(void, SetCursorPosition)(int X, int Y, DWORD Flags) override;
    STDMETHOD_(BOOL, ShowCursor)(BOOL bShow) override;
    STDMETHOD(CreateAdditionalSwapChain)(D3DPRESENT_PARAMETERS* pPresentationParameters, IDirect3DSwapChain9** pSwapChain) override;
    STDMETHOD(GetSwapChain)(UINT iSwapChain, IDirect3DSwapChain9** pSwapChain) override;
    STDMETHOD_(UINT, GetNumberOfSwapChains)() override;
    STDMETHOD(Reset)(D3DPRESENT_PARAMETERS* pPresentationParameters) override;
    STDMETHOD(Present)(CONST RECT* pSourceRect, CONST RECT* pDestRect, HWND hDestWindowOverride, CONST RGNDATA* pDirtyRegion) override;
    STDMETHOD(GetBackBuffer)(UINT iSwapChain, UINT iBackBuffer, D3DBACKBUFFER_TYPE Type, IDirect3DSurface9** ppBackBuffer) override;
    STDMETHOD(GetRasterStatus)(UINT iSwapChain, D3DRASTER_STATUS* pRasterStatus) override;
    STDMETHOD(SetDialogBoxMode)(BOOL bEnableDialogs) override;
    STDMETHOD_(void, SetGammaRamp)(UINT iSwapChain, DWORD Flags, CONST D3DGAMMARAMP* pRamp) override;
    STDMETHOD_(void, GetGammaRamp)(UINT iSwapChain, D3DGAMMARAMP* pRamp) override;
    STDMETHOD(CreateTexture)(UINT Width, UINT Height, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DTexture9** ppTexture, HANDLE* pSharedHandle) override;
    STDMETHOD(CreateVolumeTexture)(UINT Width, UINT Height, UINT Depth, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DVolumeTexture9** ppVolumeTexture, HANDLE* pSharedHandle) override;
    STDMETHOD(CreateCubeTexture)(UINT EdgeLength, UINT Levels, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DCubeTexture9** ppCubeTexture, HANDLE* pSharedHandle) override;
    STDMETHOD(CreateVertexBuffer)(UINT Length, DWORD Usage, DWORD FVF, D3DPOOL Pool, IDirect3DVertexBuffer9** ppVertexBuffer, HANDLE* pSharedHandle) override;
    STDMETHOD(CreateIndexBuffer)(UINT Length, DWORD Usage, D3DFORMAT Format, D3DPOOL Pool, IDirect3DIndexBuffer9** ppIndexBuffer, HANDLE* pSharedHandle) override;
    STDMETHOD(CreateRenderTarget)(UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Lockable, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle) override;
    STDMETHOD(CreateDepthStencilSurface)(UINT Width, UINT Height, D3DFORMAT Format, D3DMULTISAMPLE_TYPE MultiSample, DWORD MultisampleQuality, BOOL Discard, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle) override;
    STDMETHOD(UpdateSurface)(IDirect3DSurface9* pSourceSurface, CONST RECT* pSourceRect, IDirect3DSurface9* pDestinationSurface, CONST POINT* pDestPoint) override;
    STDMETHOD(UpdateTexture)(IDirect3DBaseTexture9* pSourceTexture, IDirect3DBaseTexture9* pDestinationTexture) override;
    STDMETHOD(GetRenderTargetData)(IDirect3DSurface9* pRenderTarget, IDirect3DSurface9* pDestSurface) override;
    STDMETHOD(GetFrontBufferData)(UINT iSwapChain, IDirect3DSurface9* pDestSurface) override;
    STDMETHOD(StretchRect)(IDirect3DSurface9* pSourceSurface, CONST RECT* pSourceRect, IDirect3DSurface9* pDestSurface, CONST RECT* pDestRect, D3DTEXTUREFILTERTYPE Filter) override;
    STDMETHOD(ColorFill)(IDirect3DSurface9* pSurface, CONST RECT* pRect, D3DCOLOR color) override;
    STDMETHOD(CreateOffscreenPlainSurface)(UINT Width, UINT Height, D3DFORMAT Format, D3DPOOL Pool, IDirect3DSurface9** ppSurface, HANDLE* pSharedHandle) override;
    STDMETHOD(SetRenderTarget)(DWORD RenderTargetIndex, IDirect3DSurface9* pRenderTarget) override;
    STDMETHOD(GetRenderTarget)(DWORD RenderTargetIndex, IDirect3DSurface9** ppRenderTarget) override;
    STDMETHOD(SetDepthStencilSurface)(IDirect3DSurface9* pNewZStencil) override;
    STDMETHOD(GetDepthStencilSurface)(IDirect3DSurface9** ppZStencilSurface) override;
    STDMETHOD(BeginScene)() override;
    STDMETHOD(EndScene)() override;
    STDMETHOD(Clear)(DWORD Count, CONST D3DRECT* pRects, DWORD Flags, D3DCOLOR Color, float Z, DWORD Stencil) override;
    STDMETHOD(SetTransform)(D3DTRANSFORMSTATETYPE State, CONST D3DMATRIX* pMatrix) override;
    STDMETHOD(GetTransform)(D3DTRANSFORMSTATETYPE State, D3DMATRIX* pMatrix) override;
    STDMETHOD(MultiplyTransform)(D3DTRANSFORMSTATETYPE, CONST D3DMATRIX*) override;
    STDMETHOD(SetViewport)(CONST D3DVIEWPORT9* pViewport) override;
    STDMETHOD(GetViewport)(D3DVIEWPORT9* pViewport) override;
    STDMETHOD(SetMaterial)(CONST D3DMATERIAL9* pMaterial) override;
    STDMETHOD(GetMaterial)(D3DMATERIAL9* pMaterial) override;
    STDMETHOD(SetLight)(DWORD Index, CONST D3DLIGHT9*) override;
    STDMETHOD(GetLight)(DWORD Index, D3DLIGHT9*) override;
    STDMETHOD(LightEnable)(DWORD Index, BOOL Enable) override;
    STDMETHOD(GetLightEnable)(DWORD Index, BOOL* pEnable) override;
    STDMETHOD(SetClipPlane)(DWORD Index, CONST float* pPlane) override;
    STDMETHOD(GetClipPlane)(DWORD Index, float* pPlane) override;
    STDMETHOD(SetRenderState)(D3DRENDERSTATETYPE State, DWORD Value) override;
    STDMETHOD(GetRenderState)(D3DRENDERSTATETYPE State, DWORD* pValue) override;
    STDMETHOD(CreateStateBlock)(D3DSTATEBLOCKTYPE Type, IDirect3DStateBlock9** ppSB) override;
    STDMETHOD(BeginStateBlock)() override;
    STDMETHOD(EndStateBlock)(IDirect3DStateBlock9** ppSB) override;
    STDMETHOD(SetClipStatus)(CONST D3DCLIPSTATUS9* pClipStatus) override;
    STDMETHOD(GetClipStatus)(D3DCLIPSTATUS9* pClipStatus) override;
    STDMETHOD(GetTexture)(DWORD Stage, IDirect3DBaseTexture9** ppTexture) override;
    STDMETHOD(SetTexture)(DWORD Stage, IDirect3DBaseTexture9* pTexture) override;
    STDMETHOD(GetTextureStageState)(DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD* pValue) override;
    STDMETHOD(SetTextureStageState)(DWORD Stage, D3DTEXTURESTAGESTATETYPE Type, DWORD Value) override;
    STDMETHOD(GetSamplerState)(DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD* pValue) override;
    STDMETHOD(SetSamplerState)(DWORD Sampler, D3DSAMPLERSTATETYPE Type, DWORD Value) override;
    STDMETHOD(ValidateDevice)(DWORD* pNumPasses) override;
    STDMETHOD(SetPaletteEntries)(UINT PaletteNumber, CONST PALETTEENTRY* pEntries) override;
    STDMETHOD(GetPaletteEntries)(UINT PaletteNumber, PALETTEENTRY* pEntries) override;
    STDMETHOD(SetCurrentTexturePalette)(UINT PaletteNumber) override;
    STDMETHOD(GetCurrentTexturePalette)(UINT* PaletteNumber) override;
    STDMETHOD(SetScissorRect)(CONST RECT* pRect) override;
    STDMETHOD(GetScissorRect)(RECT* pRect) override;
    STDMETHOD(SetSoftwareVertexProcessing)(BOOL bSoftware) override;
    STDMETHOD_(BOOL, GetSoftwareVertexProcessing)() override;
    STDMETHOD(SetNPatchMode)(float nSegments) override;
    STDMETHOD_(float, GetNPatchMode)() override;
    STDMETHOD(DrawPrimitive)(D3DPRIMITIVETYPE PrimitiveType, UINT StartVertex, UINT PrimitiveCount) override;
    STDMETHOD(DrawIndexedPrimitive)(D3DPRIMITIVETYPE, INT BaseVertexIndex, UINT MinVertexIndex, UINT NumVertices, UINT startIndex, UINT primCount) override;
    STDMETHOD(DrawPrimitiveUP)(D3DPRIMITIVETYPE PrimitiveType, UINT PrimitiveCount, CONST void* pVertexStreamZeroData, UINT VertexStreamZeroStride) override;
    STDMETHOD(DrawIndexedPrimitiveUP)(D3DPRIMITIVETYPE PrimitiveType, UINT MinVertexIndex, UINT NumVertices, UINT PrimitiveCount, CONST void* pIndexData, D3DFORMAT IndexDataFormat, CONST void* pVertexStreamZeroData, UINT VertexStreamZeroStride) override;
    STDMETHOD(ProcessVertices)(UINT SrcStartIndex, UINT DestIndex, UINT VertexCount, IDirect3DVertexBuffer9* pDestBuffer, IDirect3DVertexDeclaration9* pVertexDecl, DWORD Flags) override;
    STDMETHOD(CreateVertexDeclaration)(CONST D3DVERTEXELEMENT9* pVertexElements, IDirect3DVertexDeclaration9** ppDecl) override;
    STDMETHOD(SetVertexDeclaration)(IDirect3DVertexDeclaration9* pDecl) override;
    STDMETHOD(GetVertexDeclaration)(IDirect3DVertexDeclaration9** ppDecl) override;
    STDMETHOD(SetFVF)(DWORD FVF) override;
    STDMETHOD(GetFVF)(DWORD* pFVF) override;
    STDMETHOD(CreateVertexShader)(CONST DWORD* pFunction, IDirect3DVertexShader9** ppShader) override;
    STDMETHOD(SetVertexShader)(IDirect3DVertexShader9* pShader) override;
    STDMETHOD(GetVertexShader)(IDirect3DVertexShader9** ppShader) override;
    STDMETHOD(SetVertexShaderConstantF)(UINT StartRegister, CONST float* pConstantData, UINT Vector4fCount) override;
    STDMETHOD(GetVertexShaderConstantF)(UINT StartRegister, float* pConstantData, UINT Vector4fCount) override;
    STDMETHOD(SetVertexShaderConstantI)(UINT StartRegister, CONST int* pConstantData, UINT Vector4iCount) override;
    STDMETHOD(GetVertexShaderConstantI)(UINT StartRegister, int* pConstantData, UINT Vector4iCount) override;
    STDMETHOD(SetVertexShaderConstantB)(UINT StartRegister, CONST BOOL* pConstantData, UINT BoolCount) override;
    STDMETHOD(GetVertexShaderConstantB)(UINT StartRegister, BOOL* pConstantData, UINT BoolCount) override;
    STDMETHOD(SetStreamSource)(UINT StreamNumber, IDirect3DVertexBuffer9* pStreamData, UINT OffsetInBytes, UINT Stride) override;
    STDMETHOD(GetStreamSource)(UINT StreamNumber, IDirect3DVertexBuffer9** ppStreamData, UINT* pOffsetInBytes, UINT* pStride) override;
    STDMETHOD(SetStreamSourceFreq)(UINT StreamNumber, UINT Setting) override;
    STDMETHOD(GetStreamSourceFreq)(UINT StreamNumber, UINT* pSetting) override;
    STDMETHOD(SetIndices)(IDirect3DIndexBuffer9* pIndexData) override;
    STDMETHOD(GetIndices)(IDirect3DIndexBuffer9** ppIndexData) override;
    STDMETHOD(CreatePixelShader)(CONST DWORD* pFunction, IDirect3DPixelShader9** ppShader) override;
    STDMETHOD(SetPixelShader)(IDirect3DPixelShader9* pShader) override;
    STDMETHOD(GetPixelShader)(IDirect3DPixelShader9** ppShader) override;
    STDMETHOD(SetPixelShaderConstantF)(UINT StartRegister, CONST float* pConstantData, UINT Vector4fCount) override;
    STDMETHOD(GetPixelShaderConstantF)(UINT StartRegister, float* pConstantData, UINT Vector4fCount) override;
    STDMETHOD(SetPixelShaderConstantI)(UINT StartRegister, CONST int* pConstantData, UINT Vector4iCount) override;
    STDMETHOD(GetPixelShaderConstantI)(UINT StartRegister, int* pConstantData, UINT Vector4iCount) override;
    STDMETHOD(SetPixelShaderConstantB)(UINT StartRegister, CONST BOOL* pConstantData, UINT BoolCount) override;
    STDMETHOD(GetPixelShaderConstantB)(UINT StartRegister, BOOL* pConstantData, UINT BoolCount) override;
    STDMETHOD(DrawRectPatch)(UINT Handle, CONST float* pNumSegs, CONST D3DRECTPATCH_INFO* pRectPatchInfo) override;
    STDMETHOD(DrawTriPatch)(UINT Handle, CONST float* pNumSegs, CONST D3DTRIPATCH_INFO* pTriPatchInfo) override;
    STDMETHOD(DeletePatch)(UINT Handle) override;
    STDMETHOD(CreateQuery)(D3DQUERYTYPE Type, IDirect3DQuery9** ppQuery) override;

private:
    IDirect3DDevice9*  m_pOriginal;
    IDirect3D9*        m_pD3D9Proxy;
    ULONG              m_refCount;

    // Map: original texture -> replacement texture (for SetTexture swapping)
    std::unordered_map<IDirect3DBaseTexture9*, IDirect3DTexture9*> m_textureReplacements;
    std::mutex m_texMutex;
};
