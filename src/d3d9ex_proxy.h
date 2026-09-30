#pragma once
/*
 * D3D9 Texture Replacement Proxy - IDirect3D9Ex Wrapper
 * Extends the IDirect3D9 proxy to support the Ex interface.
 * Games using Direct3DCreate9Ex need this to avoid vtable crashes.
 */

#include <d3d9.h>

class Direct3D9ExProxy : public IDirect3D9Ex {
public:
    Direct3D9ExProxy(IDirect3D9Ex* pOriginal);
    virtual ~Direct3D9ExProxy();

    // IUnknown
    STDMETHOD(QueryInterface)(REFIID riid, void** ppvObj) override;
    STDMETHOD_(ULONG, AddRef)() override;
    STDMETHOD_(ULONG, Release)() override;

    // IDirect3D9
    STDMETHOD(RegisterSoftwareDevice)(void* pInitializeFunction) override;
    STDMETHOD_(UINT, GetAdapterCount)() override;
    STDMETHOD(GetAdapterIdentifier)(UINT Adapter, DWORD Flags, D3DADAPTER_IDENTIFIER9* pIdentifier) override;
    STDMETHOD_(UINT, GetAdapterModeCount)(UINT Adapter, D3DFORMAT Format) override;
    STDMETHOD(EnumAdapterModes)(UINT Adapter, D3DFORMAT Format, UINT Mode, D3DDISPLAYMODE* pMode) override;
    STDMETHOD(GetAdapterDisplayMode)(UINT Adapter, D3DDISPLAYMODE* pMode) override;
    STDMETHOD(CheckDeviceType)(UINT Adapter, D3DDEVTYPE DevType, D3DFORMAT AdapterFormat, D3DFORMAT BackBufferFormat, BOOL bWindowed) override;
    STDMETHOD(CheckDeviceFormat)(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, DWORD Usage, D3DRESOURCETYPE RType, D3DFORMAT CheckFormat) override;
    STDMETHOD(CheckDeviceMultiSampleType)(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SurfaceFormat, BOOL Windowed, D3DMULTISAMPLE_TYPE MultiSampleType, DWORD* pQualityLevels) override;
    STDMETHOD(CheckDepthStencilMatch)(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT AdapterFormat, D3DFORMAT RenderTargetFormat, D3DFORMAT DepthStencilFormat) override;
    STDMETHOD(CheckDeviceFormatConversion)(UINT Adapter, D3DDEVTYPE DeviceType, D3DFORMAT SourceFormat, D3DFORMAT TargetFormat) override;
    STDMETHOD(GetDeviceCaps)(UINT Adapter, D3DDEVTYPE DeviceType, D3DCAPS9* pCaps) override;
    STDMETHOD_(HMONITOR, GetAdapterMonitor)(UINT Adapter) override;
    STDMETHOD(CreateDevice)(UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow, DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters, IDirect3DDevice9** ppReturnedDeviceInterface) override;

    // IDirect3D9Ex
    STDMETHOD_(UINT, GetAdapterModeCountEx)(UINT Adapter, CONST D3DDISPLAYMODEFILTER* pFilter) override;
    STDMETHOD(EnumAdapterModesEx)(UINT Adapter, CONST D3DDISPLAYMODEFILTER* pFilter, UINT Mode, D3DDISPLAYMODEEX* pMode) override;
    STDMETHOD(GetAdapterDisplayModeEx)(UINT Adapter, D3DDISPLAYMODEEX* pMode, D3DDISPLAYROTATION* pRotation) override;
    STDMETHOD(CreateDeviceEx)(UINT Adapter, D3DDEVTYPE DeviceType, HWND hFocusWindow, DWORD BehaviorFlags, D3DPRESENT_PARAMETERS* pPresentationParameters, D3DDISPLAYMODEEX* pFullscreenDisplayMode, IDirect3DDevice9Ex** ppReturnedDeviceInterface) override;
    STDMETHOD(GetAdapterLUID)(UINT Adapter, LUID* pLUID) override;

private:
    IDirect3D9Ex* m_pOriginal;
    ULONG         m_refCount;
};
