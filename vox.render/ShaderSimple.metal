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
  float2 uv;
};

vertex VertexOut vertex_simple(const VertexIn vertexIn [[stage_in]],
                               constant matrix_float4x4 &projectionMatrix [[buffer(12)]],
                               constant matrix_float4x4 &viewMatrix [[buffer(13)]],
                               constant matrix_float4x4 &modelMatrix [[buffer(14)]])
{
  VertexOut out {
    .position = projectionMatrix * viewMatrix * modelMatrix * float4(vertexIn.position, 1.0),
    .worldPosition = (modelMatrix * float4(vertexIn.position, 1.0)).xyz,
    .uv = vertexIn.uv
  };
  return out;
}

fragment float4 fragment_simple(VertexOut in [[stage_in]],
                                constant matrix_float4x4 &fragColor [[buffer(1)]]) {
    return float4(in.worldPosition, 1.0);
}
