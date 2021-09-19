//
//  ShaderSimple.metal
//  vox.render
//
//  Created by 杨丰 on 2021/9/2.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn {
  float3 position [[attribute(Position)]];
  float3 normal [[attribute(Normal)]];
  float2 uv [[attribute(UV_0)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 worldPosition;
  float3 worldNormal;
  float2 uv;
};


vertex VertexOut vertex_simple(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]])
{
  VertexOut out {
    .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(vertexIn.position, 1.0),
    .worldPosition = (uniforms.modelMatrix * float4(vertexIn.position, 1.0)).xyz,
    .worldNormal = uniforms.normalMatrix * vertexIn.normal,
    .uv = vertexIn.uv
  };
  return out;
}

fragment float4 fragment_simple(VertexOut in [[stage_in]]) {
    return float4(in.worldPosition, 1.0);
}
