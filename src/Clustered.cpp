#include "Clustered.h"
#include "ShaderCompiler.h"

void Clustered::Reset()
{
	rendered = false;
	shadowLightsMap.clear();
	pointLightsMap.clear();
	std::swap(shadowLightsMap, shadowLightsMapNext);
	std::swap(pointLightsMap, pointLightsMapNext);
}

void Clustered::Initialise()
{
	reshade::register_event<reshade::addon_event::present>(OnPresentCallback);
}

void Clustered::OnPresent()
{
	//logger::info("Look at all the friends I made!");

	//for (auto& entry : shadowLightsMap) {
	//	auto light = entry.second;
	//	logger::info("	Shadow light friend!");
	//	logger::info("		Position: {} {} {}", light.shadowLightPosition.x, light.shadowLightPosition.y, light.shadowLightPosition.z);
	//	logger::info("		Color: {} {} {}", light.shadowLightColor.x, light.shadowLightColor.y, light.shadowLightColor.z);
	//	logger::info("		Fade: {}", light.shadowLightColor.w);
	//	logger::info("		Mask: {}", light.shadowLightMaskSelect);
	//}

	//for (auto& entry : pointLightsMap) {
	//	auto light = entry.second;
	//	logger::info("	Point light friend!");
	//	logger::info("		Position: {} {} {}", light.pointLightPosition.x, light.pointLightPosition.y, light.pointLightPosition.z);
	//	logger::info("		Color: {} {} {}", light.pointLightColor.x, light.pointLightColor.y, light.pointLightColor.z);
	//	logger::info("		Fade: {}", light.pointLightColor.w);
	//}
	Reset();
}


void Clustered::UpdateLights()
{
	//uint32_t current_light_count = (uint32_t)pointLightsMap.size();

}

#define CLUSTER_SIZE_X 16
#define CLUSTER_SIZE_Y 16
#define CLUSTER_SIZE_Z 16
#define CLUSTER_MAX_LIGHTS 128

void Clustered::UpdateClusters()
{
	if (!rendered) {
		rendered = true;

		if (!setup) {
			SetupResources();
		}

		//auto context = RE::BSRenderManager::GetSingleton()->GetRuntimeData().context;

		//if (true) {
		//	context->CSSetShader(clusterBuildingCS, nullptr, 0);
		//	context->Dispatch(CLUSTER_SIZE_X, CLUSTER_SIZE_Y, CLUSTER_SIZE_Z);
		//}

		//context->CSSetShader(clusterCullingCS, nullptr, 0);
		//context->Dispatch(CLUSTER_SIZE_X, CLUSTER_SIZE_Y, CLUSTER_SIZE_Z);
	}
}

void Clustered::OnPresentCallback(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*)
{
	GetSingleton()->OnPresent();
}



void Clustered::SetupResources()
{
	setup = true;

	clusterBuildingCS = (ID3D11ComputeShader*)ShaderCompiler::CompileShader(L"Data\\Shaders\\Clustered\\ClusterBuildingCS.hlsl",  { } , "cs_5_0");
	clusterCullingCS = (ID3D11ComputeShader*)ShaderCompiler::CompileShader(L"Data\\Shaders\\Clustered\\ClusterCullingCS.hlsl", { }, "cs_5_0");

	static constexpr std::uint32_t CLUSTER_COUNT = CLUSTER_SIZE_X * CLUSTER_SIZE_Y * CLUSTER_SIZE_Z;

	clusters = new StructuredBuffer(StructuredBufferDesc<ClusterAABB>(CLUSTER_COUNT));
	lightCounter = new StructuredBuffer(StructuredBufferDesc<uint32_t>(1));
	lightList = new StructuredBuffer(StructuredBufferDesc<uint32_t>(CLUSTER_COUNT * CLUSTER_MAX_LIGHTS));
	lightGrid = new StructuredBuffer(StructuredBufferDesc<LightGrid>(CLUSTER_COUNT));
}


void Clustered::SetupConstantPointLights(const BSGraphics::PixelCGroup&, RE::BSRenderPass* Pass, DirectX::XMMATRIX&, uint32_t LightCount, uint32_t ShadowLightCount, float, BSGraphics::Space)
{
	//auto& pointLightPosition = PixelCG.ParamPS<DirectX::XMVECTORF32[7], 1>();  // PS: p1 float4[7] PointLightPosition
	//auto& pointLightColor = PixelCG.ParamPS<DirectX::XMVECTORF32[7], 2>();     // PS: p2 float4[7] PointLightColor
	//auto& shadowLightMaskSelect = PixelCG.ParamPS<float[4], 10>();    // PS: p10 float4 ShadowLightMaskSelect

	for (uint32_t i = 0; i < LightCount; i++) {
		auto  screenSpaceLight = Pass->sceneLights[i];
		auto& niLight = screenSpaceLight->light;
		if (i < ShadowLightCount) {
			if (!shadowLightsMapNext.contains(screenSpaceLight)) {
				RE::NiPoint3 worldPos = niLight->world.translate;
				float        dimmer = niLight->GetLightRuntimeData().fade * screenSpaceLight->lodDimmer;

				ShadowLightData data{};
				data.shadowLightColor.x = dimmer * niLight->GetLightRuntimeData().diffuse.red;
				data.shadowLightColor.y = dimmer * niLight->GetLightRuntimeData().diffuse.green;
				data.shadowLightColor.z = dimmer * niLight->GetLightRuntimeData().diffuse.blue;

				worldPos = worldPos - BSGraphics::RendererShadowState::QInstance()->m_PosAdjust;

				data.shadowLightPosition.x = worldPos.x;
				data.shadowLightPosition.y = worldPos.y;
				data.shadowLightPosition.z = worldPos.z;
				data.shadowLightPosition.w = niLight->GetLightRuntimeData().radius.x;

				data.shadowLightMaskSelect = (float)static_cast<RE::BSShadowLight*>(screenSpaceLight)->unk520;
				shadowLightsMapNext.insert({ screenSpaceLight, data });
			}
		} else if (!pointLightsMapNext.contains(screenSpaceLight)) {
			RE::NiPoint3 worldPos = niLight->world.translate;
			float        dimmer = niLight->GetLightRuntimeData().fade * screenSpaceLight->lodDimmer;

			LightData data{};
			data.pointLightColor.x = dimmer * niLight->GetLightRuntimeData().diffuse.red;
			data.pointLightColor.y = dimmer * niLight->GetLightRuntimeData().diffuse.green;
			data.pointLightColor.z = dimmer * niLight->GetLightRuntimeData().diffuse.blue;

			worldPos = worldPos - BSGraphics::RendererShadowState::QInstance()->m_PosAdjust;

			data.pointLightPosition.x = worldPos.x;
			data.pointLightPosition.y = worldPos.y;
			data.pointLightPosition.z = worldPos.z;
			data.pointLightPosition.w = niLight->GetLightRuntimeData().radius.x;
			pointLightsMapNext.insert({ screenSpaceLight, data });
		}
	}
}
