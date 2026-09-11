/*
 * D3D9 Texture Replacement Proxy - IDirect3D9Ex Wrapper Implementation
 * All IDirect3D9 methods pass through, CreateDevice/CreateDeviceEx wrap
 * the returned device in our proxy.
 */

#include "d3d9ex_proxy.h"
#include "device_proxy.h"
#include "logger.h"


Direct3D9ExProxy::Direct3D9ExProxy(IDirect3D9Ex* pOriginal)
    : m_pOriginal(pOriginal)
    , m_refCount(1) {
    LOG("[D3D9Ex] Proxy IDirect3D9Ex created");
}

Direct3D9ExProxy::~Direct3D9ExProxy() {
    LOG("[D3D9Ex] Proxy IDirect3D9Ex destroyed");
}

// IUnknown
HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::QueryInterface(REFIID riid, void** ppvObj) {
    if (!ppvObj) return E_POINTER;

    // Compare GUIDs manually to avoid linking dxguid.lib
    HRESULT hr = m_pOriginal->QueryInterface(riid, ppvObj);
    if (SUCCEEDED(hr)) {
        // If the real object supports this interface, return ourselves
        // so the game keeps using our proxy
        *ppvObj = static_cast<IDirect3D9Ex*>(this);
    }
    return hr;
}

ULONG STDMETHODCALLTYPE Direct3D9ExProxy::AddRef() {
    m_pOriginal->AddRef();
    return ++m_refCount;
}

ULONG STDMETHODCALLTYPE Direct3D9ExProxy::Release() {
    ULONG ref = --m_refCount;
    if (ref == 0) {
        m_pOriginal->Release();
        delete this;
    } else {
        m_pOriginal->Release();
    }
    return ref;
}

// IDirect3D9 passthrough
HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::RegisterSoftwareDevice(void* pInitializeFunction) {
    return m_pOriginal->RegisterSoftwareDevice(pInitializeFunction);
}

UINT STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterCount() {
    return m_pOriginal->GetAdapterCount();
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterIdentifier(UINT Adapter, DWORD Flags, D3DADAPTER_IDENTIFIER9* pIdentifier) {
    return m_pOriginal->GetAdapterIdentifier(Adapter, Flags, pIdentifier);
}

UINT STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterModeCount(UINT Adapter, D3DFORMAT Format) {
    return m_pOriginal->GetAdapterModeCount(Adapter, Format);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::EnumAdapterModes(UINT Adapter, D3DFORMAT Format, UINT Mode, D3DDISPLAYMODE* pMode) {
    return m_pOriginal->EnumAdapterModes(Adapter, Format, Mode, pMode);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterDisplayMode(UINT Adapter, D3DDISPLAYMODE* pMode) {
    return m_pOriginal->GetAdapterDisplayMode(Adapter, pMode);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::CheckDeviceType(UINT Adapter, D3DDEVTYPE DevType, D3DFORMAT AdapterFormat, D3DFORMAT BackBufferFormat, BOOL bWindowed) {
    return m_pOriginal->CheckDeviceType(Adapter, DevType, AdapterFormat, BackBufferFormat, bWindowed);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::CheckDeviceFormat(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, DWORD Usage, D3DRESOURCETYPE RType, D3DFORMAT CheckFormat) {
    return m_pOriginal->CheckDeviceFormat(Adapter, DeviceType, AdapterFormat, Usage, RType, CheckFormat);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::CheckDeviceMultiSampleType(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SurfaceFormat, BOOL Windowed, D3DMULTISAMPLE_TYPE MultiSampleType, DWORD* pQualityLevels) {
    return m_pOriginal->CheckDeviceMultiSampleType(Adapter, DeviceType, SurfaceFormat, Windowed, MultiSampleType, pQualityLevels);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::CheckDepthStencilMatch(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, D3DFORMAT RenderTargetFormat, D3DFORMAT DepthStencilFormat) {
    return m_pOriginal->CheckDepthStencilMatch(Adapter, DeviceType, AdapterFormat, RenderTargetFormat, DepthStencilFormat);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::CheckDeviceFormatConversion(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SourceFormat, D3DFORMAT TargetFormat) {
    return m_pOriginal->CheckDeviceFormatConversion(Adapter, DeviceType, SourceFormat, TargetFormat);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::GetDeviceCaps(UINT Adapter, D3DDEVTYPE DeviceType, D3DCAPS9* pCaps) {
    return m_pOriginal->GetDeviceCaps(Adapter, DeviceType, pCaps);
}

HMONITOR STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterMonitor(UINT Adapter) {
    return m_pOriginal->GetAdapterMonitor(Adapter);
}

// CreateDevice — wrap with proxy (non-Ex path)
HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::CreateDevice(
    UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow,
    DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters,
    IDirect3DDevice9** ppReturnedDeviceInterface)
{
    LOG("[D3D9Ex] CreateDevice called (Adapter=%u)", Adapter);

    IDirect3DDevice9* pRealDevice = nullptr;
    HRESULT hr = m_pOriginal->CreateDevice(Adapter, DeviceType, hFocusWindow,
                                            BehaviorFlags, pPresentationParameters,
                                            &pRealDevice);
    if (FAILED(hr) || !pRealDevice) {
        LOG("[D3D9Ex] Real CreateDevice failed: 0x%08X", hr);
        return hr;
    }

    Direct3DDevice9Proxy* pProxy = new Direct3DDevice9Proxy(pRealDevice, this);
    *ppReturnedDeviceInterface = pProxy;

    LOG("[D3D9Ex] Created proxy device successfully");
    return hr;
}

// ============================================================================
// IDirect3D9Ex methods
// ============================================================================
UINT STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterModeCountEx(UINT Adapter, CONST D3DDISPLAYMODEFILTER* pFilter) {
    return m_pOriginal->GetAdapterModeCountEx(Adapter, pFilter);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::EnumAdapterModesEx(UINT Adapter, CONST D3DDISPLAYMODEFILTER* pFilter, UINT Mode, D3DDISPLAYMODEEX* pMode) {
    return m_pOriginal->EnumAdapterModesEx(Adapter, pFilter, Mode, pMode);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterDisplayModeEx(UINT Adapter, D3DDISPLAYMODEEX* pMode, D3DDISPLAYROTATION* pRotation) {
    return m_pOriginal->GetAdapterDisplayModeEx(Adapter, pMode, pRotation);
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::CreateDeviceEx(
    UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow,
    DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters,
    D3DDISPLAYMODEEX* pFullscreenDisplayMode,
    IDirect3DDevice9Ex** ppReturnedDeviceInterface)
{
    LOG("[D3D9Ex] CreateDeviceEx called (Adapter=%u)", Adapter);

    IDirect3DDevice9Ex* pRealDeviceEx = nullptr;
    HRESULT hr = m_pOriginal->CreateDeviceEx(Adapter, DeviceType, hFocusWindow,
                                              BehaviorFlags, pPresentationParameters,
                                              pFullscreenDisplayMode, &pRealDeviceEx);
    if (FAILED(hr) || !pRealDeviceEx) {
        LOG("[D3D9Ex] Real CreateDeviceEx failed: 0x%08X", hr);
        return hr;
    }

    // IDirect3DDevice9Ex inherits IDirect3DDevice9, so our proxy works
    Direct3DDevice9Proxy* pProxy = new Direct3DDevice9Proxy(pRealDeviceEx, this);
    *ppReturnedDeviceInterface = (IDirect3DDevice9Ex*)pProxy;

    LOG("[D3D9Ex] Created proxy device (Ex) successfully");
    return hr;
}

HRESULT STDMETHODCALLTYPE Direct3D9ExProxy::GetAdapterLUID(UINT Adapter, LUID* pLUID) {
    return m_pOriginal->GetAdapterLUID(Adapter, pLUID);
}
