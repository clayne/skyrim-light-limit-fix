#pragma once
#include <DirectXMath.h>
#include <d3d11.h>

#include "RE/BSGraphics.h"
#include "RE/BSGraphicsTypes.h"

class Lighting
{
public:
	static Lighting* GetSingleton()
	{
		static Lighting render;
		return &render;
	}

	static void InstallHooks()
	{
		Hooks::Install();
	}

	enum class Stage
	{
		kCubemap,
		kOpaque,
		kTransparent
	};

	struct RenderTargetProperties
	{
		uint32_t    uiWidth;
		uint32_t    uiHeight;
		DXGI_FORMAT eFormat;
	};

	bool inPass = false;
	bool                                        wasInPass = false;
	bool afterComposite = false;
	Stage stage = Stage::kCubemap;
	std::map<void*, std::uint32_t>              mappedShaders;
	std::map<std::uint32_t, ID3D11PixelShader*> customShaders;

	bool                         init = false;
	BSGraphics::RenderTargetData masks;

	//std::map<std::string, BSGraphics::RenderTargetData> customTargets;

	std::uint32_t activeTechnique = 0;

	reshade::api::effect_runtime* runtime;
	

	void SetResourceName(ID3D11DeviceChild* a_resource, const char* a_format, ...);
	void CreateRenderTarget(BSGraphics::RenderTargetData& a_data, RenderTargetProperties a_properties);

	void        Initialise();
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

	
	void      ModifyPass(reshade::api::command_list* cmd_list);
	ID3DBlob* CompileShader(const wchar_t* FilePath, const std::vector<std::pair<const char*, const char*>>& Defines, const char* ProgramType);
	void      SetupResources();
	void SetupAccumulator(BSGraphics::BSShaderAccumulator* a_accumulator);
	void SetupTechnique(RE::BSShader* a_shader, std::uint32_t a_technique);
	
	void OnComposite();

protected:
	struct Hooks
	{
		struct BSLightingShader_SetupTechnique
		{
			static void thunk(RE::BSShader* a_shader, std::uint32_t a_technique)
			{
				GetSingleton()->SetupTechnique(a_shader, a_technique);
				func(a_shader, a_technique);
			}
			static inline REL::Relocation<decltype(thunk)> func;
		};

		//struct BSLightingShader_SetupGeometry
		//{
		//	static void thunk(RE::BSRenderPass* a_pass, uint32_t a_flags)
		//	{
		//		func(a_pass, a_flags);
		//	}
		//	static inline REL::Relocation<decltype(thunk)> func;
		//};

		struct BSImagespaceShaderISSAOCompositeSAO_SetupTechnique
		{
			static void thunk(RE::BSShader* a_shader, RE::BSShaderMaterial* a_material)
			{
				GetSingleton()->OnComposite();
				func(a_shader, a_material);
			}
			static inline REL::Relocation<decltype(thunk)> func;
		};

		struct BSImagespaceShaderISSAOCompositeFog_SetupTechnique
		{
			static void thunk(RE::BSShader* a_shader, RE::BSShaderMaterial* a_material)
			{
				GetSingleton()->OnComposite();
				func(a_shader, a_material);
			}
			static inline REL::Relocation<decltype(thunk)> func;
		};

		struct BSImagespaceShaderISSAOCompositeSAOFog_SetupTechnique
		{
			static void thunk(RE::BSShader* a_shader, RE::BSShaderMaterial* a_material)
			{
				GetSingleton()->OnComposite();
				func(a_shader, a_material);
			}
			static inline REL::Relocation<decltype(thunk)> func;
		};

		static void Install()
		{
			stl::write_vfunc<0x2, BSLightingShader_SetupTechnique>(RE::VTABLE_BSLightingShader[0]);
			
			
			stl::write_vfunc<0x2, BSImagespaceShaderISSAOCompositeSAO_SetupTechnique>(RE::VTABLE_BSImagespaceShaderISSAOCompositeSAO[0]);
			stl::write_vfunc<0x2, BSImagespaceShaderISSAOCompositeFog_SetupTechnique>(RE::VTABLE_BSImagespaceShaderISSAOCompositeFog[0]);
			stl::write_vfunc<0x2, BSImagespaceShaderISSAOCompositeSAOFog_SetupTechnique>(RE::VTABLE_BSImagespaceShaderISSAOCompositeSAOFog[0]);
			
			logger::info("Installed technique hooks");
		}
	};

	private:
	enum Techniques
	{
		RAW_TECHNIQUE_NONE = 0,
		RAW_TECHNIQUE_ENVMAP = 1,
		RAW_TECHNIQUE_GLOWMAP = 2,
		RAW_TECHNIQUE_PARALLAX = 3,
		RAW_TECHNIQUE_FACEGEN = 4,
		RAW_TECHNIQUE_FACEGENRGBTINT = 5,
		RAW_TECHNIQUE_HAIR = 6,
		RAW_TECHNIQUE_PARALLAXOCC = 7,
		RAW_TECHNIQUE_MTLAND = 8,
		RAW_TECHNIQUE_LODLAND = 9,
		RAW_TECHNIQUE_SNOW = 10,
		RAW_TECHNIQUE_MULTILAYERPARALLAX = 11,
		RAW_TECHNIQUE_TREE = 12,
		RAW_TECHNIQUE_LODOBJ = 13,
		RAW_TECHNIQUE_MULTIINDEXTRISHAPESNOW = 14,
		RAW_TECHNIQUE_LODOBJHD = 15,
		RAW_TECHNIQUE_EYE = 16,
		RAW_TECHNIQUE_CLOUD = 17,
		RAW_TECHNIQUE_LODLANDNOISE = 18,
		RAW_TECHNIQUE_MTLANDLODBLEND = 19,
	};

	enum
	{
		RAW_FLAG_VC = 1 << 0,
		RAW_FLAG_SKINNED = 1 << 1,
		RAW_FLAG_MODELSPACENORMALS = 1 << 2,
		RAW_FLAG_LIGHTCOUNT1 = 1 << 3,  // Probably not used
		RAW_FLAG_LIGHTCOUNT2 = 1 << 4,  // ^
		RAW_FLAG_LIGHTCOUNT3 = 1 << 5,  // ^
		RAW_FLAG_LIGHTCOUNT4 = 1 << 6,  // ^
		RAW_FLAG_LIGHTCOUNT5 = 1 << 7,  // ^
		RAW_FLAG_LIGHTCOUNT6 = 1 << 8,  // ^
		RAW_FLAG_SPECULAR = 1 << 9,
		RAW_FLAG_SOFT_LIGHTING = 1 << 10,
		RAW_FLAG_RIM_LIGHTING = 1 << 11,
		RAW_FLAG_BACK_LIGHTING = 1 << 12,
		RAW_FLAG_SHADOW_DIR = 1 << 13,
		RAW_FLAG_DEFSHADOW = 1 << 14,
		RAW_FLAG_PROJECTED_UV = 1 << 15,
		RAW_FLAG_ANISO_LIGHTING = 1 << 16,
		RAW_FLAG_AMBIENT_SPECULAR = 1 << 17,
		RAW_FLAG_WORLD_MAP = 1 << 18,
		RAW_FLAG_BASE_OBJECT_IS_SNOW = 1 << 19,
		RAW_FLAG_DO_ALPHA_TEST = 1 << 20,
		RAW_FLAG_SNOW = 1 << 21,
		RAW_FLAG_CHARACTER_LIGHT = 1 << 22,
		RAW_FLAG_ADDITIONAL_ALPHA_MASK = 1 << 23,
	};

	enum class Space
	{
		World = 0,
		Model = 1,
	};

};
