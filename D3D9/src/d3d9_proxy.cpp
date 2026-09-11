/*
 * D3D9 Texture Replacement Proxy - IDirect3D9 Wrapper Implementation
 * Passes all calls through to the real IDirect3D9, except CreateDevice
 * which returns our proxy device.
 */

#include "d3d9_proxy.h"
#include "device_proxy.h"
#include "logger.h"


Direct3D9Proxy::Direct3D9Proxy(IDirect3D9* pOriginal)
    : m_pOriginal(pOriginal)
    , m_refCount(1) {
    LOG("[D3D9] Proxy IDirect3D9 created");
}

Direct3D9Proxy::~Direct3D9Proxy() {
    LOG("[D3D9] Proxy IDirect3D9 destroyed");
}

// IUnknown
HRESULT STDMETHODCALLTYPE Direct3D9Proxy::QueryInterface(REFIID riid, void** ppvObj) {
    HRESULT hr = m_pOriginal->QueryInterface(riid, ppvObj);
    if (SUCCEEDED(hr)) {
        // Return ourselves for IDirect3D9 queries
        *ppvObj = this;
    }
    return hr;
}

ULONG STDMETHODCALLTYPE Direct3D9Proxy::AddRef() {
    m_pOriginal->AddRef();
    return ++m_refCount;
}

ULONG STDMETHODCALLTYPE Direct3D9Proxy::Release() {
    ULONG ref = --m_refCount;
    if (ref == 0) {
        m_pOriginal->Release();
        delete this;
    } else {
        m_pOriginal->Release();
    }
    return ref;
}

// IDirect3D9 - passthrough methods
HRESULT STDMETHODCALLTYPE Direct3D9Proxy::RegisterSoftwareDevice(void* pInitializeFunction) {
    return m_pOriginal->RegisterSoftwareDevice(pInitializeFunction);
}

UINT STDMETHODCALLTYPE Direct3D9Proxy::GetAdapterCount() {
    return m_pOriginal->GetAdapterCount();
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::GetAdapterIdentifier(UINT Adapter, DWORD Flags, D3DADAPTER_IDENTIFIER9* pIdentifier) {
    return m_pOriginal->GetAdapterIdentifier(Adapter, Flags, pIdentifier);
}

UINT STDMETHODCALLTYPE Direct3D9Proxy::GetAdapterModeCount(UINT Adapter, D3DFORMAT Format) {
    return m_pOriginal->GetAdapterModeCount(Adapter, Format);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::EnumAdapterModes(UINT Adapter, D3DFORMAT Format, UINT Mode, D3DDISPLAYMODE* pMode) {
    return m_pOriginal->EnumAdapterModes(Adapter, Format, Mode, pMode);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::GetAdapterDisplayMode(UINT Adapter, D3DDISPLAYMODE* pMode) {
    return m_pOriginal->GetAdapterDisplayMode(Adapter, pMode);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::CheckDeviceType(UINT Adapter, D3DDEVTYPE DevType, D3DFORMAT AdapterFormat, D3DFORMAT BackBufferFormat, BOOL bWindowed) {
    return m_pOriginal->CheckDeviceType(Adapter, DevType, AdapterFormat, BackBufferFormat, bWindowed);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::CheckDeviceFormat(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, DWORD Usage, D3DRESOURCETYPE RType, D3DFORMAT CheckFormat) {
    return m_pOriginal->CheckDeviceFormat(Adapter, DeviceType, AdapterFormat, Usage, RType, CheckFormat);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::CheckDeviceMultiSampleType(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SurfaceFormat, BOOL Windowed, D3DMULTISAMPLE_TYPE MultiSampleType, DWORD* pQualityLevels) {
    return m_pOriginal->CheckDeviceMultiSampleType(Adapter, DeviceType, SurfaceFormat, Windowed, MultiSampleType, pQualityLevels);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::CheckDepthStencilMatch(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, D3DFORMAT RenderTargetFormat, D3DFORMAT DepthStencilFormat) {
    return m_pOriginal->CheckDepthStencilMatch(Adapter, DeviceType, AdapterFormat, RenderTargetFormat, DepthStencilFormat);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::CheckDeviceFormatConversion(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SourceFormat, D3DFORMAT TargetFormat) {
    return m_pOriginal->CheckDeviceFormatConversion(Adapter, DeviceType, SourceFormat, TargetFormat);
}

HRESULT STDMETHODCALLTYPE Direct3D9Proxy::GetDeviceCaps(UINT Adapter, D3DDEVTYPE DeviceType, D3DCAPS9* pCaps) {
    return m_pOriginal->GetDeviceCaps(Adapter, DeviceType, pCaps);
}

HMONITOR STDMETHODCALLTYPE Direct3D9Proxy::GetAdapterMonitor(UINT Adapter) {
    return m_pOriginal->GetAdapterMonitor(Adapter);
}

// CreateDevice - this is where we inject our proxy device
HRESULT STDMETHODCALLTYPE Direct3D9Proxy::CreateDevice(
    UINT Adapter,
    D3DDEVTYPE DeviceType,
    HWND hFocusWindow,
    DWORD BehaviorFlags,
    D3DPRESENT_PARAMETERS* pPresentationParameters,
    IDirect3DDevice9** ppReturnedDeviceInterface)
{
    LOG("[D3D9] CreateDevice called (Adapter=%u, DevType=%d)", Adapter, DeviceType);

    IDirect3DDevice9* pRealDevice = nullptr;
    HRESULT hr = m_pOriginal->CreateDevice(Adapter, DeviceType, hFocusWindow,
                                            BehaviorFlags, pPresentationParameters,
                                            &pRealDevice);
    if (FAILED(hr) || !pRealDevice) {
        LOG("[D3D9] Real CreateDevice failed: 0x%08X", hr);
        return hr;
    }

    // Wrap the real device in our proxy
    Direct3DDevice9Proxy* pProxy = new Direct3DDevice9Proxy(pRealDevice, this);
    *ppReturnedDeviceInterface = pProxy;


    LOG("[D3D9] Created proxy device successfully");
    return hr;
}
