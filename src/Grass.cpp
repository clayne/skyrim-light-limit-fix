#include "Grass.h"

#include "RE/BSGraphicsTypes.h"
#include "ShaderCompiler.h"
#include <d3dcompiler.h>

#include "Util.h"
#include "Clustered.h"

void Grass::Initialise()
{
	reshade::register_event<reshade::addon_event::reshade_reloaded_effects>(OnReloadEffectsCallback);
	reshade::register_event<reshade::addon_event::draw_indexed>(OnDrawCallback);
	reshade::register_event<reshade::addon_event::present>(OnPresentCallback);
	reshade::register_event<reshade::addon_event::init_effect_runtime>(OnInitEffectRuntimeCallback);
}

void Grass::Reset()
{
	afterComposite = false;
	activeTechnique = 0;
	inPass = false;
	wasInPass = false;
}

void Grass::ModifyPass(reshade::api::command_list* cmd_list)
{
	static auto shadowState = BSGraphics::RendererShadowState::QInstance();

	// Set a new clustered shader, does not need to invalidate

	ID3D11PixelShader* originalShader = (ID3D11PixelShader*)shadowState->m_CurrentPixelShader->m_Shader;
	auto               itOriginalShader = mappedShaders.find(originalShader);
	if (itOriginalShader != mappedShaders.end()) {
		std::uint32_t techniqueID = itOriginalShader->second;
		activeTechnique = techniqueID;
		auto itCustomShader = customShaders.find(techniqueID);

		if (itCustomShader == customShaders.end()) {
			auto   defines = GetSourceDefines(techniqueID);
			Shader shader;
			shader.pixelShader = (ID3D11PixelShader*)ShaderCompiler::CompileShader(L"Data\\Shaders\\Grass\\RunGrass.hlsl", defines, "ps_5_0");
			shader.vertexShader = (ID3D11PixelShader*)ShaderCompiler::CompileShader(L"Data\\Shaders\\Grass\\RunGrass.hlsl", defines, "vs_5_0");
			customShaders.insert({ techniqueID, shader });
			itCustomShader = customShaders.find(techniqueID);
		}

		if (auto pixelShader = itCustomShader->second.pixelShader) {
			reshade::api::pipeline customShader = reshade::api::pipeline{ reinterpret_cast<std::uintptr_t>(pixelShader) };
			cmd_list->bind_pipeline(reshade::api::pipeline_stage::pixel_shader, customShader);
		}

		if (auto vertexShader = itCustomShader->second.vertexShader) {
			reshade::api::pipeline customShader = reshade::api::pipeline{ reinterpret_cast<std::uintptr_t>(vertexShader) };
			cmd_list->bind_pipeline(reshade::api::pipeline_stage::pixel_shader, customShader);
		}

		auto context = RE::BSRenderManager::GetSingleton()->GetRuntimeData().context;
		auto renderer = BSGraphics::Renderer::QInstance();

		ID3D11Buffer* buffers[1];
		context->VSGetConstantBuffers(2, 1, buffers);
		context->PSSetConstantBuffers(2, 1, buffers);

		ID3D11ShaderResourceView* views[1];
		views[0] = renderer->pDepthStencils[DEPTH_STENCIL_TARGET_MAIN].DepthSRV;
		context->PSSetShaderResources(17, 1, views);
	}
}

bool Grass::OnDraw(reshade::api::command_list* cmd_list)
{
	static auto shadowState = BSGraphics::RendererShadowState::QInstance();
	if (!shadowState->m_CurrentPixelShader) {
		return false;
	}
	ID3D11PixelShader* originalShader = (ID3D11PixelShader*)shadowState->m_CurrentPixelShader->m_Shader;
	auto               itOriginalShader = mappedShaders.find(originalShader);
	inPass = itOriginalShader != mappedShaders.end();
	if (inPass) {
		Clustered::GetSingleton()->UpdateClusters();
		ModifyPass(cmd_list);
		inPass = false;
	}
	return false;
}

bool Grass::OnDrawCallback(reshade::api::command_list* cmd_list, uint32_t, uint32_t, uint32_t, int32_t, uint32_t)
{
	return GetSingleton()->OnDraw(cmd_list);
}

void Grass::OnPresent()
{
	Reset();
}

void Grass::OnPresentCallback(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*)
{
	GetSingleton()->OnPresent();
}

std::vector<std::pair<const char*, const char*>> Grass::GetSourceDefines(uint32_t Technique)
{
	std::vector<std::pair<const char*, const char*>> defines;

	switch (Technique & ~RAW_FLAG_DO_ALPHA) {
	case RAW_TECHNIQUE_VERTEXL:
		defines.emplace_back("VERTLIT", "");
		break;
	case RAW_TECHNIQUE_FLATL:
		break;
	case RAW_TECHNIQUE_FLATL_SLOPE:
		defines.emplace_back("SLOPE", "");
		break;
	case RAW_TECHNIQUE_VERTEXL_SLOPE:
		defines.emplace_back("VERTLIT", "");
		defines.emplace_back("SLOPE", "");
		break;
	case RAW_TECHNIQUE_VERTEXL_BILLBOARD:
		defines.emplace_back("VERTLIT", "");
		defines.emplace_back("SLOPE", "");
		defines.emplace_back("BILLBOARD", "");
		break;
	case RAW_TECHNIQUE_FLATL_BILLBOARD:
		defines.emplace_back("BILLBOARD", "");
		break;
	case RAW_TECHNIQUE_FLATL_SLOPE_BILLBOARD:
		defines.emplace_back("SLOPE", "");
		defines.emplace_back("BILLBOARD", "");
		break;
	case RAW_TECHNIQUE_VERTEXL_SLOPE_BILLBOARD:
		defines.emplace_back("VERTLIT", "");
		defines.emplace_back("SLOPE", "");
		defines.emplace_back("BILLBOARD", "");
		defines.emplace_back("RENDER_DEPTH", "");
		break;
	case RAW_TECHNIQUE_RENDERDEPTH:
		defines.emplace_back("RENDER_DEPTH", "");
		break;
	default:
		break;
	}

	if (Technique & RAW_FLAG_DO_ALPHA)
		defines.emplace_back("DO_ALPHA_TEST", "");

	return defines;
}

void Grass::OnReloadEffects()
{
	for (auto& entry : customShaders) {
		if (entry.second.pixelShader) {
			entry.second.pixelShader->Release();
		}
		if (entry.second.vertexShader) {
			entry.second.vertexShader->Release();
		}
	}
	customShaders.clear();
}

void Grass::OnReloadEffectsCallback(reshade::api::effect_runtime*)
{
	GetSingleton()->OnReloadEffects();
}
void Grass::SetupTechnique(RE::BSShader* a_shader, std::uint32_t)
{
	inPass = true;
	if (mappedShaders.empty()) {
		for (auto& entry : a_shader->pixelShaders) {
			mappedShaders.insert({ entry->shader, entry->id });
		}
	}
}

void Grass::OnInitEffectRuntime(reshade::api::effect_runtime* a_runtime)
{
	runtime = a_runtime;
}

void Grass::OnInitEffectRuntimeCallback(reshade::api::effect_runtime* a_runtime)
{
	GetSingleton()->OnInitEffectRuntime(a_runtime);
}
