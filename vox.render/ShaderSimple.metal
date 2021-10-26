//
//  ShaderSimple.metal
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

#include <metal_stdlib>
using namespace metal;
#import "function-constant.metal"

struct VertexIn {
    float3 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV_0)]];
    float3 tangent [[attribute(Tangent)]];
    float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float3 worldTangent;
    float3 worldBitangent;
    float2 uv;
};

vertex VertexOut vertex_simple(const VertexIn vertexIn [[stage_in]],
                               constant matrix_float4x4 &u_localMat [[buffer(0)]],
                               constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                               constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                               constant matrix_float4x4 &u_projMat [[buffer(3)]],
                               constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                               constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                               constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                               constant float3 &u_cameraPos [[buffer(7)]],
                               constant float4 &u_tilingOffset [[buffer(8)]]) {
    VertexOut out {
        .position = u_MVPMat * float4(vertexIn.position, 1.0),
        .worldPosition = (u_modelMat * float4(vertexIn.position, 1.0)).xyz,
        .worldNormal = (u_normalMat * float4(vertexIn.normal, 0.0)).xyz,
        .worldTangent = (u_normalMat * float4(vertexIn.tangent, 0.0)).xyz,
        .worldBitangent = (u_normalMat * float4(vertexIn.bitangent, 0.0)).xyz,
        .uv = vertexIn.uv
    };
    return out;
}

fragment float4 fragment_simple(VertexOut in [[stage_in]],
                                sampler textureSampler [[sampler(0)]],
                                // common_frag
                                constant matrix_float4x4 &u_localMat [[buffer(0)]],
                                constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                                constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                                constant matrix_float4x4 &u_projMat [[buffer(3)]],
                                constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                                constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                                constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                                constant float3 &u_cameraPos [[buffer(7)]],
                                // direct_light_frag
                                constant float3 *u_directLightColor [[buffer(10), function_constant(hasDirectLight)]],
                                constant float3 *u_directLightDirection [[buffer(11), function_constant(hasDirectLight)]],
                                // point_light_frag
                                constant float3 *u_pointLightColor [[buffer(12), function_constant(hasPointLight)]],
                                constant float3 *u_pointLightPosition [[buffer(13), function_constant(hasPointLight)]],
                                constant float *u_pointLightDistance [[buffer(14), function_constant(hasPointLight)]],
                                // spot_light_frag
                                constant float3 *u_spotLightColor [[buffer(15), function_constant(hasSpotLight)]],
                                constant float3 *u_spotLightPosition [[buffer(16), function_constant(hasSpotLight)]],
                                constant float3 *u_spotLightDirection [[buffer(17), function_constant(hasSpotLight)]],
                                constant float *u_spotLightDistance [[buffer(18), function_constant(hasSpotLight)]],
                                constant float *u_spotLightAngleCos [[buffer(19), function_constant(hasSpotLight)]],
                                constant float *u_spotLightPenumbraCos [[buffer(20), function_constant(hasSpotLight)]],
                                //pbr base frag define
                                constant float &u_alphaCutoff [[buffer(21)]],
                                constant float4 &u_baseColor [[buffer(22)]],
                                constant float &u_metal [[buffer(23)]],
                                constant float &u_roughness [[buffer(24)]],
                                constant float3 &u_specularColor [[buffer(25)]],
                                constant float &u_glossinessFactor [[buffer(26)]],
                                constant float3 &u_emissiveColor [[buffer(27)]],
                                constant float &u_normalIntensity [[buffer(28)]],
                                constant float &u_occlusionStrength [[buffer(29)]],
                                // pbr_texture_frag_define
                                texture2d<float> u_baseColorTexture [[texture(1), function_constant(hasBaseColorMap)]],
                                texture2d<float> u_normalTexture [[texture(2), function_constant(hasNormalTexture)]],
                                texture2d<float> u_emissiveTexture [[texture(3), function_constant(hasEmissiveMap)]],
                                texture2d<float> u_metallicTexture [[texture(4), function_constant(hasMetalMap)]],
                                texture2d<float> u_roughnessTexture [[texture(5), function_constant(hasRoughnessMap)]],
                                texture2d<float> u_specularTexture [[texture(6), function_constant(hasSpecularMap)]],
                                texture2d<float> u_glossinessTexture [[texture(7), function_constant(hasGlossinessMap)]],
                                texture2d<float> u_occlusionTexture [[texture(8), function_constant(hasOcclusionMap)]]) {
    // extract color
    float3 baseColor;
    if (hasBaseColorMap) {
        baseColor = u_baseColorTexture.sample(textureSampler, in.uv).rgb;
    } else {
        baseColor = u_baseColor.rgb;
    }
    // extract metallic
    float metallic;
    if (hasMetalMap) {
        metallic = u_metallicTexture.sample(textureSampler, in.uv).r;
    } else {
        metallic = u_metal;
    }
    // extract roughness
    float roughness;
    if (hasRoughnessMap) {
        roughness = u_roughnessTexture.sample(textureSampler, in.uv).r;
    } else {
        roughness = u_roughness;
    }
    // extract ambient occlusion
    float ambientOcclusion;
    if (hasOcclusionMap) {
        ambientOcclusion = u_occlusionTexture.sample(textureSampler, in.uv).r;
    } else {
        ambientOcclusion = 1.0;
    }
    
    return float4(baseColor, 1.0);
}
