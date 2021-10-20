//
//  blinn-phong.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/20.
//

#include <metal_stdlib>
using namespace metal;
#include "functionConstant.metal"

struct VertexIn {
    float3 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV_0)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float2 uv;
};

vertex VertexOut vertex_blinn_phong(const VertexIn vertexIn [[stage_in]],
                                    constant matrix_float4x4 &u_projMat [[buffer(12)]],
                                    constant matrix_float4x4 &u_viewMat [[buffer(13)]],
                                    constant matrix_float4x4 &u_modelMat [[buffer(14)]]) {    
    VertexOut out {
        .position = u_projMat * u_viewMat * u_modelMat * float4(vertexIn.position, 1.0),
        .worldPosition = (u_modelMat * float4(vertexIn.position, 1.0)).xyz,
        .uv = vertexIn.uv
    };
    return out;
}

fragment float4 fragment_blinn_phong(VertexOut in [[stage_in]],
                                     constant float4 &u_baseColor [[buffer(1)]],
                                     sampler textureSampler [[sampler(0)]],
                                     texture2d<float> u_baseColorSampler [[texture(0)]]) {
    return float4(0.5, 0.5, 0.5, 1.0);
}
