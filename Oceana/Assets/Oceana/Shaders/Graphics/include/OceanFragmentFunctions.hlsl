/*
Copyright 2024 Mitrofan Juryev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

float2 GetSSUV(float4 screenPosition)
{
    return screenPosition.xy / screenPosition.w;
}

// Effects
half Fresnel(half3 normal, half3 viewDir, half power)
{
    return pow((1.0 - saturate(dot(normalize(normal), normalize(viewDir)))), power);
}

half Contrast(half value, half contrast, half midpoint)
{
    return (value - midpoint) * contrast + midpoint;
}

void ComputeWaterScene(float z, half depth, float2 uvSS, half3 normalWS, half ior, out half4 colorz) {
    float zReal = LinearEyeDepth(SampleSceneDepth(uvSS), _ZBufferParams);
    half3 cReal = SampleSceneColor(uvSS);

    float2 uvRef = uvSS + normalWS.xz * ior * saturate(zReal - z);

    float zRefr = LinearEyeDepth(SampleSceneDepth(uvRef), _ZBufferParams);
    half3 cRefr = SampleSceneColor(uvRef);

    float zval;
    float3 color;
    if(zRefr < z) {
        zval = zReal;
        color = cReal;
    }
    else {
        float zLerp = sqrt(saturate(zRefr - z));

        zval = lerp(zReal, zRefr, zLerp);
        color = lerp(cReal, cRefr, zLerp);
    }

    colorz = float4(color, sqrt(saturate((zval - z) / depth)));
}


// Lighting
half3 SurfaceColor(half3 baseColor, float4 screenPosition, float z, float2 uv, half3 normal, half refraction, half depth, half depthPower, half shallowPower)
{
    half4 colorz;
    ComputeWaterScene(z, depth, uv, normal, refraction, colorz);

    half3 shallowColor = sqrt(colorz.rgb * baseColor.rgb);
    half depthGradient = colorz.w;
    return lerp(baseColor.rgb, lerp(colorz.rgb, lerp(shallowColor, baseColor.rgb, pow(depthGradient, shallowPower)), pow(depthGradient, depthPower)), saturate(depthGradient));
}

half3 BackSurfaceColor(half3 baseColor, float2 uv, half3 normal, half3 viewDir, half fresnel, half contrast)
{
    half fresnelMask = saturate(Contrast(Fresnel(normal, viewDir, fresnel), contrast, 0.001));
    return lerp(sqrt(SampleSceneColor(uv).rgb), baseColor.rgb, fresnelMask);
}

half Diffuse(half3 normal, half3 lightDir)
{
    return saturate(dot(normal, lightDir));
}

half Enviroment(half3 normal, half3 viewDir, half fresnel, half intesity)
{
    return Fresnel(normal, viewDir, fresnel) * intesity;
}

half Specular(half3 normal, half3 viewDir, half3 lightDir, half roughness, half specCut)
{
    float3 lightDir_float3 = float3(lightDir);
    float3 halfVector = normalize(viewDir + lightDir);

    float NoH = saturate(dot(float3(normal), halfVector));
    half LoH = saturate(dot(lightDir_float3, halfVector));

    half roughness2 = roughness * roughness;

    float d = NoH * NoH * (roughness2 - 1.0) + 1.00001f;
    half LoH2 = LoH * LoH;

    half normTerm = max(roughness * half(4.0) + half(2.0), HALF_MIN);
    half specTerm = roughness2 / ((d * d) * max(0.1h, LoH2) * normTerm);

    return clamp(specTerm, 0.0, specCut) / specCut;
}

half SSS(half thickness, half3 normal, half3 viewDir, half3 lightDir, half sssPower, half sssIntesnity, half sssNormal, half sssFresnel)
{
    //half sunDot = 1 - Diffuse(normal, lightDir);

    half baseSSS = pow(abs(thickness), sssPower) * sssIntesnity;// * sunDot;
    half normalSSS = (1 - normal.y) * sssNormal;
    half viewSSS = (1 + dot(-viewDir, lightDir)) * 0.5;

    half sssMasked = saturate(baseSSS + normalSSS * viewSSS) * Fresnel(normal, viewDir, sssFresnel);
    return sssMasked;
}