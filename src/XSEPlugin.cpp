
#include "RE/BSGraphicsTypes.h"
#include "ENB/ENBSeriesAPI.h"
#include "Clustered.h"
#include "Lighting.h"

//#include "Deferred.h"

ENB_API::ENBSDKALT1002* g_ENB = nullptr;

HMODULE m_hModule;

extern "C" __declspec(dllexport) const char* NAME = "Playground";
extern "C" __declspec(dllexport) const char* DESCRIPTION = "Advanced ReShade utility by doodlez";

BOOL APIENTRY DllMain(HMODULE hModule, DWORD dwReason, LPVOID)
{
	if (dwReason == DLL_PROCESS_ATTACH) m_hModule = hModule;
	return TRUE;
}


void MessageHandler(SKSE::MessagingInterface::Message* a_msg)
{
	switch (a_msg->type) {
	case SKSE::MessagingInterface::kPostLoad:
		g_ENB = reinterpret_cast<ENB_API::ENBSDKALT1002*>(ENB_API::RequestENBAPI(ENB_API::SDKVersion::V1002));
		if (g_ENB) {
			logger::info("Obtained ENB API");
		} else
			logger::info("Unable to acquire ENB API");
		break;
	}
}

void Load()
{

	if (reshade::register_addon(m_hModule)) {
		logger::info("Registered addon");
		Lighting::InstallHooks();
		Lighting::GetSingleton()->Initialise();
		Clustered::InstallHooks();
		Clustered::GetSingleton()->Initialise();
	} else {
		logger::info("ReShade not present, not installing hooks");
	}
}

