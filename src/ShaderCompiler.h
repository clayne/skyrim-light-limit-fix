#pragma once

#include "d3d11.h"

namespace ShaderCompiler
{
	ID3D11DeviceChild* CompileShader(const wchar_t* FilePath, const std::vector<std::pair<const char*, const char*>>& Defines, const char* ProgramType);
}
