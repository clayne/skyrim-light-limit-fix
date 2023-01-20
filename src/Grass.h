#pragma once
#include <DirectXMath.h>
#include <d3d11.h>

#include "RE/BSGraphics.h"
#include "RE/BSGraphicsTypes.h"
#include <map>

class Grass
{
public:
	static Grass* GetSingleton()
	{
		static Grass render;
		return &render;
	}

	static void InstallHooks()
	{
		Hooks::Install();
	}

	struct Shader
	{
		ID3D11PixelShader* pixelShader = nullptr;
		ID3D11PixelShader* vertexShader = nullptr;
	};

	bool                                        inPass = false;
	bool                                        wasInPass = false;
	bool                                        afterComposite = false;
	std::map<void*, std::uint32_t>              mappedShaders;
	std::map<std::uint32_t, Shader>             customShaders;

	bool init = false;

	std::uint32_t activeTechnique = 0;

	reshade::api::effect_runtime* runtime;

	void Initialise();
	void Reset();

	bool        OnDraw(reshade::api::command_list* cmd_list);
	static bool OnDrawCallback(reshade::api::command_list* cmd_list, uint32_t index_count, uint32_t instance_count, uint32_t first_index, int32_t vertex_offset, uint32_t first_instance);

	void        OnPresent();
	static void OnPresentCallback(reshade::api::command_queue* queue, reshade::api::swapchain* swapchain, const reshade::api::rect* source_rect, const reshade::api::rect* dest_rect, uint32_t dirty_rect_count, const reshade::api::rect* dirty_rects);

	std::vector<std::pair<const char*, const char*>> GetSourceDefines(uint32_t Technique);

	void        OnReloadEffects();
	static void OnReloadEffectsCallback(reshade::api::effect_runtime* a_runtime);

	void        OnInitEffectRuntime(reshade::api::effect_runtime* a_runtime);
	static void OnInitEffectRuntimeCallback(reshade::api::effect_runtime* a_runtime);

	RE::ShadowSceneNode* activeShadowSceneNode = nullptr;

	void ModifyPass(reshade::api::command_list* cmd_list);

	void SetupTechnique(RE::BSShader* a_shader, std::uint32_t a_technique);

protected:
	struct Hooks
	{
		struct BSGrassShader_SetupTechnique
		{
			static void thunk(RE::BSShader* a_shader, std::uint32_t a_technique)
			{
				GetSingleton()->SetupTechnique(a_shader, a_technique);
				func(a_shader, a_technique);
			}
			static inline REL::Relocation<decltype(thunk)> func;
		};

		static void Install()
		{
			stl::write_vfunc<0x2, BSGrassShader_SetupTechnique>(RE::VTABLE_BSGrassShader[0]);
			logger::info("Installed technique hooks");
		}
	};


private:
	enum Techniques
	{
		RAW_TECHNIQUE_VERTEXL = 0,
		RAW_TECHNIQUE_FLATL = 1,
		RAW_TECHNIQUE_FLATL_SLOPE = 2,
		RAW_TECHNIQUE_VERTEXL_SLOPE = 3,
		RAW_TECHNIQUE_VERTEXL_BILLBOARD = 4,
		RAW_TECHNIQUE_FLATL_BILLBOARD = 5,
		RAW_TECHNIQUE_FLATL_SLOPE_BILLBOARD = 6,
		RAW_TECHNIQUE_VERTEXL_SLOPE_BILLBOARD = 7,
		RAW_TECHNIQUE_RENDERDEPTH = 8,
	};

	enum
	{
		RAW_FLAG_DO_ALPHA = 0x10000,
	};

	struct TexSlot
	{
		enum
		{
			Base = 0,
			ShadowMask = 1,
		};
	};
};
