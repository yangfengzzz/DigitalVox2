//
//  functionConstant.metal
//  vox.render
//
//  Created by 杨丰 on 2021/10/21.
//

#include <metal_stdlib>
using namespace metal;
#import "ShaderCommon.h"

constant bool hasUV [[function_constant(HAS_UV)]];
constant bool hasNormal [[function_constant(HAS_NORMAL)]];
constant bool hasTangent [[function_constant(HAS_TANGENT)]];
constant bool hasVertexColor [[function_constant(HAS_VERTEXCOLOR)]];

constant bool isBlendShape [[function_constant(BLENDSHAPE)]];
constant bool hasBlendShapeNormal [[function_constant(BLENDSHAPE_NORMAL)]];
constant bool hasBlendShapeTangent [[function_constant(BLENDSHAPE_TANGENT)]];
constant bool isBlendShapeAndHasBlendShapeNormal = isBlendShape && hasBlendShapeNormal;
constant bool isBlendShapeAndhasBlendShapeTangent = isBlendShape && hasBlendShapeTangent;


constant bool hasSkin [[function_constant(HAS_SKIN)]];
constant bool hasJointTexture [[function_constant(USE_JOINT_TEXTURE)]];
constant bool hasSkinAndHasJointTexture = hasSkin && hasJointTexture;
constant bool hasSkinNotHasJointTexture = hasSkin && !hasJointTexture;

constant int jointsNum [[function_constant(JOINTS_NUM)]];

constant bool alphaCutoff [[function_constant(ALPHA_CUTOFF)]];
constant bool needWorldPos [[function_constant(NEED_WORLDPOS)]];
constant bool needTilingOffset [[function_constant(NEED_TILINGOFFSET)]];
constant bool diffuseTexture [[function_constant(DIFFUSE_TEXTURE)]];
constant bool specularTexture [[function_constant(SPECULAR_TEXTURE)]];
constant bool emissiveTexture [[function_constant(EMISSIVE_TEXTURE)]];
constant bool normalTexture [[function_constant(NORMAL_TEXTURE)]];

constant bool omitNormal [[function_constant(OMIT_NORMAL)]];
constant bool notOmitNormalAndHasNormal = !omitNormal && hasNormal;
constant bool notOmitNormalAndHasTangent = !omitNormal && hasTangent;

constant bool hasNormalAndHasTangentAndNormalTexture = hasNormal && hasTangent && normalTexture;
constant bool hasNormalNotHasTangentNotNormalTexture = hasNormal && (!hasTangent || !normalTexture);


constant bool baseTexture [[function_constant(BASE_TEXTURE)]];
constant bool baseColorMap [[function_constant(BASE_COLORMAP)]];
constant bool hasEmissiveMap [[function_constant(HAS_EMISSIVEMAP)]];
constant bool hasOcclusionMap [[function_constant(HAS_OCCLUSIONMAP)]];
constant bool hasSpecularGlossinessMap [[function_constant(HAS_SPECULARGLOSSINESSMAP)]];
constant bool hasMetalRoughnessMap [[function_constant(HAS_METALROUGHNESSMAP)]];
constant bool isMetallicWorkFlow [[function_constant(IS_METALLIC_WORKFLOW)]];

constant int directLightCount [[function_constant(DIRECT_LIGHT_COUNT)]];
constant int pointLightCount [[function_constant(POINT_LIGHT_COUNT)]];
constant int spotLightCount [[function_constant(SPOT_LIGHT_COUNT)]];

constant bool useSH [[function_constant(USE_SH)]];
constant bool useSpecularEnv [[function_constant(USE_SPECULAR_ENV)]];

constant bool particleTexture [[function_constant(PARTICLE_TEXTURE)]];
constant bool rotateToVelocity [[function_constant(ROTATE_TO_VELOCITY)]];
constant bool useOriginColor [[function_constant(USE_ORIGIN_COLOR)]];
constant bool ScaleByLifetime [[function_constant(SCALE_BY_LIFE_TIME)]];
constant bool twoDimension [[function_constant(TWO_DIMENSION)]];
constant bool fadeIn [[function_constant(FADE_IN)]];
constant bool fadeOut [[function_constant(FADE_OUT)]];

constant bool generateShadowMap [[function_constant(GENERATE_SHADOW_MAP)]];
constant int shadowMapCount [[function_constant(SHADOW_MAP_COUNT)]];
