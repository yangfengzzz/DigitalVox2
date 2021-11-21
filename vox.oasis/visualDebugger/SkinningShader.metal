//
//  SkinningShader.metal
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/21.
//

#include <metal_stdlib>
using namespace metal;
#import "../function-constant.metal"

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float3 tangent [[attribute(2)]];
    float2 uv [[attribute(3)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 worldNormal;
    float3 worldTangent;
    float2 uv;
};

vertex VertexOut skin_vertex(const VertexIn vertexIn [[stage_in]],
                               constant matrix_float4x4 &u_localMat [[buffer(0)]],
                               constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                               constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                               constant matrix_float4x4 &u_projMat [[buffer(3)]],
                               constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                               constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                               constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                               constant float3 &u_cameraPos [[buffer(7)]],
                               constant float4 &u_tilingOffset [[buffer(8)]]) {
    float4 position = float4(vertexIn.position, 1.0);
    float4 normal = float4(vertexIn.normal, 0);
    float4 tangent = float4(vertexIn.tangent, 0);
    
    VertexOut out {
        .position = u_MVPMat * position,
        .worldPosition = (u_modelMat * position).xyz,
        .worldNormal = (u_normalMat * normal).xyz,
        .worldTangent = (u_normalMat * tangent).xyz,
        .uv = vertexIn.uv
    };
    return out;
}

fragment float4 skin_fragment(VertexOut in [[stage_in]],
                                sampler textureSampler [[sampler(0)]]) {
    return float4(0.4, 0.5, 0.6, 1.0);
}
