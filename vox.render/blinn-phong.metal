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
    float3 NORMAL [[attribute(Normal), function_constant(notOmitNormalAndHasNormal)]];
    float4 COLOR_0 [[attribute(Color_0), function_constant(hasVertexColor)]];
    float4 WEIGHTS_0 [[attribute(Weights_0), function_constant(hasSkin)]];
    float4 JOINTS_0 [[attribute(Joints_0), function_constant(hasSkin)]];
    float4 TANGENT [[attribute(Tangent), function_constant(notOmitNormalAndHasTangent)]];
    float2 TEXCOORD_0 [[attribute(UV_0), function_constant(hasUV)]];
    float3 POSITION_BS0 [[attribute(10), function_constant(isBlendShape)]];
    float3 POSITION_BS1 [[attribute(11), function_constant(isBlendShape)]];
    float3 POSITION_BS2 [[attribute(12), function_constant(isBlendShape)]];
    float3 POSITION_BS3 [[attribute(13), function_constant(isBlendShape)]];
    float3 NORMAL_BS0 [[attribute(16), function_constant(isBlendShapeAndHasBlendShapeNormal)]];
    float3 NORMAL_BS1 [[attribute(17), function_constant(isBlendShapeAndHasBlendShapeNormal)]];
    float3 NORMAL_BS2 [[attribute(18), function_constant(isBlendShapeAndHasBlendShapeNormal)]];
    float3 NORMAL_BS3 [[attribute(19), function_constant(isBlendShapeAndHasBlendShapeNormal)]];
    float3 TANGENT_BS0 [[attribute(20), function_constant(isBlendShapeAndhasBlendShapeTangent)]];
    float3 TANGENT_BS1 [[attribute(21), function_constant(isBlendShapeAndhasBlendShapeTangent)]];
    float3 TANGENT_BS2 [[attribute(22), function_constant(isBlendShapeAndhasBlendShapeTangent)]];
    float3 TANGENT_BS3 [[attribute(23), function_constant(isBlendShapeAndhasBlendShapeTangent)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 v_pos [[function_constant(needWorldPos)]];
    float2 v_uv;
    float4 v_color [[function_constant(hasVertexColor)]];
    float3 normalW [[function_constant(hasNormalAndHasTangentAndNormalTexture)]];
    float3 tangentW [[function_constant(hasNormalAndHasTangentAndNormalTexture)]];
    float3 bitangentW [[function_constant(hasNormalAndHasTangentAndNormalTexture)]];
    float3 v_normal [[function_constant(hasNormalNotHasTangentNotNormalTexture)]];
};

float4x4 getJointMatrix(sampler smp, texture2d<float> joint_tex,
                        float index, int u_jointCount) {
    float base = index / u_jointCount;
    float hf = 0.5 / u_jointCount;
    float v = base + hf;
    
    float4 m0 = joint_tex.sample(smp, float2(0.125, v));
    float4 m1 = joint_tex.sample(smp, float2(0.375, v));
    float4 m2 = joint_tex.sample(smp, float2(0.625, v));
    float4 m3 = joint_tex.sample(smp, float2(0.875, v));
    
    return float4x4(m0, m1, m2, m3);
}

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
                                    constant matrix_float4x4 &u_projMatFromLight [[buffer(10)]],
                                    sampler u_jointSampler [[sampler(0), function_constant(hasSkinAndHasJointTexture)]],
                                    texture2d<float> u_jointTexture [[texture(0), function_constant(hasSkinAndHasJointTexture)]],
                                    constant int &u_jointCount [[buffer(11), function_constant(hasSkinAndHasJointTexture)]],
                                    constant matrix_float4x4 *u_jointMatrix [[buffer(12), function_constant(hasSkinNotHasJointTexture)]],
                                    constant float *u_blendShapeWeights [[buffer(13), function_constant(isBlendShape)]]) {
    VertexOut out;
    
    // begin position
    float4 position = float4( vertexIn.position, 1.0);
    
    //begin normal
    float3 normal;
    float4 tangent;
    if (hasNormal) {
        normal = vertexIn.NORMAL;
        if (hasTangent && normalTexture) {
            tangent = vertexIn.TANGENT;
        }
    }
    
    //blendshape
    if (isBlendShape) {
        position.xyz += vertexIn.POSITION_BS0 * u_blendShapeWeights[0];
        position.xyz += vertexIn.POSITION_BS1 * u_blendShapeWeights[1];
        position.xyz += vertexIn.POSITION_BS2 * u_blendShapeWeights[2];
        position.xyz += vertexIn.POSITION_BS3 * u_blendShapeWeights[3];
        if (hasNormal && hasBlendShapeNormal) {
            normal.xyz += vertexIn.NORMAL_BS0 * u_blendShapeWeights[0];
            normal.xyz += vertexIn.NORMAL_BS1 * u_blendShapeWeights[1];
            normal.xyz += vertexIn.NORMAL_BS2 * u_blendShapeWeights[2];
            normal.xyz += vertexIn.NORMAL_BS3 * u_blendShapeWeights[3];
        }
        if (hasTangent && normalTexture && hasBlendShapeTangent) {
            tangent.xyz += vertexIn.TANGENT_BS0 * u_blendShapeWeights[0];
            tangent.xyz += vertexIn.TANGENT_BS1 * u_blendShapeWeights[1];
            tangent.xyz += vertexIn.TANGENT_BS2 * u_blendShapeWeights[2];
            tangent.xyz += vertexIn.TANGENT_BS3 * u_blendShapeWeights[3];
        }
    }
    
    //skinning
    if (hasSkin) {
        matrix_float4x4 skinMatrix;
        if (hasJointTexture) {
            skinMatrix =
            vertexIn.WEIGHTS_0.x * getJointMatrix(u_jointSampler, u_jointTexture, vertexIn.JOINTS_0.x, u_jointCount) +
            vertexIn.WEIGHTS_0.y * getJointMatrix(u_jointSampler, u_jointTexture, vertexIn.JOINTS_0.y, u_jointCount) +
            vertexIn.WEIGHTS_0.z * getJointMatrix(u_jointSampler, u_jointTexture, vertexIn.JOINTS_0.z, u_jointCount) +
            vertexIn.WEIGHTS_0.w * getJointMatrix(u_jointSampler, u_jointTexture, vertexIn.JOINTS_0.w, u_jointCount);
        } else {
            skinMatrix =
            vertexIn.WEIGHTS_0.x * u_jointMatrix[int(vertexIn.JOINTS_0.x)] +
            vertexIn.WEIGHTS_0.y * u_jointMatrix[int(vertexIn.JOINTS_0.y)] +
            vertexIn.WEIGHTS_0.z * u_jointMatrix[int(vertexIn.JOINTS_0.z)] +
            vertexIn.WEIGHTS_0.w * u_jointMatrix[int(vertexIn.JOINTS_0.w)];
        }
        position = skinMatrix * position;
        if (hasNormal && !omitNormal) {
            normal = float4( skinMatrix * float4( normal, 0.0 ) ).xyz;
            if (hasTangent && normalTexture) {
                tangent.xyz = float4( skinMatrix * float4( tangent.xyz, 0.0 ) ).xyz;
            }
        }
    }
    
    // uv
    if (hasUV) {
        out.v_uv = vertexIn.TEXCOORD_0;
    } else {
        out.v_uv = float2(0.0, 0.0);
    }
    if (needTilingOffset) {
        out.v_uv = out.v_uv * u_tilingOffset.xy + u_tilingOffset.zw;
    }
    
    // color
    if (hasVertexColor) {
        out.v_color = vertexIn.COLOR_0;
    }
    
    // normal
    if (hasNormal) {
        if (hasTangent && normalTexture) {
            out.normalW = normalize( float3x3(u_MVMat.columns[0].xyz,
                                              u_MVMat.columns[1].xyz,
                                              u_MVMat.columns[2].xyz) * normal.xyz);
            out.tangentW = normalize( float3x3(u_normalMat.columns[0].xyz,
                                               u_normalMat.columns[1].xyz,
                                               u_normalMat.columns[2].xyz) * tangent.xyz);
            out.bitangentW = cross( out.normalW, out.tangentW ) * tangent.w;
        } else {
            out.v_normal = normalize( float3x3(u_normalMat.columns[0].xyz,
                                               u_normalMat.columns[1].xyz,
                                               u_normalMat.columns[2].xyz) * normal);
        }
    }
    
    // world pos
    if (needWorldPos) {
        float4 temp_pos = u_modelMat * position;
        out.v_pos = temp_pos.xyz / temp_pos.w;
    }
    
    // shadow && position
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
