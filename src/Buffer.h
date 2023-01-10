#pragma once
#include <DirectXMath.h>
#include <d3d11.h>

#include "RE/BSGraphics.h"
#include "RE/BSGraphicsTypes.h"

#include <Windows.Foundation.h>
#include <wrl\wrappers\corewrappers.h>
#include <wrl\client.h>
#include <stdio.h>

#define MAXSHADOWLIGHTS 4

template <typename T>
D3D11_BUFFER_DESC StructuredBufferDesc(uint64_t count, bool uav = true, bool dynamic = false)
{
	D3D11_BUFFER_DESC desc{};
	desc.Usage = (uav || !dynamic) ? D3D11_USAGE_DEFAULT : D3D11_USAGE_DYNAMIC;
	desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
	if (uav)
		desc.BindFlags |= D3D11_BIND_UNORDERED_ACCESS;
	desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_STRUCTURED;
	desc.CPUAccessFlags = !dynamic ? 0 : D3D11_CPU_ACCESS_WRITE;
	desc.StructureByteStride = sizeof(T);
	desc.ByteWidth = (UINT)(desc.StructureByteStride * count);
	return desc;
}

template <typename T>
D3D11_BUFFER_DESC ConstantBufferDesc(uint64_t count, bool uav = true, bool dynamic = false)
{
	D3D11_BUFFER_DESC desc{};
	desc.Usage = (uav || !dynamic) ? D3D11_USAGE_DEFAULT : D3D11_USAGE_DYNAMIC;
	desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
	if (uav)
		desc.BindFlags |= D3D11_BIND_UNORDERED_ACCESS;
	desc.CPUAccessFlags = !dynamic ? 0 : D3D11_CPU_ACCESS_WRITE;
	desc.StructureByteStride = sizeof(T);
	desc.ByteWidth = (UINT)(desc.StructureByteStride * count);
	return desc;
}


class ConstantBuffer
{
public:
	ConstantBuffer(D3D11_BUFFER_DESC const& a_desc)
	{
		desc = a_desc;
		auto    device = RE::BSRenderManager::GetSingleton()->GetRuntimeData().forwarder;
		DX::ThrowIfFailed(device->CreateBuffer(&desc, nullptr, resource.ReleaseAndGetAddressOf()));
	}
	
	ID3D11Buffer* CB() const { return resource.Get(); }

private:
	Microsoft::WRL::ComPtr<ID3D11Buffer>                           resource;
	D3D11_BUFFER_DESC                                              desc;
};


class StructuredBuffer
{
public:
	StructuredBuffer(D3D11_BUFFER_DESC const& a_desc)
	{
		desc = a_desc;
		auto device = RE::BSRenderManager::GetSingleton()->GetRuntimeData().forwarder;
		DX::ThrowIfFailed(device->CreateBuffer(&desc, nullptr, resource.ReleaseAndGetAddressOf()));
	}

	ID3D11ShaderResourceView*  SRV(size_t i = 0) const { return srvs[i].Get(); }
	ID3D11UnorderedAccessView* UAV(size_t i = 0) const { return uavs[i].Get(); }

	virtual void CreateSRV()
	{
		D3D11_SHADER_RESOURCE_VIEW_DESC srv_desc{};
		srv_desc.Format = DXGI_FORMAT_UNKNOWN;
		srv_desc.ViewDimension = D3D11_SRV_DIMENSION_BUFFEREX;
		srv_desc.Format = DXGI_FORMAT_UNKNOWN;
		srv_desc.Buffer.FirstElement = (UINT)0 / desc.StructureByteStride;
		srv_desc.Buffer.NumElements = (UINT)min(uint64_t(-1), desc.ByteWidth) / desc.ByteWidth;
	}

	virtual void CreateUAV()
	{
		D3D11_UNORDERED_ACCESS_VIEW_DESC uav_desc{};
		uav_desc.ViewDimension = D3D11_UAV_DIMENSION_BUFFER;
		uav_desc.Buffer.Flags = 0;
		uav_desc.Format = DXGI_FORMAT_UNKNOWN;
		uav_desc.Buffer.FirstElement = (UINT)0 / desc.StructureByteStride;
		uav_desc.Buffer.NumElements = (UINT)min(uint64_t(-1), desc.ByteWidth) / desc.ByteWidth;
	}

private:
	Microsoft::WRL::ComPtr<ID3D11Buffer>                           resource;
	D3D11_BUFFER_DESC                                              desc;
	std::vector<Microsoft::WRL::ComPtr<ID3D11ShaderResourceView>>  srvs;
	std::vector<Microsoft::WRL::ComPtr<ID3D11UnorderedAccessView>> uavs;
};
