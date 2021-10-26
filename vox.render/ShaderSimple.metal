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
                                constant float4 &u_baseColor [[buffer(1)]],
                                texture2d<float> u_baseColorTexture [[texture(1), function_constant(hasBaseColorMap)]],
                                texture2d<float> u_normalTexture [[texture(2), function_constant(hasNormalTexture)]],
                                texture2d<float> u_emissiveTexture [[texture(3), function_constant(hasEmissiveMap)]],
                                texture2d<float> u_metallicRoughnessTexture [[texture(4), function_constant(hasMetalRoughnessMap)]],
                                texture2d<float> u_specularGlossinessTexture [[texture(5), function_constant(hasSpecularGlossinessMap)]],
                                texture2d<float> u_occlusionTexture [[texture(6), function_constant(hasOcclusionMap)]]) {
    // extract color
    float3 baseColor;
    if (hasBaseColorMap) {
        baseColor = u_baseColorTexture.sample(textureSampler, in.uv).rgb;
    } else {
        baseColor = u_baseColor.xyz;
    }
    return float4(baseColor, 1.0);
}
