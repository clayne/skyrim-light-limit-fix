#pragma once
#include <DirectXMath.h>
#include <d3d11.h>

#include "RE/BSGraphics.h"
#include "RE/BSGraphicsTypes.h"

#include "Buffer.h"

#define MAXSHADOWLIGHTS 4

class Clustered
{
public:
	static Clustered* GetSingleton()
	{
		static Clustered render;
		return &render;
	}

	static void InstallHooks()
	{
		Hooks::Install();
	}

	struct LightData
	{
		DirectX::XMFLOAT4 pointLightPosition;
		DirectX::XMFLOAT4 pointLightColor;
	};

	struct ShadowLightData
	{
		DirectX::XMFLOAT4 shadowLightPosition;
		DirectX::XMFLOAT4 shadowLightColor;
		float             shadowLightMaskSelect;
	};

	struct ClusterAABB
	{
		DirectX::XMVECTOR min_point;
		DirectX::XMVECTOR max_point;
	};

	struct LightGrid
	{
		uint32_t offset;
		uint32_t light_count;
	};

	//struct alignas(16) PerFrame
	//{
	//	DirectX::XMMATRIX 
	//};
	//
	bool rendered = false;

	bool setup = false;

	std::map<void*, ShadowLightData> shadowLightsMapNext;
	std::map<void*, LightData>       pointLightsMapNext;

	std::map<void*, ShadowLightData> shadowLightsMap;
	std::map<void*, LightData>       pointLightsMap;

	ID3D11ComputeShader* clusterBuildingCS = nullptr;
	ID3D11ComputeShader* clusterCullingCS = nullptr;

//	ConstantBuffer*   perFrame = nullptr;
	StructuredBuffer* clusters = nullptr;
	StructuredBuffer* lightCounter = nullptr;
	StructuredBuffer* lightList = nullptr;
	StructuredBuffer* lightGrid = nullptr;

	void UpdateLights();
	void Reset();

	void Initialise();

	void        OnPresent();
	void        UpdateClusters();
	static void OnPresentCallback(reshade::api::command_queue* queue, reshade::api::swapchain* swapchain, const reshade::api::rect* source_rect, const reshade::api::rect* dest_rect, uint32_t dirty_rect_count, const reshade::api::rect* dirty_rects);
	
	void SetupResources();
	void SetupConstantPointLights(const BSGraphics::PixelCGroup& PixelCG, RE::BSRenderPass* Pass, DirectX::XMMATRIX& Transform, uint32_t LightCount, uint32_t ShadowLightCount, float WorldScale, BSGraphics::Space RenderSpace);

protected:
	struct Hooks
	{
		struct BSLightingShader_SetupGeometry_SetupConstantPointLights
		{
			static void thunk(const BSGraphics::PixelCGroup& PixelCG, RE::BSRenderPass* Pass, DirectX::XMMATRIX& Transform, uint32_t LightCount, uint32_t ShadowLightCount, float WorldScale, BSGraphics::Space RenderSpace)
			{
				GetSingleton()->SetupConstantPointLights(PixelCG, Pass, Transform, LightCount, ShadowLightCount, WorldScale, RenderSpace);
				func(PixelCG, Pass, Transform, LightCount, ShadowLightCount, WorldScale, RenderSpace);
			}
			static inline REL::Relocation<decltype(thunk)> func;
		};

		static void Install()
		{
			auto handle = (uintptr_t)GetModuleHandle(nullptr);
			stl::write_thunk_call<BSLightingShader_SetupGeometry_SetupConstantPointLights>(handle + 0x1412F2BB0 - 0x140000000 + 0x523);
			logger::info("Installed lights hooks");
		}
	};
};
