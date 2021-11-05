//
//  BoneShader.metal
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/5.
//

#include <metal_stdlib>
using namespace metal;
#import "../function-constant.metal"

float4x4 getBoneWorldMatrix(float4x4 joint) {
    // Rebuilds bone properties.
    // Bone length is set to zero to disable leaf rendering.
    float is_bone = joint[3].w;
    float3 bone_dir = float3(joint[0].w, joint[1].w, joint[2].w) * is_bone;
    float bone_len = length(bone_dir);
    
    // Setup rendering world matrix.\n"
    float dot1 = dot(joint[2].xyz, bone_dir);
    float dot2 = dot(joint[0].xyz, bone_dir);
    float3 binormal = abs(dot1) < abs(dot2) ? joint[2].xyz : joint[0].xyz;
    
    float4x4 world_matrix;
    world_matrix[0] = float4(bone_dir, 0.);
    world_matrix[1] = float4(bone_len * normalize(cross(binormal, bone_dir)), 0.);
    world_matrix[2] = float4(bone_len * normalize(cross(bone_dir, world_matrix[1].xyz)), 0.);
    world_matrix[3] = float4(joint[3].xyz, 1.);
    return world_matrix;
}

float4x4 getJointWorldMatrix(float4x4 joint) {
    // Rebuilds joint matrix.
    float4x4 joint_matrix;
    joint_matrix[0] = float4(normalize(joint[0].xyz), 0.);
    joint_matrix[1] = float4(normalize(joint[1].xyz), 0.);
    joint_matrix[2] = float4(normalize(joint[2].xyz), 0.);
    joint_matrix[3] = float4(joint[3].xyz, 1.);
    
    // Rebuilds bone properties.
    float3 bone_dir = float3(joint[0].w, joint[1].w, joint[2].w);
    float bone_len = length(bone_dir);
    
    // Setup rendering world matrix.
    float4x4 world_matrix;
    world_matrix[0] = joint_matrix[0] * bone_len;
    world_matrix[1] = joint_matrix[1] * bone_len;
    world_matrix[2] = joint_matrix[2] * bone_len;
    world_matrix[3] = joint_matrix[3];
    return world_matrix;
}

struct VertexIn {
    float3 a_position [[attribute(Position)]];
    float3 a_normal [[attribute(Normal)]];
    float4 v_color [[attribute(Color_0)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 v_world_normal;
    float4 v_vertex_color;
};

vertex VertexOut bone_vertex(const VertexIn in [[stage_in]],
                             constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                             constant matrix_float4x4 &u_joint [[buffer(6)]]) {
    VertexOut out;
    
    float4x4 world_matrix = getBoneWorldMatrix(u_joint);
    float4 pos = float4(in.a_position.xyz, 1.);
    out.position = u_MVPMat * world_matrix * pos;
    float3x3 cross_matrix = float3x3(cross(world_matrix[1].xyz, world_matrix[2].xyz),
                                     cross(world_matrix[2].xyz, world_matrix[0].xyz),
                                     cross(world_matrix[0].xyz, world_matrix[1].xyz));
    float invdet = 1.0 / dot(cross_matrix[2], world_matrix[2].xyz);
    float3x3 normal_matrix = cross_matrix * invdet;
    out.v_world_normal = normal_matrix * in.a_normal;
    out.v_vertex_color = in.v_color;
    return out;
}

vertex VertexOut joint_vertex(const VertexIn in [[stage_in]],
                              constant matrix_float4x4 &u_MVPMat [[buffer(5)]],
                              constant matrix_float4x4 &u_joint [[buffer(6)]]) {
    VertexOut out;
    
    float4x4 world_matrix = getJointWorldMatrix(u_joint);
    float4 pos = float4(in.a_position.xyz, 1.);
    out.position = u_MVPMat * world_matrix * pos;
    float3x3 cross_matrix = float3x3(cross(world_matrix[1].xyz, world_matrix[2].xyz),
                                     cross(world_matrix[2].xyz, world_matrix[0].xyz),
                                     cross(world_matrix[0].xyz, world_matrix[1].xyz));
    float invdet = 1.0 / dot(cross_matrix[2], world_matrix[2].xyz);
    float3x3 normal_matrix = cross_matrix * invdet;
    out.v_world_normal = normal_matrix * in.a_normal;
    out.v_vertex_color = in.v_color;
    return out;
}

float4 GetAmbient(float3 _world_normal) {
    float3 normal = normalize(_world_normal);
    float3 alpha = (normal + 1.) * .5;
    float2 bt = mix(float2(.3, .7), float2(.4, .8), alpha.xz);
    float3 ambient = mix(float3(bt.x, .3, bt.x), float3(bt.y, .8, bt.y), alpha.y);
    return float4(ambient, 1.);
}

fragment float4 bone_fragment(VertexOut in [[stage_in]]) {
    float4 ambient = GetAmbient(in.v_world_normal);
    return ambient * in.v_vertex_color;
}
