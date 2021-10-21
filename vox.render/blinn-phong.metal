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
    float4 color_0 [[attribute(Color_0)]];
    float3 weight [[attribute(Weights_0)]];
    float3 joint [[attribute(Joints_0)]];
    float4 tangent [[attribute(Tangent)]];
    float2 uv_0 [[attribute(UV_0)]];
    float2 uv_1 [[attribute(UV_1)]];
    float2 uv_2 [[attribute(UV_2)]];
    float2 uv_3 [[attribute(UV_3)]];
    float2 uv_4 [[attribute(UV_4)]];
    float2 uv_5 [[attribute(UV_5)]];
    float2 uv_6 [[attribute(UV_6)]];
    float2 uv_7 [[attribute(UV_7)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float2 uv;
};

vertex VertexOut vertex_blinn_phong(const VertexIn vertexIn [[stage_in]],
                                    constant matrix_float4x4 &u_localMat [[buffer(0)]],
                                    constant matrix_float4x4 &u_modelMat [[buffer(1)]],
                                    constant matrix_float4x4 &u_viewMat [[buffer(2)]],
                                    constant matrix_float4x4 &u_projMat [[buffer(3)]],
                                    constant matrix_float4x4 &u_MVMat [[buffer(4)]],
                                    constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                                    constant matrix_float4x4 &u_normalMat [[buffer(6)]],
                                    constant float3 &u_cameraPos [[buffer(7)]],
                                    constant float4 &u_tilingOffset [[buffer(8)]],
                                    constant matrix_float4x4 &u_viewMatFromLight [[buffer(9)]],
                                    constant matrix_float4x4 &u_projMatFromLight [[buffer(10)]]) {
    // begin position
    float4 position = float4( vertexIn.position, 1.0);
    
    //begin normal
    float3 normal;
    float4 tangent;
    if (hasNormal) {
        normal = vertexIn.normal;
        if (hasTangent && normalTexture) {
            tangent = vertexIn.tangent;
        }
    }
    
    // uv
    float2 v_uv;
    if (hasUV) {
        v_uv = vertexIn.uv_0;
    } else {
        v_uv = float2(0.0, 0.0);
    }
    if (needTilingOffset) {
        v_uv = v_uv * u_tilingOffset.xy + u_tilingOffset.zw;
    }
    
    // color
    float4 v_color = vertexIn.color_0;
    
    // normal
    float3 v_normal;
    float3x3 v_TBN;
    if (hasNormal) {
        if (hasTangent && normalTexture) {
            float3 normalW = normalize( float3x3(u_MVMat.columns[0].xyz,
                                                 u_MVMat.columns[1].xyz,
                                                 u_MVMat.columns[2].xyz) * normal.xyz);
            float3 tangentW = normalize( float3x3(u_normalMat.columns[0].xyz,
                                                  u_normalMat.columns[1].xyz,
                                                  u_normalMat.columns[2].xyz) * tangent.xyz);
            float3 bitangentW = cross( normalW, tangentW ) * tangent.w;
            v_TBN = float3x3( tangentW, bitangentW, normalW );
        } else {
            v_normal = normalize( float3x3(u_normalMat.columns[0].xyz,
                                           u_normalMat.columns[1].xyz,
                                           u_normalMat.columns[2].xyz) * normal);
        }
    }
    
    // world pos
    float3 v_pos;
    if (needWorldPos) {
        float4 temp_pos = u_modelMat * position;
        v_pos = temp_pos.xyz / temp_pos.w;
    }
    
    VertexOut out;
    
    if (generateShadowMap) {
        out.position = u_projMatFromLight * u_viewMatFromLight * u_modelMat * position;
    } else {
        out.position = u_MVPMat * position;
    }

    return out;
}

fragment float4 fragment_blinn_phong(VertexOut in [[stage_in]],
                                     constant float4 &u_baseColor [[buffer(1)]],
                                     sampler textureSampler [[sampler(0)]],
                                     texture2d<float> u_baseColorSampler [[texture(0)]]) {
    return float4(0.5, 0.5, 0.5, 1.0);
}
