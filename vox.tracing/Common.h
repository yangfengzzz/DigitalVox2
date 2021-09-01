//
//  Common.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/9/1.
//

#ifndef Common_h
#define Common_h

#include <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
    matrix_float4x4 shadowMatrix;
} Uniforms;

struct RayCamera {
  vector_float3 position;
  vector_float3 right;
  vector_float3 up;
  vector_float3 forward;
};

struct RayAreaLight {
  vector_float3 position;
  vector_float3 forward;
  vector_float3 right;
  vector_float3 up;
  vector_float3 color;
};

struct RayUniforms
{
  unsigned int width;
  unsigned int height;
  unsigned int blocksWide;
  unsigned int frameIndex;
  struct RayCamera camera;
  struct RayAreaLight light;
};

#endif /* Common_h */
