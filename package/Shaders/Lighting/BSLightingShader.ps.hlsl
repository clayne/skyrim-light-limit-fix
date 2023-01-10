// Skyrim Special Edition - BSLightingShader pixel shader  

// support technique: NONE, ENVMAP, GLOWMAP, PARALLAX, FACEGEN, FACEGEN_RGB_TINT, HAIR, LODLANDSCAPE, MULTI_LAYER_PARALLAX, TREE_ANIM, LODOBJECTS, LODOBJECTSHD, EYE, LODLANDNOISE
// support flags: VC, SKINNED, MODELSPACENORMALS, SPECULAR, SOFT_LIGHTING, RIM_LIGHTING, BACK_LIGHTING, SHADOW_DIR, DEFSHADOW, PROJECTED_UV, DEPTH_WRITE_DECALS, ANISO_LIGHTING, AMBIENT_SPECULAR, WORLD_MAP, BASE_OBJECT_IS_SNOW, DO_ALPHA_TEST, SNOW, CHARACTER_LIGHT


#define DEBUGLIGHTS

#if defined(ADDITIONAL_ALPHA_MASK)
const static float AAM[] = { 0.003922, 0.533333, 0.133333, 0.666667, 0.800000, 0.266667, 0.933333, 0.400000, 0.200000, 0.733333, 0.066667, 0.600000, 0.996078, 0.466667, 0.866667, 0.333333 };
#endif

#if !defined(MULTI_TEXTURE)
SamplerState DiffuseSampler : register(s0);
Texture2D<float4> TexDiffuseSampler : register(t0);
SamplerState NormalSampler : register(s1);
Texture2D<float4> TexNormalSampler : register(t1);
#if defined(MODELSPACENORMALS)
SamplerState SpecularSampler : register(s2);
Texture2D<float4> TexSpecularSampler : register(t2);
#endif
// NOTE: Parallax + ProjUV incompatible due to this
#if defined(PARALLAX)
SamplerState HeightSampler : register(s3);
Texture2D<float4> TexHeightSampler : register(t3);
#endif
// NOTE: Facegen + ProjUV incompatible due to this
#if defined(FACEGEN)
SamplerState TintSampler : register(s3);
Texture2D<float4> TexTintSampler : register(t3);
#endif
#if defined(PROJECTED_UV)
SamplerState ProjectedDiffuseSampler : register(s3);
Texture2D<float4> TexProjectedDiffuseSampler : register(t3);
#endif
#if defined(FACEGEN)
SamplerState DetailSampler : register(s4);
Texture2D<float4> TexDetailSampler : register(t4);
#endif
#if defined(ENVMAP) || defined(EYE)
SamplerState EnvSampler : register(s4);
TextureCube<float4> TexEnvSampler : register(t4);
SamplerState EnvMaskSampler : register(s5);
Texture2D<float4> TexEnvMaskSampler : register(t5);
#endif
#if defined(GLOWMAP)
SamplerState GlowSampler : register(s6);
Texture2D<float4> TexGlowSampler : register(t6);
#endif
#if defined(MULTI_LAYER_PARALLAX)
SamplerState MultiLayerParallaxSampler : register(s8);
Texture2D<float4> TexMultiLayerParallaxSampler : register(t8);
#endif
#if defined(PROJECTED_UV)
SamplerState ProjectedNormalSampler : register(s8);
Texture2D<float4> TexProjectedNormalSampler : register(t8);
#endif
#if defined(BACK_LIGHTING)
SamplerState BackLightMaskSampler : register(s9);
Texture2D<float4> TexBackLightMaskSampler : register(t9);
#endif
#if defined(PROJECTED_UV)
SamplerState ProjectedNormalDetailSampler : register(s10);
Texture2D<float4> TexProjectedNormalDetailSampler : register(t10);
#endif
#if defined(PROJECTED_UV) || defined(CHARACTER_LIGHT)
SamplerState ProjectedNoiseSampler : register(s11);
Texture2D<float4> TexProjectedNoiseSampler : register(t11);
#endif
#if defined(SOFT_LIGHTING) || defined(RIM_LIGHTING) || defined(FACEGEN)
SamplerState SubSurfaceSampler : register(s12);
Texture2D<float4> TexSubSurfaceSampler : register(t12);
#endif
#if defined(WORLD_MAP)
SamplerState WorldMapOverlayNormalSampler : register(s12);
Texture2D<float4> TexWorldMapOverlayNormalSampler : register(t12);
SamplerState WorldMapOverlayNormalSnowSampler : register(s13);
Texture2D<float4> TexWorldMapOverlayNormalSnowSampler : register(t13);
#endif
#if defined(LODLANDNOISE)
SamplerState LODNoiseSampler : register(s15);
Texture2D<float4> TexLODNoiseSampler : register(t15);
#endif
#endif

#if defined(MULTI_TEXTURE)
SamplerState MTLandDiffuseBase : register(s0);
Texture2D<float4> TexMTLandDiffuseBase : register(t0);
SamplerState MTLandDiffuse1 : register(s1);
Texture2D<float4> TexMTLandDiffuse1 : register(t1);
SamplerState MTLandDiffuse2 : register(s2);
Texture2D<float4> TexMTLandDiffuse2 : register(t2);
SamplerState MTLandDiffuse3 : register(s3);
Texture2D<float4> TexMTLandDiffuse3 : register(t3);
SamplerState MTLandDiffuse4 : register(s4);
Texture2D<float4> TexMTLandDiffuse4 : register(t4);
SamplerState MTLandDiffuse5 : register(s5);
Texture2D<float4> TexMTLandDiffuse5 : register(t5);
SamplerState MTLandNormalBase : register(s7);
Texture2D<float4> TexMTLandNormalBase : register(t7);
SamplerState MTLandNormal1 : register(s8);
Texture2D<float4> TexMTLandNormal1 : register(t8);
SamplerState MTLandNormal2 : register(s9);
Texture2D<float4> TexMTLandNormal2 : register(t9);
SamplerState MTLandNormal3 : register(s10);
Texture2D<float4> TexMTLandNormal3 : register(t10);
SamplerState MTLandNormal4 : register(s11);
Texture2D<float4> TexMTLandNormal4 : register(t11);
SamplerState MTLandNormal5 : register(s12);
Texture2D<float4> TexMTLandNormal5 : register(t12);
#endif

#if defined(LOD_LAND_BLEND)
SamplerState MTLandTerrainOverlayTexture : register(s13);
Texture2D<float4> TexMTLandTerrainOverlayTexture : register(t13);
SamplerState MTLandTerrainNoiseTexture : register(s15);
Texture2D<float4> TexMTLandTerrainNoiseTexture : register(t15);
#endif

#if defined(DEFSHADOW) || defined(SHADOW_DIR)
SamplerState ShadowMaskSampler : register(s14);
Texture2D<float4> TexShadowMaskSampler : register(t14);
#endif

float3 DirectionalLightDiffuse(float3 a_lightDirectionN, float3 a_lightColor, float3 a_Normal)
{
    float v_lightIntensity = saturate(dot(a_Normal, a_lightDirectionN));
    return a_lightColor * v_lightIntensity;
}

float3 DirectionalLightSpecular(float3 a_lightDirectionN, float3 a_lightColor, float a_specularPower, float3 a_viewDirectionN, float3 a_Normal)
{
    float3 v_halfAngle = normalize(a_lightDirectionN + a_viewDirectionN);
    float v_specIntensity = saturate(dot(v_halfAngle, a_Normal));
    float v_spec = pow(v_specIntensity, a_specularPower);

    return a_lightColor * v_spec;
}

float3 AnisotropicSpecular(float3 a_lightDirectionN, float3 a_lightColor, float a_specularPower, float3 a_viewDirectionN, float3 a_Normal, float3 a_VertexNormal)
{
    float3 v_halfAngle = normalize(a_lightDirectionN + a_viewDirectionN);
    float3 v_anisoDir = normalize(a_Normal * 0.5 + a_VertexNormal);

    float v_anisoIntensity = 1 - min(1, abs(dot(v_anisoDir, a_lightDirectionN) - dot(v_anisoDir, v_halfAngle)));
    float v_spec = 0.7 * pow(v_anisoIntensity, a_specularPower);

    return a_lightColor * v_spec * max(0, a_lightDirectionN.z);
}

float3 HairAnisotropicSpecular(float3 a_lightDirectionN, float3 a_lightColor, float a_specularPower, float3 a_viewDirectionN, float3 a_Normal, float3 a_VertexNormal, float3 a_VertexBitangent, float3 a_HairTintVertexColor)
{
    float3 v_halfAngle = normalize(a_lightDirectionN + a_viewDirectionN);
    float3 v_anisoDir = normalize(a_Normal * 0.5 + a_VertexNormal);

    float v_anisoIntensity_1 = 1 - min(1, abs(dot(v_anisoDir, a_lightDirectionN) - dot(v_anisoDir, v_halfAngle)));
    float v_spec_1 = 0.7 * pow(v_anisoIntensity_1, a_specularPower);

    float3 v_bitAnisoDir = normalize(v_anisoDir - a_VertexBitangent * 0.05);

    float v_anisoIntensity_2 = 1 - min(1, abs(dot(v_bitAnisoDir, a_lightDirectionN) - dot(v_bitAnisoDir, v_halfAngle)));
    float v_spec_2 = pow(v_anisoIntensity_2, a_specularPower);

    return a_lightColor * (v_spec_2 * a_HairTintVertexColor + v_spec_1) * max(0, a_lightDirectionN.z);
}

float3 SoftLighting(float3 a_lightDirection, float3 a_lightColor, float3 a_softMask, float a_softRolloff, float3 a_Normal)
{
    float v_softIntensity = dot(a_Normal, a_lightDirection);

    float v_soft_1 = smoothstep(-a_softRolloff, 1.0, v_softIntensity);
    float v_soft_2 = smoothstep(0, 1.0, v_softIntensity);

    float v_soft = saturate(v_soft_1 - v_soft_2);

    return a_lightColor * a_softMask * v_soft;
}

float3 RimLighting(float3 a_lightDirectionN, float3 a_lightColor, float3 a_softMask, float a_rimPower, float3 a_viewDirectionN, float3 a_Normal)
{
    float NdotV = saturate(dot(a_Normal, a_viewDirectionN));
    
    float v_rim_1 = pow(1 - NdotV, a_rimPower);
    float v_rim_2 = saturate(dot(a_viewDirectionN, -a_lightDirectionN));

    float v_rim = v_rim_1 * v_rim_2;

    return a_lightColor * a_softMask * v_rim;
}

float3 BackLighting(float3 a_lightDirectionN, float3 a_lightColor, float3 a_backMask, float3 a_Normal)
{
    float v_backIntensity = dot(a_Normal, -a_lightDirectionN);

    return a_lightColor * a_backMask * v_backIntensity;
}

float3 toGrayscale(float3 a_Color)
{
    return dot(float3(0.3, 0.59, 0.11), a_Color);
}

PS_OUTPUT main(PS_INPUT input)
{
    PS_OUTPUT output;

#if defined(HAS_VIEW_DIRECTION_VECTOR_OUTPUT)
    float3 v_ViewDirectionVec = normalize(input.ViewDirectionVec);
#else
    // sometimes used for calculations when there's no actual view direction vec
    float3 v_ViewDirectionVec = normalize(float3(1, 1, 1));
#endif

#if defined(PARALLAX) || defined(PARALLAX_OCC) || defined(MULTI_LAYER_PARALLAX)
    // Note: Row-Major
    // This is how Bethesda does it in MLP, which generates mul+mad+mad instead of having to transpose the matrix before doing 3 dp3s
#if defined(DRAW_IN_WORLDSPACE)
    float3x3 v_CommonTangentMatrix = float3x3(input.TangentWorldTransform0.xyz, input.TangentWorldTransform1.xyz, input.TangentWorldTransform2.xyz);
#else
    float3x3 v_CommonTangentMatrix = float3x3(input.TangentModelTransform0.xyz, input.TangentModelTransform1.xyz, input.TangentModelTransform2.xyz);
#endif
    float3 v_TangentViewDirection = mul(v_ViewDirectionVec.xyz, v_CommonTangentMatrix);

    float3 v_TangentViewDirectionN = normalize(v_TangentViewDirection);
#endif

#if defined(PARALLAX)
    float height = TexHeightSampler.Sample(HeightSampler, input.TexCoords.xy).x * 0.0800 - 0.0400;
#if defined(FIX_VANILLA_BUGS)
    float2 v_TexCoords = v_TangentViewDirection.xy * height + input.TexCoords.xy;
#else
    float2 v_TexCoords = v_ViewDirectionVec.xy * height + input.TexCoords.xy;
#endif
#else
    float2 v_TexCoords = input.TexCoords.xy;
#endif

#if defined(PARALLAX_OCC)
    // implement here
#endif

#if defined(MULTI_TEXTURE)
#if defined(SNOW)
    float v_bEnableSnowMask = LandscapeTexture5to6IsSnow.z;
    float v_iLandscapeMultiNormalTilingFactor = LandscapeTexture5to6IsSnow.w;
    float v_NormalIsTiled = v_iLandscapeMultiNormalTilingFactor != 1.000000;
    float2 v_TiledCoords = v_TexCoords.xy * v_iLandscapeMultiNormalTilingFactor;
#endif

    float4 v_DiffuseBase = TexMTLandDiffuseBase.Sample(MTLandDiffuseBase, v_TexCoords.xy).xyzw;
#if defined(SNOW)
    // if bEnableSnowMask = 0, this = 1
    // if bEnableSnowMask = 1, this = v_DiffuseBase.w, which is the snow mask channel of the texture
    float v_DiffuseBaseIsSnow = lerp(1, v_DiffuseBase.w, v_bEnableSnowMask);
#endif

    float4 v_NormalBase = TexMTLandNormalBase.Sample(MTLandNormalBase, v_TexCoords.xy).xyzw;

#if defined(SNOW)
    if (v_NormalIsTiled && v_DiffuseBaseIsSnow > 0.0)
    {
        float3 v_NormalBaseTiled = TexMTLandNormalBase.Sample(MTLandNormalBase, v_TiledCoords.xy).xyz;
        v_NormalBaseTiled = v_NormalBaseTiled * 2 - 1;
        float v_TiledFactor = v_NormalBase.z * 2;
        v_NormalBase.xyz = v_NormalBase.xyz * 2 - float3(1, 1, 0);
        v_NormalBaseTiled = v_NormalBaseTiled * float3(-1, -1, 0);
        float v_UntiledFactor = dot(v_NormalBase.xyz, v_NormalBaseTiled);

        v_NormalBase.xyz = normalize(v_NormalBase.xyz * v_UntiledFactor - v_NormalBaseTiled * v_TiledFactor);
    }
    else
    {
        v_NormalBase.xyz = v_NormalBase.xyz * 2 - 1;
    }
#else
    v_NormalBase.xyz = v_NormalBase.xyz * 2 - 1;
#endif

    float4 v_Diffuse1 = TexMTLandDiffuse1.Sample(MTLandDiffuse1, v_TexCoords.xy).xyzw;
#if defined(SNOW)
    // if bEnableSnowMask = 0, this = 1
    // if bEnableSnowMask = 1, this = v_Diffuse1.w, which is the snow mask channel of the texture
    float v_Diffuse1IsSnow = lerp(1, v_Diffuse1.w, v_bEnableSnowMask);
#endif

    float4 v_Normal1 = TexMTLandNormal1.Sample(MTLandNormal1, v_TexCoords.xy).xyzw;

#if defined(SNOW)
    if (v_NormalIsTiled && v_Diffuse1IsSnow > 0.0)
    {
        float3 v_Normal1Tiled = TexMTLandNormal1.Sample(MTLandNormal1, v_TiledCoords.xy).xyz;
        v_Normal1Tiled = v_Normal1Tiled * 2 - 1;
        float v_TiledFactor = v_Normal1.z * 2;
        v_Normal1.xyz = v_Normal1.xyz * 2 - float3(1, 1, 0);
        v_Normal1Tiled = v_Normal1Tiled * float3(-1, -1, 0);
        float v_UntiledFactor = dot(v_Normal1.xyz, v_Normal1Tiled);

        v_Normal1.xyz = normalize(v_Normal1.xyz * v_UntiledFactor - v_Normal1Tiled * v_TiledFactor);
    }
    else
    {
        v_Normal1.xyz = v_Normal1.xyz * 2 - 1;
    }
#else
    v_Normal1.xyz = v_Normal1.xyz * 2 - 1;
#endif

    float4 v_Diffuse2 = TexMTLandDiffuse2.Sample(MTLandDiffuse2, v_TexCoords.xy).xyzw;
#if defined(SNOW)
    // if bEnableSnowMask = 0, this = 1
    // if bEnableSnowMask = 1, this = v_Diffuse2.w, which is the snow mask channel of the texture
    float v_Diffuse2IsSnow = lerp(1, v_Diffuse2.w, v_bEnableSnowMask);
#endif

    float4 v_Normal2 = TexMTLandNormal2.Sample(MTLandNormal2, v_TexCoords.xy).xyzw;

#if defined(SNOW)
    if (v_NormalIsTiled && v_Diffuse2IsSnow > 0.0)
    {
        float3 v_Normal2Tiled = TexMTLandNormal2.Sample(MTLandNormal2, v_TiledCoords.xy).xyz;
        v_Normal2Tiled = v_Normal2Tiled * 2 - 1;
        float v_TiledFactor = v_Normal2.z * 2;
        v_Normal2.xyz = v_Normal2.xyz * 2 - float3(1, 1, 0);
        v_Normal2Tiled = v_Normal2Tiled * float3(-1, -1, 0);
        float v_UntiledFactor = dot(v_Normal2.xyz, v_Normal2Tiled);

        v_Normal2.xyz = normalize(v_Normal2.xyz * v_UntiledFactor - v_Normal2Tiled * v_TiledFactor);
    }
    else
    {
        v_Normal2.xyz = v_Normal2.xyz * 2 - 1;
    }
#else
    v_Normal2.xyz = v_Normal2.xyz * 2 - 1;
#endif

    float4 v_Diffuse3 = TexMTLandDiffuse3.Sample(MTLandDiffuse3, v_TexCoords.xy).xyzw;
#if defined(SNOW)
    // if bEnableSnowMask = 0, this = 1
    // if bEnableSnowMask = 1, this = v_Diffuse3.w, which is the snow mask channel of the texture
    float v_Diffuse3IsSnow = lerp(1, v_Diffuse3.w, v_bEnableSnowMask);
#endif

    float4 v_Normal3 = TexMTLandNormal3.Sample(MTLandNormal3, v_TexCoords.xy).xyzw;

#if defined(SNOW)
    if (v_NormalIsTiled && v_Diffuse3IsSnow > 0.0)
    {
        float3 v_Normal3Tiled = TexMTLandNormal3.Sample(MTLandNormal3, v_TiledCoords.xy).xyz;
        v_Normal3Tiled = v_Normal3Tiled * 2 - 1;
        float v_TiledFactor = v_Normal3.z * 2;
        v_Normal3.xyz = v_Normal3.xyz * 2 - float3(1, 1, 0);
        v_Normal3Tiled = v_Normal3Tiled * float3(-1, -1, 0);
        float v_UntiledFactor = dot(v_Normal3.xyz, v_Normal3Tiled);

        v_Normal3.xyz = normalize(v_Normal3.xyz * v_UntiledFactor - v_Normal3Tiled * v_TiledFactor);
    }
    else
    {
        v_Normal3.xyz = v_Normal3.xyz * 2 - 1;
    }
#else
    v_Normal3.xyz = v_Normal3.xyz * 2 - 1;
#endif

    float4 v_Diffuse4 = TexMTLandDiffuse4.Sample(MTLandDiffuse4, v_TexCoords.xy).xyzw;
#if defined(SNOW)
    // if bEnableSnowMask = 0, this = 1
    // if bEnableSnowMask = 1, this = v_Diffuse4.w, which is the snow mask channel of the texture
    float v_Diffuse4IsSnow = lerp(1, v_Diffuse4.w, v_bEnableSnowMask);
#endif

    float4 v_Normal4 = TexMTLandNormal4.Sample(MTLandNormal4, v_TexCoords.xy).xyzw;

#if defined(SNOW)
    if (v_NormalIsTiled && v_Diffuse4IsSnow > 0.0)
    {
        float3 v_Normal4Tiled = TexMTLandNormal4.Sample(MTLandNormal4, v_TiledCoords.xy).xyz;
        v_Normal4Tiled = v_Normal4Tiled * 2 - 1;
        float v_TiledFactor = v_Normal4.z * 2;
        v_Normal4.xyz = v_Normal4.xyz * 2 - float3(1, 1, 0);
        v_Normal4Tiled = v_Normal4Tiled * float3(-1, -1, 0);
        float v_UntiledFactor = dot(v_Normal4.xyz, v_Normal4Tiled);

        v_Normal4.xyz = normalize(v_Normal4.xyz * v_UntiledFactor - v_Normal4Tiled * v_TiledFactor);
    }
    else
    {
        v_Normal4.xyz = v_Normal4.xyz * 2 - 1;
    }
#else
    v_Normal4.xyz = v_Normal4.xyz * 2 - 1;
#endif

    float4 v_Diffuse5 = TexMTLandDiffuse5.Sample(MTLandDiffuse5, v_TexCoords.xy).xyzw;
#if defined(SNOW)
    // if bEnableSnowMask = 0, this = 1
    // if bEnableSnowMask = 1, this = v_Diffuse5.w, which is the snow mask channel of the texture
    float v_Diffuse5IsSnow = lerp(1, v_Diffuse5.w, v_bEnableSnowMask);
#endif

    float4 v_Normal5 = TexMTLandNormal5.Sample(MTLandNormal5, v_TexCoords.xy).xyzw;

#if defined(SNOW)
    if (v_NormalIsTiled && v_Diffuse5IsSnow > 0.0)
    {
        float3 v_Normal5Tiled = TexMTLandNormal5.Sample(MTLandNormal5, v_TiledCoords.xy).xyz;
        v_Normal5Tiled = v_Normal5Tiled * 2 - 1;
        float v_TiledFactor = v_Normal5.z * 2;
        v_Normal5.xyz = v_Normal5.xyz * 2 - float3(1, 1, 0);
        v_Normal5Tiled = v_Normal5Tiled * float3(-1, -1, 0);
        float v_UntiledFactor = dot(v_Normal5.xyz, v_Normal5Tiled);

        v_Normal5.xyz = normalize(v_Normal5.xyz * v_UntiledFactor - v_Normal5Tiled * v_TiledFactor);
    }
    else
    {
        v_Normal5.xyz = v_Normal5.xyz * 2 - 1;
    }
#else
    v_Normal5.xyz = v_Normal5.xyz * 2 - 1;
#endif

    float4 v_Diffuse = float4(  
        v_DiffuseBase.xyz * input.BlendWeight0.x
        + v_Diffuse1.xyz * input.BlendWeight0.y
        + v_Diffuse2.xyz * input.BlendWeight0.z
        + v_Diffuse3.xyz * input.BlendWeight0.w
        + v_Diffuse4.xyz * input.BlendWeight1.x
        + v_Diffuse5.xyz * input.BlendWeight1.y,
        0);

    float4 v_Normal = v_NormalBase.xyzw * input.BlendWeight0.x
        + v_Normal1.xyzw * input.BlendWeight0.y
        + v_Normal2.xyzw * input.BlendWeight0.z
        + v_Normal3.xyzw * input.BlendWeight0.w
        + v_Normal4.xyzw * input.BlendWeight1.x
        + v_Normal5.xyzw * input.BlendWeight1.y;

#if defined(SNOW)
    float4 v_SnowBlendFactors1to4 = LandscapeTexture1to4IsSnow.xyzw * input.BlendWeight0.xyzw;
    float2 v_SnowBlendFactors5to6 = LandscapeTexture5to6IsSnow.xy * input.BlendWeight1.xy;

    float v_MTLandDoSnowRim = v_DiffuseBaseIsSnow * v_SnowBlendFactors1to4.x +
        v_Diffuse1IsSnow * v_SnowBlendFactors1to4.y +
        v_Diffuse2IsSnow * v_SnowBlendFactors1to4.z +
        v_Diffuse3IsSnow * v_SnowBlendFactors1to4.w +
        v_Diffuse4IsSnow * v_SnowBlendFactors5to6.x +
        v_Diffuse5IsSnow * v_SnowBlendFactors5to6.y;
#endif

    // this code is nearly identical to the LODLANDNOISE code later on
#if defined(LOD_LAND_BLEND)
    float4 v_TerrainOverlay = TexMTLandTerrainOverlayTexture.Sample(MTLandTerrainOverlayTexture, input.TexCoords.zw).xyzw;
    float v_LODBlendFactor = 0.800 * smoothstep(0.4, 1.0, dot(v_TerrainOverlay.xyz, float3(0.550000, 0.550000, 0.550000)));
    float2 v_NoiseCoords = input.TexCoords.zw * 3;
    float v_TexNoise = TexMTLandTerrainNoiseTexture.Sample(MTLandTerrainNoiseTexture, v_NoiseCoords).x;
    float v_Noise = lerp(v_TexNoise, 0.370000, v_LODBlendFactor) * 0.833333 + 0.370000;
    float v_LandLODBlendFactor = input.BlendWeight1.w * LODTexParams.z; // LODTexParams.z is either 0 or 1
    v_Diffuse = lerp(v_Diffuse, v_TerrainOverlay * v_Noise, v_LandLODBlendFactor);
    v_Normal.xyz = lerp(v_Normal.xyz, float3(0, 0, 1), v_LandLODBlendFactor);
    // note: specular power
    v_Normal.w = v_Normal.w - v_Normal.w * v_LandLODBlendFactor;
#endif
#else
    float4 v_Diffuse = TexDiffuseSampler.Sample(DiffuseSampler, v_TexCoords.xy).xyzw;

#if defined(MODELSPACENORMALS)
    float3 v_Normal = TexNormalSampler.Sample(NormalSampler, v_TexCoords.xy).xzy;
#else
    // save original for MultiLayerParallax
    float4 v_OrigNormal = TexNormalSampler.Sample(NormalSampler, v_TexCoords.xy).xyzw;
    float4 v_Normal = v_OrigNormal;
#endif

#if defined(LODLANDSCAPE)
    v_Normal.xyz = v_Normal.xyz - 0.5;
    v_Normal.xyz = 2 * v_Normal.xyz;
#else
    v_Normal.xyz = v_Normal.xyz * 2.0 - 1.0;
#endif
#endif

#if defined(LODLANDSCAPE)
    float v_SpecularPower = 0;
#elif defined(MODELSPACENORMALS)
    float v_SpecularPower = TexSpecularSampler.Sample(SpecularSampler, v_TexCoords.xy).x;
#else
    float v_SpecularPower = v_Normal.w;
#endif

#if defined(SOFT_LIGHTING) || defined(RIM_LIGHTING)
    float3 v_SubSurfaceTexMask = TexSubSurfaceSampler.Sample(SubSurfaceSampler, v_TexCoords.xy).xyz;
#endif

#if defined(BACK_LIGHTING)
    float3 v_BackLightingTexMask = TexBackLightMaskSampler.Sample(BackLightMaskSampler, v_TexCoords.xy).xyz;
#endif

#if defined(SOFT_LIGHTING)
    float v_SoftRolloff = LightingEffectParams.x; // fSubSurfaceLightRolloff
#endif

#if defined(RIM_LIGHTING)
    float v_RimPower = LightingEffectParams.y; // fRimLightPower
#endif

#if defined(FACEGEN) || defined(FACEGEN_RGB_TINT)
#if defined(FACEGEN)
    float3 v_DetailColor = TexDetailSampler.Sample(DetailSampler, v_TexCoords.xy).xyz;
    // the compiler optimizes this in a way different from the vanilla shader so we may have slightly difference precision but no one will notice
    v_DetailColor = (v_DetailColor + (1.0 / 255.0)) * (255.0 / 64.0);

    float3 v_TintColor = TexTintSampler.Sample(TintSampler, v_TexCoords.xy).xyz;
#elif defined(FACEGEN_RGB_TINT)
    // these are close to 258/255 and 254/255
    float3 v_DetailColor = float3(1.01172, 0.996094, 1.01172);
    float3 v_TintColor = TintColor.xyz;
#endif
    // probably some known blend function?
    float3 v_TintDiffuseOverlay = v_Diffuse.xyz * v_Diffuse.xyz + 2 * (v_TintColor * v_Diffuse.xyz) - 2 * (v_TintColor * v_Diffuse.xyz) * v_Diffuse.xyz;

    v_Diffuse.xyz = v_TintDiffuseOverlay * v_DetailColor;
#endif

    int v_TotalLightCount = min(7, NumLightNumShadowLight.x);
#if defined(DEFSHADOW) || defined(SHADOW_DIR)
    int v_ShadowLightCount = min(4, NumLightNumShadowLight.y);
#endif

#if (defined(ANISO_LIGHTING) || defined(WORLD_MAP) || defined(SNOW)) && !defined(MODELSPACENORMALS)
#if defined(DRAW_IN_WORLDSPACE)
    float3 v_VertexNormal = float3(input.TangentWorldTransform0.z, input.TangentWorldTransform1.z, input.TangentWorldTransform2.z);
    float3 v_VertexNormalN = normalize(v_VertexNormal);

#if defined(HAIR)
    float3 v_VertexBitangent = float3(input.TangentWorldTransform0.x, input.TangentWorldTransform1.x, input.TangentWorldTransform2.x);
#endif
#else
    float3 v_VertexNormal = float3(input.TangentModelTransform0.z, input.TangentModelTransform1.z, input.TangentModelTransform2.z);
    float3 v_VertexNormalN = normalize(v_VertexNormal);

#if defined(HAIR)
    float3 v_VertexBitangent = float3(input.TangentModelTransform0.x, input.TangentModelTransform1.x, input.TangentModelTransform2.x);
#endif
#endif
#endif

#if (defined(WORLD_MAP) || defined(LODLANDNOISE)) && !defined(LODOBJECTS)
    float v_LODBlendFactor = smoothstep(0.4, 1.0, dot(v_Diffuse.xyz, float3(0.550000, 0.550000, 0.550000)));
#if !defined(WORLD_MAP)
    v_LODBlendFactor = 0.800 * v_LODBlendFactor;
#endif
#endif

#if defined(LODLANDNOISE)
    float2 v_NoiseCoords = v_TexCoords * 3;
    float v_TexNoise = TexLODNoiseSampler.Sample(LODNoiseSampler, v_NoiseCoords.xy).x;
    float v_Noise = lerp(v_TexNoise, 0.370000, v_LODBlendFactor) * 0.833333 + 0.370000;
    v_Diffuse.xyz = v_Diffuse.xyz * v_Noise;
#endif

    // this is always MSN and uses the snow sampler too
#if defined(WORLD_MAP) && defined(LODLANDSCAPE)
    float3 v_NormalN = normalize(v_Normal.xyz);
    float3 v_AdjNormal = max(float3(0.01, 0.01, 0.01), pow(7 * (abs(v_NormalN) - 0.200000), 3));
    v_AdjNormal = v_AdjNormal / dot(v_AdjNormal, float3(1, 1, 1));

    float v_MapMenuOverlayScale = WorldMapOverlayParametersPS.x;
    float v_MapMenuOverlaySnowScale = WorldMapOverlayParametersPS.w;

    float3x3 v_WorldMapOverlayNormalTransform = float3x3(
        TexWorldMapOverlayNormalSampler.Sample(WorldMapOverlayNormalSampler, input.WorldMapVertexPos.yz * v_MapMenuOverlayScale).xyz,
        TexWorldMapOverlayNormalSampler.Sample(WorldMapOverlayNormalSampler, input.WorldMapVertexPos.xz * v_MapMenuOverlayScale).xyz,
        TexWorldMapOverlayNormalSampler.Sample(WorldMapOverlayNormalSampler, input.WorldMapVertexPos.xy * v_MapMenuOverlayScale).xyz
        );

    float3x3 v_WorldMapOverlayNormalSnowTransform = float3x3(
        TexWorldMapOverlayNormalSnowSampler.Sample(WorldMapOverlayNormalSnowSampler, input.WorldMapVertexPos.yz * v_MapMenuOverlaySnowScale).xyz,
        TexWorldMapOverlayNormalSnowSampler.Sample(WorldMapOverlayNormalSnowSampler, input.WorldMapVertexPos.xz * v_MapMenuOverlaySnowScale).xyz,
        TexWorldMapOverlayNormalSnowSampler.Sample(WorldMapOverlayNormalSnowSampler, input.WorldMapVertexPos.xy * v_MapMenuOverlaySnowScale).xyz
        );

    // NOTE: row vector/row-major matrix
    float3 v_WorldMapOverlayNormal = mul(v_AdjNormal, v_WorldMapOverlayNormalTransform);
    float3 v_WorldMapOverlayNormalSnow = mul(v_AdjNormal, v_WorldMapOverlayNormalSnowTransform);

    float3 v_BlendedWorldMapOverlayNormal = normalize(2 * (lerp(v_WorldMapOverlayNormal, v_WorldMapOverlayNormalSnow, v_LODBlendFactor) - 0.5));

    float v_WMapNormalBlendFactor = saturate(1.5 - smoothstep(0.95, 1.0, v_Normal.z));

    float3 v_Tangent = normalize(float3(v_Normal.z, 0, -v_Normal.x));
    float3 v_Bitangent = normalize(cross(v_Tangent.xyz, v_Normal.xyz));

    float3x3 v_TBN = float3x3(v_Tangent, v_Bitangent, v_Normal.xyz);

    float3 v_BlendedWorldMapOverlayNormalWMapSpace = normalize(mul(v_BlendedWorldMapOverlayNormal, v_TBN));
    float v_LengthSquared = dot(v_BlendedWorldMapOverlayNormalWMapSpace, v_BlendedWorldMapOverlayNormalWMapSpace);

    if (v_LengthSquared > 0.999 && v_LengthSquared < 1.001)
    {
        v_Normal.xyz = lerp(v_Normal.xyz, v_BlendedWorldMapOverlayNormalWMapSpace, v_WMapNormalBlendFactor);
    }  
#endif

    // this is always not MSN and doesn't use the snow sampler
#if defined(WORLD_MAP) && (defined(LODOBJECTS) || defined(LODOBJECTSHD))
    float3 v_AdjNormal = max(float3(0.01, 0.01, 0.01), pow(7 * (abs(v_VertexNormalN) - 0.200000), 3));
    v_AdjNormal = v_AdjNormal / dot(v_AdjNormal, float3(1, 1, 1));

    float v_MapMenuOverlayScale = WorldMapOverlayParametersPS.x;

    float3x3 v_WorldMapOverlayNormalTransform = float3x3(
        TexWorldMapOverlayNormalSampler.Sample(WorldMapOverlayNormalSampler, input.WorldMapVertexPos.yz * v_MapMenuOverlayScale).xyz,
        TexWorldMapOverlayNormalSampler.Sample(WorldMapOverlayNormalSampler, input.WorldMapVertexPos.xz * v_MapMenuOverlayScale).xyz,
        TexWorldMapOverlayNormalSampler.Sample(WorldMapOverlayNormalSampler, input.WorldMapVertexPos.xy * v_MapMenuOverlayScale).xyz
        );

    float3 v_WorldMapOverlayNormal = normalize(2 * (mul(v_AdjNormal, v_WorldMapOverlayNormalTransform) - 0.5));

    float v_MapMenuOverlayNormalStrength = WorldMapOverlayParametersPS.z;

    v_Normal.xyz = lerp(v_WorldMapOverlayNormal.xyz, v_Normal.xyz, v_MapMenuOverlayNormalStrength);
#endif

    float4 v_CommonSpaceNormal;
    
#if defined(MODELSPACENORMALS)
#if defined(DRAW_IN_WORLDSPACE) 
    v_CommonSpaceNormal.xyz = normalize(float3(
        dot(input.ModelWorldTransform0.xyz, v_Normal.xyz),
        dot(input.ModelWorldTransform1.xyz, v_Normal.xyz),
        dot(input.ModelWorldTransform2.xyz, v_Normal.xyz)
        ));
#else
    v_CommonSpaceNormal.xyz = v_Normal.xyz;
#endif
#elif defined(DRAW_IN_WORLDSPACE)
    v_CommonSpaceNormal.xyz = normalize(float3(
        dot(input.TangentWorldTransform0.xyz, v_Normal.xyz),
        dot(input.TangentWorldTransform1.xyz, v_Normal.xyz),
        dot(input.TangentWorldTransform2.xyz, v_Normal.xyz)
        ));
#else
    v_CommonSpaceNormal.xyz = normalize(float3(
        dot(input.TangentModelTransform0.xyz, v_Normal.xyz),
        dot(input.TangentModelTransform1.xyz, v_Normal.xyz),
        dot(input.TangentModelTransform2.xyz, v_Normal.xyz)
        ));
#endif

    float3 v_CommonSpaceVertexPos;

#if defined(WORLD_MAP)
    v_CommonSpaceVertexPos = input.WorldMapVertexPos;
#elif defined(DRAW_IN_WORLDSPACE)
    v_CommonSpaceVertexPos = input.WorldSpaceVertexPos;
#else
    v_CommonSpaceVertexPos = input.ModelSpaceVertexPos;
#endif


// note: MULTIINDEXTRISHAPE technique has different code here
#if defined(PROJECTED_UV)
    float2 v_ProjectedUVCoords = input.TexCoords.zw * ProjectedUVParams.z;
    float v_ProjUVNoise = TexProjectedNoiseSampler.Sample(ProjectedNoiseSampler, v_ProjectedUVCoords.xy).x;
    float3 v_ProjDirN = normalize(input.ProjDir.xyz);
    float v_NdotP = dot(v_CommonSpaceNormal.xyz, v_ProjDirN.xyz);
#if defined(LODOBJECTSHD)
    float v_ProjDiffuseIntensity = (-0.5 + input.VertexColor.w) * 2.5 + v_NdotP - ProjectedUVParams.w - (ProjectedUVParams.x * v_ProjUVNoise);
#elif defined(TREE_ANIM)
    float v_ProjDiffuseIntensity = v_NdotP - ProjectedUVParams.w - (ProjectedUVParams.x * v_ProjUVNoise);
#else
    float v_ProjDiffuseIntensity = v_NdotP * input.VertexColor.w - ProjectedUVParams.w - (ProjectedUVParams.x * v_ProjUVNoise);
#endif
#if defined(SNOW)
    float v_ProjUVDoSnowRim = 0;
#endif
    // ProjectedUVParams3.w = EnableProjectedNormals
    if (ProjectedUVParams3.w > 0.5)
    {
        // fProjectedUVDiffuseNormalTilingScale
        float2 v_ProjectedUVDiffuseNormalCoords = v_ProjectedUVCoords * ProjectedUVParams3.x;
        // fProjectedUVNormalDetailTilingScale
        float2 v_ProjectedUVNormalDetailCoords = v_ProjectedUVCoords * ProjectedUVParams3.y;

        float3 v_ProjectedNormal = TexProjectedNormalSampler.Sample(ProjectedNormalSampler, v_ProjectedUVDiffuseNormalCoords.xy).xyz;
        v_ProjectedNormal = v_ProjectedNormal * 2 - 1;
        float3 v_ProjectedNormalDetail = TexProjectedNormalDetailSampler.Sample(ProjectedNormalDetailSampler, v_ProjectedUVNormalDetailCoords.xy).xyz;

        float3 v_ProjectedNormalCombined = v_ProjectedNormalDetail * 2 + float3(v_ProjectedNormal.x, v_ProjectedNormal.y, -1);
        v_ProjectedNormalCombined.xy = v_ProjectedNormalCombined.xy + float2(-1, -1);
        v_ProjectedNormalCombined.z = v_ProjectedNormalCombined.z * v_ProjectedNormal.z;

        float3 v_ProjectedNormalCombinedN = normalize(v_ProjectedNormalCombined);

        float3 v_ProjectedDiffuse = TexProjectedDiffuseSampler.Sample(ProjectedDiffuseSampler, v_ProjectedUVDiffuseNormalCoords.xy).xyz;

        float v_AdjProjDiffuseIntensity = smoothstep(-0.100000, 0.100000, v_ProjDiffuseIntensity);

        // note that this modifies the original normal, not the common space one that is used for lighting calculation
        // it ends up only being used later on for the view space normal used for the normal map output which is used for later image space shaders
        // unsure if this is a bug
        v_Normal.xyz = lerp(v_Normal.xyz, v_ProjectedNormalCombinedN.xyz, v_AdjProjDiffuseIntensity);
        v_Diffuse.xyz = lerp(v_Diffuse.xyz, v_ProjectedDiffuse.xyz * ProjectedUVParams2.xyz, v_AdjProjDiffuseIntensity);
#if defined(SNOW)
        v_ProjUVDoSnowRim = -1;
#if defined(BASE_OBJECT_IS_SNOW)
        output.SnowMask.y = min(1, v_AdjProjDiffuseIntensity + v_Diffuse.w);
#else
        output.SnowMask.y = v_AdjProjDiffuseIntensity;
#endif
#endif
    }
    else
    {
        if (v_ProjDiffuseIntensity > 0)
        {
            v_Diffuse.xyz = ProjectedUVParams2.xyz;
#if defined(SNOW)
            v_ProjUVDoSnowRim = -1;
#if defined(BASE_OBJECT_IS_SNOW)
            output.SnowMask.y = min(1, v_ProjDiffuseIntensity + v_Diffuse.w);
#else
            output.SnowMask.y = v_ProjDiffuseIntensity;
#endif
#endif
        }
#if defined(SNOW)
        else
        {
            output.SnowMask.y = 0;
        }
#endif
    }
#endif

#if defined(WORLD_MAP) && ((defined(LODLANDSCAPE) || defined(LODOBJECTSHD)) || (defined(LODOBJECTS) && defined(PROJECTED_UV)))
#if defined(LODOBJECTS)
    float v_LODBlendFactor = saturate(v_ProjDiffuseIntensity * 10);
    float v_AdjLODBlendFactor = v_LODBlendFactor * 0.5;
#else
    float v_AdjLODBlendFactor = v_LODBlendFactor * 0.2 + 0.3;
#endif

    float3 v_DiffuseTint = v_LODBlendFactor * float3(0.270, 0.281, 0.441) + float3(0.078, 0.098, 0.465);

    v_DiffuseTint.xy = max(2 * v_DiffuseTint.xy, v_Diffuse.xy);

    if (v_DiffuseTint.z > 0.5)
    {
        v_DiffuseTint.z = max(2 * (v_LODBlendFactor * 0.441 - 0.035), v_Diffuse.z);
    }
    else
    {
        v_DiffuseTint.z = min(v_DiffuseTint.z, v_Diffuse.z);
    }

    v_Diffuse.xyz = lerp(v_Diffuse.xyz, v_DiffuseTint.xyz, v_AdjLODBlendFactor);
#endif

#if defined(DEFSHADOW) || defined(SHADOW_DIR)
    float4 v_ShadowMask;
#if !defined(SHADOW_DIR)
    if (v_ShadowLightCount > 0)
    {
#endif
        float2 DRes_Inv = float2(DynamicRes_InvWidthX_InvHeightY_WidthClampZ_HeightClampW.xy);
        float2 DRes = float2(DynamicRes_WidthX_HeightY_PreviousWidthZ_PreviousHeightW.xy);
        float DRes_WidthClamp = DynamicRes_InvWidthX_InvHeightY_WidthClampZ_HeightClampW.z;

        float2 v_ShadowMaskPos = (DRes_Inv.xy * input.ProjVertexPos.xy * VPOSOffset.xy + VPOSOffset.zw) * DRes.xy;
        // Uses the Height instead of HeightClamp for clamping; HeightClamp is unusued anywhere else in the shader
        // Presumably this is intentional but who knows 
        v_ShadowMaskPos = clamp(float2(0, 0), float2(DRes_WidthClamp, DRes.y), v_ShadowMaskPos);

        v_ShadowMask = TexShadowMaskSampler.Sample(ShadowMaskSampler, v_ShadowMaskPos).xyzw;
#if !defined(SHADOW_DIR)
    }
    else
    {
        v_ShadowMask = float4(1, 1, 1, 1);
    }
#endif
#endif

    float3 v_DiffuseAccumulator = 0;

#if defined(SPECULAR)
    float3 v_SpecularAccumulator = 0;
#if defined(MULTI_TEXTURE)
    // blend specular shininess
    float v_SpecularShininess = dot(LandscapeTexture1to4IsSpecPower.xyzw, input.BlendWeight0.xyzw);
    v_SpecularShininess += LandscapeTexture5to6IsSpecPower.x * input.BlendWeight1.x + LandscapeTexture5to6IsSpecPower.y * input.BlendWeight1.y;
#else
    float v_SpecularShininess = SpecularColor.w;
#endif
#endif

#if defined(SHADOW_DIR)
    float v_DirLightShadowedFactor = v_ShadowMask.x;
    float3 v_DirLightColor = DirLightColor.xyz * v_DirLightShadowedFactor;
#else
    float3 v_DirLightColor = DirLightColor.xyz;
#endif
    // directional light
    v_DiffuseAccumulator = DirectionalLightDiffuse(DirLightDirection.xyz, v_DirLightColor, v_CommonSpaceNormal.xyz);

#if defined(SOFT_LIGHTING)
    v_DiffuseAccumulator += SoftLighting(DirLightDirection.xyz, v_DirLightColor, v_SubSurfaceTexMask, v_SoftRolloff, v_CommonSpaceNormal.xyz);
#endif

#if defined(RIM_LIGHTING)
    v_DiffuseAccumulator += RimLighting(DirLightDirection.xyz, v_DirLightColor, v_SubSurfaceTexMask, v_RimPower, v_ViewDirectionVec, v_CommonSpaceNormal.xyz);
#endif

#if defined(BACK_LIGHTING)
    v_DiffuseAccumulator += BackLighting(DirLightDirection.xyz, v_DirLightColor, v_BackLightingTexMask, v_CommonSpaceNormal.xyz);
#endif

#if defined(HAIR)    
    float3 v_VertexColor = lerp(float3(1, 1, 1), TintColor.xyz, input.VertexColor.y);
#else
    float3 v_VertexColor = input.VertexColor.xyz;
#endif

    // i've duplicated a bunch of code in these defines in order to increase readability
    // SNOW-related specular lighting
#if defined(SNOW)
    float v_SnowRimLight = 0.0;
#if defined(MULTI_TEXTURE)
    if (v_MTLandDoSnowRim != 0)
    {
        // bEnableSnowRimLighting
        if (SnowRimLightParameters.w > 0.0)
        {
            float v_SnowRimLightIntensity = SnowRimLightParameters.x;
            float v_SnowGeometrySpecPower = SnowRimLightParameters.y;
            float v_SnowNormalSpecPower = SnowRimLightParameters.z;

            float v_SnowRim_Normal = pow(1 - saturate(dot(v_CommonSpaceNormal.xyz, v_ViewDirectionVec.xyz)), v_SnowNormalSpecPower);
            float v_SnowRim_Geometry = pow(1 - saturate(dot(v_VertexNormalN.xyz, v_ViewDirectionVec.xyz)), v_SnowGeometrySpecPower);

            v_SnowRimLight = v_SnowRim_Normal * v_SnowRim_Geometry * v_SnowRimLightIntensity;
#if defined(SPECULAR)
            v_SpecularAccumulator.xyz = v_SnowRimLight.xxx;
#endif
        }
    }
#elif defined(PROJECTED_UV)
    if (v_ProjUVDoSnowRim != 0)
    {
        // bEnableSnowRimLighting
        if (SnowRimLightParameters.w > 0.0)
        {
            float v_SnowRimLightIntensity = SnowRimLightParameters.x;
            float v_SnowGeometrySpecPower = SnowRimLightParameters.y;
            float v_SnowNormalSpecPower = SnowRimLightParameters.z;

            float v_SnowRim_Normal = pow(1 - saturate(dot(v_CommonSpaceNormal.xyz, v_ViewDirectionVec.xyz)), v_SnowNormalSpecPower);
#if defined(MODELSPACENORMALS)
            float v_SnowRim_Geometry = pow(1 - saturate(v_ViewDirectionVec.z), v_SnowGeometrySpecPower);
#else
            float v_SnowRim_Geometry = pow(1 - saturate(dot(v_VertexNormalN.xyz, v_ViewDirectionVec.xyz)), v_SnowGeometrySpecPower);
#endif
            v_SnowRimLight = v_SnowRim_Normal * v_SnowRim_Geometry * v_SnowRimLightIntensity;

#if defined(SPECULAR)
            v_SpecularAccumulator.xyz = v_SnowRimLight.xxx;
#endif
        }
    }
#if defined(SPECULAR)
    else
    {
#if defined(ANISO_LIGHTING)
#if defined(HAIR)
        v_SpecularAccumulator = HairAnisotropicSpecular(DirLightDirection.xyz, v_DirLightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz, v_VertexNormal, v_VertexBitangent, v_VertexColor);
#else
        v_SpecularAccumulator = AnisotropicSpecular(DirLightDirection.xyz, v_DirLightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz, v_VertexNormal);
#endif
#else
        v_SpecularAccumulator = DirectionalLightSpecular(DirLightDirection.xyz, v_DirLightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz);
#endif
    }
#endif 

#else  // !defined(PROJECTED_UV) && !defined(MULTI_TEXTURE)
    // bEnableSnowRimLighting
    if (SnowRimLightParameters.w > 0.0)
    {
        float v_SnowRimLightIntensity = SnowRimLightParameters.x;
        float v_SnowGeometrySpecPower = SnowRimLightParameters.y;
        float v_SnowNormalSpecPower = SnowRimLightParameters.z;

        float v_SnowRim_Normal = pow(1 - saturate(dot(v_CommonSpaceNormal.xyz, v_ViewDirectionVec.xyz)), v_SnowNormalSpecPower);
#if defined(MODELSPACENORMALS)
        float v_SnowRim_Geometry = pow(1 - saturate(v_ViewDirectionVec.z), v_SnowGeometrySpecPower);
#else
        float v_SnowRim_Geometry = pow(1 - saturate(dot(v_VertexNormalN.xyz, v_ViewDirectionVec.xyz)), v_SnowGeometrySpecPower);
#endif
        v_SnowRimLight = v_SnowRim_Normal * v_SnowRim_Geometry * v_SnowRimLightIntensity;

#if defined(SPECULAR)
        v_SpecularAccumulator.xyz = v_SnowRimLight.xxx;
#endif
    }
#endif // end if defined(PROJECTED_UV) else

#endif // end if defined(SNOW)

    // non-SNOW related specular lighting
#if defined(SPECULAR) && !defined(SNOW)
#if defined(ANISO_LIGHTING)
#if defined(HAIR)
    v_SpecularAccumulator = HairAnisotropicSpecular(DirLightDirection.xyz, v_DirLightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz, v_VertexNormal, v_VertexBitangent, v_VertexColor);
#else
    v_SpecularAccumulator = AnisotropicSpecular(DirLightDirection.xyz, v_DirLightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz, v_VertexNormal);
#endif
#else
    v_SpecularAccumulator = DirectionalLightSpecular(DirLightDirection.xyz, v_DirLightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz);
#endif
#endif

    // point lights
    for (int currentLight = 0; currentLight < v_TotalLightCount; currentLight++)
    {
#if defined(DEFSHADOW) || defined(SHADOW_DIR)
        float v_ShadowedFactor;

        if (currentLight < v_ShadowLightCount)
        {
            int v_ShadowMaskOffset = (int) dot(ShadowLightMaskSelect.xyzw, M_IdentityMatrix[currentLight].xyzw);
            v_ShadowedFactor = dot(v_ShadowMask.xyzw, M_IdentityMatrix[v_ShadowMaskOffset].xyzw);
        }
        else
        {
            v_ShadowedFactor = 1;
        }

        float3 v_lightColor = PointLightColor[currentLight].xyz * v_ShadowedFactor;
#else
        float3 v_lightColor = PointLightColor[currentLight].xyz;
#endif
        
        float3 v_lightDirection = PointLightPosition[currentLight].xyz - v_CommonSpaceVertexPos.xyz;
        float v_lightRadius = PointLightPosition[currentLight].w;
        float v_lightAttenuation = 1 - pow(saturate(length(v_lightDirection) / v_lightRadius), 2);
        float3 v_lightDirectionN = normalize(v_lightDirection);
        float3 v_SingleLightDiffuseAccumulator = DirectionalLightDiffuse(v_lightDirectionN, v_lightColor, v_CommonSpaceNormal.xyz);
#if defined(SOFT_LIGHTING)
        // NOTE: This is using the un-normalized light direction. Unsure if this is a bug or intentional.
        v_SingleLightDiffuseAccumulator += SoftLighting(v_lightDirection, v_lightColor, v_SubSurfaceTexMask, v_SoftRolloff, v_CommonSpaceNormal.xyz);
#endif
#if defined(RIM_LIGHTING)
        v_SingleLightDiffuseAccumulator += RimLighting(v_lightDirectionN, v_lightColor, v_SubSurfaceTexMask, v_RimPower, v_ViewDirectionVec, v_CommonSpaceNormal.xyz);
#endif
#if defined(BACK_LIGHTING)
        v_SingleLightDiffuseAccumulator += BackLighting(v_lightDirectionN, v_lightColor, v_BackLightingTexMask, v_CommonSpaceNormal.xyz);
#endif
        v_DiffuseAccumulator += v_lightAttenuation * v_SingleLightDiffuseAccumulator;
#if defined(SPECULAR)
#if defined(ANISO_LIGHTING)
#if defined(HAIR)
        v_SpecularAccumulator += v_lightAttenuation * HairAnisotropicSpecular(v_lightDirectionN, v_lightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz, v_VertexNormal, v_VertexBitangent, v_VertexColor);
#else
        v_SpecularAccumulator += v_lightAttenuation * AnisotropicSpecular(v_lightDirectionN, v_lightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz, v_VertexNormal);
#endif
#else
        v_SpecularAccumulator += v_lightAttenuation * DirectionalLightSpecular(v_lightDirectionN, v_lightColor, v_SpecularShininess, v_ViewDirectionVec, v_CommonSpaceNormal.xyz);
#endif
#endif
    }

    // TODO: probably need to make this clearer later on, important part is that for the envmap, directional ambient, and ambient specular calculations, EYE uses the eye direction vec instead of the normal
#if defined(EYE)
    v_CommonSpaceNormal.xyz = input.EyeDirectionVec.xyz;
#endif

#if defined(ENVMAP) || defined(EYE)
    float v_EnvMapMask = TexEnvMaskSampler.Sample(EnvMaskSampler, v_TexCoords.xy).x;

    float v_EnvMapScale = EnvmapData.x;
    float v_EnvMapLODFade = MaterialData.x;
    float v_HasEnvMapMask = EnvmapData.y;
    
    // if/else implemented as lerp with 0.0/1.0 param
    float v_EnvMapIntensity = lerp(v_SpecularPower, v_EnvMapMask, v_HasEnvMapMask) * v_EnvMapScale * v_EnvMapLODFade;
    float3 v_ReflectionVec = 2 * dot(v_CommonSpaceNormal.xyz, v_ViewDirectionVec.xyz) * v_CommonSpaceNormal.xyz - v_ViewDirectionVec.xyz;

    float3 v_EnvMapColor = TexEnvSampler.Sample(EnvSampler, v_ReflectionVec.xyz).xyz * v_EnvMapIntensity;
#endif

    // toggled by cl on/off
    // brightens the output
#if defined(CHARACTER_LIGHT)
    float CharacterLightingStrengthPrimary = CharacterLightParams.x;
    float CharacterLightingStrengthSecondary = CharacterLightParams.y;
    float CharacterLightingStrengthLuminance = CharacterLightParams.z;
    float CharacterLightingStrengthMaxLuminance = CharacterLightParams.w;

    float VdotN = saturate(dot(v_ViewDirectionVec, v_CommonSpaceNormal.xyz));
    // TODO: these constants are probably something simple
    float SecondaryIntensity = saturate(dot(float2(0.164399, -0.986394), v_CommonSpaceNormal.yz));

    float CharacterLightingStrength = VdotN * CharacterLightingStrengthPrimary + SecondaryIntensity * CharacterLightingStrengthSecondary;
    float Noise = TexProjectedNoiseSampler.Sample(ProjectedNoiseSampler, float2(1, 1)).x;
    float CharacterLightingLuminance = clamp(CharacterLightingStrengthLuminance * Noise, 0, CharacterLightingStrengthMaxLuminance);
    v_DiffuseAccumulator += CharacterLightingStrength * CharacterLightingLuminance;
#endif

    v_CommonSpaceNormal.w = 1;

    // directional ambient
    // don't understand this exactly 
    float3 DirectionalAmbientNormal = float3(
        dot(DirectionalAmbient[0].xyzw, v_CommonSpaceNormal.xyzw),
        dot(DirectionalAmbient[1].xyzw, v_CommonSpaceNormal.xyzw),
        dot(DirectionalAmbient[2].xyzw, v_CommonSpaceNormal.xyzw)
        );
    v_DiffuseAccumulator += DirectionalAmbientNormal.xyz;

#if defined(MULTI_LAYER_PARALLAX)
    float3 v_DiffuseBeforeEmit = v_DiffuseAccumulator;
#endif

#if defined(GLOWMAP)
    float3 v_GlowColor = TexGlowSampler.Sample(GlowSampler, v_TexCoords.xy).xyz;
    v_DiffuseAccumulator += EmitColor.xyz * v_GlowColor.xyz;
#else
    v_DiffuseAccumulator += EmitColor.xyz;
#endif

    // IBL
    v_DiffuseAccumulator += IBLParams.yzw * IBLParams.x;

    float3 v_OutDiffuse = v_DiffuseAccumulator.xyz * v_Diffuse.xyz * v_VertexColor.xyz;

#if defined(MULTI_LAYER_PARALLAX)
    float v_MLPLayerThickness = MultiLayerParallaxData.x;
    float v_MLPRefractionScale = MultiLayerParallaxData.y;
    float2 v_MLPUVScale = MultiLayerParallaxData.zw;

    float v_MLPThickness = TexMultiLayerParallaxSampler.Sample(MultiLayerParallaxSampler, v_TexCoords.xy).w * v_MLPLayerThickness;

    float3 v_MLPAdjustedNormal = v_MLPRefractionScale * (v_OrigNormal.xyz * 2 - float3(1, 1, 2)) + float3(0, 0, 1);

    float3 v_MLPReflectionVec = -2 * dot(-v_TangentViewDirection, v_MLPAdjustedNormal) * v_MLPAdjustedNormal - v_TangentViewDirection;

    // 0.0009765625 = 1/1024
    v_MLPReflectionVec.z = v_MLPThickness / abs(v_MLPReflectionVec.z) * 0.0009765625;
    v_MLPReflectionVec.xy = v_MLPReflectionVec.xy * v_MLPReflectionVec.z;

    float2 v_MLPCoords = v_TexCoords.xy * v_MLPUVScale.xy + v_MLPReflectionVec.xy;

    float3 v_MLPColor = TexMultiLayerParallaxSampler.Sample(MultiLayerParallaxSampler, v_MLPCoords.xy).xyz * input.VertexColor.xyz;

    float v_MLPBlendFactor = saturate(v_EnvMapScale * v_EnvMapLODFade) * (1 - v_Diffuse.w);

    float3 v_MLPBlendedColor = lerp(v_OutDiffuse, v_MLPColor * v_DiffuseBeforeEmit, v_MLPBlendFactor);
#endif

#if defined(ENVMAP) || defined(EYE)
    v_OutDiffuse += v_DiffuseAccumulator.xyz * v_EnvMapColor.xyz;
#endif

#if defined(MULTI_LAYER_PARALLAX)
    v_OutDiffuse += v_MLPBlendedColor;
#endif

#if defined(SPECULAR) 
    float3 v_OutSpecular;
    float v_SpecularLODFade = MaterialData.y;
#if defined(MULTI_TEXTURE) && defined(SNOW)
    if (v_MTLandDoSnowRim != 0)
    {
        v_OutSpecular = float3(0, 0, 0);
    }
    else
    {
        v_OutSpecular = v_SpecularAccumulator.xyz * v_SpecularPower * v_SpecularLODFade;
    }
#elif defined(PROJECTED_UV) && defined(SNOW)
    if (v_ProjUVDoSnowRim != 0)
    {
        v_OutSpecular = float3(0, 0, 0);
    }
    else
    {
        v_OutSpecular = v_SpecularAccumulator.xyz * v_SpecularPower * v_SpecularLODFade;
    }
#elif !defined(SNOW)
    v_OutSpecular = v_SpecularAccumulator.xyz * v_SpecularPower * v_SpecularLODFade;
#endif
#endif

    // motion vector
    float2 v_CurrProjPosition = float2(
        dot(ViewProjMatrixUnjittered[0].xyzw, input.WorldVertexPos.xyzw),
        dot(ViewProjMatrixUnjittered[1].xyzw, input.WorldVertexPos.xyzw))
    / dot(ViewProjMatrixUnjittered[3].xyzw, input.WorldVertexPos.xyzw);
    float2 v_PrevProjPosition = float2(
        dot(PreviousViewProjMatrixUnjittered[0].xyzw, input.PreviousWorldVertexPos.xyzw),
        dot(PreviousViewProjMatrixUnjittered[1].xyzw, input.PreviousWorldVertexPos.xyzw))
        / dot(PreviousViewProjMatrixUnjittered[3].xyzw, input.PreviousWorldVertexPos.xyzw);
    float2 v_MotionVector = (v_CurrProjPosition - v_PrevProjPosition) * float2(-0.5, 0.5);

#if defined(AMBIENT_SPECULAR)
    float v_AmbientSpecularIntensity = pow(1 - saturate(dot(v_CommonSpaceNormal.xyz, v_ViewDirectionVec)), AmbientSpecularTintAndFresnelPower.w);
    float4 v_CommonSpaceNormal_AS = float4(v_CommonSpaceNormal.xyz, 0.15);
    float3 v_AmbientSpecularColor = AmbientSpecularTintAndFresnelPower.xyz *
        float3(
            saturate(dot(DirectionalAmbient[0].xyzw, v_CommonSpaceNormal_AS.xyzw)),
            saturate(dot(DirectionalAmbient[1].xyzw, v_CommonSpaceNormal_AS.xyzw)),
            saturate(dot(DirectionalAmbient[2].xyzw, v_CommonSpaceNormal_AS.xyzw))
            );

    float3 v_AmbientSpecular = v_AmbientSpecularColor * v_AmbientSpecularIntensity;
#endif

    // ColorOutputClamp.x = fLightingOutputColourClampPostLit
    v_OutDiffuse = min(v_OutDiffuse, ColourOutputClamp.x);

#if defined(SPECULAR) || defined(AMBIENT_SPECULAR)
#if defined(SPECULAR) && (!defined(SNOW) || defined(PROJECTED_UV))
    v_OutDiffuse += v_OutSpecular * SpecularColor.xyz;
#endif
#if defined(AMBIENT_SPECULAR)
    v_OutDiffuse += v_AmbientSpecular;
#endif
    // ColourOutputClamp.z = fLightingOutputColourClampPostSpec
    v_OutDiffuse = min(v_OutDiffuse, ColourOutputClamp.z);
#endif

	// fog
	// note that this code does NOT match Bethesda's but is probably what was intended, can't be sure though
	// the diassembled shaders have a mess of code where the above clamping is mixed with the fog in a way that doesn't make much sense
	
	// SE implements fog as an imagespace shader that runs after most passes of the lighting shader
    // AlphaPass and FirstPerson both act to turn the fog on/off in the lighting shader	
    float FirstPerson = GammaInvX_FirstPersonY_AlphaPassZ_CreationKitW.y; // 0.0 if rendering first person body, 1.0 otherwise
    float AlphaPass = GammaInvX_FirstPersonY_AlphaPassZ_CreationKitW.z; // 0.0 for the majority of BSLightingShader render passes, 1.0 for passes after the fog imagespace shader(?) haven't verified
	
    float v_EnableFogInLightingShader = FirstPerson * AlphaPass;
	
    float3 v_FoggedDiffuse = lerp(v_OutDiffuse, input.FogParam.xyz, input.FogParam.w) * FogColor.w;

#if defined(ADDITIONAL_ALPHA_MASK)
    uint2 v_ProjVertexPosTrunc = (uint2) input.ProjVertexPos.xy;

    // 0xC - 0b1100
    // 0x3 - 0b0011
    uint v_AAM_Index = (v_ProjVertexPosTrunc.x << 2) & 0xC | (v_ProjVertexPosTrunc.y) & 0x3;

    float v_AAM = MaterialData.z - AAM[v_AAM_Index];
    
    if (v_AAM < 0)
    {
        discard;
    }

#if defined(LODOBJECTS) || defined(LODOBJECTSHD) || defined(TREE_ANIM)
    float v_OutAlpha = v_Diffuse.w;
#else
    float v_OutAlpha = input.VertexColor.w * v_Diffuse.w;
#endif
#else
    // MaterialData.z = LightingProperty Alpha
#if defined(LODOBJECTS) || defined(LODOBJECTSHD) || defined(TREE_ANIM)
    float v_OutAlpha = MaterialData.z * v_Diffuse.w;
#else
    float v_OutAlpha = input.VertexColor.w * MaterialData.z * v_Diffuse.w;
#endif
#endif

#if defined(DEPTH_WRITE_DECALS)
    if (v_OutAlpha - 0.0156863 < 0)
    {
        discard;
    }
    v_OutAlpha = saturate(1.05 * v_OutAlpha);
#endif

#if defined(DO_ALPHA_TEST)
    if (v_OutAlpha - AlphaTestRefCB.x < 0)
    {
        discard;
    }
#endif

#if defined(MULTI_TEXTURE) && !defined(LOD_LAND_BLEND)
    output.Color.w = 0;
#else
    output.Color.w = v_OutAlpha;
#endif
    output.Color.xyz = lerp(v_OutDiffuse, v_FoggedDiffuse, v_EnableFogInLightingShader);

    if (SSRParams.z > 0.000010)
    {
        output.MotionVector.xy = float2(1, 0);
    }
    else
    {
        output.MotionVector.xy = v_MotionVector.xy;
    }

#if defined(MODELSPACENORMALS)
    float3 v_ViewSpaceNormal = normalize(float3(
        dot(input.ModelViewTransform0.xyz, v_Normal.xyz),
        dot(input.ModelViewTransform1.xyz, v_Normal.xyz),
        dot(input.ModelViewTransform2.xyz, v_Normal.xyz)));
#else
    float3 v_ViewSpaceNormal = normalize(float3(
        dot(input.TangentViewTransform0.xyz, v_Normal.xyz),
        dot(input.TangentViewTransform1.xyz, v_Normal.xyz),
        dot(input.TangentViewTransform2.xyz, v_Normal.xyz)));
#endif

    // specular map for SSR
    // SSRParams.x = fSpecMaskBegin
    // SSRParams.y = fSpecMaskSpan + fSpecMaskBegin
    // SSRParams.w = 1.0 or fSpecularLODFade if RAW_FLAG_SPECULAR
    float v_SpecMaskBegin = SSRParams.x - 0.000010;
    float v_SpecMaskSpan = SSRParams.y;
    // specularity is in the normal alpha

    output.Normal.w = SSRParams.w * smoothstep(v_SpecMaskBegin, v_SpecMaskSpan, v_SpecularPower);

    // view space normal map
    v_ViewSpaceNormal.z = v_ViewSpaceNormal.z * -8 + 8;
    v_ViewSpaceNormal.z = sqrt(v_ViewSpaceNormal.z);
    v_ViewSpaceNormal.z = max(0.001, v_ViewSpaceNormal.z);

    output.Normal.xy = float2(0.5, 0.5) + (v_ViewSpaceNormal.xy / v_ViewSpaceNormal.z);
    output.MotionVector.zw = float2(0, 1);
    output.Normal.z = 0;

#if defined(SNOW)
#if defined(SPECULAR)
    output.SnowMask.x = toGrayscale(v_SpecularAccumulator);
#else
    output.SnowMask.x = toGrayscale(v_SnowRimLight);
#endif
#if !defined(PROJECTED_UV)
    output.SnowMask.y = v_Diffuse.w;
#endif
#endif

    return output;
}