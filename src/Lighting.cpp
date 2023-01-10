#include "Lighting.h"

#include "RE/BSGraphicsTypes.h"
#include "ShaderCompiler.h"
#include <d3dcompiler.h>

#include "Util.h"
#include "Clustered.h"

void Lighting::Initialise()
{
	reshade::register_event<reshade::addon_event::reshade_reloaded_effects>(OnReloadEffectsCallback);
	reshade::register_event<reshade::addon_event::draw_indexed>(OnDrawCallback);
	reshade::register_event<reshade::addon_event::present>(OnPresentCallback);
	reshade::register_event<reshade::addon_event::init_effect_runtime>(OnInitEffectRuntimeCallback);
}

void Lighting::Reset()
{
	afterComposite = false;
	activeTechnique = 0;
	inPass = false;
	wasInPass = false;
}

void Lighting::ModifyPass(reshade::api::command_list* cmd_list)
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
			customShaders.insert({ techniqueID, (ID3D11PixelShader*)ShaderCompiler::CompileShader(L"Data\\Shaders\\Lighting\\BSLightingShader.hlsl", GetSourceDefines(techniqueID), "ps_5_0") });
			itCustomShader = customShaders.find(techniqueID);
		}

		if (itCustomShader->second) {
			reshade::api::pipeline customShader = reshade::api::pipeline{ reinterpret_cast<std::uintptr_t>(itCustomShader->second) };
			cmd_list->bind_pipeline(reshade::api::pipeline_stage::pixel_shader, customShader);
		} else {
			return;
		}
	}

}

bool Lighting::OnDraw(reshade::api::command_list* cmd_list)
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

bool Lighting::OnDrawCallback(reshade::api::command_list* cmd_list, uint32_t, uint32_t, uint32_t, int32_t, uint32_t)
{
	return GetSingleton()->OnDraw(cmd_list);
}

void Lighting::OnPresent()
{
//	logger::debug("Present reset");
	Reset();
}

void Lighting::OnPresentCallback(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*)
{
	GetSingleton()->OnPresent();
}

std::vector<std::pair<const char*, const char*>> Lighting::GetSourceDefines(uint32_t Technique)
{
	std::vector<std::pair<const char*, const char*>> defines;
	uint32_t                                         subType = (Technique >> 24) & 0x3F;

	if (Technique & RAW_FLAG_VC)
		defines.emplace_back("VC", "");
	if (Technique & RAW_FLAG_SKINNED)
		defines.emplace_back("SKINNED", "");
	if (Technique & RAW_FLAG_MODELSPACENORMALS)
		defines.emplace_back("MODELSPACENORMALS", "");
	if (Technique & RAW_FLAG_SPECULAR)
		defines.emplace_back("SPECULAR", "");
	if (Technique & RAW_FLAG_SOFT_LIGHTING)
		defines.emplace_back("SOFT_LIGHTING", "");
	if (Technique & RAW_FLAG_SHADOW_DIR)
		defines.emplace_back("SHADOW_DIR", "");
	if (Technique & RAW_FLAG_DEFSHADOW)
		defines.emplace_back("DEFSHADOW", "");
	if (Technique & RAW_FLAG_RIM_LIGHTING)
		defines.emplace_back("RIM_LIGHTING", "");
	if (Technique & RAW_FLAG_BACK_LIGHTING)
		defines.emplace_back("BACK_LIGHTING", "");
	if ((Technique & RAW_FLAG_PROJECTED_UV) && subType != RAW_TECHNIQUE_HAIR)
		defines.emplace_back("PROJECTED_UV", "");
	if (Technique & RAW_FLAG_ANISO_LIGHTING)
		defines.emplace_back("ANISO_LIGHTING", "");
	if (Technique & RAW_FLAG_AMBIENT_SPECULAR)
		defines.emplace_back("AMBIENT_SPECULAR", "");
	if (Technique & RAW_FLAG_WORLD_MAP)
		defines.emplace_back("WORLD_MAP", "");
	if (Technique & RAW_FLAG_DO_ALPHA_TEST)
		defines.emplace_back("DO_ALPHA_TEST", "");
	if (Technique & RAW_FLAG_SNOW)
		defines.emplace_back("SNOW", "");
	if (Technique & RAW_FLAG_BASE_OBJECT_IS_SNOW)
		defines.emplace_back("BASE_OBJECT_IS_SNOW", "");
	if (Technique & RAW_FLAG_CHARACTER_LIGHT)
		defines.emplace_back("CHARACTER_LIGHT", "");
	if ((Technique & RAW_FLAG_PROJECTED_UV) && subType == RAW_TECHNIQUE_HAIR)
		defines.emplace_back("DEPTH_WRITE_DECALS", "");
	if (Technique & RAW_FLAG_ADDITIONAL_ALPHA_MASK)
		defines.emplace_back("ADDITIONAL_ALPHA_MASK", "");

	switch (subType) {
	case RAW_TECHNIQUE_NONE: /* Nothing */
		break;
	case RAW_TECHNIQUE_ENVMAP:
		defines.emplace_back("ENVMAP", "");
		break;
	case RAW_TECHNIQUE_GLOWMAP:
		defines.emplace_back("GLOWMAP", "");
		break;
	case RAW_TECHNIQUE_PARALLAX:
		defines.emplace_back("PARALLAX", "");
		break;
	case RAW_TECHNIQUE_FACEGEN:
		defines.emplace_back("FACEGEN", "");
		break;
	case RAW_TECHNIQUE_FACEGENRGBTINT:
		defines.emplace_back("FACEGEN_RGB_TINT", "");
		break;
	case RAW_TECHNIQUE_HAIR:
		defines.emplace_back("HAIR", "");
		break;
	case RAW_TECHNIQUE_PARALLAXOCC:
		defines.emplace_back("PARALLAX_OCC", "");
		break;
	case RAW_TECHNIQUE_MTLAND:
		defines.emplace_back("MULTI_TEXTURE", "");
		defines.emplace_back("LANDSCAPE", "");
		break;
	case RAW_TECHNIQUE_LODLAND:
		defines.emplace_back("LODLANDSCAPE", "");
		break;
	case RAW_TECHNIQUE_SNOW: /* Nothing */
		break;
	case RAW_TECHNIQUE_MULTILAYERPARALLAX:
		defines.emplace_back("MULTI_LAYER_PARALLAX", "");
		defines.emplace_back("ENVMAP", "");
		break;
	case RAW_TECHNIQUE_TREE:
		defines.emplace_back("TREE_ANIM", "");
		break;
	case RAW_TECHNIQUE_LODOBJ:
		defines.emplace_back("LODOBJECTS", "");
		break;
	case RAW_TECHNIQUE_MULTIINDEXTRISHAPESNOW:
		defines.emplace_back("MULTI_INDEX", "");
		defines.emplace_back("SPARKLE", "");
		break;
	case RAW_TECHNIQUE_LODOBJHD:
		defines.emplace_back("LODOBJECTSHD", "");
		break;
	case RAW_TECHNIQUE_EYE:
		defines.emplace_back("EYE", "");
		break;
	case RAW_TECHNIQUE_CLOUD:
		defines.emplace_back("CLOUD", "");
		defines.emplace_back("INSTANCED", "");
		break;
	case RAW_TECHNIQUE_LODLANDNOISE:
		defines.emplace_back("LODLANDSCAPE", "");
		defines.emplace_back("LODLANDNOISE", "");
		break;
	case RAW_TECHNIQUE_MTLANDLODBLEND:
		defines.emplace_back("MULTI_TEXTURE", "");
		defines.emplace_back("LANDSCAPE", "");
		defines.emplace_back("LOD_LAND_BLEND", "");
		break;
	default:
		break;
	}

	return defines;
}

void Lighting::OnReloadEffects()
{
	for (auto& entry : customShaders) {
		if (entry.second) {
			entry.second->Release();
		}
	}
	customShaders.clear();
}

void Lighting::OnReloadEffectsCallback(reshade::api::effect_runtime*)
{
	GetSingleton()->OnReloadEffects();
}
void Lighting::SetupTechnique(RE::BSShader* a_shader, std::uint32_t)
{
	//activeRawTechnique = GetRawTechnique(a_technique);
	inPass = true;
	if (mappedShaders.empty()) {
		for (auto& entry : a_shader->pixelShaders) {
			mappedShaders.insert({ entry->shader, entry->id });
		}
	}
}

void Lighting::OnComposite()
{
	afterComposite = true;
}

void Lighting::OnInitEffectRuntime(reshade::api::effect_runtime* a_runtime)
{
	runtime = a_runtime;
}

void Lighting::OnInitEffectRuntimeCallback(reshade::api::effect_runtime* a_runtime)
{
	GetSingleton()->OnInitEffectRuntime(a_runtime);
}
