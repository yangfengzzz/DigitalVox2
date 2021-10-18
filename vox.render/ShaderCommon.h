//
//  ShaderCommon.h
//  DigitalVox2
//
//  Created by 杨丰 on 2021/10/18.
//

#ifndef ShaderCommon_h
#define ShaderCommon_h

#import <simd/simd.h>
#include "MacroName.h"

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef enum {
    unused = 0,
    Sunlight = 1,
    Spotlight = 2,
    Pointlight = 3,
    Ambientlight = 4
} LightType;

typedef struct {
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    vector_float3 attenuation;
    LightType type;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
    uint tiling;
} FragmentUniforms;

typedef enum {
    Position = 0,
    Normal = 1,
    Color_0 = 2,
    Weights_0 = 3,
    Joints_0 = 4,
    Tangent = 5,
    UV_0 = 6,
    UV_1 = 7,
    UV_2 = 8,
    UV_3 = 9,
    UV_4 = 10,
    UV_5 = 11,
    UV_6 = 12,
    UV_7 = 13
} Attributes;

typedef enum {
    BaseColorTexture = 0,
    NormalTexture = 1
} Textures;

typedef enum {
    BufferIndexVertices = 0,
    BufferIndexUniforms = 15,
    BufferIndexLights = 16,
    BufferIndexFragmentUniforms = 17,
    BufferIndexMaterials = 18
} BufferIndices;

typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float roughness;
    float metallic;
    vector_float3 ambientOcclusion;
    float shininess;
} MaterialConstant;

#endif /* ShaderCommon_h */
