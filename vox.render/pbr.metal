//
//  pbr.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/23.
//

#include <metal_stdlib>
using namespace metal;
#include "function-constant.metal"

struct VertexOut {
    float4 position [[position]];
    float3 v_pos [[function_constant(needWorldPos)]];
    float2 v_uv;
    float4 v_color [[function_constant(hasVertexColor)]];
    float3 normalW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 tangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 bitangentW [[function_constant(hasNormalAndHasTangentAndHasNormalTexture)]];
    float3 v_normal [[function_constant(hasNormalNotHasTangentOrHasNormalTexture)]];
};

fragment float4 fragment_pbr(VertexOut in [[stage_in]],
                             sampler textureSampler [[sampler(0)]],
                             texture2d<float> u_cube [[texture(0)]]) {
    return u_cube.sample(textureSampler, in.v_uv);
}
