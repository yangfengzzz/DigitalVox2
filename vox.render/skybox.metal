//
//  skybox.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.metal"

struct VertexIn {
    float3 position [[attribute(Position)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 v_cubeUV;
};

vertex VertexOut vertex_skybox(const VertexIn in [[stage_in]],
                               constant matrix_float4x4 &u_mvpNoscale [[buffer(0)]]) {
    VertexOut out;
    
    out.v_cubeUV = in.position.xyz;
    out.position = u_mvpNoscale * float4( in.position, 1.0 );
    out.position.z = out.position.w;
    return out;
}

fragment float4 fragment_skybox(VertexOut in [[stage_in]],
                                sampler textureSampler [[sampler(0)]],
                                texturecube<float> u_cube [[texture(0)]]) {
    return u_cube.sample(textureSampler, in.v_cubeUV);
}
